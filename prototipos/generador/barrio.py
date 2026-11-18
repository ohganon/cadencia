"""Los barrios de la campaña del prototipo.

Uso (desde esta carpeta):
    python -X utf8 barrio.py              # escribe godot/datos/barrio_1.json, barrio_2.json y barrio_3.json
    python -X utf8 barrio.py --comprobar  # falla si los archivos no están al día

Barrio 1, «La Plaza» (niveles 1–20): los 10 hechos a mano de la entrega 1 y 10 del generador.
Barrio 2, «El Puerto» (niveles 21–40): presenta la **puerta de vaivén**. Los niveles 21–23 la
enseñan paso a paso (hechos a mano) y 24–40 salen del generador, mezclando puertas con lo ya
aprendido y con respiros.
Barrio 3, «La Relojería» (niveles 41–60): presenta la **espiral de retardo**. El 41 y el 42 la
enseñan a mano (la recta pasa por ella; luego hay que desviarse para pasar) y 43–60 salen del
generador: espirales que abren puertas a tiempo o igualan las ramas de una campana doble, mezcladas
con lo ya aprendido.

Ambos siguen la regla de ritmo de la Fase 4 (sección 5.2): dificultad creciente con picos cortos,
respiros, preparación y el Gran Tramo al final. Las semillas son fijas: los barrios no cambian.
"""
from __future__ import annotations

import json
import pathlib
import random
import sys

import generador as G
import sim
from niveles_entrega1 import exportar, niveles, suave, tramo_a_dict
from sim import Campana, Espiral, Nivel, Tramo, nivel_a_dict, simular

DATOS = pathlib.Path(__file__).resolve().parents[2] / "godot" / "datos"

OBJETIVOS = {
    "simple": "Llega a la [b]campana[/b] esquivando los muros.",
    "dos": "Haz sonar [b]las dos campanas[/b]: abre una rama desde una ficha puesta.",
    "numeradas": "Las campanas suenan [b]en orden[/b]: la 1 antes que la 2.",
    "doble": "Haz sonar la [b]campana doble[/b]: las dos ramas tienen que llegar a la vez.",
    "doble_y_simple": "Haz sonar la [b]campana[/b] y la [b]campana doble[/b].",
    "puerta": "Cruza la [b]puerta[/b] cuando esté abierta y haz sonar la campana.",
    "dos_puertas": "Cruza [b]las dos puertas[/b], cada una en su momento.",
    "espiral": "Pasa por la [b]espiral[/b] si necesitas llegar más tarde a la puerta.",
    "espiral_doble": "Haz sonar la [b]campana doble[/b]: una espiral retrasa la rama que llegaría antes.",
}

# (número, título, tipo, dificultad, semilla)
PLAN_1 = [
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

PLAN_2 = [
    (24, "La compuerta", "puerta", 0.4, 2401),
    (25, "Marea", "puerta", 0.5, 2502),
    (26, "Esclusa", "dos_puertas", 0.5, 2603),
    (27, "Las boyas", "numeradas", 0.5, 2704),
    (28, "A destiempo", "puerta", 0.6, 2805),
    (29, "Respiro en el muelle", "simple", 0.3, 2906),
    (30, "Dos compuertas", "dos_puertas", 0.6, 3007),
    (31, "Paciencia", "puerta", 0.65, 3108),
    (32, "Las dos grúas", "doble", 0.55, 3209),
    (33, "Ritmos distintos", "dos_puertas", 0.65, 3310),
    (34, "Justo a tiempo", "puerta", 0.7, 3411),
    (35, "Respiro en la lonja", "dos", 0.45, 3512),
    (36, "Doble esclusa", "dos_puertas", 0.7, 3613),
    (37, "La última ola", "puerta", 0.75, 3714),
    (38, "Contracorriente", "dos_puertas", 0.75, 3815),
    (39, "Carga y campana", "doble_y_simple", 0.7, 3916),
    (40, "Gran Tramo: el faro", "dos_puertas", 0.85, 4017),
]

PLAN_3 = [
    (43, "Dos relojes", "espiral_doble", 0.35, 4301),
    (44, "Tic tac", "espiral", 0.4, 4402),
    (45, "Cuerda corta", "espiral_doble", 0.45, 4503),
    (46, "Engranajes", "numeradas", 0.5, 4604),
    (47, "El péndulo", "espiral", 0.5, 4705),
    (48, "Respiro en el escaparate", "simple", 0.3, 4806),
    (49, "Sincronía", "espiral_doble", 0.55, 4907),
    (50, "Hora punta", "puerta", 0.55, 5008),
    (51, "El cuco", "espiral", 0.6, 5109),
    (52, "Minutero", "espiral_doble", 0.6, 5210),
    (53, "Respiro en la trastienda", "dos", 0.4, 5311),
    (54, "Segundero", "espiral", 0.65, 5412),
    (55, "Las dos agujas", "doble", 0.6, 5513),
    (56, "Maquinaria", "espiral_doble", 0.7, 5614),
    (57, "A la hora en punto", "espiral", 0.7, 5715),
    (58, "Dos compuertas", "dos_puertas", 0.7, 5816),
    (59, "Puesta a punto", "espiral_doble", 0.75, 5917),
    (60, "Gran Tramo: la torre del reloj", "espiral", 0.85, 6018),
]


def _generados(plan):
    lista = []
    for numero, titulo, tipo, dificultad, semilla in plan:
        g = G.generar(semilla, tipo, dificultad)
        if g is None:
            raise RuntimeError(f"no se pudo generar el nivel {numero}")
        d = G.a_dict(g)
        lista.append({"id": numero, "titulo": titulo, "ayuda": OBJETIVOS[tipo], "nivel": d["nivel"],
                      "solucion": d["solucion"], "origen": f"generador (semilla {semilla}, dificultad {g.dificultad})"})
    return lista


def _con_dorada(lista):
    """Pone la campana dorada en cada nivel (semilla fija por nivel) y actualiza marca, fichas y
    solución de referencia. Si en un nivel no cabe, se queda sin ella (y sin tercera estrella)."""
    salida = []
    for n in lista:
        nivel = sim.nivel_de_dict(n["nivel"])
        tramos = [Tramo([tuple(p) for p in t["puntos"]], t["padre"], t["desde"]) for t in n["solucion"]]
        r = G.poner_dorada(nivel, tramos, 7919 * int(n["id"]))
        if r is not None:
            nivel, tramos = r
            n = n | {"nivel": nivel_a_dict(nivel), "solucion": [tramo_a_dict(x) for x in tramos]}
        salida.append(n)
    return salida


def barrio_1() -> dict:
    hechos = json.loads(exportar(niveles())["niveles_entrega1.json"])["niveles"]
    lista = [{k: n[k] for k in ("id", "titulo", "ayuda", "nivel", "solucion")} | {"origen": "a mano"} for n in hechos]
    return {"version": 1, "barrio": 1, "nombre": "La Plaza", "niveles": _con_dorada(lista + _generados(PLAN_1))}


# ---------------------------------------------------------------- El Puerto: niveles de enseñanza

def _con_puertas(inicio, campana, filas, solucion_puntos, ritmos, fichas_extra):
    """Nivel hecho a mano con filas de muro y puerta. `ritmos[k]` es (periodo, abierta, desfase):
    la fase se calcula para que la solución cruce la puerta k en el tic `desfase` de su apertura."""
    muros, puertas = [], []
    tramo = Tramo(suave(solucion_puntos, 3))
    for (y, centro, ancho), (periodo, abierta, desfase) in zip(filas, ritmos):
        m, (a, b) = G.fila_con_puerta(y, centro, ancho)
        muros += m
        t = G._tic_cruce(tramo.puntos, a, b)
        puertas.append(sim.Puerta(a, b, periodo, abierta, (t - desfase) % periodo))
    nivel = Nivel(100, 160, inicio, [Campana("a", campana)], muros=muros, puertas=puertas, fichas=10_000)
    r = simular(nivel, [tramo])
    assert r["exito"], r
    nivel.marca, nivel.fichas = r["fichas_usadas"], r["fichas_usadas"] + fichas_extra
    return nivel, [tramo]


def ensenanza():
    lista = []
    # 21. La puerta: la línea recta llega con la puerta abierta (ventana amplia). Solo hay que verla.
    n, s = _con_puertas((50, 150), (50, 25), [(90, 50, 30)], [(50, 150), (50, 25)], [(16, 8, 3)], 15)
    lista.append((21, "La puerta", "La [b]puerta[/b] se abre y se cierra a su ritmo: mírala antes de tumbar.", n, s))
    # 22. Espera a que abra: en línea recta llega cerrada; con un rodeo, llega cuando se abre.
    rodeo = [(50, 150), (22, 128), (22, 105), (50, 97), (50, 83), (50, 25)]
    n, s = _con_puertas((50, 150), (50, 25), [(90, 50, 24)], rodeo, [(18, 5, 2)], 14)
    recta = simular(n, [Tramo([(50, 150), (50, 25)])])
    assert not recta["exito"] and recta["parada"]["motivo"] == "puerta cerrada", recta
    lista.append((22, "Espera a que abra", "Si llegas con la puerta cerrada, [b]alarga el camino[/b] para llegar cuando se abra.", n, s))
    # 23. Dos puertas, con ventanas generosas, para practicar el ritmo de las dos.
    ruta = [(50, 150), (35, 125), (35, 105), (35, 90), (55, 72), (65, 60), (65, 48), (50, 25)]
    n, s = _con_puertas((50, 150), (50, 25), [(112, 35, 26), (54, 65, 26)], ruta, [(14, 6, 2), (16, 6, 3)], 14)
    lista.append((23, "Dos puertas", "Dos puertas: llega a [b]cada una[/b] en su momento.", n, s))
    return [{"id": i, "titulo": t, "ayuda": a, "nivel": nivel_a_dict(n), "solucion": [tramo_a_dict(x) for x in s],
             "origen": "a mano"} for i, t, a, n, s in lista]


def barrio_2() -> dict:
    return {"version": 1, "barrio": 2, "nombre": "El Puerto", "niveles": _con_dorada(ensenanza() + _generados(PLAN_2))}


# ---------------------------------------------------------------- La Relojería: niveles de enseñanza

def _con_espiral(inicio, campana, fila, solucion_puntos, ritmo, espiral, fichas_extra):
    """Nivel hecho a mano con una fila de muro, su puerta y una espiral. `ritmo` es (periodo,
    abierta, desfase): la solución cruza la puerta en el tic `desfase` de su apertura, contando el
    retraso de la espiral."""
    y, centro, ancho = fila
    muros, (a, b) = G.fila_con_puerta(y, centro, ancho)
    tramo = Tramo(suave(solucion_puntos, 3))
    nivel = Nivel(100, 160, inicio, [Campana("a", campana)], muros=muros, fichas=10_000, espirales=[espiral])
    t = G._tic_cruce_espiral(nivel, tramo.puntos, a, b)
    periodo, abierta, desfase = ritmo
    nivel.puertas = [sim.Puerta(a, b, periodo, abierta, (t - desfase) % periodo)]
    r = simular(nivel, [tramo])
    assert r["exito"], r
    nivel.marca, nivel.fichas = r["fichas_usadas"], r["fichas_usadas"] + fichas_extra
    return nivel, [tramo]


def ensenanza_3():
    lista = []
    # 41. La espiral: la recta pasa por ella y llega a la puerta justo cuando se abre.
    recta = [(50, 150), (50, 25)]
    n, s = _con_espiral((50, 150), (50, 25), (88, 50, 30), recta, (16, 6, 2), Espiral((50, 122), 6), 15)
    sin = Nivel(n.ancho, n.alto, n.inicio, n.campanas, n.muros, n.puertas, n.fichas)
    assert not simular(sin, s)["exito"], "sin la espiral, la recta tiene que llegar con la puerta cerrada"
    lista.append((41, "La espiral", "La [b]espiral[/b] retrasa lo que pasa por ella: mira cómo cambian los números al dibujar.", n, s))
    # 42. Pasa por la espiral: la recta no pasa por ella y llega con la puerta cerrada.
    rodeo = [(50, 150), (27, 130), (27, 114), (50, 100), (50, 82), (50, 25)]
    n, s = _con_espiral((50, 150), (50, 25), (90, 50, 26), rodeo, (18, 5, 2), Espiral((27, 122), 6), 14)
    r = simular(n, [Tramo([(50, 150), (50, 25)])])
    assert not r["exito"] and r["parada"]["motivo"] == "puerta cerrada", r
    lista.append((42, "Pasa por la espiral", "La recta llega con la puerta cerrada: [b]pasa por la espiral[/b] para llegar más tarde.", n, s))
    return [{"id": i, "titulo": t, "ayuda": a, "nivel": nivel_a_dict(n), "solucion": [tramo_a_dict(x) for x in s],
             "origen": "a mano"} for i, t, a, n, s in lista]


def barrio_3() -> dict:
    generados = _generados(PLAN_3)
    generados[0]["ayuda"] = "Las dos ramas no miden lo mismo: [b]pasa la corta por la espiral[/b] para que lleguen a la vez."
    return {"version": 1, "barrio": 3, "nombre": "La Relojería", "niveles": _con_dorada(ensenanza_3() + generados)}


def archivos() -> dict:
    fmt = lambda d: json.dumps(d, ensure_ascii=False, indent=1) + "\n"
    return {"barrio_1.json": fmt(barrio_1()), "barrio_2.json": fmt(barrio_2()), "barrio_3.json": fmt(barrio_3())}


def main():
    textos = archivos()
    if "--comprobar" in sys.argv:
        desfasados = [k for k, v in textos.items() if not (DATOS / k).exists() or (DATOS / k).read_text(encoding="utf-8") != v]
        print("barrios al día" if not desfasados else f"DESFASADOS: {desfasados}: ejecuta barrio.py")
        sys.exit(1 if desfasados else 0)
    for k, v in textos.items():
        (DATOS / k).write_text(v, encoding="utf-8")
        for n in json.loads(v)["niveles"]:
            print(f"{n['id']:>2}. {n['titulo']:<24} marca {n['nivel']['m']:>3}  fichas {n['nivel']['f']:>3}"
                  f"  puertas {len(n['nivel']['p'])}  espirales {len(n['nivel'].get('e', []))}  {n['origen']}")


if __name__ == "__main__":
    main()
