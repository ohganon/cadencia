"""Construye la matriz comparativa de la Fase 2 y las clasificaciones por dimensión.

Uso: python -I -X utf8 matriz.py <carpeta_datos>

Entradas:  <carpeta_datos>/edades.json (clasificación por edad real del App Store ES)
Salidas:   <carpeta_datos>/matriz50.csv y <carpeta_datos>/rankings_dimensiones.json

Las puntuaciones (1-5) son juicio profesional documentado en las fichas de los lotes 1-4.
Los atributos de monetización proceden de las compras integradas oficiales (datos/iap_lote*.txt).
"""
import csv
import json
import os
import statistics as st
import sys
from collections import Counter

D = sys.argv[1]
edades = json.load(open(os.path.join(D, "edades.json"), encoding="utf-8"))

# juego: (estrato, subgénero, modelo, meta, social, pase, sin_anuncios(€), oferta_fallo,
#         suscripción, azar_de_pago, moneda_de_pago, GP, RET, MON, VIS, PRO, VIR, EQU, S/P)
G = {
    "Royal Match": ("1", "Match-3", "Compras", "Decoración", "Equipos", 1, "-", 0, 0, 0, 1, 5, 5, 5, 5, 5, 3, 5, 5),
    "Royal Kingdom": ("1", "Match-3", "Compras", "Decoración", "Equipos", 1, "-", 0, 0, 0, 1, 5, 4, 5, 5, 5, 3, 5, 5),
    "Toon Blast": ("1", "Tap-blast", "Compras", "Episodios", "Equipos", 0, "-", 0, 0, 0, 1, 4, 5, 4, 4, 4, 3, 4, 4),
    "Match Factory!": ("1", "Triple match 3D", "Compras", "Episodios", "Equipos", 1, "-", 0, 0, 0, 1, 4, 4, 4, 4, 4, 4, 4, 4),
    "Gardenscapes": ("1", "Match-3", "Compras", "Decoración+narrativa", "Equipos", 1, "-", 0, 0, 0, 1, 4, 4, 5, 5, 4, 3, 4, 3),
    "Township": ("1", "Granja/ciudad", "Compras", "Construcción", "Cooperativas", 1, "-", 0, 0, 0, 1, 4, 5, 5, 4, 5, 2, 4, 3),
    "Gossip Harbor": ("1", "Merge-2", "Compras", "Narrativa", "Mínimo", 1, "-", 0, 0, 0, 1, 3, 5, 5, 4, 4, 2, 4, 3),
    "Travel Town": ("1", "Merge-2", "Compras", "Restauración", "Amigos", 0, "-", 0, 0, 0, 1, 3, 4, 4, 3, 4, 2, 3, 3),
    "Tasty Travels": ("1", "Merge-2", "Compras", "Viajes/cocina", "Mínimo", 0, "-", 0, 0, 0, 1, 3, 4, 4, 4, 4, 2, 4, 3),
    "Disney Solitaire": ("1", "Solitario TriPeaks", "Compras", "Colección (licencia)", "Mínimo", 0, "-", 0, 0, 0, 1, 4, 4, 5, 5, 4, 3, 4, 4),
    "Jelly Busters": ("1", "Ordenar/romper", "Híbrido", "Mínimo", "Mínimo", 0, "-", 0, 0, 0, 1, 4, 3, 3, 4, 3, 4, 3, 4),
    "Screwdom": ("1", "Tornillos 3D", "Híbrido", "Mínimo", "Mínimo", 0, "-", 0, 0, 0, 1, 4, 3, 3, 3, 3, 4, 3, 4),
    "Solitaire Associations Journey": ("1", "Solitario+palabras", "Híbrido", "Mínimo", "Mínimo", 0, "9,99", 1, 0, 0, 1, 4, 3, 3, 3, 3, 3, 3, 4),
    "Block Out!": ("2", "Bloques de color", "Híbrido", "Mínimo", "Mínimo", 1, "-", 0, 0, 0, 1, 4, 3, 4, 4, 3, 4, 3, 4),
    "Magic Sort!": ("2", "Ordenar líquidos", "Híbrido", "Mínimo", "Mínimo", 0, "-", 1, 0, 0, 1, 4, 3, 5, 4, 3, 4, 3, 4),
    "Meowdoku!": ("2", "Lógica (Star Battle)", "Anuncios+suscripción", "Ninguno", "Ninguno", 0, "-", 0, 1, 0, 0, 5, 4, 3, 4, 3, 5, 2, 5),
    "Amaze GO!": ("2", "Flechas", "Anuncios", "Ninguno", "Ninguno", 0, "-", 0, 0, 0, 0, 3, 2, 2, 3, 2, 3, 2, 4),
    "Bus Traffic Fever!": ("2", "Tráfico/colores", "Híbrido", "Mínimo", "Mínimo", 1, "14,99", 1, 0, 0, 1, 4, 3, 3, 3, 3, 4, 3, 4),
    "CubeAway": ("2", "Desmontar 3D", "Híbrido", "Mínimo", "Mínimo", 0, "8,99", 0, 0, 0, 1, 4, 3, 3, 3, 3, 4, 3, 4),
    "Pixel Flow!": ("2", "Shooter de colores", "Híbrido", "Imagen a completar", "Mínimo", 1, "8,99", 1, 0, 0, 1, 5, 4, 5, 4, 4, 5, 3, 5),
    "Colony Flow!": ("2", "Shooter de colores", "Híbrido", "Mínimo", "Mínimo", 1, "8,99", 1, 0, 0, 1, 3, 3, 4, 3, 3, 4, 3, 3),
    "Sand Blocks": ("2", "Bloques de arena", "Híbrido", "Mínimo", "Mínimo", 1, "8,99", 1, 0, 0, 1, 4, 3, 3, 4, 3, 5, 3, 4),
    "Yarn Loop": ("2", "Ordenar lana", "Híbrido", "Mínimo", "Mínimo", 0, "-", 0, 0, 0, 1, 4, 3, 4, 4, 3, 4, 3, 4),
    "Parking Loop": ("2", "Tráfico", "Híbrido", "Mínimo", "Mínimo", 0, "0,99", 1, 0, 0, 1, 3, 2, 3, 3, 2, 3, 2, 3),
    "Cube Smash": ("2", "Romper cubos", "Híbrido", "Mínimo", "Mínimo", 0, "-", 0, 0, 0, 1, 3, 2, 3, 3, 2, 3, 3, 3),
    "Vita Mahjong": ("3", "Mahjong", "Híbrido+suscripción", "Mínimo", "Mínimo", 0, "6,99", 0, 1, 0, 1, 3, 4, 4, 3, 3, 2, 3, 4),
    "Word Tiles": ("3", "Palabras", "Híbrido", "Mínimo", "Mínimo", 0, "9,99", 0, 0, 0, 1, 3, 3, 3, 3, 3, 2, 3, 3),
    "Brain Puzzle 3": ("3", "Acertijos", "Anuncios", "Ninguno", "Ninguno", 0, "6,99", 0, 0, 0, 0, 3, 2, 2, 2, 2, 4, 2, 3),
    "Magic Tiles 3": ("3", "Ritmo", "Híbrido+suscripción", "Canciones", "Mínimo", 0, "9,99", 0, 1, 0, 1, 4, 3, 4, 3, 3, 4, 3, 4),
    "Paper.io 2": ("3", "IO territorial", "Anuncios+cosmética", "Skins", "PvP con bots", 0, "9,99", 0, 0, 0, 1, 4, 3, 3, 3, 2, 4, 2, 4),
    "Mob Control": ("3", "Casual híbrido", "Híbrido", "Cartas/mejoras", "PvP", 1, "-", 0, 0, 1, 1, 4, 3, 4, 4, 4, 4, 3, 3),
    "Subway Surfers": ("3", "Endless runner", "Híbrido", "Colección+World Tour", "Mínimo", 1, "-", 0, 0, 0, 1, 4, 4, 4, 4, 3, 5, 4, 4),
    "Geometry Dash Lite": ("3", "Plataformas rítmico", "Demo+premium", "Iconos", "Contenido de usuarios", 0, "-", 0, 0, 0, 0, 5, 4, 3, 4, 4, 5, 4, 5),
    "MONOPOLY GO!": ("4", "Tablero de dados", "Compras", "Construcción+álbum", "Intercambio", 0, "-", 0, 0, 1, 1, 3, 5, 5, 4, 4, 4, 4, 3),
    "Coin Master": ("4", "Tragaperras+aldea", "Compras", "Construcción+cartas", "Ataques/amigos", 0, "-", 0, 0, 1, 1, 2, 4, 5, 3, 3, 4, 3, 2),
    "Pokémon GO": ("4", "Geolocalización", "Compras", "Colección", "Presencial", 1, "-", 0, 0, 0, 1, 4, 5, 5, 4, 5, 5, 4, 4),
    "Pokémon TCG Pocket": ("4", "Cartas", "Compras", "Colección", "Intercambio/PvP", 1, "-", 0, 0, 1, 1, 4, 3, 5, 5, 4, 4, 4, 4),
    "BitLife": ("4", "Simulador de vida", "Pago único+expansiones", "Vidas", "Compartir historias", 0, "8,99", 0, 0, 0, 0, 4, 4, 4, 2, 3, 5, 3, 4),
    "Parchisi STAR": ("4", "Parchís online", "Compras", "Cosmética", "PvP con amigos", 1, "-", 0, 0, 1, 1, 3, 4, 3, 3, 3, 3, 3, 4),
    "8 Ball Pool": ("4", "Billar", "Compras", "Tacos/ligas", "PvP", 1, "-", 0, 1, 1, 1, 4, 4, 4, 3, 4, 3, 3, 4),
    "Among Us!": ("4", "Deducción social", "Cosmética", "Cosmética", "Multijugador", 0, "1,99", 0, 0, 0, 1, 4, 3, 2, 4, 2, 5, 4, 4),
    "NYT Games": ("5", "Pasatiempos diarios", "Suscripción", "Rachas/archivo", "Conversación diaria", 0, "-", 0, 1, 0, 0, 5, 5, 4, 4, 3, 5, 5, 5),
    "Chess.com": ("5", "Ajedrez", "Suscripción por niveles", "Rating/lecciones", "PvP", 0, "-", 0, 1, 0, 0, 5, 5, 4, 3, 5, 4, 4, 5),
    "Clash Royale": ("5", "Estrategia con cartas", "Compras", "Mazo/trofeos", "PvP+clanes", 1, "-", 0, 0, 0, 1, 5, 5, 5, 5, 5, 4, 5, 5),
    "Brawl Stars": ("5", "Acción por equipos", "Compras", "Personajes", "PvP+clubes", 1, "-", 0, 0, 0, 1, 5, 4, 4, 5, 5, 4, 5, 4),
    "Whiteout Survival": ("5", "4X", "Compras", "Ciudad/héroes", "Alianzas", 1, "-", 0, 0, 0, 1, 3, 5, 5, 4, 5, 2, 4, 2),
    "Roblox": ("5", "Plataforma de contenido de usuarios", "Suscripción+moneda", "Plataforma", "Contenido de usuarios", 0, "-", 0, 1, 0, 1, 4, 5, 5, 3, 4, 5, 4, 4),
    "Balatro": ("6", "Roguelike de póker", "Premium", "Desbloqueos", "Ninguno", 0, "-", 0, 0, 0, 0, 5, 5, 3, 5, 4, 5, 5, 5),
    "Mini Metro": ("6", "Diseño de redes", "Premium", "Ciudades", "Ninguno", 0, "-", 0, 0, 0, 0, 5, 3, 2, 5, 3, 3, 5, 5),
    "Bloons TD 6": ("6", "Tower defense", "Premium+compras", "Héroes/mapas", "Cooperativo+contenido de usuarios", 0, "-", 0, 0, 0, 1, 5, 5, 4, 4, 5, 3, 5, 4),
}
COLS = ["GP", "RET", "MON", "VIS", "PRO", "VIR", "EQU", "S/P"]


def riesgo(v):
    """Riesgo frente a la propuesta de DFA si el juego se considera 'dirigido a menores'
    (clasificación inferior a 18 años)."""
    azar, fallo, moneda = v[9], v[7], v[10]
    if azar or (fallo and moneda):
        return "Alto"
    if moneda or fallo:
        return "Medio"
    return "Bajo"


rows = []
for k, v in G.items():
    sc = dict(zip(COLS, v[11:]))
    rows.append(dict(
        juego=k, estrato=v[0], subgenero=v[1], modelo=v[2], meta=v[3], social=v[4],
        pase="Sí" if v[5] else "No", sin_anuncios=v[6], oferta_fallo="Sí" if v[7] else "No",
        suscripcion="Sí" if v[8] else "No", azar_pago="Sí" if v[9] else "No",
        moneda_pago="Sí" if v[10] else "No", edad_ES=edades[k]["edad"], riesgo_DFA=riesgo(v),
        **sc, total=sum(v[11:])))

with open(os.path.join(D, "matriz50.csv"), "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=rows[0].keys())
    w.writeheader()
    w.writerows(rows)

rk = {c: sorted(rows, key=lambda r: (-r[c], -r["total"], r["juego"]))[:10] for c in COLS + ["total"]}
json.dump({c: [(r["juego"], r[c], r["total"]) for r in v] for c, v in rk.items()},
          open(os.path.join(D, "rankings_dimensiones.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)

print("n", len(rows))
for fld in ["modelo", "pase", "oferta_fallo", "suscripcion", "azar_pago", "moneda_pago", "edad_ES", "riesgo_DFA"]:
    print(fld, Counter(r[fld] for r in rows).most_common())
print("venden 'sin anuncios':", sum(1 for r in rows if r["sin_anuncios"] != "-"))
for c in COLS + ["total"]:
    print("\n#", c, "; ".join(f"{r['juego']} {r[c]}" for r in rk[c]))
for e in "123456":
    t = [r["total"] for r in rows if r["estrato"] == e]
    print("estrato", e, "media", round(st.mean(t), 1))
print("\nriesgo bajo, por total:", [(r["juego"], r["total"]) for r in sorted(rows, key=lambda r: -r["total"]) if r["riesgo_DFA"] == "Bajo"])
print("edad < 18:", sum(1 for r in rows if r["edad_ES"] != "18+"))
