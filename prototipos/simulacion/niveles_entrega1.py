"""Los 10 niveles hechos a mano de la entrega 1 (Fase 8) y sus soluciones de referencia.

Uso (desde esta carpeta):
    python -X utf8 niveles_entrega1.py           # valida y escribe datos/*.json
    python -X utf8 niveles_entrega1.py --comprobar   # solo valida; falla si los JSON no están al día

Cada nivel lleva:
- la **solución de referencia**: demuestra que el nivel tiene solución (LR-02) y fija la marca de
  fichas (★★). También es la pista que se dibuja «en fantasma»;
- uno o varios **intentos ingenuos** que deben fallar por el motivo indicado: comprueban que el
  nivel enseña lo que dice enseñar.

La entrega 1 es una muestra vertical, no el capítulo 1 definitivo: en 10 niveles recorre dibujar,
curvas, muros, fichas justas, bifurcador, campanas numeradas y la campana doble, que es lo que la
puerta 0 del lanzamiento tiene que validar con gente real.

Tablero lógico de 100 × 160 unidades (vertical, como un teléfono). Las coordenadas crecen hacia
abajo, igual que en la pantalla.
"""
from __future__ import annotations

import json
import math
import pathlib
import sys

from sim import PASO, Campana, Espiral, Interruptor, Muelle, Nivel, Puerta, Tramo, longitud, nivel_a_dict, repartir, simular

ANCHO, ALTO = 100, 160
DATOS = pathlib.Path(__file__).with_name("datos")
# Copia que carga el proyecto de Godot (res://datos/). Las dos se generan juntas.
DATOS_GODOT = pathlib.Path(__file__).resolve().parents[2] / "godot" / "datos"
DESTINOS = (DATOS, DATOS_GODOT)


# ---------------------------------------------------------------- ayudas de trazado

def suave(puntos, vueltas=3):
    """Redondea las esquinas (Chaikin) conservando los extremos: así el trazo no rompe por curva."""
    p = [tuple(map(float, q)) for q in puntos]
    for _ in range(vueltas):
        q = [p[0]]
        for a, b in zip(p, p[1:]):
            q.append((a[0] * .75 + b[0] * .25, a[1] * .75 + b[1] * .25))
            q.append((a[0] * .25 + b[0] * .75, a[1] * .25 + b[1] * .75))
        q.append(p[-1])
        p = q
    return [(round(x, 3), round(y, 3)) for x, y in p]


def con_curva(a, b, amplitud, n=24):
    """Trazo de a a b con una barriga lateral. Con amplitud positiva, la barriga queda a la derecha
    de quien va de a hacia b mirando la pantalla (las y crecen hacia abajo)."""
    dx, dy = b[0] - a[0], b[1] - a[1]
    d = math.hypot(dx, dy)
    nx, ny = -dy / d, dx / d
    return [(round(a[0] + dx * t + nx * amplitud * math.sin(math.pi * t), 3),
             round(a[1] + dy * t + ny * amplitud * math.sin(math.pi * t), 3)) for t in (k / n for k in range(n + 1))]


def igualar(a, b, objetivo, signo=1):
    """Busca la barriga que hace que el trazo de a a b mida `objetivo` (para la campana doble)."""
    lo, hi = 0.0, 60.0
    for _ in range(60):
        m = (lo + hi) / 2
        if longitud(con_curva(a, b, signo * m)) < objetivo:
            lo = m
        else:
            hi = m
    return con_curva(a, b, signo * (lo + hi) / 2)


def fin(tramo_puntos):
    return len(repartir(tramo_puntos)) - 1


# ---------------------------------------------------------------- los niveles

def niveles():
    lista = []

    def nuevo(id_, titulo, ayuda, pieza, nivel, solucion, margen, ingenuos=()):
        r = simular(nivel, solucion)
        nivel.marca = r["fichas_usadas"]
        nivel.fichas = nivel.marca + margen
        lista.append({"id": id_, "titulo": titulo, "ayuda": ayuda, "pieza_nueva": pieza,
                      "nivel": nivel, "solucion": solucion, "ingenuos": list(ingenuos)})

    # 1. Dibujar y empujar
    t = [Tramo([(50, 150), (50, 30)])]
    nuevo(1, "Primer empujón", "Arrastra el dedo desde el [b]botón verde[/b] hasta la campana y pulsa «¡A tumbar!».",
          "campana", Nivel(ANCHO, ALTO, (50, 150), [Campana("a", (50, 30))]), t, 15)

    # 2. Curvas suaves para esquivar un muro
    muro2 = ((30, 100), (100, 100))
    t = [Tramo(suave([(20, 150), (18, 95), (30, 68), (55, 45), (80, 30)]))]
    nuevo(2, "La curva", "Rodea el muro: las [b]curvas suaves[/b] aguantan, las cerradas rompen la cadena.", "muro",
          Nivel(ANCHO, ALTO, (20, 150), [Campana("a", (80, 30))], muros=[muro2]), t, 12,
          ingenuos=[("recto contra el muro", [Tramo([(20, 150), (80, 30)])], "choca con un muro"),
                    ("esquina en ángulo recto", [Tramo([(20, 150), (20, 30), (80, 30)])], "curva demasiado cerrada")])

    # 3. Fichas justas
    muro3 = ((25, 80), (75, 80))
    t = [Tramo(suave([(50, 150), (45, 115), (20, 92), (18, 70), (35, 45), (50, 22)]))]
    nuevo(3, "Fichas justas", "Llega a la campana con [b]pocas fichas[/b]: busca el camino corto.", None,
          Nivel(ANCHO, ALTO, (50, 150), [Campana("a", (50, 22))], muros=[muro3]), t, 3,
          ingenuos=[("rodeo muy largo", [Tramo(suave([(50, 150), (85, 135), (92, 95), (92, 60), (80, 30), (50, 22)]))], "faltan fichas")])

    # 4. Bifurcador: dos campanas a la vez
    tronco = [(50, 150), (50, 105)]
    f = fin(tronco)
    t = [Tramo(tronco),
         Tramo(suave([(50, 105), (36, 75), (22, 32)]), 0, f),
         Tramo(suave([(50, 105), (64, 75), (78, 32)]), 0, f)]
    nuevo(4, "Dos caminos", "Haz sonar [b]las dos campanas[/b]: arrastra desde una ficha puesta para abrir otra rama.", "bifurcador",
          Nivel(ANCHO, ALTO, (50, 150), [Campana("a", (22, 32)), Campana("b", (78, 32))]), t, 12)

    # 5. Respiro: eslalon largo y satisfactorio
    muros5 = [((0, 115), (60, 115)), ((40, 75), (100, 75))]
    t = [Tramo(suave([(80, 150), (78, 122), (62, 102), (35, 92), (24, 72), (30, 48), (50, 28)]))]
    nuevo(5, "Eslalon", "Un respiro: baja por el [b]eslalon[/b] y disfruta de la caída.", None,
          Nivel(ANCHO, ALTO, (80, 150), [Campana("a", (50, 28))], muros=muros5), t, 20)

    # 6. Campanas numeradas: el orden importa
    c6 = [Campana("1", (72, 30), "numerada", 1), Campana("2", (28, 100), "numerada", 2)]
    t = [Tramo(suave([(50, 150), (62, 105), (72, 55), (72, 30), (60, 18), (42, 25), (32, 50), (28, 75), (28, 100)]))]
    nuevo(6, "Primero la 1", "Las campanas numeradas suenan [b]en orden[/b]: la 1 antes que la 2.", "campanas numeradas",
          Nivel(ANCHO, ALTO, (50, 150), c6), t, 10,
          ingenuos=[("la cercana primero", [Tramo(suave([(50, 150), (28, 100), (45, 60), (72, 30)]))], "orden")])

    # 7. Campana doble simétrica
    tronco = [(50, 150), (50, 110)]
    f = fin(tronco)
    t = [Tramo(tronco),
         Tramo(suave([(50, 110), (35, 80), (35, 50), (50, 25)]), 0, f),
         Tramo(suave([(50, 110), (65, 80), (65, 50), (50, 25)]), 0, f)]
    nuevo(7, "La campana doble", "Haz sonar la [b]campana doble[/b]: las dos ramas tienen que llegar a la vez.", "campana doble",
          Nivel(ANCHO, ALTO, (50, 150), [Campana("d", (50, 25), "doble")]), t, 10,
          ingenuos=[("un solo camino", [Tramo([(50, 150), (50, 25)])], "solo llegó una rama")])

    # 8. Campana doble desplazada: el camino corto tiene que esperar
    tronco = [(50, 150), (50, 108)]
    f = fin(tronco)
    a, d = (50, 108), (74, 30)
    larga = suave([a, (30, 80), (32, 50), (50, 32), (74, 30)])
    corta = igualar(a, d, longitud(larga), signo=1)
    t = [Tramo(tronco), Tramo(larga, 0, f), Tramo(corta, 0, f)]
    nuevo(8, "El que espera", "La [b]longitud es el tiempo[/b]: alarga el camino corto para que las dos ramas lleguen juntas.", None,
          Nivel(ANCHO, ALTO, (50, 150), [Campana("d", (74, 30), "doble")]), t, 8,
          ingenuos=[("rama corta recta", [Tramo(tronco), Tramo(larga, 0, f), Tramo([a, d], 0, f)], "no llegaron a la vez")])

    # 9. Una sola salida: las dos ramas pasan por el mismo hueco
    muro9 = ((30, 62), (100, 62))
    tronco = suave([(50, 150), (30, 112), (17, 78), (20, 50)])
    f = fin(tronco)
    a, d = (20, 50), (64, 24)
    directa = suave([a, (40, 32), (64, 24)])
    rodeo = igualar(a, d, longitud(directa) + 16, signo=1)
    directa = igualar(a, d, longitud(rodeo), signo=-1)
    t = [Tramo(tronco), Tramo(directa, 0, f), Tramo(rodeo, 0, f)]
    nuevo(9, "Una sola salida", "Solo hay un hueco: pásalo y [b]divide después[/b] hacia la campana doble.", None,
          Nivel(ANCHO, ALTO, (50, 150), [Campana("d", (64, 24), "doble")], muros=[muro9]), t, 6,
          ingenuos=[("recto contra el muro", [Tramo([(50, 150), (64, 24)])], "choca con un muro")])

    # 10. Gran Tramo del prototipo: una campana simple y una doble, con fichas ajustadas
    muro10 = ((45, 62), (65, 62))
    tronco = [(50, 150), (50, 106)]
    f = fin(tronco)
    a, d = (50, 106), (55, 24)
    izq = suave([a, (36, 80), (38, 48), (55, 24)])
    der = igualar(a, d, longitud(izq), signo=1)
    lado = suave([a, (32, 100), (14, 96)])
    t = [Tramo(tronco), Tramo(izq, 0, f), Tramo(der, 0, f), Tramo(lado, 0, f)]
    nuevo(10, "Gran Tramo: la plaza", "Haz sonar [b]la campana y la doble[/b] con pocas fichas de sobra.", None,
          Nivel(ANCHO, ALTO, (50, 150), [Campana("s", (14, 96)), Campana("d", (55, 24), "doble")], muros=[muro10]), t, 5,
          ingenuos=[("sin la campana del lado", [Tramo(tronco), Tramo(izq, 0, f), Tramo(der, 0, f)], "no llegó")])
    return lista


# ---------------------------------------------------------------- validación y exportación

def tramo_a_dict(t: Tramo):
    return {"puntos": [list(p) for p in t.puntos], "padre": t.padre, "desde": t.desde}


def casos_borde(lista):
    """Casos de la tolerancia de la campana doble sobre el nivel 7: una rama 1 o 2 tics más tarde.

    Devuelve (nombre, nivel, tramos, debe_sonar). Sin ellos, los casos compartidos no notarían
    un error en TOLERANCIA_DOBLE, porque en las soluciones de referencia las ramas llegan a la vez.
    """
    n7 = next(n for n in lista if n["id"] == 7)
    tronco, izq, der = n7["solucion"]
    a, d = tuple(der.puntos[0]), tuple(der.puntos[-1])
    casos = []
    for extra, debe in ((1, True), (2, False)):
        objetivo = longitud(der.puntos) + extra * PASO
        tarde = Tramo(igualar(a, d, objetivo, signo=1), der.padre, der.desde)
        casos.append((f"campana doble con una rama {extra} tic{'s' if extra > 1 else ''} más tarde",
                      n7["nivel"], [tronco, izq, tarde], debe))
    return casos


def casos_reglas():
    """Casos de reglas sueltas que los 10 niveles no cubren (puertas, redondeo, paradas).

    Devuelve (nombre, nivel, tramos). Sirven para que el port a Godot no pueda diferir en ellas.
    """
    recta = [Tramo([(10, 50), (110, 50)])]          # cruza x = 60 en el tic 10

    def con_puerta(fase):
        return Nivel(200, 100, (10, 50), [Campana("a", (110, 50))],
                     puertas=[Puerta((60, 0), (60, 100), periodo=20, abierta=5, fase=fase)], fichas=500)
    base = Nivel(200, 100, (10, 50), [Campana("a", (110, 50))], fichas=500)

    def con_espiral(fase, espirales):
        n = con_puerta(fase)
        n.espirales = espirales
        return n

    def doble(espirales):
        return Nivel(200, 100, (10, 50), [Campana("d", (60, 90), "doble")], fichas=500, espirales=espirales)
    def con_compuerta(interruptores, muro=False):
        return Nivel(200, 100, (10, 50), [Campana("a", (110, 50))], fichas=500, interruptores=interruptores,
                     muros=[((20, 0), (20, 100))] if muro else [])

    def con_muelle(salto, muro_antes=False, espiral=False):
        muros = [((60, 0), (60, 100))] + ([((40, 0), (40, 100))] if muro_antes else [])
        return Nivel(200, 100, (10, 50), [Campana("a", (110, 50))], muros=muros, fichas=500,
                     muelles=[Muelle((55, 50), (65, 50), salto)], espirales=[Espiral((90, 50), 5)] if espiral else [])
    horquilla = [Tramo([(10, 50), (60, 50)]), Tramo([(60, 50), (40, 70), (60, 90)], 0, 10),
                 Tramo([(60, 50), (80, 70), (60, 90)], 0, 10)]
    return [
        ("puerta abierta", con_puerta(8), recta),
        ("puerta cerrada", con_puerta(13), recta),
        # fase mayor que el tic: el módulo tiene que ser positivo, como en Python (posmod en GDScript)
        ("puerta con fase mayor que el tic", con_puerta(25), recta),
        # 12,5 unidades = 2,5 pasos: se redondea hacia arriba (4 fichas), igual en los dos lenguajes
        ("medio paso se redondea hacia arriba", Nivel(100, 100, (0, 50), [Campana("a", (12.5, 50))], fichas=10),
         [Tramo([(0, 50), (12.5, 50)])]),
        ("sale del tablero", Nivel(100, 100, (10, 50), [Campana("a", (90, 50))], fichas=500), [Tramo([(10, 50), (150, 50)])]),
        ("no empieza en el inicio", base, [Tramo([(40, 50), (110, 50)])]),
        ("bifurcador no válido", base, [Tramo([(10, 50), (110, 50)]), Tramo([(30, 50), (30, 90)], 0, 99)]),
        ("faltan fichas", Nivel(200, 100, (10, 50), [Campana("a", (110, 50))], fichas=5), recta),
        # La campana dorada es opcional: sin ella se supera igual; con una rama, también suena
        ("dorada sin sonar", Nivel(200, 100, (10, 50), [Campana("a", (110, 50)), Campana("oro", (60, 90), "dorada")],
                                   fichas=500), recta),
        ("dorada sonando", Nivel(200, 100, (10, 50), [Campana("a", (110, 50)), Campana("oro", (60, 90), "dorada")],
                                 fichas=500), recta + [Tramo([(60, 50), (60, 90)], 0, 10)]),
        ("solo la dorada no basta", Nivel(200, 100, (10, 50), [Campana("oro", (110, 50), "dorada")], fichas=500), recta),
        ("curva demasiado cerrada", Nivel(200, 200, (10, 100), [Campana("a", (10, 150))], fichas=500),
         [Tramo([(10, 100), (100, 100), (10, 150)])]),
        # Espiral de retardo: la recta cruza x = 60 en el tic 10 (puerta cerrada); pasando por una espiral
        # de 4 tics en x = 35, llega en el 14, con la puerta abierta
        ("espiral abre la puerta", con_espiral(13, [Espiral((35, 50), 4)]), recta),
        ("espiral fuera del camino", con_espiral(13, [Espiral((35, 80), 4)]), recta),
        ("espiral sobre el empujador no cuenta", con_espiral(13, [Espiral((10, 50), 4)]), recta),
        ("dos espirales se suman", con_espiral(15, [Espiral((25, 50), 2), Espiral((45, 50), 4)]), recta),
        ("espiral en una rama desincroniza la doble", doble([Espiral((80, 70), 3)]), horquilla),
        ("espiral de 1 tic cabe en la tolerancia de la doble", doble([Espiral((80, 70), 1)]), horquilla),
        ("espiral en el tronco retrasa las dos ramas por igual", doble([Espiral((35, 50), 5)]), horquilla),
        # Muelle: un muro de lado a lado en x = 60; la entrada está antes del muro y la salida, después
        ("muelle salta el muro", con_muelle(6), [Tramo([(10, 50), (55, 50)]), Tramo([(65, 50), (110, 50)])]),
        ("sin llegar a la entrada no sale nada", con_muelle(6), [Tramo([(10, 50), (40, 50)]), Tramo([(65, 50), (110, 50)])]),
        ("un tramo que no empieza en la salida", con_muelle(6), [Tramo([(10, 50), (55, 50)]), Tramo([(72, 50), (110, 50)])]),
        ("la entrada la toca una ficha que no cae", con_muelle(6, muro_antes=True),
         [Tramo([(10, 50), (55, 50)]), Tramo([(65, 50), (110, 50)])]),
        ("rama desde un tramo del muelle", Nivel(200, 100, (10, 50), [Campana("a", (110, 50)), Campana("b", (85, 85))],
                                                 muros=[((60, 0), (60, 100))], fichas=500,
                                                 muelles=[Muelle((55, 50), (65, 50), 4)]),
         [Tramo([(10, 50), (55, 50)]), Tramo([(65, 50), (110, 50)]), Tramo([(85, 50), (85, 85)], 1, 4)]),
        ("muelle y espiral se suman", con_muelle(3, espiral=True), [Tramo([(10, 50), (55, 50)]), Tramo([(65, 50), (110, 50)])]),
        # Interruptor: la compuerta en x = 60 se abre el tic siguiente a que caiga una ficha en la placa
        ("compuerta sin pisar el interruptor", con_compuerta([Interruptor((30, 80), (60, 0), (60, 100))]), recta),
        ("el tronco pisa el interruptor antes", con_compuerta([Interruptor((30, 50), (60, 0), (60, 100))]), recta),
        ("rama que llega antes al interruptor", con_compuerta([Interruptor((30, 70), (60, 0), (60, 100))]),
         recta + [Tramo([(30, 50), (30, 70)], 0, 4)]),
        ("rama que llega tarde al interruptor", con_compuerta([Interruptor((30, 80), (60, 0), (60, 100))]),
         recta + [Tramo([(30, 50), (30, 80)], 0, 4)]),
        ("una compuerta abierta deja pisar otro interruptor",
         con_compuerta([Interruptor((30, 50), (60, 0), (60, 100)), Interruptor((80, 50), (100, 0), (100, 100))]), recta),
        ("la placa la pisa una ficha que no cae", con_compuerta([Interruptor((30, 50), (60, 0), (60, 100))], muro=True), recta),
        ("rama de un bifurcador que no llegó a caer", Nivel(200, 100, (10, 50), [Campana("a", (110, 50))],
                                                            muros=[((40, 0), (40, 100))], fichas=500),
         [Tramo([(10, 50), (110, 50)]), Tramo([(60, 50), (60, 90)], 0, 10)]),
    ]


def validar(lista):
    errores = []
    for nombre, nivel, tramos, debe in casos_borde(lista):
        r = simular(nivel, tramos)
        if r["exito"] != debe:
            errores.append(f"caso de borde «{nombre}»: se esperaba éxito={debe}: {r}")
    for n in lista:
        r = simular(n["nivel"], n["solucion"])
        if not r["exito"]:
            errores.append(f"nivel {n['id']}: la solución de referencia falla: {r}")
        if r["fichas_usadas"] != n["nivel"].marca:
            errores.append(f"nivel {n['id']}: la marca no coincide")
        for c in n["nivel"].campanas:
            if not (8 <= c.pos[0] <= ANCHO - 8 and 8 <= c.pos[1] <= ALTO - 8):
                errores.append(f"nivel {n['id']}: campana {c.id} demasiado cerca del borde")
        for nombre, tramos, motivo in n["ingenuos"]:
            ri = simular(n["nivel"], tramos)
            texto = json.dumps(ri, ensure_ascii=False)
            if ri["exito"] or motivo not in texto:
                errores.append(f"nivel {n['id']}: el intento «{nombre}» debía fallar por «{motivo}»: {ri}")
    return errores


def exportar(lista):
    niveles_json = {"version": 1, "tablero": [ANCHO, ALTO], "niveles": [
        {"id": n["id"], "titulo": n["titulo"], "ayuda": n["ayuda"], "pieza_nueva": n["pieza_nueva"],
         "nivel": nivel_a_dict(n["nivel"]), "solucion": [tramo_a_dict(t) for t in n["solucion"]]}
        for n in lista]}
    casos = []
    for n in lista:
        casos.append({"nombre": f"nivel {n['id']}: solución de referencia", "nivel": nivel_a_dict(n["nivel"]),
                      "tramos": [tramo_a_dict(t) for t in n["solucion"]],
                      "esperado": simular(n["nivel"], n["solucion"])})
        for nombre, tramos, _ in n["ingenuos"]:
            casos.append({"nombre": f"nivel {n['id']}: {nombre}", "nivel": nivel_a_dict(n["nivel"]),
                          "tramos": [tramo_a_dict(t) for t in tramos], "esperado": simular(n["nivel"], tramos)})
    for nombre, nivel, tramos, _ in casos_borde(lista):
        casos.append({"nombre": f"borde: {nombre}", "nivel": nivel_a_dict(nivel),
                      "tramos": [tramo_a_dict(t) for t in tramos], "esperado": simular(nivel, tramos)})
    for nombre, nivel, tramos in casos_reglas():
        casos.append({"nombre": f"regla: {nombre}", "nivel": nivel_a_dict(nivel),
                      "tramos": [tramo_a_dict(t) for t in tramos], "esperado": simular(nivel, tramos)})
    fmt = lambda d: json.dumps(d, ensure_ascii=False, indent=1) + "\n"
    return {"niveles_entrega1.json": fmt(niveles_json),
            "casos_compartidos.json": fmt({"version": 1,
                                           "nota": "Casos que la versión de Godot debe reproducir exactamente. Generados por niveles_entrega1.py.",
                                           "casos": casos}),
            "codigos_taller.json": fmt(codigos_taller(lista))}


def _codigo_crudo(d) -> str:
    """Código hecho a mano a partir de cualquier dato (para fabricar códigos malos a propósito)."""
    import base64
    import zlib
    return "DING1-" + base64.urlsafe_b64encode(zlib.compress(json.dumps(d).encode(), 9)).decode().rstrip("=")


def codigos_taller(lista):
    """Códigos del Taller que Godot tiene que abrir igual que Python: los 10 niveles con su solución
    (válidos) y una colección de códigos rotos o manipulados (que hay que rechazar)."""
    import base64
    import zlib
    from sim import codigo_taller
    validos = [{"nombre": f"nivel {n['id']}", "codigo": codigo_taller(n["nivel"], n["solucion"]),
                "nivel": nivel_a_dict(n["nivel"]), "tramos_solucion": len(n["solucion"])} for n in lista]
    base = nivel_a_dict(lista[0]["nivel"])
    malos = {
        "sin prefijo": "hola",
        "prefijo de otra versión": "DING2-" + validos[0]["codigo"][6:],
        "caracteres raros": "DING1-!!!!",
        "no es zlib": "DING1-" + base64.urlsafe_b64encode(b"no es zlib").decode(),
        "bomba de descompresión": "DING1-" + base64.urlsafe_b64encode(zlib.compress(b" " * 5_000_000, 9)).decode().rstrip("="),
        "no es json": "DING1-" + base64.urlsafe_b64encode(zlib.compress(b"{esto no", 9)).decode().rstrip("="),
        "no es un objeto": _codigo_crudo([1, 2, 3]),
        "fuera del tablero": _codigo_crudo({**base, "i": [500, 150]}),
        "sin campanas": _codigo_crudo({**base, "c": []}),
        "demasiadas campanas": _codigo_crudo({**base, "c": [[str(k), [50, 20], "simple", 0] for k in range(7)]}),
        "tipo de campana raro": _codigo_crudo({**base, "c": [["a", [50, 20], "bomba", 0]]}),
        "numeradas sin el 1": _codigo_crudo({**base, "c": [["a", [50, 20], "numerada", 2]]}),
        "booleano como número": _codigo_crudo({**base, "f": True}),
        "demasiados muros": _codigo_crudo({**base, "mu": [[[1, 1], [2, 2]]] * 13}),
        "otro tablero": _codigo_crudo({**base, "w": 1000}),
        "solución que no llega": _codigo_crudo({**base, "s": [[[[50, 150], [50, 100]], None, 0]]}),
    }
    return {"version": 1, "nota": "Generado por niveles_entrega1.py. Godot debe abrir los válidos y rechazar los malos.",
            "validos": validos, "malos": [{"nombre": k, "codigo": v} for k, v in malos.items()]}


def main():
    lista = niveles()
    errores = validar(lista)
    for e in errores:
        print("ERROR", e)
    archivos = exportar(lista)
    if "--comprobar" in sys.argv:
        desfasados = [str(d / k) for d in DESTINOS for k, v in archivos.items()
                      if not (d / k).exists() or (d / k).read_text(encoding="utf-8") != v]
        for k in desfasados:
            print("DESFASADO", k, "(ejecuta niveles_entrega1.py)")
        sys.exit(1 if errores or desfasados else 0)
    if errores:
        sys.exit(1)
    for d in DESTINOS:
        d.mkdir(parents=True, exist_ok=True)
        for k, v in archivos.items():
            (d / k).write_text(v, encoding="utf-8")
    for n in lista:
        nv = n["nivel"]
        print(f"{n['id']:>2}. {n['titulo']:<22} marca {nv.marca:>3}  fichas {nv.fichas:>3}  ramas {len(n['solucion'])}  intentos que fallan {len(n['ingenuos'])}")


if __name__ == "__main__":
    main()
