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
from sim import Campana, Nivel, Tramo, longitud, nivel_a_dict, repartir, simular  # noqa: E402
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


# ---------------------------------------------------------------- generador

def _candidato(rnd, tipo, dificultad):
    """Un intento de nivel: topología, obstáculos y validación. Devuelve un Generado o None."""
    if tipo == "simple":
        base = _simple(rnd)
    elif tipo == "dos":
        base = _dos(rnd)
    elif tipo == "numeradas":
        base = _numeradas(rnd)
    elif tipo == "doble":
        base = _doble(rnd)
    else:
        base = _doble(rnd, extra=True)
    if base is None:
        return None
    inicio, campanas, tramos = base
    nivel = Nivel(ANCHO, ALTO, (round(inicio[0], 2), round(inicio[1], 2)),
                  [Campana(c.id, (round(c.pos[0], 2), round(c.pos[1], 2)), c.tipo, c.numero) for c in campanas],
                  fichas=10_000)
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
    """El nivel de un día: misma fecha UTC, mismo nivel para todo el mundo."""
    semilla = sim.semilla_diaria(fecha)
    tipo, dificultad = RITMO[fecha.weekday()]
    for k in range(50):
        g = generar(semilla + k, tipo, dificultad)
        if g is not None:
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
        for k in range(args.muestra):
            tipo = TIPOS[k % len(TIPOS)]
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
