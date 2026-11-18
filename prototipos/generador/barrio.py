"""Barrio 1, «La Plaza»: los 20 niveles de la campaña del prototipo.

Uso (desde esta carpeta):
    python -X utf8 barrio.py              # escribe godot/datos/barrio_1.json
    python -X utf8 barrio.py --comprobar  # falla si el archivo no está al día

Niveles 1–10: los hechos a mano de la entrega 1 (niveles_entrega1.py).
Niveles 11–20: del generador, siguiendo la regla de ritmo de la Fase 4 (sección 5.2): dificultad
creciente con picos cortos (11–16), preparación (17–19) y el Gran Tramo (20). Se eligen semillas
fijas, así que el barrio es siempre el mismo.
"""
from __future__ import annotations

import json
import pathlib
import sys

import generador as G
from niveles_entrega1 import exportar, niveles

SALIDA = pathlib.Path(__file__).resolve().parents[2] / "godot" / "datos" / "barrio_1.json"

# (número, título, tipo, dificultad, semilla)
PLAN = [
    (11, "Dos destinos", "dos", 0.45, 1101),
    (12, "Primero la lejana", "numeradas", 0.5, 1202),
    (13, "A la vez", "doble", 0.5, 1303),
    (14, "Respiro", "simple", 0.3, 1404),
    (15, "Las tres campanas", "doble_y_simple", 0.6, 1505),
    (16, "Vuelta atrás", "numeradas", 0.65, 1606),
    (17, "Rodeo", "dos", 0.55, 1707),
    (18, "El muro del medio", "doble", 0.65, 1808),
    (19, "Casi listo", "doble_y_simple", 0.7, 1909),
    (20, "Gran Tramo: el reloj", "doble_y_simple", 0.85, 2010),
]

OBJETIVOS = {
    "simple": "Llega a la [b]campana[/b] esquivando los muros.",
    "dos": "Haz sonar [b]las dos campanas[/b]: abre una rama desde una ficha puesta.",
    "numeradas": "Las campanas suenan [b]en orden[/b]: la 1 antes que la 2.",
    "doble": "Haz sonar la [b]campana doble[/b]: las dos ramas tienen que llegar a la vez.",
    "doble_y_simple": "Haz sonar la [b]campana[/b] y la [b]campana doble[/b].",
}


def barrio() -> dict:
    hechos = json.loads(exportar(niveles())["niveles_entrega1.json"])["niveles"]
    lista = []
    for n in hechos:
        lista.append({k: n[k] for k in ("id", "titulo", "ayuda", "nivel", "solucion")} | {"origen": "a mano"})
    for numero, titulo, tipo, dificultad, semilla in PLAN:
        g = G.generar(semilla, tipo, dificultad)
        if g is None:
            raise RuntimeError(f"no se pudo generar el nivel {numero}")
        d = G.a_dict(g)
        lista.append({"id": numero, "titulo": titulo, "ayuda": OBJETIVOS[tipo], "nivel": d["nivel"],
                      "solucion": d["solucion"], "origen": f"generador (semilla {semilla}, dificultad {g.dificultad})"})
    return {"version": 1, "barrio": 1, "nombre": "La Plaza", "niveles": lista}


def main():
    texto = json.dumps(barrio(), ensure_ascii=False, indent=1) + "\n"
    if "--comprobar" in sys.argv:
        al_dia = SALIDA.exists() and SALIDA.read_text(encoding="utf-8") == texto
        print("barrio_1.json al día" if al_dia else "DESFASADO: ejecuta barrio.py")
        sys.exit(0 if al_dia else 1)
    SALIDA.write_text(texto, encoding="utf-8")
    for n in json.loads(texto)["niveles"]:
        print(f"{n['id']:>2}. {n['titulo']:<24} marca {n['nivel']['m']:>3}  fichas {n['nivel']['f']:>3}  {n['origen']}")


if __name__ == "__main__":
    main()
