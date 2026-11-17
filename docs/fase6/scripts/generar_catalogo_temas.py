"""Genera docs/fase6/CATALOGO_TEMAS.pdf: los 11 temas seleccionables y el tablero de Dominó Pop.

Uso (desde la raíz del repositorio):
    python -X utf8 docs/fase6/scripts/generar_catalogo_temas.py

Requisitos: playwright (con Chromium: `playwright install chromium`) y Pillow.
Abre docs/fase6/temas/index.html, elige cada tema con el selector, espera a que la demo se tumbe
y maqueta un PDF A4 vertical: portada con índice visual, una página por tema y el tablero completo
de Dominó Pop al final. El catálogo histórico con las 15 direcciones es CATALOGO_DISENOS.pdf.
"""
import html
import pathlib
import tempfile

from PIL import Image
from playwright.sync_api import sync_playwright

RAIZ = pathlib.Path(__file__).resolve().parents[3]
FASE6 = RAIZ / "docs" / "fase6"
SALIDA = FASE6 / "CATALOGO_TEMAS.pdf"
DSF = 1.25

TEMAS = [("pop", "Dominó Pop"), ("mesa", "Mesa de juego"), ("calma", "Calma premium"), ("grafico", "Gráfico y limpio"),
         ("negro", "Cine negro"), ("tinta", "Tinta japonesa"), ("bauhaus", "Bauhaus"), ("brutal", "Brutalista"),
         ("riso", "Risografía"), ("nocturno", "Nocturno"), ("nordico", "Nórdico")]


def jpg(png, destino, recorte=None):
    im = Image.open(png).convert("RGB")
    if recorte:
        im = im.crop(recorte)
    im.save(destino, "JPEG", quality=85, optimize=True)


def capturar(carpeta):
    imgs = {}
    with sync_playwright() as p:
        nav = p.chromium.launch(channel="chromium")
        pg = nav.new_context(viewport={"width": 1440, "height": 1000}, device_scale_factor=DSF).new_page()
        pg.goto((FASE6 / "temas" / "index.html").as_uri())
        pg.wait_for_timeout(1500)
        for ident, _ in TEMAS:
            pg.click(f'#selector button[data-tema="{ident}"]')
            pg.wait_for_timeout(400)
            pg.locator("[data-lienzo]").scroll_into_view_if_needed()
            pg.wait_for_timeout(6500)  # la demo se tumba sola al entrar en pantalla
            pg.evaluate("scrollTo(0,0)")
            pg.wait_for_timeout(200)
            png = carpeta / f"{ident}.png"
            pg.screenshot(path=str(png), full_page=True)
            jpg(png, carpeta / f"{ident}.jpg")
            imgs[ident] = carpeta / f"{ident}.jpg"
            print("capturado", ident)
        # Tablero completo de Dominó Pop, en dos mitades por secciones
        pg.goto((FASE6 / "tablero" / "index.html").as_uri())
        pg.wait_for_timeout(1500)
        alto = pg.evaluate("document.documentElement.scrollHeight")
        for y in range(0, alto, 500):
            pg.evaluate(f"scrollTo(0,{y})")
            pg.wait_for_timeout(200)
        pg.evaluate("document.querySelector('.escaparate').scrollIntoView({block:'center'})")
        pg.wait_for_timeout(9000)
        corte = pg.evaluate("Math.round(document.querySelector('[aria-labelledby=\"h-sis\"]').getBoundingClientRect().top + scrollY)")
        png = carpeta / "tablero.png"
        pg.screenshot(path=str(png), full_page=True)
        ancho = Image.open(png).width
        imgs["tablero"] = []
        for k, (a, z) in enumerate([(0, corte), (corte, alto)], 1):
            d = carpeta / f"tablero_{k}.jpg"
            jpg(png, d, (0, int(a * DSF), ancho, int(z * DSF)))
            imgs["tablero"].append(d)
        nav.close()
    return imgs


CSS = """
@page{size:210mm 297mm;margin:0}
*{box-sizing:border-box}
html,body{margin:0;background:#f4f3ef;color:#1d1d1b;font-family:"Figtree",sans-serif}
.hoja{width:210mm;height:297mm;padding:11mm 12mm 8mm;display:flex;flex-direction:column;page-break-after:always;overflow:hidden}
.hoja:last-child{page-break-after:auto}
.cab{display:flex;align-items:baseline;justify-content:space-between;gap:6mm;border-bottom:.35mm solid #1d1d1b;padding-bottom:2.5mm;margin-bottom:4mm}
.cab h2{margin:0;font-size:17pt;font-weight:800}
.cab span{font-size:8.5pt;color:#55534c}
.lienzo{flex:1;min-height:0;display:flex;align-items:flex-start;justify-content:center}
.lienzo img{max-width:100%;max-height:100%;object-fit:contain;border-radius:1.5mm;box-shadow:0 .5mm 2.5mm rgba(0,0,0,.18)}
.pie{display:flex;justify-content:space-between;font-size:7pt;color:#7a7870;margin-top:3mm}
.portada h1{font-size:30pt;line-height:1.05;margin:4mm 0 3mm}
.portada .sub{font-size:10pt;line-height:1.5;color:#3d3c38;margin:0 0 7mm;max-width:170mm}
.rejilla{display:grid;grid-template-columns:repeat(3,1fr);gap:4mm;flex:1;min-height:0;align-content:start}
.mini .foto{height:44mm;border-radius:1.2mm;background-size:cover;background-position:center top;border:.3mm solid #cfcdc6}
.mini p{margin:1.4mm 0 0;font-size:8.5pt;font-weight:700}
.mini p small{font-weight:500;color:#7a7870}
"""


def maquetar(imgs):
    e = html.escape
    minis = "".join(
        f'<div class="mini"><div class="foto" style="background-image:url(\'{imgs[i].as_uri()}\')"></div>'
        f'<p>{e(n)}{" <small>· por defecto</small>" if i == "pop" else ""}</p></div>' for i, n in TEMAS)
    hojas = [f"""<section class="hoja portada">
      <h1>Cadencia · Temas del juego</h1>
      <p class="sub">Selección final del 17/11/2026. El jugador elige el aspecto en Ajustes › Apariencia. Dominó Pop
      (versión 2, más calmada) viene por defecto; los otros diez comparten pantallas, componentes y reglas, y cambian
      solo colores, letras, formas y tono. Ningún tema cambia niveles, precios ni progreso.</p>
      <div class="rejilla">{minis}</div>
      <div class="pie"><span>Fuentes SIL OFL (Google Fonts) · gráficos dibujados en código</span><span>1</span></div></section>"""]
    pag = 1
    for i, n in TEMAS:
        pag += 1
        hojas.append(f"""<section class="hoja"><header class="cab"><h2>{e(n)}</h2><span>{"Tema por defecto" if i == "pop" else "Tema seleccionable"}</span></header>
          <div class="lienzo"><img src="{imgs[i].as_uri()}" alt="{e(n)}"></div>
          <div class="pie"><span>Cadencia · Temas del juego</span><span>{pag}</span></div></section>""")
    for k, img in enumerate(imgs["tablero"], 1):
        pag += 1
        hojas.append(f"""<section class="hoja"><header class="cab"><h2>Dominó Pop · tablero completo</h2><span>parte {k} de {len(imgs["tablero"])}</span></header>
          <div class="lienzo"><img src="{img.as_uri()}" alt="Tablero de Dominó Pop, parte {k}"></div>
          <div class="pie"><span>Cadencia · Temas del juego</span><span>{pag}</span></div></section>""")
    return f"""<!doctype html><html lang="es"><head><meta charset="utf-8"><title>Cadencia · Temas del juego</title>
<link href="https://fonts.googleapis.com/css2?family=Figtree:wght@400;500;700;800&display=swap" rel="stylesheet">
<style>{CSS}</style></head><body>{''.join(hojas)}</body></html>"""


def main():
    with tempfile.TemporaryDirectory() as tmp:
        carpeta = pathlib.Path(tmp)
        imgs = capturar(carpeta)
        pagina = carpeta / "catalogo.html"
        pagina.write_text(maquetar(imgs), encoding="utf-8")
        with sync_playwright() as p:
            nav = p.chromium.launch(channel="chromium")
            pg = nav.new_page()
            pg.goto(pagina.as_uri())
            pg.wait_for_load_state("networkidle")
            pg.evaluate("document.fonts.ready")
            pg.pdf(path=str(SALIDA), width="210mm", height="297mm", print_background=True, prefer_css_page_size=True)
            nav.close()
    print("PDF:", SALIDA)


if __name__ == "__main__":
    main()
