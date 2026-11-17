"""Pruebas de la simulación de referencia.  Uso:  python -X utf8 -m unittest -v test_sim  (desde esta carpeta)"""
import base64
import datetime as dt
import math
import unittest
import zlib

import sim
from sim import Campana, Nivel, Puerta, Tramo, simular, repartir, longitud


def linea(a, b, n=2):
    """Trazo recto de a a b con n puntos (simula la densidad variable del dedo)."""
    return [(a[0] + (b[0] - a[0]) * k / (n - 1), a[1] + (b[1] - a[1]) * k / (n - 1)) for k in range(n)]


def nivel_doble(fichas=200):
    """Tablero 100 × 160 con inicio abajo y una campana doble arriba (como la demo)."""
    return Nivel(100, 160, (20, 150), [Campana("doble", (50, 20), "doble")], fichas=fichas)


def arbol_simetrico(desplazamiento=0.0):
    """Tronco recto hacia arriba y dos ramas simétricas hasta la campana doble.

    Con desplazamiento > 0 la rama derecha da un rodeo y llega más tarde.
    """
    tronco = Tramo(linea((20, 150), (50, 110), 9))
    fin = len(repartir(tronco.puntos)) - 1
    izq = Tramo([(50, 110), (35, 80), (35, 50), (50, 20)], padre=0, desde=fin)
    der = Tramo([(50, 110), (65 + desplazamiento, 80), (65 + desplazamiento, 50), (50, 20)], padre=0, desde=fin)
    return [tronco, izq, der]


class Reparto(unittest.TestCase):
    def test_numero_de_fichas_solo_depende_de_la_longitud(self):
        # Lección del 16/11/2026: el mismo recorrido con distinta densidad de puntos da las mismas fichas
        for n in (2, 5, 37, 200):
            self.assertEqual(len(repartir(linea((0, 0), (100, 0), n))), round(100 / sim.PASO) + 1)

    def test_fichas_equidistantes(self):
        f = repartir([(0, 0), (30, 0), (30, 40)])            # longitud 70
        d = [math.dist(f[i - 1], f[i]) for i in range(1, len(f))]
        self.assertAlmostEqual(sum(d), 70, places=6)
        self.assertLess(max(d) - min(d), 1.5)                 # la esquina acorta un poco la cuerda

    def test_primera_y_ultima_en_los_extremos(self):
        f = repartir(linea((3, 4), (53, 4), 3))
        self.assertEqual(f[0], (3, 4))
        self.assertAlmostEqual(f[-1][0], 53)


class LongitudEsTiempo(unittest.TestCase):
    def test_camino_mas_largo_llega_mas_tarde(self):
        n = Nivel(200, 100, (10, 50), [Campana("a", (110, 50))], fichas=500)
        corto = simular(n, [Tramo(linea((10, 50), (110, 50)))])
        largo = simular(n, [Tramo([(10, 50), (60, 80), (110, 50)])])
        self.assertTrue(corto["exito"] and largo["exito"])
        self.assertLess(corto["campanas"]["a"], largo["campanas"]["a"])

    def test_tic_igual_al_numero_de_fichas(self):
        n = Nivel(200, 100, (10, 50), [Campana("a", (110, 50))], fichas=500)
        r = simular(n, [Tramo(linea((10, 50), (110, 50)))])
        # La campana se activa con la primera ficha a RADIO_CAMPANA o menos
        self.assertEqual(r["campanas"]["a"], math.ceil((100 - sim.RADIO_CAMPANA) / sim.PASO))


class CampanaDoble(unittest.TestCase):
    def test_ramas_iguales_suenan_a_la_vez(self):
        r = simular(nivel_doble(), arbol_simetrico())
        self.assertTrue(r["exito"], r)

    def test_rama_mas_larga_no_suena(self):
        r = simular(nivel_doble(), arbol_simetrico(desplazamiento=12))
        self.assertFalse(r["exito"])
        self.assertEqual(r["motivos"]["doble"], "no llegaron a la vez")

    def test_una_sola_rama_no_basta(self):
        tr = arbol_simetrico()[:2]
        r = simular(nivel_doble(), tr)
        self.assertFalse(r["exito"])
        self.assertEqual(r["motivos"]["doble"], "solo llegó una rama")


class Paradas(unittest.TestCase):
    def test_curva_cerrada_rompe_la_cadena(self):
        n = Nivel(200, 200, (10, 100), [Campana("a", (10, 150))], fichas=500)
        r = simular(n, [Tramo([(10, 100), (100, 100), (10, 150)])])   # giro de unos 150°
        self.assertFalse(r["exito"])
        self.assertEqual(r["parada"]["motivo"], "curva demasiado cerrada")

    def test_muro(self):
        n = Nivel(200, 100, (10, 50), [Campana("a", (110, 50))], muros=[((60, 0), (60, 100))], fichas=500)
        r = simular(n, [Tramo(linea((10, 50), (110, 50)))])
        self.assertFalse(r["exito"])
        self.assertEqual(r["parada"]["motivo"], "choca con un muro")
        self.assertEqual(r["campanas"]["a"], None)

    def test_sale_del_tablero(self):
        n = Nivel(100, 100, (10, 50), [Campana("a", (90, 50))], fichas=500)
        r = simular(n, [Tramo(linea((10, 50), (150, 50)))])
        self.assertEqual(r["parada"]["motivo"], "sale del tablero")

    def test_faltan_fichas(self):
        n = Nivel(200, 100, (10, 50), [Campana("a", (110, 50))], fichas=5)
        r = simular(n, [Tramo(linea((10, 50), (110, 50)))])
        self.assertFalse(r["exito"])
        self.assertEqual(r["parada"]["motivo"], "faltan fichas")

    def test_tiene_que_empezar_en_el_inicio(self):
        n = Nivel(200, 100, (10, 50), [Campana("a", (110, 50))], fichas=500)
        r = simular(n, [Tramo(linea((40, 50), (110, 50)))])
        self.assertEqual(r["parada"]["motivo"], "no empieza en el inicio")


class Puertas(unittest.TestCase):
    def nivel(self, fase):
        p = Puerta((60, 0), (60, 100), periodo=20, abierta=5, fase=fase)
        return Nivel(200, 100, (10, 50), [Campana("a", (110, 50))], puertas=[p], fichas=500)

    def test_pasa_si_esta_abierta(self):
        # La cadena cruza x=60 entre las fichas 9 y 10 (tic 10)
        r = simular(self.nivel(fase=8), [Tramo(linea((10, 50), (110, 50)))])
        self.assertTrue(r["exito"], r)

    def test_se_para_si_esta_cerrada(self):
        r = simular(self.nivel(fase=13), [Tramo(linea((10, 50), (110, 50)))])
        self.assertFalse(r["exito"])
        self.assertEqual(r["parada"]["motivo"], "puerta cerrada")


class Numeradas(unittest.TestCase):
    def test_orden(self):
        campanas = [Campana("1", (60, 50), "numerada", 1), Campana("2", (110, 50), "numerada", 2)]
        n = Nivel(200, 100, (10, 50), campanas, fichas=500)
        self.assertTrue(simular(n, [Tramo(linea((10, 50), (110, 50)))])["exito"])
        campanas_al_reves = [Campana("1", (110, 50), "numerada", 1), Campana("2", (60, 50), "numerada", 2)]
        r = simular(Nivel(200, 100, (10, 50), campanas_al_reves, fichas=500), [Tramo(linea((10, 50), (110, 50)))])
        self.assertFalse(r["exito"])
        self.assertIn("orden", r["motivos"])


class Determinismo(unittest.TestCase):
    def test_mismo_trazo_mismo_resultado(self):
        a = simular(nivel_doble(), arbol_simetrico())
        b = simular(nivel_doble(), arbol_simetrico())
        self.assertEqual(a, b)

    def test_independiente_de_la_escala_de_pantalla(self):
        # Lección del 17/11/2026: el motor trabaja en unidades lógicas. Dibujar a otra escala y
        # convertir a unidades lógicas antes de simular da exactamente el mismo resultado.
        escala = 2.37
        tr = arbol_simetrico()
        en_pantalla = [Tramo([(x * escala, y * escala) for x, y in t.puntos], t.padre, t.desde) for t in tr]
        de_vuelta = [Tramo([(x / escala, y / escala) for x, y in t.puntos], t.padre, t.desde) for t in en_pantalla]
        self.assertEqual(simular(nivel_doble(), tr)["campanas"], simular(nivel_doble(), de_vuelta)["campanas"])


class RetoDiarioYTaller(unittest.TestCase):
    def test_semilla_por_fecha_utc(self):
        madrid = dt.timezone(dt.timedelta(hours=1))
        nueva_york = dt.timezone(dt.timedelta(hours=-5))
        # 17/11 a las 00:30 en Madrid es 16/11 en UTC; 16/11 a las 19:00 en Nueva York también es 17/11 UTC
        self.assertEqual(sim.fecha_utc(dt.datetime(2026, 11, 17, 0, 30, tzinfo=madrid)), dt.date(2026, 11, 16))
        self.assertEqual(sim.fecha_utc(dt.datetime(2026, 11, 16, 19, 0, tzinfo=nueva_york)), dt.date(2026, 11, 17))
        self.assertEqual(sim.semilla_diaria(dt.date(2026, 11, 17)), sim.semilla_diaria(dt.date(2026, 11, 17)))
        self.assertNotEqual(sim.semilla_diaria(dt.date(2026, 11, 17)), sim.semilla_diaria(dt.date(2026, 11, 18)))
        with self.assertRaises(ValueError):
            sim.fecha_utc(dt.datetime(2026, 11, 17))     # sin zona horaria: error, no se adivina

    def test_codigo_ida_y_vuelta(self):
        n = Nivel(100, 160, (20, 150), [Campana("d", (50, 20), "doble")],
                  muros=[((0, 80), (30, 80))], puertas=[Puerta((60, 0), (60, 50), 20, 5, 3)], fichas=42, marca=37)
        codigo = sim.codigo_taller(n)
        self.assertTrue(codigo.startswith("CAD1-"))
        self.assertLess(len(codigo), 400)
        self.assertEqual(sim.nivel_de_codigo(codigo), n)

    def test_codigo_manipulado(self):
        for malo in ("hola", "CAD1-!!!!", "CAD1-" + base64.urlsafe_b64encode(b"no es zlib").decode()):
            with self.assertRaises(ValueError):
                sim.nivel_de_codigo(malo)

    def test_bomba_de_descompresion(self):
        bomba = "CAD1-" + base64.urlsafe_b64encode(zlib.compress(b" " * 5_000_000, 9)).decode().rstrip("=")
        with self.assertRaises(ValueError):
            sim.nivel_de_codigo(bomba)


if __name__ == "__main__":
    unittest.main()
