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
            self.assertEqual(len(repartir(linea((0, 0), (100, 0), n))), math.floor(100 / sim.PASO + 0.5) + 1)

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


class Portabilidad(unittest.TestCase):
    def test_coseno_del_giro_maximo(self):
        self.assertAlmostEqual(sim.COS_GIRO_MAXIMO, math.cos(sim.GIRO_MAXIMO), places=15)

    def test_redondeo_de_medios_hacia_arriba(self):
        # 12,5 unidades = 2,5 pasos: Python round() daría 2 (al par); la regla común da 3
        self.assertEqual(len(repartir(linea((0, 0), (12.5, 0)))), 4)


class Dorada(unittest.TestCase):
    def nivel(self):
        return Nivel(200, 100, (10, 50), [Campana("a", (110, 50)), Campana("oro", (60, 90), "dorada")], fichas=500)

    def test_no_hace_falta_para_superar(self):
        r = simular(self.nivel(), [Tramo(linea((10, 50), (110, 50)))])
        self.assertTrue(r["exito"])
        self.assertIsNone(r["campanas"]["oro"])
        self.assertNotIn("oro", r["motivos"])

    def test_suena_si_llega_una_rama(self):
        tronco = Tramo(linea((10, 50), (110, 50)))
        rama = Tramo([(60, 50), (60, 90)], 0, 10)
        r = simular(self.nivel(), [tronco, rama])
        self.assertTrue(r["exito"])
        self.assertIsNotNone(r["campanas"]["oro"])

    def test_sola_no_basta(self):
        n = Nivel(200, 100, (10, 50), [Campana("oro", (110, 50), "dorada")], fichas=500)
        self.assertFalse(simular(n, [Tramo(linea((10, 50), (110, 50)))])["exito"])

    def test_codigo_con_dorada(self):
        n = Nivel(100, 160, (50, 150), [Campana("a", (50, 20)), Campana("oro", (20, 80), "dorada")], fichas=60, marca=30)
        nivel, _ = sim.datos_de_codigo(sim.codigo_taller(n))
        self.assertEqual(nivel, n)
        dos = sim.nivel_a_dict(n)
        dos["c"].append(["oro2", [80, 20], "dorada", 0])
        self.assertNotEqual(sim.validar_nivel_taller(dos), "")


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
        self.assertTrue(codigo.startswith("DING1-"))
        self.assertLess(len(codigo), 400)
        self.assertEqual(sim.nivel_de_codigo(codigo), n)

    def test_codigo_manipulado(self):
        for malo in ("hola", "CAD1-!!!!", "DING1-" + base64.urlsafe_b64encode(b"no es zlib").decode()):
            with self.assertRaises(ValueError):
                sim.nivel_de_codigo(malo)

    def test_codigo_con_solucion_de_los_10_niveles(self):
        import niveles_entrega1 as gen
        for n in gen.niveles():
            with self.subTest(n["id"]):
                codigo = sim.codigo_taller(n["nivel"], n["solucion"])
                nivel, solucion = sim.datos_de_codigo(codigo)
                self.assertEqual(nivel, n["nivel"])
                self.assertTrue(simular(nivel, solucion)["exito"])
                self.assertLess(len(codigo), 2500, "el código tiene que caber en un mensaje")

    def test_python_abre_los_codigos_de_godot(self):
        import json
        import pathlib
        import niveles_entrega1 as gen
        ruta = pathlib.Path(__file__).resolve().parents[2] / "godot" / "datos" / "codigos_godot.json"
        codigos = json.loads(ruta.read_text(encoding="utf-8"))["codigos"]
        niveles = {n["id"]: n for n in gen.niveles()}
        self.assertEqual(len(codigos), 10)
        for c in codigos:
            with self.subTest(c["id"]):
                nivel, solucion = sim.datos_de_codigo(c["codigo"])
                self.assertEqual(nivel, niveles[c["id"]]["nivel"])
                self.assertTrue(simular(nivel, solucion)["exito"])

    def test_codigos_que_se_salen_de_los_limites(self):
        import json, zlib
        def codigo(d):
            return "DING1-" + base64.urlsafe_b64encode(zlib.compress(json.dumps(d).encode())).decode().rstrip("=")
        base = sim.nivel_a_dict(Nivel(100, 160, (20, 150), [Campana("a", (50, 20))], fichas=40, marca=30))
        malos = {
            "fuera del tablero": {**base, "i": [500, 150]},
            "sin campanas": {**base, "c": []},
            "demasiadas campanas": {**base, "c": [[str(k), [50, 20], "simple", 0] for k in range(7)]},
            "tipo raro": {**base, "c": [["a", [50, 20], "bomba", 0]]},
            "numeradas sin el 1": {**base, "c": [["a", [50, 20], "numerada", 2]]},
            "número infinito": {**base, "f": float("inf")},
            "booleano como número": {**base, "f": True},
            "demasiados muros": {**base, "mu": [[[1, 1], [2, 2]]] * 13},
            "otro tablero": {**base, "w": 1000},
            "solución que no llega": {**base, "s": [[[[20, 150], [20, 100]], None, 0]]},
            "solución con padre imposible": {**base, "s": [[[[20, 150], [50, 20]], None, 0], [[[50, 20], [60, 20]], 5, 0]]},
            "no es un objeto": [1, 2, 3],
        }
        for nombre, d in malos.items():
            with self.subTest(nombre):
                with self.assertRaises(ValueError):
                    sim.datos_de_codigo(codigo(d))

    def test_bomba_de_descompresion(self):
        bomba = "DING1-" + base64.urlsafe_b64encode(zlib.compress(b" " * 5_000_000, 9)).decode().rstrip("=")
        with self.assertRaises(ValueError):
            sim.nivel_de_codigo(bomba)


class NivelesEntrega1(unittest.TestCase):
    """Los 10 niveles de la entrega 1 y los casos compartidos con la versión de Godot."""

    def test_json_al_dia(self):
        import niveles_entrega1 as gen
        archivos = gen.exportar(gen.niveles())
        for destino in gen.DESTINOS:
            for nombre, contenido in archivos.items():
                with self.subTest(str(destino / nombre)):
                    self.assertEqual((destino / nombre).read_text(encoding="utf-8"), contenido,
                                     "ejecuta: python -X utf8 niveles_entrega1.py")

    def test_niveles_validos(self):
        import niveles_entrega1 as gen
        lista = gen.niveles()
        self.assertEqual([n["id"] for n in lista], list(range(1, 11)))
        self.assertEqual(gen.validar(lista), [])

    def test_casos_compartidos(self):
        import json
        import niveles_entrega1 as gen
        datos = json.loads((gen.DATOS / "casos_compartidos.json").read_text(encoding="utf-8"))
        self.assertEqual(len(datos["casos"]), 20 + len(gen.casos_reglas()))   # 10 soluciones, 8 intentos, 2 de borde y las reglas
        for caso in datos["casos"]:
            with self.subTest(caso["nombre"]):
                n = sim.nivel_de_dict(caso["nivel"])
                tramos = [Tramo([tuple(p) for p in t["puntos"]], t["padre"], t["desde"]) for t in caso["tramos"]]
                # JSON convierte las tuplas en listas: se compara en la misma forma
                obtenido = json.loads(json.dumps(simular(n, tramos)))
                self.assertEqual(obtenido, caso["esperado"])


if __name__ == "__main__":
    unittest.main()
