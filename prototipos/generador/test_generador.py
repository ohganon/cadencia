"""Pruebas del generador y de la Caída del Día.  Uso (desde esta carpeta):  python -X utf8 -m unittest -v test_generador"""
import datetime as dt
import json
import pathlib
import unittest

import generador as G
import sim
from sim import Tramo, simular

DATOS = pathlib.Path(__file__).resolve().parent.parent / "simulacion" / "datos" / "caida_del_dia.json"


def tramos_de(lista):
    return [Tramo([tuple(p) for p in t["puntos"]], t["padre"], t["desde"]) for t in lista]


class Generador(unittest.TestCase):
    def test_determinista(self):
        a = G.a_dict(G.generar(77, "doble", 0.5))
        b = G.a_dict(G.generar(77, "doble", 0.5))
        self.assertEqual(a, b)

    def test_cada_tipo_genera_niveles_validos(self):
        for tipo in G.TIPOS:
            for semilla in (5, 6):
                with self.subTest(tipo=tipo, semilla=semilla):
                    g = G.generar(semilla, tipo, 0.5)
                    self.assertIsNotNone(g)
                    r = simular(g.nivel, g.solucion)
                    self.assertTrue(r["exito"], r)
                    self.assertEqual(r["fichas_usadas"], g.nivel.marca)
                    self.assertGreaterEqual(g.nivel.fichas - g.nivel.marca, 2)
                    # Ningún atajo en línea recta resuelve el nivel
                    self.assertEqual(G.atajos(g.nivel)["recto"], 0)
                    # Los muros no cruzan la solución ni se pegan entre sí
                    for m in g.nivel.muros:
                        for a, b in G._segmentos(g.solucion):
                            self.assertFalse(sim._cruza(m[0], m[1], a, b))
                    for i, m in enumerate(g.nivel.muros):
                        for o in g.nivel.muros[i + 1:]:
                            self.assertTrue(G._separados(m, o))

    def test_numeradas_en_orden_real_de_llegada(self):
        g = G.generar(11, "numeradas", 0.5)
        r = simular(g.nivel, g.solucion)
        tics = [r["campanas"][c.id] for c in sorted(g.nivel.campanas, key=lambda c: c.numero)]
        self.assertEqual(tics, sorted(tics))

    def test_campana_doble_con_muro_debajo(self):
        g = G.generar(12, "doble", 0.5)
        d = g.nivel.campanas[0].pos
        debajo = [m for m in g.nivel.muros if m[0][1] == m[1][1] and d[1] < m[0][1] < d[1] + 16
                  and min(m[0][0], m[1][0]) < d[0] < max(m[0][0], m[1][0])]
        self.assertTrue(debajo, "falta el muro que corta la horquilla simétrica")

    def test_mas_dificil_menos_margen(self):
        facil = G.generar(21, "dos", 0.1)
        dificil = G.generar(21, "dos", 0.9)
        self.assertGreater(facil.nivel.fichas - facil.nivel.marca, dificil.nivel.fichas - dificil.nivel.marca)


class CaidaDelDia(unittest.TestCase):
    def test_mismo_dia_mismo_nivel(self):
        f = dt.date(2026, 11, 18)
        self.assertEqual(G.a_dict(G.caida_del_dia(f)), G.a_dict(G.caida_del_dia(f)))
        self.assertNotEqual(G.a_dict(G.caida_del_dia(f)), G.a_dict(G.caida_del_dia(f + dt.timedelta(days=1))))

    def test_ritmo_semanal(self):
        lunes = dt.date(2026, 11, 16)
        self.assertEqual(lunes.weekday(), 0)
        self.assertEqual(G.caida_del_dia(lunes).tipo, G.RITMO[0][0])

    def test_calendario_publicado(self):
        d = json.loads(DATOS.read_text(encoding="utf-8"))
        self.assertEqual(d["dias"], len(d["niveles"]))
        fechas = [e["fecha"] for e in d["niveles"]]
        self.assertEqual(fechas, sorted(set(fechas)))
        for e in d["niveles"]:
            n = sim.nivel_de_dict(e["nivel"])
            r = simular(n, tramos_de(e["solucion"]))
            self.assertTrue(r["exito"], e["fecha"])
            # La solución de referencia hace sonar la dorada sin pasarse de la marca: 3 estrellas
            doradas = [c for c in n.campanas if c.tipo == "dorada"]
            self.assertEqual(len(doradas), 1, e["fecha"])
            self.assertIsNotNone(r["campanas"][doradas[0].id], e["fecha"])
            self.assertLessEqual(r["fichas_usadas"], n.marca, e["fecha"])
        # Los primeros días coinciden con lo que genera el código actual
        for e in d["niveles"][:3]:
            g = G.caida_del_dia(dt.date.fromisoformat(e["fecha"]))
            self.assertEqual({k: v for k, v in e.items() if k != "fecha"}, json.loads(json.dumps(G.a_dict(g))))
        # La copia de Godot es idéntica
        godot = pathlib.Path(__file__).resolve().parents[2] / "godot" / "datos" / "caida_del_dia.json"
        self.assertEqual(godot.read_bytes(), DATOS.read_bytes())


class Barrio(unittest.TestCase):
    def test_barrio_al_dia_y_con_solucion(self):
        import barrio
        primero = 1
        for nombre, texto in barrio.archivos().items():
            self.assertEqual((barrio.DATOS / nombre).read_text(encoding="utf-8"), texto, "ejecuta: python -X utf8 barrio.py")
            d = json.loads(texto)
            self.assertEqual([n["id"] for n in d["niveles"]], list(range(primero, primero + 20)))
            for n in d["niveles"]:
                r = simular(sim.nivel_de_dict(n["nivel"]), tramos_de(n["solucion"]))
                self.assertTrue(r["exito"], n["id"])
                self.assertEqual(r["fichas_usadas"], n["nivel"]["m"])
            primero += 20

    def test_niveles_con_puertas(self):
        for tipo in G.TIPOS_PUERTA:
            for semilla in (41, 42, 43):
                with self.subTest(tipo=tipo, semilla=semilla):
                    g = G.generar(semilla, tipo, 0.6)
                    self.assertIsNotNone(g)
                    self.assertEqual(len(g.nivel.puertas), 1 if tipo == "puerta" else 2)
                    self.assertTrue(simular(g.nivel, g.solucion)["exito"])
                    # La línea recta por los huecos no sirve: llega a destiempo a alguna puerta
                    self.assertEqual(G.atajos(g.nivel)["recto"], 0)
                    huecos = sorted([((p.a[0] + p.b[0]) / 2, p.a[1]) for p in g.nivel.puertas], key=lambda h: -h[1])
                    recta = simular(g.nivel, [Tramo([g.nivel.inicio] + huecos + [g.nivel.campanas[0].pos])])
                    self.assertFalse(recta["exito"])


    def test_niveles_con_espiral(self):
        for tipo in G.TIPOS_ESPIRAL:
            for semilla in (51, 52, 53):
                with self.subTest(tipo=tipo, semilla=semilla):
                    g = G.generar(semilla, tipo, 0.6)
                    self.assertIsNotNone(g)
                    self.assertEqual(len(g.nivel.espirales), 1)
                    self.assertTrue(simular(g.nivel, g.solucion)["exito"])
                    self.assertEqual(G.atajos(g.nivel)["recto"], 0)
                    # Sin la espiral, la solución de referencia ya no sirve: la espiral es la clave
                    g.nivel.espirales = []
                    self.assertFalse(simular(g.nivel, g.solucion)["exito"])


if __name__ == "__main__":
    unittest.main()
