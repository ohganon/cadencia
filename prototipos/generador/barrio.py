"""Los barrios de la campaña del prototipo.

Uso (desde esta carpeta):
    python -X utf8 barrio.py              # escribe godot/datos/barrio_1.json … barrio_7.json
    python -X utf8 barrio.py --comprobar  # falla si los archivos no están al día

Barrio 1, «La Plaza» (niveles 1–20): los 10 hechos a mano de la entrega 1 y 10 del generador.
Barrio 2, «El Puerto» (niveles 21–40): presenta la **puerta de vaivén**. Los niveles 21–23 la
enseñan paso a paso (hechos a mano) y 24–40 salen del generador, mezclando puertas con lo ya
aprendido y con respiros.
Barrio 3, «La Relojería» (niveles 41–60): presenta la **espiral de retardo**. El 41 y el 42 la
enseñan a mano (la recta pasa por ella; luego hay que desviarse para pasar) y 43–60 salen del
generador: espirales que abren puertas a tiempo o igualan las ramas de una campana doble, mezcladas
con lo ya aprendido.
Barrio 4, «La Feria» (niveles 61–80): presenta el **muelle**, que lanza la cadena por encima de un
muro a cambio de unos tics. El 61 lo enseña a mano (un muro de lado a lado) y 62–80 salen del
generador: muros que solo se saltan y campanas dobles donde una rama rodea y la otra salta.
Barrio 5, «La Estación» (niveles 81–100): presenta el **interruptor**, una placa que abre su
compuerta en cuanto cae una ficha encima. El 81 lo enseña a mano (la cadena pisa la placa y luego
cruza) y 82–100 salen del generador: una rama pisa la placa y la otra da el rodeo justo para llegar
a la compuerta ya abierta.
Barrio 6, «La Fábrica» (niveles 101–120): presenta la **noria**, que lleva la cadena al otro lado de
un muro y la suelta en su siguiente vuelta. El 101 la enseña a mano y 102–120 salen del generador:
muros que solo se pasan con la noria y dos norias del mismo ritmo que sueltan a la vez dos ramas
que llegan a destiempo.
Barrio 7, «El Jardín» (niveles 121–140): presenta el **globo**, que lleva colgado un camino de fichas
gratis que cae al reventarlo. El 121 lo enseña a mano y 122–140 salen del generador: campanas
lejos de tus fichas y campanas dobles con dos globos que hay que reventar cada uno a su tiempo.

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
from sim import Campana, Espiral, Globo, Interruptor, Muelle, Nivel, Noria, Tramo, nivel_a_dict, simular

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
    "muelle": "Hay un muro de lado a lado: llega al [b]muelle[/b] y sigue dibujando desde su salida.",
    "muelle_doble": "Haz sonar la [b]campana doble[/b]: una rama rodea el muro y la otra salta con el muelle.",
    "interruptor": "Pisa la [b]placa[/b] con una rama para abrir la compuerta, y crúzala después.",
    "noria": "Un muro de lado a lado: la [b]noria[/b] lleva la cadena al otro lado en su siguiente vuelta.",
    "noria_doble": "Haz sonar la [b]campana doble[/b]: las dos norias sueltan las ramas a la vez, aunque lleguen a destiempo.",
    "globo": "La campana queda lejos de tus fichas: revienta el [b]globo[/b] y su camino llegará por ti.",
    "globo_doble": "Revienta los dos [b]globos[/b], cada uno a su tiempo, para que sus caminos lleguen a la vez a la campana doble.",
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

PLAN_4 = [
    (62, "Dos caminos", "muelle_doble", 0.35, 6201),
    (63, "La noria", "muelle", 0.4, 6302),
    (64, "Tiro al blanco", "numeradas", 0.5, 6403),
    (65, "Montaña rusa", "muelle_doble", 0.5, 6504),
    (66, "Coches de choque", "espiral", 0.5, 6605),
    (67, "El salto", "muelle", 0.55, 6706),
    (68, "Respiro en la tómbola", "simple", 0.3, 6807),
    (69, "Carrusel", "muelle_doble", 0.55, 6908),
    (70, "La taquilla", "puerta", 0.55, 7009),
    (71, "Tren de la bruja", "muelle", 0.6, 7110),
    (72, "La casa de los espejos", "espiral_doble", 0.6, 7211),
    (73, "Respiro con algodón de azúcar", "dos", 0.4, 7312),
    (74, "El látigo", "muelle_doble", 0.65, 7413),
    (75, "La ola", "dos_puertas", 0.65, 7514),
    (76, "Caída libre", "muelle", 0.7, 7615),
    (77, "Las dos norias", "doble_y_simple", 0.7, 7716),
    (78, "Sincronizados", "muelle_doble", 0.75, 7817),
    (79, "Casi en lo alto", "espiral", 0.75, 7918),
    (80, "Gran Tramo: la gran noria", "muelle_doble", 0.85, 8019),
]

PLAN_5 = [
    (82, "Andén uno", "interruptor", 0.3, 8201),
    (83, "El billete", "interruptor", 0.4, 8302),
    (84, "Vía muerta", "muelle", 0.45, 8403),
    (85, "El revisor", "interruptor", 0.45, 8504),
    (86, "Cambio de agujas", "numeradas", 0.5, 8605),
    (87, "Transbordo", "interruptor", 0.5, 8706),
    (88, "Respiro en la cantina", "simple", 0.3, 8807),
    (89, "El reloj de la estación", "espiral", 0.55, 8908),
    (90, "La barrera", "interruptor", 0.55, 9009),
    (91, "Expreso", "muelle_doble", 0.6, 9110),
    (92, "La consigna", "interruptor", 0.6, 9211),
    (93, "Respiro en la sala de espera", "dos", 0.4, 9312),
    (94, "Puertas automáticas", "dos_puertas", 0.65, 9413),
    (95, "Señales", "interruptor", 0.65, 9514),
    (96, "Cercanías", "espiral_doble", 0.7, 9615),
    (97, "Último aviso", "interruptor", 0.7, 9716),
    (98, "Doble vía", "doble_y_simple", 0.7, 9817),
    (99, "El jefe de estación", "interruptor", 0.75, 9918),
    (100, "Gran Tramo: el último tren", "interruptor", 0.85, 10019),
]

PLAN_6 = [
    (102, "Dos ruedas", "noria_doble", 0.35, 10201),
    (103, "La cadena de montaje", "noria", 0.4, 10302),
    (104, "Turno de mañana", "interruptor", 0.45, 10403),
    (105, "Las poleas", "noria_doble", 0.45, 10504),
    (106, "El almacén", "numeradas", 0.5, 10605),
    (107, "La prensa", "noria", 0.5, 10706),
    (108, "Respiro en el comedor", "simple", 0.3, 10807),
    (109, "Turno de tarde", "noria_doble", 0.55, 10908),
    (110, "La caldera", "espiral", 0.55, 11009),
    (111, "El montacargas", "muelle", 0.55, 11110),
    (112, "Las cintas", "noria_doble", 0.6, 11211),
    (113, "Respiro en el vestuario", "dos", 0.4, 11312),
    (114, "La sirena", "interruptor", 0.65, 11413),
    (115, "Control de calidad", "noria", 0.65, 11514),
    (116, "Horas extra", "espiral_doble", 0.7, 11615),
    (117, "El turno de noche", "noria_doble", 0.7, 11716),
    (118, "Expedición", "muelle_doble", 0.75, 11817),
    (119, "Cadena completa", "noria_doble", 0.75, 11918),
    (120, "Gran Tramo: la gran rueda", "noria_doble", 0.85, 12019),
]

PLAN_7 = [
    (122, "Pompas", "globo_doble", 0.35, 12201),
    (123, "El estanque", "globo", 0.4, 12302),
    (124, "Los aspersores", "interruptor", 0.45, 12403),
    (125, "Diente de león", "globo_doble", 0.45, 12504),
    (126, "El invernadero", "numeradas", 0.5, 12605),
    (127, "La cometa", "globo", 0.5, 12706),
    (128, "Respiro bajo el sauce", "simple", 0.3, 12807),
    (129, "El laberinto de setos", "globo_doble", 0.55, 12908),
    (130, "La fuente", "noria", 0.55, 13009),
    (131, "Las mariposas", "espiral", 0.55, 13110),
    (132, "El tobogán", "globo", 0.6, 13211),
    (133, "Respiro en el banco", "dos", 0.4, 13312),
    (134, "Los columpios", "muelle_doble", 0.65, 13413),
    (135, "Bandada", "globo_doble", 0.65, 13514),
    (136, "El reloj de sol", "espiral_doble", 0.7, 13615),
    (137, "Las dos glorietas", "noria_doble", 0.7, 13716),
    (138, "Fuegos artificiales", "globo_doble", 0.75, 13817),
    (139, "La verja", "interruptor", 0.75, 13918),
    (140, "Gran Tramo: el gran globo", "globo_doble", 0.85, 14019),
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
        if r is None:
            r = G.poner_dorada(nivel, tramos, 7919 * int(n["id"]), corto=True)
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


def ensenanza_4():
    # 61. El muelle: un muro de lado a lado; la cadena llega al muelle y sigue desde su salida.
    muelle = Muelle((50, 97), (50, 83), 6)
    n = Nivel(100, 160, (50, 150), [Campana("a", (50, 25))], muros=[((0.0, 90.0), (100.0, 90.0))], fichas=10_000,
              muelles=[muelle])
    s = [Tramo([(50, 150), (50, 97)]), Tramo([(50, 83), (50, 25)])]
    r = simular(n, s)
    assert r["exito"], r
    assert not simular(n, [Tramo([(50, 150), (50, 25)])])["exito"], "la recta tiene que chocar con el muro"
    n.marca, n.fichas = r["fichas_usadas"], r["fichas_usadas"] + 15
    return [{"id": 61, "titulo": "El muelle", "nivel": nivel_a_dict(n), "solucion": [tramo_a_dict(x) for x in s],
             "ayuda": "Un muro de lado a lado: llega al [b]muelle[/b] y sigue dibujando desde su salida, al otro lado.",
             "origen": "a mano"}]


def barrio_4() -> dict:
    generados = _generados(PLAN_4)
    generados[0]["ayuda"] = "Una rama rodea el muro por el hueco y la otra [b]salta con el muelle[/b]: el salto tarda lo justo para que lleguen a la vez."
    return {"version": 1, "barrio": 4, "nombre": "La Feria", "niveles": _con_dorada(ensenanza_4() + generados)}


def ensenanza_5():
    # 81. El interruptor: la cadena pisa la placa y, ya abierta, cruza la compuerta.
    muros, (a, b) = G.fila_con_puerta(90.0, 50.0, 16.0)
    n = Nivel(100, 160, (50, 150), [Campana("a", (50, 25))], muros=muros, fichas=10_000,
              interruptores=[Interruptor((50, 122), a, b)])
    s = [Tramo([(50, 150), (50, 25)])]
    r = simular(n, s)
    assert r["exito"], r
    sin = Nivel(100, 160, (50, 150), [Campana("a", (50, 25))], muros=muros, fichas=10_000,
                interruptores=[Interruptor((20, 122), a, b)])
    assert not simular(sin, s)["exito"], "sin pisar la placa, la compuerta tiene que estar cerrada"
    n.marca, n.fichas = r["fichas_usadas"], r["fichas_usadas"] + 15
    return [{"id": 81, "titulo": "El interruptor", "nivel": nivel_a_dict(n), "solucion": [tramo_a_dict(x) for x in s],
             "ayuda": "La [b]compuerta[/b] se abre cuando cae una ficha en su [b]placa[/b]: písala antes de cruzar.",
             "origen": "a mano"}]


def barrio_5() -> dict:
    generados = _generados(PLAN_5)
    generados[0]["ayuda"] = "La placa está a un lado: [b]abre una rama hasta ella[/b] y haz que la otra llegue a la compuerta después."
    return {"version": 1, "barrio": 5, "nombre": "La Estación", "niveles": _con_dorada(ensenanza_5() + generados)}


def ensenanza_6():
    # 101. La noria: un muro de lado a lado; la cadena entra en la noria y sale en su vuelta.
    n = Nivel(100, 160, (50, 150), [Campana("a", (50, 25))], muros=[((0.0, 90.0), (100.0, 90.0))], fichas=10_000,
              norias=[Noria((50, 97), (50, 83), 8, 0)])
    s = [Tramo([(50, 150), (50, 97)]), Tramo([(50, 83), (50, 25)])]
    r = simular(n, s)
    assert r["exito"], r
    n.marca, n.fichas = r["fichas_usadas"], r["fichas_usadas"] + 15
    return [{"id": 101, "titulo": "La noria", "nivel": nivel_a_dict(n), "solucion": [tramo_a_dict(x) for x in s],
             "ayuda": "La [b]noria[/b] recoge la cadena y la suelta al otro lado en su siguiente vuelta: mira cada cuánto gira.",
             "origen": "a mano"}]


def barrio_6() -> dict:
    generados = _generados(PLAN_6)
    generados[0]["ayuda"] = "Las dos ramas llegan a destiempo, pero las dos [b]norias[/b] giran igual y las sueltan a la vez."
    return {"version": 1, "barrio": 6, "nombre": "La Fábrica", "niveles": _con_dorada(ensenanza_6() + generados)}


def ensenanza_7():
    # 121. El globo: las fichas no llegan a la campana; el camino del globo, sí.
    regalo = [(50.0, 128.0), (50.0, 25.0)]
    n = Nivel(100, 160, (50, 150), [Campana("a", (50, 25))], fichas=10_000, globos=[Globo((50, 128), regalo)])
    s = [Tramo([(50, 150), (50, 128)])]
    r = simular(n, s)
    assert r["exito"], r
    n.marca, n.fichas = r["fichas_usadas"], r["fichas_usadas"] + 8
    assert not simular(Nivel(100, 160, (50, 150), [Campana("a", (50, 25))], fichas=n.fichas), [Tramo([(50, 150), (50, 25)])])["exito"]
    return [{"id": 121, "titulo": "El globo", "nivel": nivel_a_dict(n), "solucion": [tramo_a_dict(x) for x in s],
             "ayuda": "Toca el [b]globo[/b] con la cadena: revienta y su camino de fichas cae solo, sin gastar las tuyas.",
             "origen": "a mano"}]


def barrio_7() -> dict:
    generados = _generados(PLAN_7)
    generados[0]["ayuda"] = "Dos [b]globos[/b] con caminos de largo distinto: revienta antes el del camino largo para que lleguen a la vez."
    return {"version": 1, "barrio": 7, "nombre": "El Jardín", "niveles": _con_dorada(ensenanza_7() + generados)}


def archivos() -> dict:
    fmt = lambda d: json.dumps(d, ensure_ascii=False, indent=1) + "\n"
    return {"barrio_1.json": fmt(barrio_1()), "barrio_2.json": fmt(barrio_2()), "barrio_3.json": fmt(barrio_3()),
            "barrio_4.json": fmt(barrio_4()), "barrio_5.json": fmt(barrio_5()),
            "barrio_6.json": fmt(barrio_6()), "barrio_7.json": fmt(barrio_7())}


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
                  f"  puertas {len(n['nivel']['p'])}  espirales {len(n['nivel'].get('e', []))}  muelles {len(n['nivel'].get('ml', []))}  interruptores {len(n['nivel'].get('in', []))}  norias {len(n['nivel'].get('nr', []))}  {n['origen']}")


if __name__ == "__main__":
    main()
