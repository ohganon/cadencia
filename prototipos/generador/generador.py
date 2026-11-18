"""Generador de niveles «por construcción» (Fase 4, sección 5.3): primero la solución, luego el problema.

Uso (desde esta carpeta):
    python -X utf8 generador.py --muestra 12          # genera y describe 12 niveles
    python -X utf8 generador.py --calendario 365      # escribe la Caída del Día de un año

Pasos, como en el diseño:
1. Topología según el tipo de nivel (simple, dos campanas, numeradas, doble, doble y simple).
2. Trazado de la solución con curvas suaves dentro del tablero.
3. Tiempos: se simula la solución (sim.py) y se colocan los objetivos donde llega de verdad.
4. Restricciones derivadas de esos tiempos: el número de cada campana numerada es su orden real de
   llegada; la campana doble se pone donde dos ramas llegan a la vez.
5. Obstáculos fuera del corredor de la solución, para cortar los atajos obvios.
6. Fichas = marca de la solución + margen según la dificultad pedida.
7. Validación: la solución funciona (por construcción) y un «solucionador perezoso» prueba los
   atajos típicos de un jugador (línea recta, un solo codo, horquilla simétrica). Si un atajo
   recto funciona, el nivel se descarta; los demás atajos cuentan para la dificultad.
8. Dificultad prevista (0–1) a partir de restricciones, margen, ramas y atajos que funcionan. Se
   calibrará con datos reales (Fase 9).

Todo es determinista: la misma semilla da siempre el mismo nivel.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import pathlib
import random
import sys
from dataclasses import dataclass, field

AQUI = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(AQUI.parent / "simulacion"))

import sim  # noqa: E402
from sim import Campana, Espiral, Nivel, Tramo, longitud, nivel_a_dict, repartir, simular  # noqa: E402
from niveles_entrega1 import con_curva, igualar, suave, tramo_a_dict  # noqa: E402

ANCHO, ALTO = 100, 160
BORDE = 9.0                 # margen con el borde del tablero
HOLGURA = 4.5               # distancia mínima entre un muro y la solución
TIPOS = ("simple", "dos", "numeradas", "doble", "doble_y_simple")


@dataclass
class Generado:
    nivel: Nivel
    solucion: list
    tipo: str
    semilla: int
    dificultad: float
    atajos: int                     # atajos del solucionador perezoso que funcionan
    info: dict = field(default_factory=dict)


# ---------------------------------------------------------------- utilidades

def _dentro(p, margen=BORDE):
    return margen <= p[0] <= ANCHO - margen and margen <= p[1] <= ALTO - margen


def _camino(rnd, a, b, curvas=1, desvio=18.0):
    """Trazo suave de a a b con `curvas` puntos intermedios desplazados a un lado u otro."""
    puntos = [a]
    for k in range(1, curvas + 1):
        t = k / (curvas + 1)
        dx, dy = b[0] - a[0], b[1] - a[1]
        d = math.hypot(dx, dy) or 1.0
        nx, ny = -dy / d, dx / d
        off = rnd.uniform(-desvio, desvio)
        puntos.append((a[0] + dx * t + nx * off, a[1] + dy * t + ny * off))
    puntos.append(b)
    return suave(puntos, 3)


def _segmentos(tramos):
    for t in tramos:
        for i in range(1, len(t.puntos)):
            yield t.puntos[i - 1], t.puntos[i]


def _distancia_segmento(p, a, b):
    ax, ay = a
    bx, by = b
    dx, dy = bx - ax, by - ay
    l2 = dx * dx + dy * dy
    t = 0.0 if l2 == 0 else max(0.0, min(1.0, ((p[0] - ax) * dx + (p[1] - ay) * dy) / l2))
    return math.hypot(p[0] - (ax + t * dx), p[1] - (ay + t * dy))


def _muro_libre(muro, tramos, campanas):
    """El muro no cruza la solución, deja holgura y no toca ninguna campana."""
    a, b = muro
    if not (_dentro(a, 2) and _dentro(b, 2)):
        return False
    for s in _segmentos(tramos):
        if sim._cruza(a, b, s[0], s[1]):
            return False
    for t in tramos:
        for f in repartir(t.puntos):
            if _distancia_segmento(f, a, b) < HOLGURA:
                return False
    return all(_distancia_segmento(c.pos, a, b) > sim.RADIO_CAMPANA + 3 for c in campanas)


def _muro_cortando(rnd, desde, hasta, tramos, campanas, intentos=40):
    """Busca un muro perpendicular a la línea recta desde → hasta que no toque la solución."""
    dx, dy = hasta[0] - desde[0], hasta[1] - desde[1]
    d = math.hypot(dx, dy) or 1.0
    nx, ny = -dy / d, dx / d
    for _ in range(intentos):
        t = rnd.uniform(0.3, 0.7)
        c = (desde[0] + dx * t, desde[1] + dy * t)
        largo = rnd.uniform(14, 34)
        sesgo = rnd.uniform(-0.5, 0.5) * largo
        a = (c[0] + nx * (-largo / 2 + sesgo), c[1] + ny * (-largo / 2 + sesgo))
        b = (c[0] + nx * (largo / 2 + sesgo), c[1] + ny * (largo / 2 + sesgo))
        muro = (tuple(round(v, 2) for v in a), tuple(round(v, 2) for v in b))
        if _muro_libre(muro, tramos, campanas):
            return muro
    return None


SEPARACION_MUROS = 7.0      # dos muros más cerca que esto parecen uno roto


def _separados(m, o):
    """Dos muros no se cruzan y guardan una separación mínima entre sí."""
    if sim._cruza(m[0], m[1], o[0], o[1]):
        return False
    d = min(_distancia_segmento(m[0], *o), _distancia_segmento(m[1], *o),
            _distancia_segmento(o[0], *m), _distancia_segmento(o[1], *m))
    return d >= SEPARACION_MUROS


def _llegada(tramos, idx, objetivo):
    """Tic en que la rama `idx` de la solución llega a `objetivo` (según la simulación)."""
    tics, fichas = [], []
    for i, t in enumerate(tramos):
        f = repartir(t.puntos)
        base = -1 if t.padre is None else tics[t.padre][t.desde]
        tics.append([base + 1 + j for j in range(len(f))])
        fichas.append(f)
    for j, p in enumerate(fichas[idx]):
        if math.dist(p, objetivo) <= sim.RADIO_CAMPANA:
            return tics[idx][j]
    return None


# ---------------------------------------------------------------- topologías

def _simple(rnd):
    inicio = (rnd.uniform(15, 85), rnd.uniform(140, 150))
    campana = (rnd.uniform(15, 85), rnd.uniform(18, 45))
    tr = [Tramo(_camino(rnd, inicio, campana, curvas=rnd.choice([1, 2])))]
    return inicio, [Campana("a", campana)], tr


def _dos(rnd):
    inicio = (rnd.uniform(35, 65), rnd.uniform(140, 150))
    fork = (inicio[0] + rnd.uniform(-10, 10), rnd.uniform(95, 118))
    izq = (rnd.uniform(12, 35), rnd.uniform(18, 60))
    der = (rnd.uniform(65, 88), rnd.uniform(18, 60))
    tronco = _camino(rnd, inicio, fork, curvas=1, desvio=8)
    f = len(repartir(tronco)) - 1
    tr = [Tramo(tronco), Tramo(_camino(rnd, fork, izq, 1, 12), 0, f), Tramo(_camino(rnd, fork, der, 1, 12), 0, f)]
    return inicio, [Campana("a", izq), Campana("b", der)], tr


def _numeradas(rnd):
    """Un camino que pasa primero por la campana lejana y vuelve a la cercana (el orden engaña)."""
    inicio = (rnd.uniform(25, 75), rnd.uniform(140, 150))
    lado = rnd.choice([-1, 1])
    lejana = (50 + lado * rnd.uniform(15, 30), rnd.uniform(20, 40))
    cercana = (50 - lado * rnd.uniform(15, 30), rnd.uniform(80, 110))
    giro = (lejana[0] - lado * 12, lejana[1] - 8)
    puntos = suave([inicio, ((inicio[0] + lejana[0]) / 2 + lado * 6, 95), lejana, giro,
                    ((lejana[0] + cercana[0]) / 2, (lejana[1] + cercana[1]) / 2 - 6), cercana], 3)
    tr = [Tramo(puntos)]
    t1 = _llegada(tr, 0, lejana)
    t2 = _llegada(tr, 0, cercana)
    if t1 is None or t2 is None or t1 == t2:
        return None
    orden = sorted([(t1, lejana), (t2, cercana)])
    campanas = [Campana(str(k + 1), p, "numerada", k + 1) for k, (_, p) in enumerate(orden)]
    return inicio, campanas, tr


def _ruta_lateral(fork, d, lado, ancho, empuje=0.0):
    """Rama que sale del bifurcador, sube por un lado y entra en la campana desde ese lado."""
    medio = (fork[0] + lado * (ancho * 0.6 + empuje), (fork[1] + d[1]) / 2 + 6)
    entrada = (d[0] + lado * ancho, d[1] + 4)
    return suave([fork, medio, entrada, d], 3)


def _igualar_lado(fork, d, lado, ancho, objetivo):
    """Empuja hacia fuera el tramo medio de la rama hasta que mida `objetivo` (la longitud es el tiempo)."""
    lo, hi = 0.0, 45.0
    for _ in range(50):
        m = (lo + hi) / 2
        if longitud(_ruta_lateral(fork, d, lado, ancho, m)) < objetivo:
            lo = m
        else:
            hi = m
    return _ruta_lateral(fork, d, lado, ancho, (lo + hi) / 2)


def _doble(rnd, extra=False):
    """Las dos ramas entran en la campana doble por los lados, con anchos distintos: la más corta se
    alarga hasta medir lo mismo. Así cabe un muro justo debajo de la campana, que impide la horquilla
    simétrica pegada a ella (el atajo obvio)."""
    inicio = (rnd.uniform(35, 65), rnd.uniform(140, 150))
    fork = (inicio[0] + rnd.uniform(-8, 8), rnd.uniform(100, 118))
    d = (rnd.uniform(32, 68), rnd.uniform(22, 36))
    tronco = _camino(rnd, inicio, fork, curvas=1, desvio=6)
    f = len(repartir(tronco)) - 1
    anchos = {-1: rnd.uniform(12, 24), 1: rnd.uniform(12, 24)}
    izq = _ruta_lateral(fork, d, -1, anchos[-1])
    der = _ruta_lateral(fork, d, 1, anchos[1])
    if longitud(izq) < longitud(der):
        izq = _igualar_lado(fork, d, -1, anchos[-1], longitud(der))
    else:
        der = _igualar_lado(fork, d, 1, anchos[1], longitud(izq))
    tr = [Tramo(tronco), Tramo(izq, 0, f), Tramo(der, 0, f)]
    campanas = [Campana("d", d, "doble")]
    if extra:
        s = (rnd.choice([rnd.uniform(12, 20), rnd.uniform(80, 88)]), rnd.uniform(75, 100))
        tr.append(Tramo(_camino(rnd, fork, s, 1, 8), 0, f))
        campanas.append(Campana("s", s))
    return inicio, campanas, tr


# ---------------------------------------------------------------- solucionador perezoso

def atajos(nivel: Nivel, limite=None):
    """Prueba soluciones «de jugador con prisa» y devuelve cuántas funcionan, por familia."""
    resultado = {"recto": 0, "codo": 0, "horquilla": 0}
    ini = nivel.inicio
    simples = [c for c in nivel.campanas if c.tipo != "doble"]
    dobles = [c for c in nivel.campanas if c.tipo == "doble"]
    numeradas = sorted([c for c in simples if c.tipo == "numerada"], key=lambda c: c.numero)
    libres = [c for c in simples if c.tipo == "simple"]

    def prueba(tramos, familia):
        r = simular(nivel, tramos)
        if r["exito"]:
            resultado[familia] += 1
        return r["exito"]

    if nivel.puertas and not dobles:
        # Por los huecos de las puertas (del inicio hacia arriba): en línea recta y con rodeos
        huecos = sorted([((p.a[0] + p.b[0]) / 2, (p.a[1] + p.b[1]) / 2) for p in nivel.puertas], key=lambda h: -h[1])
        destino = [c.pos for c in numeradas + libres]
        recta = [ini] + huecos + destino
        prueba([Tramo(recta)], "recto")
        prueba([Tramo(suave(recta, 3))], "recto")
        paradas = [ini] + huecos + destino
        for off in (-28, -14, 14, 28):
            for k in range(1, len(paradas)):
                ruta = list(paradas)
                a, b = paradas[k - 1], paradas[k]
                medio = ((a[0] + b[0]) / 2 + off, (a[1] + b[1]) / 2)
                ruta.insert(k, medio)
                prueba([Tramo(suave(ruta, 3))], "codo")
        return resultado
    if not dobles:
        # Un solo trazo que visita las campanas (numeradas en su orden; simples de cerca a lejos)
        visita = numeradas + sorted(libres, key=lambda c: math.dist(ini, c.pos))
        recta = [ini] + [c.pos for c in visita]
        prueba([Tramo(recta)], "recto")
        prueba([Tramo(suave(recta, 3))], "recto")
        for vx in range(15, 90, 15):
            for vy in range(25, 145, 20):
                prueba([Tramo(suave([ini, (vx, vy)] + [c.pos for c in visita], 3))], "codo")
        if len(libres) == 2:          # dos ramas rectas desde un punto
            for fy in range(60, 141, 20):
                tronco = [ini, (ini[0], fy)]
                f = len(repartir(tronco)) - 1
                prueba([Tramo(tronco)] + [Tramo([(ini[0], fy), c.pos], 0, f) for c in libres], "codo")
    else:
        d = dobles[0]
        otras = libres
        for fy in range(int(d.pos[1]) + 12, 146, 8):
            for fx in (d.pos[0] - 8, d.pos[0], d.pos[0] + 8):
                for ancho in (6, 12, 20):
                    for via in (None, (fx, (ini[1] + fy) / 2)):
                        tronco = [ini, (fx, fy)] if via is None else suave([ini, via, (fx, fy)], 2)
                        f = len(repartir(tronco)) - 1
                        medio = (fy + d.pos[1]) / 2
                        a = Tramo(suave([(fx, fy), (fx - ancho, medio), d.pos], 2), 0, f)
                        b = Tramo(suave([(fx, fy), (fx + ancho, medio), d.pos], 2), 0, f)
                        extra = [Tramo([(fx, fy), c.pos], 0, f) for c in otras]
                        prueba([Tramo(tronco), a, b] + extra, "horquilla")
    return resultado


# ---------------------------------------------------------------- campana dorada

def poner_dorada(nivel: Nivel, solucion: list, semilla: int, intentos=300):
    """Añade la campana dorada (opcional, tercera estrella) a un nivel ya resuelto.

    Sale una rama nueva de una ficha de la solución hacia un sitio alejado del camino principal: así
    hay que ir a por ella a propósito. La rama no puede pararse (muro, puerta, borde) ni tocar otra
    campana, y el camino principal no puede hacerla sonar de paso. La marca incluye esa rama, así que
    las tres estrellas se consiguen con la solución de referencia; el margen de fichas se conserva.
    Devuelve (nivel nuevo, solución nueva) o None si no encuentra un sitio.
    """
    rnd = random.Random(semilla)
    margen = nivel.fichas - nivel.marca
    fichas = [repartir(t.puntos) for t in solucion]
    todas = [p for f in fichas for p in f]
    for _ in range(intentos):
        i = rnd.randrange(len(solucion))
        if len(fichas[i]) < 8:
            continue
        j = rnd.randrange(3, len(fichas[i]) - 3)
        base = fichas[i][j]
        ang = rnd.uniform(0, 2 * math.pi)
        largo = rnd.uniform(14, 28)
        destino = (round(base[0] + math.cos(ang) * largo, 2), round(base[1] + math.sin(ang) * largo, 2))
        if not _dentro(destino, 9):
            continue
        if min(math.dist(destino, p) for p in todas) < sim.RADIO_CAMPANA + 5:
            continue
        if any(math.dist(destino, c.pos) < 2 * sim.RADIO_CAMPANA + 3 for c in nivel.campanas):
            continue
        if any(math.dist(destino, e.pos) < sim.RADIO_CAMPANA + sim.RADIO_ESPIRAL + 2 for e in nivel.espirales):
            continue
        # Ni encima de un muro ni de una puerta: tiene que verse limpia
        segmentos = list(nivel.muros) + [(p.a, p.b) for p in nivel.puertas]
        if any(_distancia_segmento(destino, a, b) < sim.RADIO_CAMPANA + 2 for a, b in segmentos):
            continue
        rama = Tramo([(round(base[0], 3), round(base[1], 3)), destino], i, j)
        campanas = nivel.campanas + [Campana("oro", destino, "dorada")]
        nuevo = Nivel(nivel.ancho, nivel.alto, nivel.inicio, campanas, nivel.muros, nivel.puertas, fichas=10_000,
                      espirales=nivel.espirales)
        tramos = solucion + [rama]
        r = simular(nuevo, tramos)
        if not r["exito"] or r["parada"] is not None or r["campanas"]["oro"] is None:
            continue
        # Las demás campanas tienen que sonar igual que sin la rama (no altera el nivel)
        antes = simular(Nivel(nivel.ancho, nivel.alto, nivel.inicio, nivel.campanas, nivel.muros, nivel.puertas, fichas=10_000,
                              espirales=nivel.espirales), solucion)
        if any(r["campanas"][c.id] != antes["campanas"][c.id] for c in nivel.campanas):
            continue
        nuevo.marca = r["fichas_usadas"]
        nuevo.fichas = nuevo.marca + margen
        return nuevo, tramos
    return None


# ---------------------------------------------------------------- puertas de vaivén

TIPOS_PUERTA = ("puerta", "dos_puertas")
TIPOS_ESPIRAL = ("espiral", "espiral_doble")


def _tic_cruce(tramo_puntos, a, b):
    """Tic en que el tronco cruza el segmento a-b (la ficha j cae en el tic j), o None."""
    f = repartir(tramo_puntos)
    for j in range(1, len(f)):
        if sim._cruza(f[j - 1], f[j], a, b):
            return j
    return None


def fila_con_puerta(y, centro, ancho):
    """Una fila de muro de lado a lado del tablero con un hueco cerrado por una puerta."""
    a, b = (round(centro - ancho / 2, 2), y), (round(centro + ancho / 2, 2), y)
    return [((0.0, y), a), (b, (float(ANCHO), y))], (a, b)


def ritmo_para(rnd, tic_bueno, tics_malos, abierta):
    """Busca periodo y fase para que la puerta esté abierta en `tic_bueno` y cerrada en todos los
    `tics_malos` (los atajos). Devuelve (periodo, abierta, fase) o None."""
    opciones = []
    for periodo in range(max(abierta * 3, 10), 25):
        for desfase in range(abierta):
            fase = (tic_bueno - desfase) % periodo
            if all((t - fase) % periodo >= abierta for t in tics_malos):
                opciones.append((periodo, abierta, fase))
    return rnd.choice(opciones) if opciones else None


def _candidato_puertas(rnd, tipo, dificultad):
    """Nivel con una o dos filas de muro cerradas por puertas: hay que pasar por el hueco justo
    cuando la puerta está abierta. La solución da un rodeo; la línea recta llega a destiempo."""
    n = 1 if tipo == "puerta" else 2
    inicio = (round(rnd.uniform(25, 75), 2), round(rnd.uniform(142, 150), 2))
    campana = (round(rnd.uniform(18, 82), 2), round(rnd.uniform(18, 32), 2))
    filas_y = [round(rnd.uniform(70, 100), 2)] if n == 1 else [round(rnd.uniform(98, 115), 2), round(rnd.uniform(52, 68), 2)]
    huecos = [(round(rnd.uniform(28, 72), 2), y) for y in filas_y]
    ancho_hueco = rnd.uniform(16, 22)
    # Solución: pasa por el centro de cada hueco, con rodeos laterales entre medias
    puntos = [inicio]
    previo = inicio
    for h in huecos + [campana]:
        medio_y = (previo[1] + h[1]) / 2
        lado = rnd.choice([-1, 1])
        rodeo = rnd.uniform(14, 30)
        medio_x = min(ANCHO - 10, max(10, (previo[0] + h[0]) / 2 + lado * rodeo))
        puntos += [(medio_x, medio_y), (h[0], h[1] + 7) if h != campana else h]
        if h != campana:
            puntos.append((h[0], h[1] - 7))
        previo = h
    solucion = [Tramo([(round(x, 3), round(y, 3)) for x, y in suave(puntos, 3)])]
    if not all(_dentro(p, 3) for p in solucion[0].puntos):
        return None
    muros, puertas_seg = [], []
    for (cx, y) in huecos:
        m, p = fila_con_puerta(y, cx, ancho_hueco)
        muros += m
        puertas_seg.append(p)
    nivel = Nivel(ANCHO, ALTO, inicio, [Campana("a", campana)], muros=muros, fichas=10_000)
    if not simular(nivel, solucion)["exito"]:       # sin puertas, la solución pasa por los huecos
        return None
    # Ritmo de cada puerta: abierta para la solución, cerrada para la línea recta por los huecos
    recta = [inicio] + list(huecos) + [campana]
    abierta = 3 if dificultad >= 0.6 else (4 if dificultad >= 0.4 else 5)
    puertas = []
    for k, (a, b) in enumerate(puertas_seg):
        t_sol = _tic_cruce(solucion[0].puntos, a, b)
        t_recta = _tic_cruce(recta, a, b)
        t_suave = _tic_cruce(suave(recta, 3), a, b)
        if t_sol is None:
            return None
        malos = [t for t in (t_recta, t_suave) if t is not None]
        r = ritmo_para(rnd, t_sol, malos, abierta)
        if r is None and k > 0:
            r = ritmo_para(rnd, t_sol, [], abierta)   # basta con que el atajo falle en la primera puerta
        if r is None:
            return None
        puertas.append(sim.Puerta(a, b, *r))
    nivel.puertas = puertas
    r = simular(nivel, solucion)
    if not r["exito"]:
        return None
    marca = r["fichas_usadas"]
    margen = max(3, round(14 - dificultad * 10))
    nivel.marca, nivel.fichas = marca, marca + margen
    a = atajos(nivel)
    if a["recto"] > 0:
        return None
    g = Generado(nivel, solucion, tipo, 0, 0.0, a["codo"] + a["horquilla"], {"atajos": a, "margen": margen})
    g.dificultad = puntuar(g)
    return g


# ---------------------------------------------------------------- espirales de retardo

def _tics(nivel, tramos):
    """Tic de cada ficha de cada tramo, como en la simulación (con espirales)."""
    tics, fichas = [], []
    for t in tramos:
        f = repartir(t.puntos)
        base = -1 if t.padre is None else tics[t.padre][t.desde]
        tics.append(sim.tics_tramo(nivel, f, base))
        fichas.append(f)
    return tics, fichas


def _tic_cruce_espiral(nivel, puntos, a, b):
    tics, fichas = _tics(nivel, [Tramo(puntos)])
    for j in range(1, len(fichas[0])):
        if sim._cruza(fichas[0][j - 1], fichas[0][j], a, b):
            return tics[0][j]
    return None


def _candidato_espiral(rnd, dificultad):
    """Una fila de muro con puerta y una espiral a un lado del camino recto. La solución pasa por la
    espiral y llega al hueco cuando la puerta se abre; la recta (y el mismo rodeo sin espiral)
    llegan antes, con la puerta cerrada."""
    inicio = (round(rnd.uniform(30, 70), 2), round(rnd.uniform(142, 150), 2))
    campana = (round(rnd.uniform(18, 82), 2), round(rnd.uniform(18, 32), 2))
    y = round(rnd.uniform(72, 98), 2)
    hueco = (round(rnd.uniform(30, 70), 2), y)
    ancho_hueco = rnd.uniform(16, 22)
    medio_y = round((inicio[1] + y) / 2, 2)
    recto_x = inicio[0] + (hueco[0] - inicio[0]) * (inicio[1] - medio_y) / (inicio[1] - y)
    lado = rnd.choice([-1, 1])
    ex = round(min(85, max(15, recto_x + lado * rnd.uniform(13, 22))), 2)
    if abs(ex - recto_x) < 11:
        return None
    retardo = rnd.randint(4, 8)
    espiral = Espiral((ex, medio_y), retardo)
    puntos = suave([inicio, (ex, medio_y + 6), (ex, medio_y - 6), (hueco[0], y + 7), (hueco[0], y - 7), campana], 3)
    solucion = [Tramo([(round(a, 3), round(b, 3)) for a, b in puntos])]
    if not all(_dentro(q, 3) for q in solucion[0].puntos):
        return None
    muros, (pa, pb) = fila_con_puerta(y, hueco[0], ancho_hueco)
    nivel = Nivel(ANCHO, ALTO, inicio, [Campana("a", campana)], muros=muros, fichas=10_000, espirales=[espiral])
    tics, _ = _tics(nivel, solucion)
    if tics[0][-1] != len(tics[0]) - 1 + retardo:          # la solución tiene que pasar por la espiral
        return None
    if not simular(nivel, solucion)["exito"]:
        return None
    t_sol = _tic_cruce_espiral(nivel, solucion[0].puntos, pa, pb)
    recta = [inicio, hueco, campana]
    malos = [_tic_cruce_espiral(nivel, recta, pa, pb), _tic_cruce_espiral(nivel, suave(recta, 3), pa, pb),
             t_sol - retardo]
    abierta = 3 if dificultad >= 0.6 else 4
    ritmo = ritmo_para(rnd, t_sol, [m for m in malos if m is not None], abierta)
    if ritmo is None:
        return None
    nivel.puertas = [sim.Puerta(pa, pb, *ritmo)]
    r = simular(nivel, solucion)
    if not r["exito"]:
        return None
    marca = r["fichas_usadas"]
    margen = max(3, round(14 - dificultad * 10))
    nivel.marca, nivel.fichas = marca, marca + margen
    a = atajos(nivel)
    if a["recto"] > 0:
        return None
    g = Generado(nivel, solucion, "espiral", 0, 0.0, a["codo"] + a["horquilla"], {"atajos": a, "margen": margen})
    g.dificultad = puntuar(g)
    return g


def _doble_espiral(rnd):
    """Campana doble con ramas de largo distinto: una espiral en la corta la retrasa justo lo que
    le falta. Devuelve (inicio, campanas, tramos, espirales) o None."""
    inicio = (rnd.uniform(35, 65), rnd.uniform(140, 150))
    fork = (inicio[0] + rnd.uniform(-8, 8), rnd.uniform(100, 118))
    d = (rnd.uniform(32, 68), rnd.uniform(22, 36))
    tronco = _camino(rnd, inicio, fork, curvas=1, desvio=6)
    f = len(repartir(tronco)) - 1
    corto, largo = rnd.uniform(10, 14), rnd.uniform(26, 34)
    lados = [(-1, corto), (1, largo)] if rnd.random() < 0.5 else [(-1, largo), (1, corto)]
    ramas = {lado: _ruta_lateral(fork, d, lado, ancho, 0.0 if ancho == corto else rnd.uniform(6, 16)) for lado, ancho in lados}
    tr = [Tramo(tronco), Tramo(ramas[-1], 0, f), Tramo(ramas[1], 0, f)]
    t_izq, t_der = _llegada(tr, 1, d), _llegada(tr, 2, d)
    if t_izq is None or t_der is None:
        return None
    retardo = abs(t_izq - t_der)
    if not 3 <= retardo <= 10:
        return None
    k = 1 if t_izq < t_der else 2                       # la rama corta
    fichas = repartir(tr[k].puntos)
    j = round(len(fichas) * rnd.uniform(0.3, 0.5))
    pos = (round(fichas[j][0], 2), round(fichas[j][1], 2))
    # Que ni el tronco ni la otra rama pasen por la espiral, ni que esté pegada a la campana
    otros = repartir(tr[0].puntos) + repartir(tr[3 - k].puntos)
    if min(math.dist(pos, q) for q in otros) < sim.RADIO_ESPIRAL + 4 or math.dist(pos, d) < sim.RADIO_CAMPANA + 8:
        return None
    return inicio, [Campana("d", d, "doble")], tr, [Espiral(pos, retardo)]


# ---------------------------------------------------------------- generador

def _candidato(rnd, tipo, dificultad):
    """Un intento de nivel: topología, obstáculos y validación. Devuelve un Generado o None."""
    if tipo in TIPOS_PUERTA:
        return _candidato_puertas(rnd, tipo, dificultad)
    if tipo == "espiral":
        return _candidato_espiral(rnd, dificultad)
    espirales = []
    if tipo == "simple":
        base = _simple(rnd)
    elif tipo == "dos":
        base = _dos(rnd)
    elif tipo == "numeradas":
        base = _numeradas(rnd)
    elif tipo == "doble":
        base = _doble(rnd)
    elif tipo == "espiral_doble":
        base = _doble_espiral(rnd)
        if base is not None:
            base, espirales = base[:3], base[3]
    else:
        base = _doble(rnd, extra=True)
    if base is None:
        return None
    inicio, campanas, tramos = base
    nivel = Nivel(ANCHO, ALTO, (round(inicio[0], 2), round(inicio[1], 2)),
                  [Campana(c.id, (round(c.pos[0], 2), round(c.pos[1], 2)), c.tipo, c.numero) for c in campanas],
                  fichas=10_000, espirales=espirales)
    tramos = [Tramo([(round(x, 3), round(y, 3)) for x, y in t.puntos], t.padre, t.desde) for t in tramos]
    if not all(_dentro(p, 3) for t in tramos for p in t.puntos):
        return None
    r = simular(nivel, tramos)
    if not r["exito"] or r["parada"] is not None:
        return None
    muros = []
    if nivel.campanas[0].tipo == "doble":
        # Muro justo debajo de la campana doble: corta la horquilla simétrica pegada a ella
        d = nivel.campanas[0].pos
        for _ in range(40):
            ancho = rnd.uniform(14, 26)
            y = d[1] + rnd.uniform(9, 15)
            x = d[0] + rnd.uniform(-3, 3)
            m = ((round(x - ancho / 2, 2), round(y, 2)), (round(x + ancho / 2, 2), round(y, 2)))
            if _muro_libre(m, tramos, nivel.campanas):
                muros.append(m)
                break
        else:
            return None
    # Muros que cortan la línea recta hacia cada objetivo; más muros cuanto más difícil
    n_muros = len(muros) + 1 + round(dificultad * 2)
    for k in range(6):
        if len(muros) >= n_muros:
            break
        c = nivel.campanas[k % len(nivel.campanas)]
        desde = nivel.inicio if c.tipo != "doble" else tramos[0].puntos[-1]
        m = _muro_cortando(rnd, desde, c.pos, tramos + [Tramo(list(mm)) for mm in muros], nivel.campanas)
        if m and all(_separados(m, o) for o in muros):
            muros.append(m)
    nivel.muros = muros
    r = simular(nivel, tramos)
    if not r["exito"]:
        return None
    marca = r["fichas_usadas"]
    margen = max(2, round(14 - dificultad * 11))
    nivel.marca, nivel.fichas = marca, marca + margen
    a = atajos(nivel)
    if a["recto"] > 0:
        return None                   # se resuelve con una línea recta: demasiado fácil
    if espirales:
        # Sin la espiral la solución tiene que fallar: si no, la espiral sobra
        sin = Nivel(nivel.ancho, nivel.alto, nivel.inicio, nivel.campanas, nivel.muros, nivel.puertas, fichas=10_000)
        if simular(sin, tramos)["exito"]:
            return None
    g = Generado(nivel, tramos, tipo, 0, 0.0, a["codo"] + a["horquilla"], {"atajos": a, "margen": margen})
    g.dificultad = puntuar(g)
    return g


def generar(semilla: int, tipo: str | None = None, dificultad: float = 0.5, candidatos=6, intentos=80):
    """Genera un nivel válido a partir de la semilla: crea varios candidatos y se queda con el de
    dificultad prevista más cercana a la pedida. Devuelve un Generado o None."""
    rnd = random.Random(semilla)
    tipo = tipo or rnd.choice(TIPOS)
    validos = []
    for _ in range(intentos):
        g = _candidato(rnd, tipo, dificultad)
        if g is not None:
            validos.append(g)
            if len(validos) >= candidatos:
                break
    if not validos:
        return None
    mejor = min(validos, key=lambda g: (abs(g.dificultad - dificultad), g.atajos))
    mejor.semilla = semilla
    return mejor


def puntuar(g: Generado) -> float:
    """Dificultad prevista entre 0 y 1. Pesos razonables, sin datos todavía (se calibran en la Fase 9)."""
    restricciones = sum(2 if c.tipo == "doble" else (1.5 if c.tipo == "numerada" else 1) for c in g.nivel.campanas)
    restricciones += 1.5 * len(g.nivel.puertas)       # cada puerta obliga a llegar en su momento
    restricciones += 1.0 * len(g.nivel.espirales)     # hay que ver que la espiral es la clave
    ramas = len(g.solucion)
    margen = g.info["margen"]
    p = 0.12 * restricciones + 0.06 * ramas + 0.05 * len(g.nivel.muros) + 0.02 * (14 - margen)
    p -= 0.04 * min(g.atajos, 10)
    return round(max(0.0, min(1.0, p)), 3)


def a_dict(g: Generado) -> dict:
    return {"semilla": g.semilla, "tipo": g.tipo, "dificultad": g.dificultad, "atajos": g.atajos,
            "nivel": nivel_a_dict(g.nivel), "solucion": [tramo_a_dict(t) for t in g.solucion]}


# ---------------------------------------------------------------- Caída del Día

# Ritmo semanal: más fácil el lunes y más reto el fin de semana (0 = lunes)
RITMO = [("simple", 0.3), ("dos", 0.4), ("numeradas", 0.5), ("doble", 0.5), ("doble_y_simple", 0.6),
         ("numeradas", 0.7), ("doble_y_simple", 0.8)]


def caida_del_dia(fecha) -> Generado:
    """El nivel de un día: misma fecha UTC, mismo nivel para todo el mundo. Lleva campana dorada
    (tercera estrella) siempre que quepa; la marca y la solución de referencia ya la incluyen."""
    semilla = sim.semilla_diaria(fecha)
    tipo, dificultad = RITMO[fecha.weekday()]
    for k in range(50):
        g = generar(semilla + k, tipo, dificultad)
        if g is not None:
            con_dorada = poner_dorada(g.nivel, g.solucion, 7919 * (semilla + k) + 1)
            if con_dorada is not None:
                g.nivel, g.solucion = con_dorada
            return g
    raise RuntimeError(f"No se pudo generar la Caída del Día de {fecha}")


def calendario(desde, dias: int) -> dict:
    import datetime as dt
    entradas = []
    for k in range(dias):
        f = desde + dt.timedelta(days=k)
        g = caida_del_dia(f)
        entradas.append({"fecha": f.isoformat(), **a_dict(g)})
    contenido = json.dumps(entradas, ensure_ascii=False, sort_keys=True).encode()
    return {"version": 1, "desde": desde.isoformat(), "dias": dias,
            "huella": hashlib.sha256(contenido).hexdigest()[:16], "niveles": entradas}


def main():
    import datetime as dt
    ap = argparse.ArgumentParser()
    ap.add_argument("--muestra", type=int, default=0)
    ap.add_argument("--calendario", type=int, default=0)
    ap.add_argument("--desde", default="2027-01-01")
    args = ap.parse_args()
    if args.muestra:
        todos = TIPOS + TIPOS_PUERTA
        for k in range(args.muestra):
            tipo = todos[k % len(todos)]
            g = generar(1000 + k, tipo, 0.5)
            if g is None:
                print(f"{k:>2}. {tipo:<15} sin nivel válido")
                continue
            print(f"{k:>2}. {tipo:<15} dificultad {g.dificultad:.2f}  marca {g.nivel.marca:>3}  fichas {g.nivel.fichas:>3}"
                  f"  muros {len(g.nivel.muros)}  atajos {g.info['atajos']}")
    if args.calendario:
        cal = calendario(dt.date.fromisoformat(args.desde), args.calendario)
        texto = json.dumps(cal, ensure_ascii=False, separators=(",", ":")) + "\n"
        destinos = [AQUI.parent / "simulacion" / "datos" / "caida_del_dia.json",
                    AQUI.parents[1] / "godot" / "datos" / "caida_del_dia.json"]
        for d in destinos:
            d.write_text(texto, encoding="utf-8")
        print(f"Calendario de {args.calendario} días desde {args.desde}: {len(texto) // 1024} KB, huella {cal['huella']}")


if __name__ == "__main__":
    main()
