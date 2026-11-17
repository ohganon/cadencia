"""Simulación de referencia de la caída de dominós (especificación ejecutable).

Es la fuente de verdad de las reglas del juego, sin motor gráfico. La versión de Godot (GDScript)
debe dar exactamente los mismos resultados; las pruebas de test_sim.py sirven para comprobarlo.
También es el oráculo del generador de niveles y del Taller.

Reglas (Fase 4, sección 4.3):
- El jugador dibuja un árbol de tramos: un tronco desde el inicio y ramas que salen de un
  bifurcador (una ficha de otro tramo).
- Cada tramo se reparte en fichas separadas por PASO unidades **a lo largo del recorrido**
  (longitud de arco), no por los puntos del dedo: así el número de fichas solo depende de la
  longitud (lección del fallo de la demo del 16/11/2026, que recortaba una rama).
- Todas las coordenadas son **unidades lógicas del tablero**, nunca píxeles: el resultado no
  cambia con el tamaño de la pantalla (lección del fallo del modo clip del 17/11/2026).
- La ficha i del tronco cae en el tic i. La ficha j de una rama cae en el tic (tic del
  bifurcador) + 1 + j. **La longitud es el tiempo.**
- La cadena se para en una curva demasiado cerrada, al chocar con un muro, al salir del
  tablero o al cruzar una puerta cerrada. El resultado dice dónde y por qué.
- Objetivos: campana simple, campana doble (dos ramas distintas a la vez, con tolerancia) y
  campanas numeradas (deben sonar en orden).

Todo es determinista: sin azar, sin reloj y sin dependencias externas.
"""
from __future__ import annotations

import base64
import datetime as _dt
import hashlib
import json
import math
import zlib
from dataclasses import dataclass, field

PASO = 5.0                 # separación entre fichas, en unidades del tablero
GIRO_MAXIMO = math.radians(55)   # giro máximo entre dos fichas seguidas antes de romperse
RADIO_CAMPANA = 6.0        # una ficha a esta distancia o menos activa la campana
TOLERANCIA_DOBLE = 1       # tics de diferencia permitidos en la campana doble


# ---------------------------------------------------------------- geometría

def _dist(a, b):
    return math.hypot(b[0] - a[0], b[1] - a[1])


def longitud(puntos):
    return sum(_dist(puntos[i - 1], puntos[i]) for i in range(1, len(puntos)))


def repartir(puntos, paso=PASO):
    """Reparte un trazo en fichas equidistantes a lo largo del recorrido.

    Devuelve round(L / paso) + 1 fichas (mínimo 2 si hay longitud), con la primera en el
    inicio y la última en el final del trazo. No depende de cuántos puntos tenga el trazo.
    """
    if len(puntos) < 2 or longitud(puntos) == 0:
        return [tuple(puntos[0])] if puntos else []
    total = longitud(puntos)
    n = max(2, round(total / paso) + 1)
    fichas, s, acum = [], 1, 0.0
    for k in range(n):
        objetivo = total * k / (n - 1)
        while s < len(puntos) - 1 and acum + _dist(puntos[s - 1], puntos[s]) < objetivo:
            acum += _dist(puntos[s - 1], puntos[s])
            s += 1
        a, b = puntos[s - 1], puntos[s]
        d = _dist(a, b) or 1.0
        t = min(1.0, max(0.0, (objetivo - acum) / d))
        fichas.append((a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t))
    return fichas


def _cruza(p1, p2, q1, q2):
    """¿Se cortan los segmentos p1-p2 y q1-q2? (incluye tocarse)."""
    def orient(a, b, c):
        v = (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
        return 0 if abs(v) < 1e-9 else (1 if v > 0 else -1)

    def sobre(a, b, c):
        return min(a[0], b[0]) - 1e-9 <= c[0] <= max(a[0], b[0]) + 1e-9 and \
               min(a[1], b[1]) - 1e-9 <= c[1] <= max(a[1], b[1]) + 1e-9

    o1, o2, o3, o4 = orient(p1, p2, q1), orient(p1, p2, q2), orient(q1, q2, p1), orient(q1, q2, p2)
    if o1 != o2 and o3 != o4:
        return True
    return (o1 == 0 and sobre(p1, p2, q1)) or (o2 == 0 and sobre(p1, p2, q2)) or \
           (o3 == 0 and sobre(q1, q2, p1)) or (o4 == 0 and sobre(q1, q2, p2))


def _giro(a, b, c):
    """Ángulo de giro (radianes) entre los vectores a→b y b→c."""
    v1, v2 = (b[0] - a[0], b[1] - a[1]), (c[0] - b[0], c[1] - b[1])
    n1, n2 = math.hypot(*v1), math.hypot(*v2)
    if n1 == 0 or n2 == 0:
        return 0.0
    cos = max(-1.0, min(1.0, (v1[0] * v2[0] + v1[1] * v2[1]) / (n1 * n2)))
    return math.acos(cos)


# ---------------------------------------------------------------- modelo

@dataclass
class Campana:
    id: str
    pos: tuple
    tipo: str = "simple"        # "simple" | "doble" | "numerada"
    numero: int = 0             # solo para las numeradas


@dataclass
class Puerta:
    """Puerta de vaivén: un segmento que solo se puede cruzar mientras está abierta.

    Está abierta en los tics t con (t - fase) % periodo < abierta.
    """
    a: tuple
    b: tuple
    periodo: int
    abierta: int
    fase: int = 0

    def abierta_en(self, tic):
        return (tic - self.fase) % self.periodo < self.abierta


@dataclass
class Nivel:
    ancho: float
    alto: float
    inicio: tuple
    campanas: list
    muros: list = field(default_factory=list)      # lista de segmentos ((x1, y1), (x2, y2))
    puertas: list = field(default_factory=list)
    fichas: int = 60                                # fichas disponibles
    marca: int = 0                                  # fichas de la solución de referencia


@dataclass
class Tramo:
    """Un tramo dibujado. padre=None es el tronco; si no, sale de la ficha `desde` del tramo padre."""
    puntos: list
    padre: int | None = None
    desde: int = 0


# ---------------------------------------------------------------- simulación

def simular(nivel: Nivel, tramos: list[Tramo]):
    """Simula la caída y devuelve un diccionario con el resultado.

    Claves: exito, fichas_usadas, sobran, campanas {id: tic o None}, parada (o None) y motivo
    del fallo de cada objetivo.
    """
    fichas_por_tramo, tics = [], []
    for idx, tr in enumerate(tramos):
        f = repartir(tr.puntos)
        if tr.padre is None:
            if _dist(f[0], nivel.inicio) > PASO:
                return _resultado(nivel, tramos, [], {}, {"tramo": idx, "ficha": 0, "motivo": "no empieza en el inicio"})
            base = -1
        else:
            if tr.padre >= idx or tr.desde >= len(fichas_por_tramo[tr.padre]):
                return _resultado(nivel, tramos, [], {}, {"tramo": idx, "ficha": 0, "motivo": "bifurcador no válido"})
            base = tics[tr.padre][tr.desde]
        fichas_por_tramo.append(f)
        tics.append([base + 1 + j for j in range(len(f))])

    usadas = sum(len(f) for f in fichas_por_tramo)
    if usadas > nivel.fichas:
        return _resultado(nivel, tramos, fichas_por_tramo, {}, {"tramo": None, "ficha": None, "motivo": "faltan fichas"}, usadas)

    # Recorrer cada tramo y encontrar dónde se para (si se para)
    caidas = []          # (tramo, índice de la última ficha que cae)
    parada = None
    for idx, f in enumerate(fichas_por_tramo):
        if tramos[idx].padre is not None and caidas[tramos[idx].padre] < tramos[idx].desde:
            caidas.append(-1)        # su bifurcador nunca cayó
            continue
        ultima = len(f) - 1
        for j in range(1, len(f)):
            motivo = None
            x, y = f[j]
            if not (0 <= x <= nivel.ancho and 0 <= y <= nivel.alto):
                motivo = "sale del tablero"
            elif j >= 2 and _giro(f[j - 2], f[j - 1], f[j]) > GIRO_MAXIMO:
                motivo = "curva demasiado cerrada"
            elif any(_cruza(f[j - 1], f[j], m[0], m[1]) for m in nivel.muros):
                motivo = "choca con un muro"
            else:
                for p in nivel.puertas:
                    if _cruza(f[j - 1], f[j], p.a, p.b) and not p.abierta_en(tics[idx][j]):
                        motivo = "puerta cerrada"
                        break
            if motivo:
                ultima = j - 1
                if parada is None or tics[idx][j] < parada["tic"]:
                    parada = {"tramo": idx, "ficha": j, "tic": tics[idx][j], "motivo": motivo}
                break
        caidas.append(ultima)

    # Campanas: el primer tic en que una ficha caída de cada tramo llega a su radio
    llegadas = {c.id: [] for c in nivel.campanas}        # lista de (tic, tramo)
    for c in nivel.campanas:
        for idx, f in enumerate(fichas_por_tramo):
            for j in range(0, caidas[idx] + 1):
                if _dist(f[j], c.pos) <= RADIO_CAMPANA:
                    llegadas[c.id].append((tics[idx][j], idx))
                    break
    return _resultado(nivel, tramos, fichas_por_tramo, llegadas, parada, usadas)


def _resultado(nivel, tramos, fichas, llegadas, parada, usadas=None):
    usadas = sum(len(f) for f in fichas) if usadas is None else usadas
    estado, motivos = {}, {}
    for c in nivel.campanas:
        ll = sorted(llegadas.get(c.id, []))
        if c.tipo == "doble":
            ok = None
            for i in range(len(ll)):
                for k in range(i + 1, len(ll)):
                    if ll[i][1] != ll[k][1] and abs(ll[i][0] - ll[k][0]) <= TOLERANCIA_DOBLE:
                        ok = max(ll[i][0], ll[k][0])
                        break
                if ok is not None:
                    break
            estado[c.id] = ok
            if ok is None:
                motivos[c.id] = "solo llegó una rama" if len({t for _, t in ll}) == 1 else \
                                ("no llegaron a la vez" if ll else "no llegó ninguna rama")
        else:
            estado[c.id] = ll[0][0] if ll else None
            if not ll:
                motivos[c.id] = "no llegó"
    numeradas = sorted((c for c in nivel.campanas if c.tipo == "numerada"), key=lambda c: c.numero)
    orden_ok = True
    tics_num = [estado[c.id] for c in numeradas]
    if numeradas and all(t is not None for t in tics_num):
        orden_ok = all(tics_num[i] < tics_num[i + 1] for i in range(len(tics_num) - 1))
        if not orden_ok:
            motivos["orden"] = "las campanas numeradas sonaron en otro orden"
    exito = bool(nivel.campanas) and all(v is not None for v in estado.values()) and orden_ok \
        and usadas <= nivel.fichas and not (parada and parada.get("motivo") in ("faltan fichas", "no empieza en el inicio", "bifurcador no válido"))
    return {"exito": exito, "fichas_usadas": usadas, "sobran": nivel.fichas - usadas,
            "campanas": estado, "parada": parada, "motivos": motivos}


# ---------------------------------------------------------------- reto diario y Taller

def semilla_diaria(fecha: _dt.date) -> int:
    """Semilla de la Caída del Día: la misma para todo el mundo en la misma fecha UTC."""
    return int.from_bytes(hashlib.sha256(f"caida-del-dia:{fecha.isoformat()}".encode()).digest()[:8], "big")


def fecha_utc(ahora: _dt.datetime) -> _dt.date:
    if ahora.tzinfo is None:
        raise ValueError("la hora debe llevar zona horaria; el reto diario usa la fecha UTC")
    return ahora.astimezone(_dt.timezone.utc).date()


def nivel_a_dict(n: Nivel) -> dict:
    return {"v": 1, "w": n.ancho, "h": n.alto, "i": list(n.inicio), "f": n.fichas, "m": n.marca,
            "c": [[c.id, list(c.pos), c.tipo, c.numero] for c in n.campanas],
            "mu": [[list(a), list(b)] for a, b in n.muros],
            "p": [[list(p.a), list(p.b), p.periodo, p.abierta, p.fase] for p in n.puertas]}


def nivel_de_dict(d: dict) -> Nivel:
    if d.get("v") != 1:
        raise ValueError("versión de nivel desconocida")
    return Nivel(d["w"], d["h"], tuple(d["i"]),
                 [Campana(c[0], tuple(c[1]), c[2], c[3]) for c in d["c"]],
                 [(tuple(a), tuple(b)) for a, b in d["mu"]],
                 [Puerta(tuple(p[0]), tuple(p[1]), p[2], p[3], p[4]) for p in d["p"]],
                 d["f"], d["m"])


PREFIJO_TALLER = "DING1-"     # nombre del juego + versión del formato


def codigo_taller(n: Nivel) -> str:
    """Código de texto para compartir un nivel del Taller sin servidor."""
    datos = json.dumps(nivel_a_dict(n), separators=(",", ":"), sort_keys=True).encode()
    return PREFIJO_TALLER + base64.urlsafe_b64encode(zlib.compress(datos, 9)).decode().rstrip("=")


def nivel_de_codigo(codigo: str) -> Nivel:
    if not codigo.startswith(PREFIJO_TALLER):
        raise ValueError("código no válido")
    cuerpo = codigo[len(PREFIJO_TALLER):]
    cuerpo += "=" * (-len(cuerpo) % 4)
    limite = 65536             # un nivel ocupa unos pocos KB; más es un código manipulado
    try:
        dec = zlib.decompressobj()
        datos = dec.decompress(base64.urlsafe_b64decode(cuerpo), limite + 1)
    except Exception as e:      # código corrupto o manipulado
        raise ValueError("código no válido") from e
    if len(datos) > limite or dec.unconsumed_tail:
        raise ValueError("nivel demasiado grande")
    try:
        return nivel_de_dict(json.loads(datos))
    except (ValueError, KeyError, TypeError, IndexError) as e:
        raise ValueError("código no válido") from e
