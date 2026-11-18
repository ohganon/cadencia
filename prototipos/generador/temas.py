"""Convierte los 11 temas de la maqueta (docs/fase6/temas/index.html) a datos para Godot.

Entrada: datos_temas_maqueta.json, con {"temas": [...], "base": {...}} sacado de las constantes TEMAS
y BASE de la maqueta (se evaluaron en un navegador porque son JavaScript). Salida: godot/datos/temas.json.

Uso:
    python prototipos/generador/temas.py [datos_temas_maqueta.json]

Qué hace con cada tema:
- Colores CSS (#abc, #aabbcc, rgba(), transparent) -> "#rrggbbaa" que entiende Color() de Godot.
- Degradados (linear-gradient) -> el color del medio, porque la pantalla de Godot es de un color.
- Labio de los botones: el color del «inset» de la sombra de la maqueta; si no hay, se oscurece.
- Campana normal y dorada: la dorada usa el color de la estrella del tema y la normal, el de la
  campana o el badajo (el que no coincida con la dorada). Dos temas se ajustan a mano.
- Letras: la maqueta usa fuentes distintas por tema. Hasta que se descarguen (necesita permiso), el
  juego usa Lilita One y Nunito en todos; la fuente prevista queda anotada en "fuentes_previstas".
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
TEXTOS = ["ya", "superado", "sinTitulo"]


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
    textos = {k: t.get("t", {}).get(k, base.get(k)) for k in TEXTOS}
    ancho_borde, color_borde = borde(v.get("--borde-tablero"))
    # Tinta del tablero (muros, postes, marcas): el marco o el texto, el que más contraste
    fondo_tablero = sobre(color(L["tablero"]), pantalla)
    tinta = max([color(v["--marco"]), color(v["--texto"])], key=lambda c: contraste(c, fondo_tablero))
    return {
        "id": t["id"], "nombre": t["nombre"], "desc": t.get("desc", ""), "club": not t.get("defecto", False),
        "fuentes_previstas": [t.get("fd", ""), t.get("fu", "")],
        "radio_boton": min(px(v.get("--rb"), 16), 999), "radio_ventana": px(v.get("--rventana"), 22),
        "sombra_solida": bool(re.search(r"(^|,)\s*-?\d+(px)? -?\d+px 0 #", re.sub(r"inset[^,]*", "", sombra))),
        "textos": textos,
        "ui": {
            "pantalla": pantalla, "texto": color(v["--texto"]), "suave": color(v["--suave"]),
            "marco": color(v["--marco"]), "chip": color(v["--chip"]),
            "chip_t": color(v.get("--chip-t") or v["--texto"]),
            "prim": prim, "prim_t": color(v["--prim-t"]), "prim_labio": labio(sombra, prim, 0.18),
            "sec": sec, "sec_t": color(v["--sec-t"]), "sec_labio": labio(v.get("--sec-sombra"), sec, 0.1),
            "nodo_h": color(v["--nodo-h"]), "nodo_h_t": color(v.get("--nodo-h-t") or v["--marco"]),
            "nodo_c": color(v["--nodo-c"]),
            "ventana": color(v["--ventana"]), "ventana_t": color(v["--ventana-t"]), "ventana_s": color(v["--ventana-s"]),
            "velo": color(v["--velo"]), "estrella": estrella,
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
