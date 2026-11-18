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
- Espiral de retardo: cuando una ficha de un tramo entra en una espiral (a RADIO_ESPIRAL o
  menos), las siguientes fichas de ese tramo caen `retardo` tics más tarde. Cada espiral retrasa
  cada tramo una sola vez; las ramas que salen después heredan el retraso por su bifurcador. No
  ocupa sitio ni para la cadena. La primera ficha de un tramo (el empujador o el bifurcador) no
  cuenta: ya contó en su tramo.
- Muelle: lanza la cadena por encima de lo que haya (un muro, por ejemplo) a cambio de un tiempo
  fijo. Tiene entrada, salida y `salto` en tics. Un tramo sin padre que empieza en la salida (a PASO
  o menos) sale del muelle: su primera ficha cae `salto` tics después de la primera ficha que llega
  a la entrada (a RADIO_MUELLE o menos) y cae de verdad, de cualquier tramo dibujado antes. Si no
  llega ninguna, ese tramo no cae. La primera ficha de cada tramo no cuenta para la entrada.
- La campana dorada es opcional: no hace falta para superar el nivel (ni da motivo de fallo si no
  suena), pero su tic aparece en el resultado. Da la tercera estrella.

Todo es determinista: sin azar, sin reloj y sin dependencias externas.

Portabilidad (la versión de Godot debe dar resultados idénticos bit a bit):
- distancias con sqrt(dx*dx + dy*dy), nunca hypot;
- redondeo con floor(x + 0.5): Python redondea .5 al par y GDScript hacia arriba;
- curvas comparando cosenos con COS_GIRO_MAXIMO, sin acos;
- módulo de las puertas siempre positivo (posmod en GDScript).
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
# cos(55°) escrito como literal: así Python y GDScript comparan contra el mismo número exacto,
# sin depender de cómo calcula cos/acos la biblioteca matemática de cada plataforma.
COS_GIRO_MAXIMO = 0.573576436351046
RADIO_CAMPANA = 6.0        # una ficha a esta distancia o menos activa la campana
RADIO_ESPIRAL = 4.5        # una ficha a esta distancia o menos entra en la espiral de retardo
RADIO_MUELLE = 4.5         # una ficha a esta distancia o menos de la entrada dispara el muelle
TOLERANCIA_DOBLE = 1       # tics de diferencia permitidos en la campana doble


# ---------------------------------------------------------------- geometría

def _dist(a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]
    return math.sqrt(dx * dx + dy * dy)


def longitud(puntos):
    return sum(_dist(puntos[i - 1], puntos[i]) for i in range(1, len(puntos)))


def repartir(puntos, paso=PASO):
    """Reparte un trazo en fichas equidistantes a lo largo del recorrido.

    Devuelve floor(L / paso + 0.5) + 1 fichas (mínimo 2 si hay longitud), con la primera en el
    inicio y la última en el final del trazo. No depende de cuántos puntos tenga el trazo.
    """
    if len(puntos) < 2 or longitud(puntos) == 0:
        return [tuple(puntos[0])] if puntos else []
    total = longitud(puntos)
    n = max(2, math.floor(total / paso + 0.5) + 1)
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


def _curva_cerrada(a, b, c):
    """¿El giro entre a→b y b→c supera GIRO_MAXIMO? Se compara el coseno para no usar acos."""
    v1x, v1y = b[0] - a[0], b[1] - a[1]
    v2x, v2y = c[0] - b[0], c[1] - b[1]
    n1 = math.sqrt(v1x * v1x + v1y * v1y)
    n2 = math.sqrt(v2x * v2x + v2y * v2y)
    if n1 == 0 or n2 == 0:
        return False
    return (v1x * v2x + v1y * v2y) / (n1 * n2) < COS_GIRO_MAXIMO


# ---------------------------------------------------------------- modelo

@dataclass
class Campana:
    id: str
    pos: tuple
    tipo: str = "simple"        # "simple" | "doble" | "numerada" | "dorada" (opcional: da la tercera estrella)
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
class Espiral:
    """Espiral de retardo: retrasa `retardo` tics el resto del tramo que pasa por ella."""
    pos: tuple
    retardo: int


@dataclass
class Muelle:
    """Muelle: lo que llega a la entrada sale por la salida `salto` tics después."""
    entrada: tuple
    salida: tuple
    salto: int


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
    espirales: list = field(default_factory=list)
    muelles: list = field(default_factory=list)


@dataclass
class Tramo:
    """Un tramo dibujado. padre=None es el tronco; si no, sale de la ficha `desde` del tramo padre."""
    puntos: list
    padre: int | None = None
    desde: int = 0


# ---------------------------------------------------------------- simulación

def tics_tramo(nivel: Nivel, fichas: list, base: int) -> list:
    """Tic en que cae cada ficha de un tramo: base + 1 + j, más el retraso de las espirales por
    las que ya ha pasado."""
    tics, extra, usadas = [], 0, set()
    for j, p in enumerate(fichas):
        tics.append(base + 1 + j + extra)
        if j == 0:
            continue
        for k, e in enumerate(nivel.espirales):
            if k not in usadas and _dist(p, e.pos) <= RADIO_ESPIRAL:
                usadas.add(k)
                extra += e.retardo
    return tics


def disparo_muelle(m: Muelle, fichas: list, tics: list, caidas: list):
    """Tic de la primera ficha que llega a la entrada del muelle y cae de verdad, entre los tramos
    ya resueltos (`caidas` tiene uno por tramo); None si no llega ninguna."""
    mejor = None
    for t in range(len(caidas)):
        for j in range(1, caidas[t] + 1):
            if _dist(fichas[t][j], m.entrada) <= RADIO_MUELLE and (mejor is None or tics[t][j] < mejor):
                mejor = tics[t][j]
    return mejor


def simular(nivel: Nivel, tramos: list[Tramo]):
    """Simula la caída y devuelve un diccionario con el resultado.

    Claves: exito, fichas_usadas, sobran, campanas {id: tic o None}, parada (o None) y motivo
    del fallo de cada objetivo.
    """
    fichas_por_tramo, salidas = [], []      # salidas[idx]: muelle del que sale el tramo, o None
    for idx, tr in enumerate(tramos):
        f = repartir(tr.puntos)
        salida = None
        if tr.padre is None:
            if _dist(f[0], nivel.inicio) > PASO:
                salida = next((k for k, m in enumerate(nivel.muelles) if _dist(f[0], m.salida) <= PASO), None)
                if salida is None:
                    return _resultado(nivel, tramos, [], {}, {"tramo": idx, "ficha": 0, "motivo": "no empieza en el inicio"})
        elif tr.padre >= idx or tr.desde >= len(fichas_por_tramo[tr.padre]):
            return _resultado(nivel, tramos, [], {}, {"tramo": idx, "ficha": 0, "motivo": "bifurcador no válido"})
        fichas_por_tramo.append(f)
        salidas.append(salida)

    usadas = sum(len(f) for f in fichas_por_tramo)
    if usadas > nivel.fichas:
        return _resultado(nivel, tramos, fichas_por_tramo, {}, {"tramo": None, "ficha": None, "motivo": "faltan fichas"}, usadas)

    # Tramo a tramo, en el orden en que se dibujaron: cuándo cae cada ficha y dónde se para (si se
    # para). Un tramo solo depende de los anteriores (su bifurcador o la entrada de su muelle).
    tics, caidas = [], []          # caidas[idx]: índice de la última ficha que cae (-1: ninguna)
    parada = None
    for idx, f in enumerate(fichas_por_tramo):
        tr = tramos[idx]
        cae = True
        if salidas[idx] is not None:
            m = nivel.muelles[salidas[idx]]
            disparo = disparo_muelle(m, fichas_por_tramo, tics, caidas)
            base = -1 if disparo is None else disparo + m.salto - 1
            cae = disparo is not None          # si nada llegó a la entrada, no sale nada
        elif tr.padre is None:
            base = -1
        else:
            base = tics[tr.padre][tr.desde]
            cae = caidas[tr.padre] >= tr.desde  # su bifurcador tiene que haber caído
        tics.append(tics_tramo(nivel, f, base))
        if not cae:
            caidas.append(-1)
            continue
        ultima = len(f) - 1
        for j in range(1, len(f)):
            motivo = None
            x, y = f[j]
            if not (0 <= x <= nivel.ancho and 0 <= y <= nivel.alto):
                motivo = "sale del tablero"
            elif j >= 2 and _curva_cerrada(f[j - 2], f[j - 1], f[j]):
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
            if not ll and c.tipo != "dorada":        # la dorada es opcional: no hacerla sonar no es un fallo
                motivos[c.id] = "no llegó"
    numeradas = sorted((c for c in nivel.campanas if c.tipo == "numerada"), key=lambda c: c.numero)
    orden_ok = True
    tics_num = [estado[c.id] for c in numeradas]
    if numeradas and all(t is not None for t in tics_num):
        orden_ok = all(tics_num[i] < tics_num[i + 1] for i in range(len(tics_num) - 1))
        if not orden_ok:
            motivos["orden"] = "las campanas numeradas sonaron en otro orden"
    obligatorias = [c for c in nivel.campanas if c.tipo != "dorada"]
    exito = bool(obligatorias) and all(estado[c.id] is not None for c in obligatorias) and orden_ok \
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
            "p": [[list(p.a), list(p.b), p.periodo, p.abierta, p.fase] for p in n.puertas]} | (
        {"e": [[list(e.pos), e.retardo] for e in n.espirales]} if n.espirales else {}) | (
        {"ml": [[list(m.entrada), list(m.salida), m.salto] for m in n.muelles]} if n.muelles else {})


def nivel_de_dict(d: dict) -> Nivel:
    if d.get("v") != 1:
        raise ValueError("versión de nivel desconocida")
    return Nivel(d["w"], d["h"], tuple(d["i"]),
                 [Campana(c[0], tuple(c[1]), c[2], c[3]) for c in d["c"]],
                 [(tuple(a), tuple(b)) for a, b in d["mu"]],
                 [Puerta(tuple(p[0]), tuple(p[1]), p[2], p[3], p[4]) for p in d["p"]],
                 d["f"], d["m"], [Espiral(tuple(e[0]), int(e[1])) for e in d.get("e", [])],
                 [Muelle(tuple(m[0]), tuple(m[1]), int(m[2])) for m in d.get("ml", [])])


PREFIJO_TALLER = "DING1-"     # nombre del juego + versión del formato

# Límites de un nivel del Taller. Un código es texto que llega de cualquiera: todo se comprueba
# antes de jugarlo (godot/nucleo/taller.gd aplica exactamente las mismas reglas).
LIMITES_TALLER = {"campanas": 6, "numeradas": 4, "muros": 12, "puertas": 6, "fichas": 400,
                  "tramos": 8, "puntos": 600, "id": 8, "periodo": 200, "espirales": 4, "retardo": 12,
                  "muelles": 4, "salto": 20}
TIPOS_CAMPANA = ("simple", "doble", "numerada", "dorada")


def _numero(x, minimo, maximo):
    return isinstance(x, (int, float)) and not isinstance(x, bool) and math.isfinite(x) and minimo <= x <= maximo


def _punto(p, d):
    return isinstance(p, (list, tuple)) and len(p) == 2 and _numero(p[0], 0, d["w"]) and _numero(p[1], 0, d["h"])


def validar_nivel_taller(d: dict) -> str:
    """Devuelve "" si el nivel es válido o el motivo por el que no lo es."""
    L = LIMITES_TALLER
    try:
        if d.get("v") != 1 or d.get("w") != 100 or d.get("h") != 160:
            return "versión o tablero desconocidos"
        if not _punto(d["i"], d):
            return "inicio fuera del tablero"
        if not (_numero(d["f"], 2, L["fichas"]) and _numero(d["m"], 0, d["f"])):
            return "número de fichas no válido"
        c = d["c"]
        if not (isinstance(c, list) and 1 <= len(c) <= L["campanas"]):
            return "hacen falta entre 1 y 6 campanas"
        numeros = []
        for x in c:
            if not (isinstance(x, list) and len(x) == 4 and isinstance(x[0], str) and 0 < len(x[0]) <= L["id"]
                    and _punto(x[1], d) and x[2] in TIPOS_CAMPANA and _numero(x[3], 0, L["numeradas"])):
                return "campana no válida"
            if x[2] == "numerada":
                numeros.append(int(x[3]))
        if len({x[0] for x in c}) != len(c):
            return "campanas repetidas"
        doradas = sum(1 for x in c if x[2] == "dorada")
        if doradas > 1 or doradas == len(c):
            return "como mucho una campana dorada, y no puede ser la única"
        if sorted(numeros) != list(range(1, len(numeros) + 1)):
            return "las numeradas tienen que ir 1, 2, 3…"
        if not (isinstance(d["mu"], list) and len(d["mu"]) <= L["muros"]):
            return "demasiados muros"
        for m in d["mu"]:
            if not (isinstance(m, list) and len(m) == 2 and _punto(m[0], d) and _punto(m[1], d)):
                return "muro no válido"
        if not (isinstance(d["p"], list) and len(d["p"]) <= L["puertas"]):
            return "demasiadas puertas"
        for p in d["p"]:
            if not (isinstance(p, list) and len(p) == 5 and _punto(p[0], d) and _punto(p[1], d)
                    and _numero(p[2], 2, L["periodo"]) and _numero(p[3], 1, p[2]) and _numero(p[4], 0, L["periodo"])):
                return "puerta no válida"
        e = d.get("e", [])
        if not (isinstance(e, list) and len(e) <= L["espirales"]):
            return "demasiadas espirales"
        for x in e:
            if not (isinstance(x, list) and len(x) == 2 and _punto(x[0], d) and _numero(x[1], 1, L["retardo"])):
                return "espiral no válida"
        ml = d.get("ml", [])
        if not (isinstance(ml, list) and len(ml) <= L["muelles"]):
            return "demasiados muelles"
        for x in ml:
            if not (isinstance(x, list) and len(x) == 3 and _punto(x[0], d) and _punto(x[1], d) and _numero(x[2], 1, L["salto"])):
                return "muelle no válido"
    except (KeyError, TypeError, IndexError):
        return "faltan datos del nivel"
    return ""


def _validar_solucion(s, d) -> str:
    L = LIMITES_TALLER
    if not (isinstance(s, list) and 1 <= len(s) <= L["tramos"]):
        return "solución no válida"
    for k, t in enumerate(s):
        if not (isinstance(t, list) and len(t) == 3 and isinstance(t[0], list) and 2 <= len(t[0]) <= L["puntos"]
                and all(_punto(p, d) for p in t[0])):
            return "solución no válida"
        if k == 0 and t[1] is not None or k > 0 and not (_numero(t[1], 0, k - 1) and _numero(t[2], 0, L["puntos"])):
            return "solución no válida"
    return ""


def codigo_taller(n: Nivel, solucion: list | None = None) -> str:
    """Código de texto para compartir un nivel del Taller sin servidor.

    Con `solucion` (la del autor, que lo superó al probarlo), el código la lleva dentro: quien lo
    recibe sabe que el nivel tiene solución y puede usarla de pista. Las coordenadas de la solución
    se redondean a una décima.
    """
    d = nivel_a_dict(n)
    if solucion is not None:
        d["s"] = [[[[round(x, 1), round(y, 1)] for x, y in t.puntos], t.padre, t.desde] for t in solucion]
    datos = json.dumps(d, separators=(",", ":"), sort_keys=True).encode()
    return PREFIJO_TALLER + base64.urlsafe_b64encode(zlib.compress(datos, 9)).decode().rstrip("=")


def datos_de_codigo(codigo: str):
    """Abre un código del Taller y lo comprueba entero. Devuelve (Nivel, solución o None).

    Lanza ValueError si el código está mal, es demasiado grande, se sale de los límites o trae una
    solución que no supera el nivel.
    """
    if not isinstance(codigo, str) or not codigo.startswith(PREFIJO_TALLER) or len(codigo) > 20_000:
        raise ValueError("código no válido")
    cuerpo = codigo[len(PREFIJO_TALLER):].strip()
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
        d = json.loads(datos)
    except ValueError as e:
        raise ValueError("código no válido") from e
    if not isinstance(d, dict):
        raise ValueError("código no válido")
    motivo = validar_nivel_taller(d)
    if motivo:
        raise ValueError(motivo)
    nivel = nivel_de_dict(d)
    solucion = None
    if "s" in d:
        motivo = _validar_solucion(d["s"], d)
        if motivo:
            raise ValueError(motivo)
        # Godot escribe todos los números como decimales (0.0): padre y desde se pasan a enteros
        solucion = [Tramo([tuple(p) for p in t[0]], None if t[1] is None else int(t[1]), int(t[2])) for t in d["s"]]
        try:
            exito = simular(nivel, solucion)["exito"]
        except (TypeError, ValueError, IndexError, KeyError) as e:     # nunca un fallo sin controlar
            raise ValueError("código no válido") from e
        if not exito:
            raise ValueError("la solución del código no supera el nivel")
    return nivel, solucion


def nivel_de_codigo(codigo: str) -> Nivel:
    return datos_de_codigo(codigo)[0]
