"""Convierte los 11 temas de la maqueta (docs/fase6/temas/index.html) a datos para Godot.

Entrada: datos_temas_maqueta.json, con {"temas": [...], "base": {...}} sacado de las constantes TEMAS
y BASE de la maqueta (se evaluaron en un navegador porque son JavaScript). Salida: godot/datos/temas.json.

Uso:
    python prototipos/generador/temas.py [datos_temas_maqueta.json]

Qué hace con cada tema:
- Colores CSS (#abc, #aabbcc, rgba(), transparent) -> "#rrggbbaa" que entiende Color() de Godot.
- Degradados (linear-gradient) -> el color del medio en "ui" (para lo que necesita un solo color) y las
  paradas completas en "estilo" › pantalla, que el juego pinta tal cual (escenas/comun/fondo.gd).
- "estilo": todo lo que la maqueta dibuja con CSS, en px de la maqueta: cada caja (botones, nodos,
  ventana, tarjeta, pastilla, tablero) con fondo, borde, radio y sus sombras (box-shadow completo:
  duras, suaves, anillos y la de dentro), mayúsculas y espaciado de títulos y botones, el fondo de la
  pantalla con su textura, el brillo al pasar el ratón, cuánto baja un botón al pulsarlo y cómo se ve
  apagado. El juego lo multiplica todo por Temas.ESCALA.
- Labio de los botones: el color del «inset» de la sombra de la maqueta; si no hay, se oscurece.
- Campana normal y dorada: la dorada usa el color de la estrella del tema y la normal, el de la
  campana o el badajo (el que no coincida con la dorada). Dos temas se ajustan a mano.
- Letras: las de la maqueta (todas SIL OFL, en godot/fuentes con su licencia), con cuatro usos:
  títulos, botones, texto y negrita, cada uno con su archivo y su peso (eje «wght» de las
  fuentes variables; las fijas lo ignoran). Las japonesas van recortadas a caracteres latinos.
"""
import json
import pathlib
import re
import sys

RAIZ = pathlib.Path(__file__).resolve().parents[2]
SALIDA = RAIZ / "godot" / "datos" / "temas.json"

# Ajustes a mano: [campana normal, dorada]
CAMPANAS = {"bauhaus": ["#1b4fbf", "#f7c600"], "brutal": ["#000000", "#c6ff00"],
            "nordico": ["#2f5d50", "#d8b98e"]}
TEXTOS = ["ya", "superado", "sinTitulo", "jugar", "repetir", "siguiente", "casi", "apTitulo", "barrio"]

# Valores por defecto de la maqueta (:root): los temas que no ponen una variable usan estos
POR_DEFECTO_CSS = {"--rpanel": "12px", "--rventana": "16px", "--rb": "10px", "--rredondo": "10px", "--rnodo": "999px",
    "--rchip": "999px", "--wb": 700, "--lsb": ".02em", "--ttb": "none", "--wd": 700, "--ttd": "none", "--lsd": "0",
    "--prim-sombra": "none", "--sec-sombra": "none", "--sombra-ventana": "0 20px 40px -18px rgba(0,0,0,.45)",
    "--sombra-tablero": "none", "--borde-panel": "1px solid var(--linea)", "--borde-chip": "1px solid transparent",
    "--borde-tablero": "1px solid var(--linea)", "--borde-ventana": "0", "--nodo-borde": "0", "--nodo-sombra": "none",
    "--nodo-h-sombra": "none", "--sec-borde": "1px solid var(--linea)", "--prim-borde": "0",
    "--panel-t": "var(--texto)", "--chip-t": "var(--texto)"}

# Fondos con textura de la maqueta (.tema-X .pant): degradado vertical y dibujo encima
FONDOS = {
    "grafico": {"textura": "rejilla", "color": "#e2e2dd", "paso": 24},
    "riso": {"textura": "trama", "color": "rgba(30,59,138,.07)", "paso": 5, "radio": 1},
    "nocturno": {"textura": "estrellas", "degradado": "linear-gradient(180deg,#121a3d,#0a0f24)",
                 "capas": [{"tile": [83, 97], "desde": [0, 0], "radio": 0.7, "color": "#ffffff"},
                           {"tile": [47, 61], "desde": [20, 30], "radio": 0.5, "color": "rgba(255,255,255,.6)"}]},
    "negro": {"textura": "grano", "degradado": "linear-gradient(180deg,#151515,#0b0b0b)",
              "color": "rgba(255,255,255,.035)", "paso": 3, "radio": 1},
}


def _l(archivo, peso, **ejes):
    return {"archivo": archivo, "peso": peso, "ejes": ejes}


def _familia(archivo, titulos, botones, texto, negrita, **ejes_titulos):
    """Una sola fuente variable para todo, con pesos distintos."""
    return {"titulos": _l(archivo, titulos, **ejes_titulos), "botones": _l(archivo, botones),
            "texto": _l(archivo, texto), "negrita": _l(archivo, negrita)}


# Letras de cada tema (maqueta: --fd títulos, --fu resto, --wd y --wb pesos). El texto corrido va
# a 500 como mínimo para que se lea bien en el móvil.
LETRAS = {
    "pop": {"titulos": _l("LilitaOne-Regular.ttf", 400), "botones": _l("LilitaOne-Regular.ttf", 400),
            "texto": _l("Nunito-wght.ttf", 700), "negrita": _l("Nunito-wght.ttf", 900)},
    "mesa": _familia("Manrope-wght.ttf", 800, 800, 600, 800),
    "calma": _familia("Jost-wght.ttf", 400, 500, 500, 700),
    # Gráfico: títulos al 78 % de ancho y botones al 88 % (font-stretch de la maqueta)
    "grafico": {"titulos": _l("Archivo-wdth-wght.ttf", 900, wdth=78), "botones": _l("Archivo-wdth-wght.ttf", 800, wdth=88),
                "texto": _l("Archivo-wdth-wght.ttf", 500), "negrita": _l("Archivo-wdth-wght.ttf", 800)},
    "negro": {"titulos": _l("BebasNeue-Regular.ttf", 400), "botones": _l("Barlow-Bold.ttf", 700),
              "texto": _l("Barlow-Regular.ttf", 400), "negrita": _l("Barlow-Bold.ttf", 700)},
    "tinta": {"titulos": _l("ShipporiMincho-Bold-latin.ttf", 700), "botones": _l("ZenKakuGothicNew-Bold-latin.ttf", 700),
              "texto": _l("ZenKakuGothicNew-Medium-latin.ttf", 500), "negrita": _l("ZenKakuGothicNew-Bold-latin.ttf", 700)},
    "bauhaus": _familia("LeagueSpartan-wght.ttf", 800, 800, 500, 800),
    "brutal": _familia("FamiljenGrotesk-wght.ttf", 700, 700, 500, 700),
    "riso": _familia("BricolageGrotesque-opsz-wdth-wght.ttf", 800, 800, 500, 800),
    "nocturno": {"titulos": _l("RedHatDisplay-wght.ttf", 900), "botones": _l("RedHatText-wght.ttf", 700),
                 "texto": _l("RedHatText-wght.ttf", 500), "negrita": _l("RedHatText-wght.ttf", 700)},
    "nordico": _familia("Figtree-wght.ttf", 800, 700, 500, 800),
}


def color(css):
    """Color CSS -> '#rrggbbaa' (o None)."""
    if css is None:
        return None
    css = str(css).strip()
    if css == "transparent":
        return "#00000000"
    if css.startswith("linear-gradient"):
        paradas = re.findall(r"#[0-9a-fA-F]{3,8}|rgba?\([^)]*\)", css)
        return color(paradas[len(paradas) // 2])
    m = re.fullmatch(r"rgba?\(([^)]*)\)", css)
    if m:
        partes = [p.strip() for p in m.group(1).split(",")]
        r, g, b = (int(float(x)) for x in partes[:3])
        a = float(partes[3]) if len(partes) > 3 else 1.0
        return "#%02x%02x%02x%02x" % (r, g, b, int(a * 255 + 0.5))
    m = re.fullmatch(r"#([0-9a-fA-F]+)", css)
    if m:
        h = m.group(1).lower()
        if len(h) in (3, 4):
            h = "".join(c * 2 for c in h)
        if len(h) == 6:
            h += "ff"
        return "#" + h
    raise ValueError("color desconocido: " + css)


def oscurecer(hexa, f):
    r, g, b, a = (int(hexa[i:i + 2], 16) for i in (1, 3, 5, 7))
    return "#%02x%02x%02x%02x" % (int(r * (1 - f)), int(g * (1 - f)), int(b * (1 - f)), a)


def rgba(hexa):
    return [int(hexa[i:i + 2], 16) / 255 for i in (1, 3, 5, 7)]


def sobre(arriba, abajo):
    """Color opaco que se ve al poner `arriba` (quizá translúcido) encima de `abajo`."""
    a, b = rgba(arriba), rgba(abajo)
    return "#%02x%02x%02xff" % tuple(int((a[i] * a[3] + b[i] * (1 - a[3])) * 255 + 0.5) for i in range(3))


def luminancia(hexa):
    def canal(c):
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b, _ = rgba(hexa)
    return 0.2126 * canal(r) + 0.7152 * canal(g) + 0.0722 * canal(b)


def contraste(x, y):
    a, b = sorted([luminancia(x), luminancia(y)], reverse=True)
    return (a + 0.05) / (b + 0.05)


def labio(sombra, fondo, f):
    m = re.search(r"inset 0 -\d+px 0 (#[0-9a-fA-F]{3,8})", sombra or "")
    return color(m.group(1)) if m else oscurecer(fondo, f)


def px(valor, defecto):
    m = re.match(r"(\d+)", str(valor or ""))
    return int(m.group(1)) if m else defecto


def borde(css):
    """'2px solid #142554' -> [2, '#142554ff'] o [0, None]."""
    if not css:
        return [0, None]
    m = re.match(r"([\d.]+)px solid (.+)", css)
    return [max(1, round(float(m.group(1)))), color(m.group(2))] if m else [0, None]


def _css(v, clave):
    """Variable CSS del tema con los valores por defecto y las var(--x) resueltas."""
    valor = str(v.get(clave, POR_DEFECTO_CSS.get(clave, "")))
    for _ in range(4):
        m = re.search(r"var\((--[a-z-]+)\)", valor)
        if not m:
            break
        valor = valor.replace(m.group(0), str(v.get(m.group(1), POR_DEFECTO_CSS.get(m.group(1), ""))))
    return valor


def _partir(css):
    """Divide una lista CSS por las comas de primer nivel (no las de dentro de rgba())."""
    partes, nivel, actual = [], 0, ""
    for ch in css:
        if ch == "(":
            nivel += 1
        elif ch == ")":
            nivel -= 1
        if ch == "," and nivel == 0:
            partes.append(actual.strip())
            actual = ""
        else:
            actual += ch
    if actual.strip():
        partes.append(actual.strip())
    return partes


COLOR_CSS = r"(#[0-9a-fA-F]{3,8}|rgba?\([^)]*\))"


def sombras(css):
    """box-shadow -> [{x, y, desenfoque, extension, color, dentro}] en px de la maqueta."""
    if not css or css.strip() in ("none", "0"):
        return []
    r = []
    for s in _partir(css):
        dentro = s.startswith("inset")
        s = s.replace("inset", "").strip()
        m = re.search(COLOR_CSS, s)
        col = color(m.group(1)) if m else "#000000ff"
        medidas = [float(x.replace("px", "")) for x in re.sub(COLOR_CSS, "", s).split()]
        medidas += [0.0] * (4 - len(medidas))
        r.append({"x": medidas[0], "y": medidas[1], "desenfoque": medidas[2], "extension": medidas[3],
                  "color": col, "dentro": dentro})
    return r


def radio(css):
    """'16px' -> 16; '50%' -> -1 (círculo); '999px' -> 999 (pastilla)."""
    css = str(css).strip()
    if css.endswith("%"):
        return -1
    return px(css, 0)


def borde_css(css):
    """'1.5px solid #1e3b8a' -> [1.5, '#1e3b8aff']; '0' -> [0, None]."""
    m = re.match(r"([\d.]+)px solid (.+)", str(css or "").strip())
    return [float(m.group(1)), color(m.group(2))] if m else [0, None]


def caja(fondo, borde, rad, sombra, texto=None):
    c = {"fondo": color(fondo) if fondo else None, "borde": borde_css(borde), "radio": radio(rad),
         "sombras": sombras(sombra)}
    if texto:
        c["texto"] = color(texto)
    return c


def em(css):
    m = re.match(r"(-?[\d.]+)em", str(css).strip())
    return float(m.group(1)) if m else 0.0


def degradado(css):
    """linear-gradient(180deg, a 0%, b 55%, ...) -> [[0.0, a], [0.55, b], ...]; un color -> [[0, c]]."""
    css = str(css)
    if not css.startswith("linear-gradient"):
        return [[0.0, color(css)]]
    paradas = _partir(css[css.index("(") + 1:css.rindex(")")])[1:]
    r = []
    for k, p in enumerate(paradas):
        m = re.match(r"(.+?)\s+([\d.]+)%$", p)
        pos = float(m.group(2)) / 100 if m else k / max(len(paradas) - 1, 1)
        r.append([pos, color(m.group(1) if m else p)])
    return r


def estilo(t):
    """Todo lo que la maqueta dibuja con CSS y que el juego tiene que copiar tal cual (en px de la maqueta;
    el juego los multiplica por su escala, nucleo/temas.gd › ESCALA)."""
    v = t["v"]
    g = lambda k: _css(v, k)
    pop = t["id"] == "pop"
    boton_s = caja(g("--sec"), g("--sec-borde"), g("--rb"), g("--sec-sombra"), g("--sec-t"))
    fondo = FONDOS.get(t["id"], {})
    pantalla = {"degradado": degradado(fondo.get("degradado", g("--pantalla")))}
    if fondo:
        textura = {k: (color(x) if k == "color" else x) for k, x in fondo.items() if k != "degradado"}
        for capa in textura.get("capas", []):
            capa["color"] = color(capa["color"])
        pantalla["textura"] = textura
    return {
        "titulos": {"mayus": g("--ttd") == "uppercase", "espaciado": em(g("--lsd"))},
        "botones": {"mayus": g("--ttb") == "uppercase", "espaciado": em(g("--lsb"))},
        "boton_p": caja(g("--prim"), g("--prim-borde"), g("--rb"), g("--prim-sombra"), g("--prim-t")),
        "boton_s": boton_s,
        # Dentro de las ventanas, el secundario es un contorno (.ventana .b.s); en Dominó Pop, el mismo botón
        "boton_s_ventana": boton_s if pop else caja(v.get("--sec-v", "transparent"), "1.5px solid " + g("--ventana-t"),
                                                    g("--rb"), "none", g("--ventana-t")),
        "radio_redondo": radio(g("--rredondo")),
        "nodo_h": caja(g("--nodo-h"), g("--nodo-borde"), g("--rnodo"), g("--nodo-h-sombra"), g("--nodo-h-t") or g("--marco")),
        "nodo_a": caja(g("--prim"), g("--prim-borde"), g("--rnodo"), g("--nodo-sombra"), g("--prim-t")),
        "nodo_c": caja(g("--nodo-c"), g("--nodo-borde"), g("--rnodo"), "none", g("--nodo-c-t")),
        "ventana": caja(g("--ventana"), g("--borde-ventana"), g("--rventana"), g("--sombra-ventana"), g("--ventana-t")),
        "panel": caja(g("--panel"), g("--borde-panel"), g("--rpanel"), "none", g("--panel-t")),
        "chip": caja(g("--chip"), g("--borde-chip"), g("--rchip"), "none", g("--chip-t")),
        "tablero": caja(None, g("--borde-tablero"), g("--rpanel"), g("--sombra-tablero")),
        "aviso": {"fondo": color(g("--aviso")), "texto": color(g("--aviso-t")), "radio": max(radio(g("--rpanel")) - 4, 0)},
        "pantalla": pantalla,
        # Botones (maqueta): al pasar el ratón, brillo 1.05 (1.04 en Dominó Pop); al pulsar bajan 2 px
        # (3 px en Dominó Pop, donde además se recoge la sombra); apagados, al 60 % (Dominó Pop: gris azulado)
        "brillo": 1.04 if pop else 1.05,
        "pulsar": 3 if pop else 2,
        "desactivado": {"fondo": color("#b7c4df"), "labio": color("#97a7c8"), "texto": color("#43557f")} if pop else {"opacidad": 0.6},
    }


def texto_tono(clave, valor):
    """Textos de tono de la maqueta, listos para el juego: el «5» de «Jugar nivel 5» pasa a ser «%d» y el
    «Barrio 1» dice cómo se numeran los barrios (número, romano u ordinal)."""
    if valor is None:
        return None
    if clave == "jugar":
        return valor.replace("5", "%d") if "5" in valor else valor
    if clave == "barrio":
        return "romano" if valor.endswith(" I") else ("ordinal" if valor.lower().startswith("primer") else "numero")
    return valor


def tema(t, base):
    v, L = t["v"], t["L"]
    pantalla = color(v["--pantalla"])
    estrella = color(t["estrella"])
    normal, dorada = CAMPANAS.get(t["id"], [None, estrella])
    if normal is None:
        normal = L["campana"] if color(L["campana"]) != estrella else L["badajo"]
    sec = color(v["--sec"])
    prim = color(v["--prim"])
    sombra = str(v.get("--prim-sombra") or "")
    textos = {k: texto_tono(k, t.get("t", {}).get(k, base.get(k))) for k in TEXTOS}
    ancho_borde, color_borde = borde(v.get("--borde-tablero"))
    # Tinta del tablero (muros, postes, marcas): el marco o el texto, el que más contraste
    fondo_tablero = sobre(color(L["tablero"]), pantalla)
    tinta = max([color(v["--marco"]), color(v["--texto"])], key=lambda c: contraste(c, fondo_tablero))
    return {
        "id": t["id"], "nombre": t["nombre"], "desc": t.get("desc", ""), "club": not t.get("defecto", False),
        "letras": LETRAS[t["id"]],
        "radio_boton": min(px(v.get("--rb"), 16), 999), "radio_ventana": px(v.get("--rventana"), 22),
        "sombra_solida": bool(re.search(r"(^|,)\s*-?\d+(px)? -?\d+px 0 #", re.sub(r"inset[^,]*", "", sombra))),
        "textos": textos,
        "estilo": estilo(t),
        "ui": {
            "pantalla": pantalla, "texto": color(v["--texto"]), "suave": color(v["--suave"]),
            "marco": color(v["--marco"]), "chip": color(v["--chip"]),
            "chip_t": color(v.get("--chip-t") or v["--texto"]),
            "prim": prim, "prim_t": color(v["--prim-t"]), "prim_labio": labio(sombra, prim, 0.18),
            "sec": sec, "sec_t": color(v["--sec-t"]), "sec_labio": labio(v.get("--sec-sombra"), sec, 0.1),
            "nodo_h": color(v["--nodo-h"]), "nodo_h_t": color(v.get("--nodo-h-t") or v["--marco"]),
            "nodo_c": color(v["--nodo-c"]),
            "ventana": color(v["--ventana"]), "ventana_t": color(v["--ventana-t"]), "ventana_s": color(v["--ventana-s"]),
            "velo": color(v["--velo"]), "estrella": estrella, "acento": color(v["--acento"]),
            "camino": color(t["camino"]), "camino_no": color(t["caminoNo"]),
        },
        "tablero": {
            "tablero": color(L["tablero"]), "tinta": tinta, "punto": color(L["punto"]), "ficha": color(L["ficha"]),
            "pip": color(L["pip"]), "borde_ficha": color(L["borde"]), "sombra": color(L["sombra"]),
            "cae": color(L["cae"]), "caida": color(L["caida"]), "campana": color(normal), "dorada": color(dorada),
            "inicio": color(L["inicio"]), "inicio_ico": color(L["inicioIco"]),
            "cifra": color(L["cifra"]), "cifra_t": color(L["cifraT"]),
            "borde": color_borde, "grosor_borde": ancho_borde,
        },
    }


def main():
    entrada = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).with_name("datos_temas_maqueta.json")
    crudo = json.loads(entrada.read_text(encoding="utf-8"))
    temas = [tema(t, crudo["base"]) for t in crudo["temas"]]
    assert temas[0]["id"] == "pop" and not temas[0]["club"], "Dominó Pop tiene que ser el primero y gratis"
    SALIDA.write_text(json.dumps({"version": 1, "temas": temas}, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print("%d temas -> %s" % (len(temas), SALIDA))


if __name__ == "__main__":
    main()
