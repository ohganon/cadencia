"""Graba clips verticales (WebM, 720 × 1280) de la demo jugable para el plan de TikTok.

Uso (desde la raíz del repositorio):
    python -X utf8 docs/fase7/scripts/grabar_clips.py

Usa el «modo clip» de docs/fase6/temas/index.html (?clip=1&t=gancho#tema=id): solo la partida,
con el gancho arriba y la marca «Prototipo · en desarrollo», como exige el plan de contenido.
Los clips se guardan en docs/fase7/clips/. Para Instagram Reels hay que convertirlos a MP4
con una herramienta gratuita (por ejemplo, ffmpeg completo o HandBrake).
"""
import pathlib
import shutil
import tempfile
from urllib.parse import quote

from playwright.sync_api import sync_playwright

RAIZ = pathlib.Path(__file__).resolve().parents[3]
PAGINA = RAIZ / "docs" / "fase6" / "temas" / "index.html"
SALIDA = RAIZ / "docs" / "fase7" / "clips"
TAM = {"width": 720, "height": 1280}

CLIPS = [
    ("01_llega_a_la_campana_pop", "pop", "¿Las dos llegan a la vez?"),
    ("02_campana_doble_nocturno", "nocturno", "Dos ramas. Una campana."),
    ("03_mismo_puzle_mesa", "mesa", "Mismo puzle, otro estilo"),
]


def main():
    SALIDA.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp, sync_playwright() as p:
        nav = p.chromium.launch(channel="chromium")
        for nombre, tema, gancho in CLIPS:
            ctx = nav.new_context(viewport=TAM, record_video_dir=tmp, record_video_size=TAM)
            pg = ctx.new_page()
            pg.goto(f"{PAGINA.as_uri()}?clip=1&t={quote(gancho)}#tema={tema}")
            pg.wait_for_timeout(9500)  # carga, pausa de 0,45 s y caída completa con la campana
            video = pg.video
            ctx.close()
            destino = SALIDA / f"{nombre}.webm"
            shutil.copy(video.path(), destino)
            print("grabado", destino.name, round(destino.stat().st_size / 1024), "KB")
        nav.close()


if __name__ == "__main__":
    main()
