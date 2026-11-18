## La cuerda: la energía del juego (Fase 5, sección 1).
##
## - Cuesta 1 cuerda **empezar un nivel nuevo** de la campaña. Reintentar, repetir niveles superados,
##   la Caída del Día y el Taller no cuestan nada.
## - Máximo 5; se recupera 1 cada 30 minutos.
## - Los primeros 15 niveles no gastan cuerda (protección del jugador nuevo).
## - Se paga una vez por nivel: si sales y vuelves a entrar sin haberlo superado, no se cobra otra vez.
##
## Todo recibe la hora (segundos Unix) desde fuera, para poder probarlo sin esperar. Si el reloj del
## teléfono va hacia atrás, no se pierde cuerda ni se rompe nada: se toma la hora nueva como punto
## de partida.
extends RefCounted

const MAXIMO := 5
const RECARGA := 1800              # 30 minutos
const GRATIS_HASTA := 15           # los niveles 1–15 no gastan cuerda


## Estado guardado {n, t}: n cuerdas en el instante t. Devuelve el estado al día en `ahora`.
static func al_dia(c: Dictionary, ahora: int) -> Dictionary:
	var n := clampi(int(c.get("n", MAXIMO)), 0, MAXIMO)
	var t := int(c.get("t", ahora))
	if t > ahora:                  # el reloj fue hacia atrás: se reinicia el conteo, sin quitar nada
		t = ahora
	if n >= MAXIMO:
		return {"n": MAXIMO, "t": ahora}
	var ganadas := (ahora - t) / RECARGA
	n = mini(MAXIMO, n + ganadas)
	t = ahora if n >= MAXIMO else t + ganadas * RECARGA
	return {"n": n, "t": t}


## Segundos que faltan para la siguiente cuerda (0 si está llena).
static func falta(c: Dictionary, ahora: int) -> int:
	var d := al_dia(c, ahora)
	if d["n"] >= MAXIMO:
		return 0
	return RECARGA - (ahora - int(d["t"]))


## Gasta una cuerda. Devuelve el estado nuevo, o un diccionario vacío si no queda ninguna.
static func gastar(c: Dictionary, ahora: int) -> Dictionary:
	var d := al_dia(c, ahora)
	if d["n"] <= 0:
		return {}
	if d["n"] >= MAXIMO:
		d["t"] = ahora             # empieza a contar la recarga desde este momento
	d["n"] -= 1
	return d


static func necesita(id: int) -> bool:
	return id > GRATIS_HASTA


## «12:40» para el contador de la recarga.
static func reloj(segundos: int) -> String:
	return "%d:%02d" % [segundos / 60, segundos % 60]
