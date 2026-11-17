"""Genera docs/fase6/CATALOGO_DISENOS.pdf con todas las direcciones de diseño.

Uso (desde la raíz del repositorio):
    python -X utf8 docs/fase6/scripts/generar_catalogo.py

Requisitos: playwright (con Chromium instalado: `playwright install chromium`) y Pillow.
Captura cada dirección en 1440 px de ancho, espera a que su demo termine de tumbarse
y maqueta un PDF A4 apaisado con una dirección por página.
«La Banda del Pueblo» se recupera del historial de Git (commit b4c547a).
"""
import html
import pathlib
import subprocess
import sys
import tempfile

from PIL import Image
from playwright.sync_api import sync_playwright

RAIZ = pathlib.Path(__file__).resolve().parents[3]
FASE6 = RAIZ / "docs" / "fase6"
SALIDA = FASE6 / "CATALOGO_DISENOS.pdf"
DSF = 1.5  # densidad de las capturas
ALTO_MAX = 1400  # alto máximo (px CSS) de cada trozo de los tableros largos

GRUPOS = {
    "fav": ("Favorita", "#b0892f"),
    "t2": ("Tanda 2", "#3d5a80"),
    "ant": ("Anterior", "#6b6b6b"),
}

# id, grupo, nombre, fuentes, tono, descripción
DISENOS = [
    ("mesa", "fav", "Mesa de juego", "Manrope", "«Tumbar» · «Bien hecho» · «Inténtalo otra vez»",
     "El dominó de siempre, sobre una mesa: tapete de pizarra, fichas de hueso con sombra real, detalles de latón y un rojo lacre para las campanas. Pensado para parecer un juego de mesa premium."),
    ("calma", "fav", "Calma premium", "Jost", "«Soltar» · «Todo encaja» · «Casi. Otra vez, con calma»",
     "Degradados de atardecer, fichas blancas mate con sombra larga, mucho espacio y una sola nota de color por barrio. Texto mínimo y tranquilo."),
    ("grafico", "fav", "Gráfico y limpio", "Archivo", "«Tumbar» · «Resuelto» · «No llegó. Reintentar»",
     "Como los pasatiempos de un periódico: fondo blanco roto, fichas negras, mostaza y cobalto como únicos acentos, bordes de 2 px y una grotesca muy firme."),
    ("negro", "t2", "Cine negro", "Bebas Neue + Barlow", "«Acción» · «Caso cerrado»",
     "Blanco y negro de película de detectives: alto contraste, grano fino y un único rojo para lo importante. Títulos altos y estrechos como un cartel de cine."),
    ("tinta", "t2", "Tinta japonesa", "Shippori Mincho + Zen Kaku Gothic New", "«Soltar» · «Armonía»",
     "Papel de arroz gris, trazos de tinta sumi y un sello bermellón como único color. Mucho vacío, ritmo pausado y textos muy breves."),
    ("deco", "t2", "Art déco", "Marcellus SC + Josefin Sans", "«Adelante» · «Magnífico»",
     "Vestíbulo de hotel de los años 20: verde esmeralda profundo, filetes dorados, geometría simétrica y mayúsculas romanas."),
    ("bauhaus", "t2", "Bauhaus", "League Spartan", "«Tumbar» · «Forma completa»",
     "Formas puras y colores primarios: círculo rojo, cuadrado azul y triángulo amarillo sobre blanco y negro. Tipografía geométrica gruesa."),
    ("brutal", "t2", "Brutalista", "Familjen Grotesk", "«Hecho.» · «Error: no llegó. Reintentar.»",
     "Web sin maquillaje: gris hormigón, bordes negros gruesos, sombras duras y un verde ácido para la acción. Directo y muy reconocible en redes."),
    ("riso", "t2", "Risografía", "Bricolage Grotesque", "«¡Allá va!» · «¡Impreso!»",
     "Fanzine impreso en risógrafo: rosa fluorescente y azul verdoso sobre papel con trama, colores que se pisan y un punto artesanal."),
    ("nocturno", "t2", "Nocturno", "Red Hat Display + Red Hat Text", "«Encender» · «Constelación completa»",
     "Un observatorio de noche: azul medianoche, cielo estrellado discreto, fichas plateadas y las cadenas como constelaciones. Sin neones."),
    ("terracota", "t2", "Terracota mediterránea", "Gloock + Mulish", "«¡Venga!» · «¡Olé!» · «Hora de la siesta»",
     "Patio andaluz al mediodía: arcilla, arena y azul de azulejo, con una serif cálida y textos con sabor local, sin caer en el folclore."),
    ("nordico", "t2", "Nórdico", "Figtree", "«Tumbar» · «Bien hecho» · «Pausa»",
     "Salón escandinavo: gris verdoso claro, fichas de madera de pino, verde bosque para la acción y esquinas suaves."),
    ("cuaderno", "t2", "Cuaderno", "Caveat + Patrick Hand", "«¡Allá va!» · «¡Resuelto!»",
     "Cuaderno de cuadros con bolígrafo azul y margen rojo, como resolver un acertijo en clase. Letra manuscrita y apuntes de lápiz."),
    ("pop", "ant", "Dominó Pop", "Lilita One + Nunito", "«¡A TUMBAR!» · «¡NIVEL SUPERADO!»",
     "Juego casual jugoso tras revisar 222 diseños de Pinterest: azul piscina, botones que se hunden, contornos gruesos y fichas de dominó de verdad. Bien valorado, pero demasiado visto."),
    ("banda", "ant", "La Banda del Pueblo", "Bodoni Moda + Atkinson Hyperlegible", "«¡YA!» · «¡A tiempo!»",
     "Primera dirección: programa de una banda de música de pueblo, azul marino con rejilla de tiza, escarlata y latón, títulos de partitura. Descartada."),
]


def a_jpg(png: pathlib.Path, destino: pathlib.Path, recorte=None):
    im = Image.open(png).convert("RGB")
    if recorte:
        im = im.crop(recorte)
    im.save(destino, "JPEG", quality=86, optimize=True)


def capturar(carpeta: pathlib.Path) -> dict:
    """Devuelve {id: [rutas de imagen]}."""
    imagenes = {}
    banda = FASE6 / "tablero" / "_banda_tmp.html"
    banda.write_bytes(subprocess.check_output(
        ["git", "show", "b4c547a:docs/fase6/tablero/index.html"], cwd=RAIZ))
    try:
        with sync_playwright() as p:
            nav = p.chromium.launch(channel="chromium")
            pg = nav.new_context(viewport={"width": 1440, "height": 1000},
                                 device_scale_factor=DSF).new_page()
            for rel, ids in [("variantes/favoritas/index.html", ["mesa", "calma", "grafico"]),
                             ("variantes/tanda-2/index.html", ["negro", "tinta", "deco", "bauhaus", "brutal",
                                                                "riso", "nocturno", "terracota", "nordico", "cuaderno"])]:
                pg.goto((FASE6 / rel).as_uri())
                pg.wait_for_timeout(1500)
                pg.add_style_tag(content=".indice{display:none!important}")
                for i in ids:
                    sec = pg.locator(f"section#{i}")
                    sec.scroll_into_view_if_needed()
                    pg.wait_for_timeout(7000)  # la demo se tumba sola al entrar en pantalla
                    png = carpeta / f"{i}.png"
                    sec.screenshot(path=str(png))
                    a_jpg(png, carpeta / f"{i}.jpg")
                    imagenes[i] = [carpeta / f"{i}.jpg"]
                    print("capturado", i)
            for rel, nombre in [("tablero/_banda_tmp.html", "banda"), ("tablero/index.html", "pop")]:
                pg.goto((FASE6 / rel).as_uri())
                pg.wait_for_timeout(1500)
                alto = pg.evaluate("document.documentElement.scrollHeight")
                for y in range(0, alto, 500):
                    pg.evaluate(f"window.scrollTo(0,{y})")
                    pg.wait_for_timeout(250)
                pg.evaluate("document.querySelector('.escena,.escaparate').scrollIntoView({block:'center'})")
                pg.wait_for_timeout(1000)
                if nombre == "banda":  # su demo se lanza con «Ejemplo» y «¡Ya!»
                    pg.click("#ejemplo")
                    pg.wait_for_timeout(500)
                    pg.click("#ya")
                pg.wait_for_timeout(9000)
                bordes = pg.evaluate("""[...document.querySelectorAll('header.cabecera, main section, footer.pie')]
                    .map(e => Math.round(e.getBoundingClientRect().bottom + scrollY))""")
                png = carpeta / f"{nombre}_full.png"
                pg.screenshot(path=str(png), full_page=True)
                im = Image.open(png)
                cortes = sorted(set([0] + bordes + [alto]))
                trozos, ini, prev = [], 0, 0
                for c in cortes[1:]:
                    if c - ini > ALTO_MAX and prev > ini:
                        trozos.append((ini, prev))
                        ini = prev
                    prev = c
                trozos.append((ini, alto))
                imagenes[nombre] = []
                for k, (a, z) in enumerate(trozos, 1):
                    destino = carpeta / f"{nombre}_{k}.jpg"
                    a_jpg(png, destino, (0, int(a * DSF), im.width, int(z * DSF)))
                    imagenes[nombre].append(destino)
                print("capturado", nombre, trozos)
            nav.close()
    finally:
        banda.unlink(missing_ok=True)
    return imagenes


CSS = """
@page{size:297mm 210mm;margin:0}
*{box-sizing:border-box}
html,body{margin:0;background:#f4f3ef;color:#1d1d1b;font-family:"Figtree",sans-serif}
.hoja{width:297mm;height:210mm;padding:9mm 12mm 7mm;display:flex;flex-direction:column;page-break-after:always;overflow:hidden}
.hoja:last-child{page-break-after:auto}
.cab{display:grid;grid-template-columns:auto 1fr auto;gap:6mm;align-items:start;border-bottom:.4mm solid #1d1d1b;padding-bottom:3.5mm;margin-bottom:4mm}
.num{font-weight:800;font-size:22pt;line-height:1;font-variant-numeric:tabular-nums}
.nombre{font-weight:800;font-size:18pt;line-height:1.05;margin:0 0 1.5mm}
.desc{font-size:8.6pt;line-height:1.4;margin:0;color:#3d3c38;max-width:165mm}
.meta{text-align:right;font-size:8pt;line-height:1.5;color:#3d3c38;max-width:70mm}
.meta b{color:#1d1d1b}
.chip{display:inline-block;color:#fff;font-weight:800;font-size:7pt;letter-spacing:.08em;text-transform:uppercase;padding:1mm 2.4mm;border-radius:1mm;margin-bottom:1.5mm}
.lienzo{flex:1;min-height:0;display:flex;align-items:center;justify-content:center}
.lienzo img{max-width:100%;max-height:100%;object-fit:contain;border-radius:1.5mm;box-shadow:0 .6mm 3mm rgba(0,0,0,.18)}
.pie{display:flex;justify-content:space-between;font-size:7pt;color:#7a7870;margin-top:3mm}
.portada{justify-content:flex-start}
.portada h1{font-size:34pt;line-height:1;margin:2mm 0 2mm;letter-spacing:-.01em}
.portada .sub{font-size:10.5pt;color:#3d3c38;margin:0 0 6mm;max-width:200mm;line-height:1.45}
.rejilla{display:grid;grid-template-columns:repeat(5,1fr);gap:3.2mm 4mm;flex:1;min-height:0}
.mini{display:flex;flex-direction:column;min-height:0}
.mini .foto{flex:1;min-height:0;border-radius:1mm;background-size:cover;background-position:center top;border:.3mm solid #cfcdc6}
.mini p{margin:1.3mm 0 0;font-size:7.6pt;font-weight:600;line-height:1.2;display:flex;gap:1.6mm;align-items:center}
.mini i{width:2.2mm;height:2.2mm;border-radius:50%;flex:none}
.leyenda{display:flex;gap:6mm;font-size:8pt;margin:0 0 4mm;color:#3d3c38;align-items:center}
.leyenda span{display:inline-flex;gap:1.6mm;align-items:center}
.leyenda i{width:2.6mm;height:2.6mm;border-radius:50%}
"""


def maquetar(imagenes: dict) -> str:
    e = html.escape
    hojas = []
    # Portada con índice visual
    minis = "".join(
        f'<div class="mini"><div class="foto" style="background-image:url(\'{imagenes[d[0]][0].as_uri()}\')"></div>'
        f'<p><i style="background:{GRUPOS[d[1]][1]}"></i>{n}. {e(d[2])}</p></div>'
        for n, d in enumerate(DISENOS, 1))
    leyenda = "".join(f'<span><i style="background:{c}"></i>{e(t)}</span>' for t, c in GRUPOS.values())
    hojas.append(f"""<section class="hoja portada">
      <div class="chip" style="background:#1d1d1b;align-self:flex-start">Fase 6 · Dirección de arte</div>
      <h1>Dingfall · Catálogo de diseños</h1>
      <p class="sub">Las 15 direcciones visuales generadas hasta el 17/11/2026. Todas comparten la mecánica, las pantallas
      (inicio con mapa, partida, nivel superado y ventana sin cuerda) y el marco legal; cambian el color, las letras, las
      texturas y el tono de los textos. Cada página muestra la demo de la partida ya resuelta.</p>
      <div class="leyenda">{leyenda}</div>
      <div class="rejilla">{minis}</div>
      <div class="pie"><span>Fuentes: todas con licencia SIL OFL (Google Fonts)</span><span>1</span></div>
    </section>""")
    pagina = 1
    for n, (ident, grupo, nombre, fuentes, tono, desc) in enumerate(DISENOS, 1):
        partes = imagenes[ident]
        for k, img in enumerate(partes, 1):
            pagina += 1
            parte = f" · parte {k} de {len(partes)}" if len(partes) > 1 else ""
            etiqueta, color = GRUPOS[grupo]
            hojas.append(f"""<section class="hoja">
              <header class="cab">
                <div class="num">{n:02d}</div>
                <div><h2 class="nombre">{e(nombre)}</h2><p class="desc">{e(desc)}</p></div>
                <div class="meta"><span class="chip" style="background:{color}">{e(etiqueta)}{e(parte)}</span><br>
                  <b>Letras:</b> {e(fuentes)}<br><b>Tono:</b> {e(tono)}</div>
              </header>
              <div class="lienzo"><img src="{img.as_uri()}" alt="{e(nombre)}"></div>
              <div class="pie"><span>Dingfall · Catálogo de diseños</span><span>{pagina}</span></div>
            </section>""")
    return f"""<!doctype html><html lang="es"><head><meta charset="utf-8"><title>Dingfall · Catálogo de diseños</title>
<link href="https://fonts.googleapis.com/css2?family=Figtree:wght@400;600;800&display=swap" rel="stylesheet">
<style>{CSS}</style></head><body>{''.join(hojas)}</body></html>"""


def main():
    with tempfile.TemporaryDirectory() as tmp:
        carpeta = pathlib.Path(tmp)
        imagenes = capturar(carpeta)
        pagina_html = carpeta / "catalogo.html"
        pagina_html.write_text(maquetar(imagenes), encoding="utf-8")
        with sync_playwright() as p:
            nav = p.chromium.launch(channel="chromium")
            pg = nav.new_page()
            pg.goto(pagina_html.as_uri())
            pg.wait_for_load_state("networkidle")
            pg.evaluate("document.fonts.ready")
            pg.pdf(path=str(SALIDA), width="297mm", height="210mm", print_background=True,
                   prefer_css_page_size=True)
            nav.close()
    print("PDF:", SALIDA)


if __name__ == "__main__":
    sys.exit(main())
