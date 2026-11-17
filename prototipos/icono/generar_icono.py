"""Icono provisional del prototipo: una ficha de dominó marfil cayendo sobre el azul de Dominó Pop.

Uso (desde la raíz del repositorio):
    python -X utf8 prototipos/icono/generar_icono.py

Escribe en godot/iconos/:
- icono.png (512 × 512): icono del proyecto y principal de Android.
- adaptable_frente.png y adaptable_fondo.png (432 × 432): icono adaptable de Android 8+, con lo
  importante dentro del círculo seguro de 264 px de diámetro.

Es obra propia y provisional: el icono final (con Pío) llega con el arte definitivo.
Requiere Pillow solo para generarlo; el juego usa los PNG ya generados.
"""
from __future__ import annotations

import pathlib

from PIL import Image, ImageDraw

AZUL = (36, 98, 214, 255)       # pool-blue
TINTA = (20, 37, 84, 255)
MARFIL = (255, 253, 246, 255)
AMARILLO = (255, 200, 61, 255)
CORAL = (255, 84, 112, 255)
SALIDA = pathlib.Path(__file__).resolve().parents[2] / "godot" / "iconos"
ESCALA = 4                       # se dibuja a 4× y se reduce: bordes suaves


def ficha(lado: int, centro: tuple, alto: float, angulo: float, color=MARFIL) -> Image.Image:
    """Una ficha vertical (alto × alto/2) con dos puntos, girada `angulo` grados alrededor de su base."""
    s = lado * ESCALA
    capa = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(capa)
    h = alto * ESCALA
    w = h * 0.5
    cx, cy = centro[0] * ESCALA, centro[1] * ESCALA
    caja = (cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2)
    borde = max(2, int(h * 0.045))
    d.rounded_rectangle(caja, radius=int(w * 0.18), fill=color, outline=TINTA, width=borde)
    d.line((cx - w * 0.32, cy, cx + w * 0.32, cy), fill=TINTA, width=max(2, int(borde * 0.7)))
    r = w * 0.12
    for py in (cy - h * 0.25, cy + h * 0.25):
        d.ellipse((cx - r, py - r, cx + r, py + r), fill=TINTA)
    pivote = (cx + w / 2, cy + h / 2)        # gira sobre la esquina inferior derecha, como al caer
    return capa.rotate(-angulo, center=pivote, resample=Image.BICUBIC)


def escena(lado: int, desplazamiento=(0, 0), tam=1.0) -> Image.Image:
    """Tres fichas: dos de pie y la última empezando a caer (como el logotipo de fichas)."""
    s = lado * ESCALA
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    alto = lado * 0.36 * tam
    base_y = lado * 0.5 + desplazamiento[1]
    paso = lado * 0.235 * tam
    xs = [lado * 0.5 - paso * 1.25 + k * paso for k in range(3)]
    for k, x in enumerate(xs):
        angulo = 24 if k == 2 else 0
        color = AMARILLO if k == 2 else MARFIL
        capa = ficha(lado, (x + desplazamiento[0], base_y), alto, angulo, color)
        img.alpha_composite(capa)
    return img


def icono_principal(lado=512) -> Image.Image:
    s = lado * ESCALA
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(img).rounded_rectangle((0, 0, s - 1, s - 1), radius=int(s * 0.22), fill=AZUL)
    img.alpha_composite(escena(lado))
    return img.resize((lado, lado), Image.LANCZOS)


def adaptable(lado=432):
    fondo = Image.new("RGBA", (lado, lado), AZUL)
    # Frente: la escena reducida para que quepa en el círculo seguro (264 de 432 px)
    frente = escena(lado, tam=0.68).resize((lado, lado), Image.LANCZOS)
    return frente, fondo


def main():
    SALIDA.mkdir(parents=True, exist_ok=True)
    icono_principal().save(SALIDA / "icono.png")
    frente, fondo = adaptable()
    frente.save(SALIDA / "adaptable_frente.png")
    fondo.save(SALIDA / "adaptable_fondo.png")
    for f in sorted(SALIDA.glob("*.png")):
        print(f.name, Image.open(f).size)


if __name__ == "__main__":
    main()
