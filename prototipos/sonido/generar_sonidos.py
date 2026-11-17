"""Genera los sonidos del prototipo por síntesis: son obra propia, sin licencias de terceros.

Uso (desde la raíz del repositorio):
    python -X utf8 prototipos/sonido/generar_sonidos.py

Escribe WAV mono de 16 bits a 44,1 kHz en godot/sonidos/. Python puro (módulo wave), sin
dependencias, y determinista: la misma ejecución da siempre los mismos bytes.

Sonidos:
- ficha.wav: el clic seco de una ficha al caer sobre la siguiente (madera clara).
- campana.wav: campana pequeña de latón; parciales inarmónicos como los de una campana real.
- superado.wav: tres campanitas ascendentes (do, mi, sol).
- fallo.wav: dos golpes suaves y graves, descendentes. Avisa sin castigar.

Se generan con calma (DESIGN.md: nada que grite). El volumen se normaliza a -3 dBFS.
"""
from __future__ import annotations

import math
import pathlib
import random
import struct
import wave

FRECUENCIA = 44100
SALIDA = pathlib.Path(__file__).resolve().parents[2] / "godot" / "sonidos"


def _env(t, ataque, caida):
    """Envolvente: subida lineal de `ataque` segundos y caída exponencial con constante `caida`."""
    if t < ataque:
        return t / ataque
    return math.exp(-(t - ataque) / caida)


def ficha(duracion=0.06):
    rnd = random.Random(7)
    n = int(FRECUENCIA * duracion)
    muestras, prev = [], 0.0
    for i in range(n):
        t = i / FRECUENCIA
        ruido = rnd.uniform(-1, 1)
        prev = prev * 0.55 + ruido * 0.45            # paso bajo suave: quita el siseo
        clic = prev * _env(t, 0.0005, 0.004)
        cuerpo = math.sin(2 * math.pi * 1650 * t) * _env(t, 0.0005, 0.007) * 0.5
        golpe = math.sin(2 * math.pi * 210 * t) * _env(t, 0.001, 0.012) * 0.6
        muestras.append(clic + cuerpo + golpe)
    return muestras


# Parciales de una campana pequeña (proporciones típicas: hum, prime, tierce, quint, nominal...)
PARCIALES = [(0.5, 0.35, 1.2), (1.0, 1.0, 0.9), (1.19, 0.55, 0.7), (1.5, 0.35, 0.55),
             (2.0, 0.6, 0.45), (2.52, 0.25, 0.3), (3.0, 0.15, 0.22), (4.1, 0.08, 0.15)]


def campana(fundamental=1046.5, duracion=1.6, volumen=1.0):
    n = int(FRECUENCIA * duracion)
    muestras = []
    for i in range(n):
        t = i / FRECUENCIA
        v = 0.0
        for ratio, amp, caida in PARCIALES:
            v += amp * math.sin(2 * math.pi * fundamental * ratio * t) * _env(t, 0.002, caida)
        # golpe del badajo: un instante de brillo al principio
        v += 0.25 * math.sin(2 * math.pi * fundamental * 5.4 * t) * _env(t, 0.0005, 0.01)
        muestras.append(v * volumen)
    return muestras


def mezclar(pistas, duracion):
    n = int(FRECUENCIA * duracion)
    total = [0.0] * n
    for inicio, muestras in pistas:
        desde = int(inicio * FRECUENCIA)
        for i, m in enumerate(muestras):
            if desde + i < n:
                total[desde + i] += m
    return total


def superado():
    notas = [523.25, 659.25, 783.99]           # do5, mi5, sol5
    return mezclar([(k * 0.13, campana(f * 2, 1.1, 0.8)) for k, f in enumerate(notas)], 1.5)


def fallo():
    def golpe(f, dur=0.35):
        n = int(FRECUENCIA * dur)
        return [math.sin(2 * math.pi * f * (i / FRECUENCIA)) * _env(i / FRECUENCIA, 0.004, 0.09) for i in range(n)]
    return mezclar([(0.0, golpe(330)), (0.16, golpe(247))], 0.6)


def normalizar(muestras, dbfs=-3.0):
    pico = max(abs(m) for m in muestras) or 1.0
    objetivo = 10 ** (dbfs / 20)
    # pequeño desvanecimiento final para que nunca termine con un chasquido
    cola = int(0.005 * FRECUENCIA)
    salida = []
    for i, m in enumerate(muestras):
        f = min(1.0, (len(muestras) - i) / cola)
        salida.append(m / pico * objetivo * f)
    return salida


def escribir(nombre, muestras):
    SALIDA.mkdir(parents=True, exist_ok=True)
    ruta = SALIDA / nombre
    with wave.open(str(ruta), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(FRECUENCIA)
        w.writeframes(b"".join(struct.pack("<h", int(round(m * 32767))) for m in normalizar(muestras)))
    print(f"{ruta.name}: {len(muestras) / FRECUENCIA:.2f} s, {ruta.stat().st_size // 1024} KB")


def main():
    escribir("ficha.wav", ficha())
    escribir("campana.wav", campana())
    escribir("superado.wav", superado())
    escribir("fallo.wav", fallo())


if __name__ == "__main__":
    main()
