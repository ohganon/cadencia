## Las piezas del juego, explicadas en una frase (guía de piezas y presentación de la primera vez).
##
## `de_nivel(nivel)` dice qué piezas lleva un nivel, en el orden de esta lista, para presentar las que
## el jugador aún no ha visto. La campana sencilla y el muro no se presentan: los enseña el nivel 1.
extends RefCounted

const PIEZAS := [
	{"id": "campana", "nombre": "Campana", "icono": "campana_simple",
		"texto": "Haz que una ficha llegue hasta ella para que suene."},
	{"id": "muro", "nombre": "Muro", "icono": "muro",
		"texto": "La cadena no lo puede cruzar: rodéalo."},
	{"id": "doble", "nombre": "Campana doble", "icono": "doble",
		"texto": "Necesita dos ramas distintas que lleguen a la vez (un tic de diferencia como mucho)."},
	{"id": "numerada", "nombre": "Campanas numeradas", "icono": "numerada",
		"texto": "Tienen que sonar en orden: primero la 1, luego la 2…"},
	{"id": "dorada", "nombre": "Campana dorada", "icono": "dorada",
		"texto": "Opcional: si suena, ganas la tercera estrella."},
	{"id": "puerta", "nombre": "Puerta de vaivén", "icono": "puerta",
		"texto": "Se abre y se cierra a su ritmo: llega cuando esté abierta. Encima pone cuándo abre."},
	{"id": "espiral", "nombre": "Espiral", "icono": "espiral",
		"texto": "Retrasa lo que pasa por ella tantos tics como marca (+4, +6…) sin ocupar sitio."},
	{"id": "muelle", "nombre": "Muelle", "icono": "muelle",
		"texto": "Lanza la cadena por encima del muro: al llegar a la entrada, sigue dibujando desde la salida."},
	{"id": "interruptor", "nombre": "Interruptor", "icono": "interruptor",
		"texto": "Su compuerta está cerrada hasta que cae una ficha en la placa."},
	{"id": "noria", "nombre": "Noria", "icono": "noria",
		"texto": "Como el muelle, pero suelta la cadena en su siguiente vuelta: llegar un poco antes o después da igual."},
	{"id": "globo", "nombre": "Globo", "icono": "globo",
		"texto": "Lleva un camino de fichas gratis: tócalo con la cadena y revienta."},
	{"id": "cristal", "nombre": "Cristal", "icono": "cristal",
		"texto": "Para la cadena como un muro, pero se rompe: la rama que choca se queda ahí y las siguientes pasan."},
]

## Piezas que se presentan la primera vez que salen (las demás las enseña el nivel 1)
const SIN_PRESENTAR := ["campana", "muro"]


static func de(id: String) -> Dictionary:
	for p in PIEZAS:
		if p["id"] == id:
			return p
	return {}


## Ids de las piezas que lleva un nivel, en el orden de PIEZAS.
static func de_nivel(nivel: Dictionary) -> Array:
	var hay := {}
	for c in nivel.get("c", []):
		hay[{"simple": "campana", "doble": "doble", "numerada": "numerada", "dorada": "dorada"}.get(c[2], "campana")] = true
	var claves := {"mu": "muro", "p": "puerta", "e": "espiral", "ml": "muelle", "in": "interruptor", "nr": "noria",
		"gl": "globo", "cr": "cristal"}
	for k in claves:
		if not nivel.get(k, []).is_empty():
			hay[claves[k]] = true
	var r := []
	for p in PIEZAS:
		if hay.has(p["id"]):
			r.append(p["id"])
	return r


## Las piezas de un nivel que todavía no se le han presentado al jugador.
static func nuevas(nivel: Dictionary, vistas: Array) -> Array:
	var r := []
	for id in de_nivel(nivel):
		if not (id in SIN_PRESENTAR) and not (id in vistas):
			r.append(id)
	return r
