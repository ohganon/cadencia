## Tablero del editor del Taller: el mismo dibujo que en la partida, pero el dedo coloca piezas.
##
## Herramientas: «inicio», «campana», «doble», «numerada», «dorada», «muro» y «puerta» (arrastrar),
## «espiral» (tocar para ponerla; tocarla otra vez cambia su retraso) y «goma».
## Cada cambio emite `editado`; la pantalla del Taller guarda el borrador y valida.
extends "res://escenas/partida/tablero.gd"

signal editado
signal aviso(texto: String)

const Partida = preload("res://nucleo/partida.gd")
const LIMITES := {"campanas": 6, "numeradas": 4, "muros": 12, "puertas": 6, "espirales": 4, "muelles": 4}
## Salto de un muelle nuevo, y cuánto sube al tocar su entrada (de 2 en 2 hasta 20, y vuelta a 2)
const SALTO_NUEVO := 6
const SALTO_MAXIMO := 20
## Retraso de una espiral nueva, y cuánto sube al tocarla (de 2 en 2 hasta 12, y vuelta a 2)
const RETARDO_NUEVO := 4
const RETARDO_MAXIMO := 12
## Ritmo de una puerta nueva: periodo 16 tics, abierta 5. Tocarla adelanta cuándo se abre.
const PUERTA_NUEVA := [16, 5, 0]
const PASO_FASE := 4
const MURO_MINIMO := 6.0

var herramienta := "campana"
var nivel: Dictionary = {}
var _muro_desde = null           # punto lógico donde empezó a arrastrarse un muro
var _muro_hasta = null


func editar_nivel(n: Dictionary) -> void:
	nivel = n
	_refrescar()


func _refrescar() -> void:
	var dibujo := nivel.duplicate(true)
	dibujo["f"] = 400
	preparar(Partida.new(dibujo))


func _limitar(p: Array) -> Array:
	return [clampf(p[0], 4.0, float(nivel["w"]) - 4.0), clampf(p[1], 4.0, float(nivel["h"]) - 4.0)]


func _gui_input(evento: InputEvent) -> void:
	if nivel.is_empty():
		return
	_medir()
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		var p := _limitar(a_logico(evento.position))
		if evento.pressed:
			if herramienta == "puerta" and _cambiar_ritmo(p):
				return
			if herramienta == "muelle" and _cambiar_salto(p):
				return
			if herramienta in ["muro", "puerta", "muelle"]:
				_muro_desde = p
				_muro_hasta = p
			else:
				_aplicar(p)
		elif herramienta in ["muro", "puerta", "muelle"] and _muro_desde != null:
			_terminar_muro()
		accept_event()
	elif evento is InputEventMouseMotion and _muro_desde != null:
		_muro_hasta = _limitar(a_logico(evento.position))
		queue_redraw()
		accept_event()


func _aplicar(p: Array) -> void:
	var campanas: Array = nivel["c"]
	match herramienta:
		"inicio":
			nivel["i"] = [snappedf(p[0], 0.1), snappedf(p[1], 0.1)]
		"campana", "doble", "numerada", "dorada":
			if campanas.size() >= LIMITES["campanas"]:
				aviso.emit("Como mucho 6 campanas por nivel.")
				return
			if Sim.dist(p, nivel["i"]) < 12.0:
				aviso.emit("Pon la campana un poco más lejos del inicio.")
				return
			for c in campanas:
				if Sim.dist(p, c[1]) < 2 * Sim.RADIO_CAMPANA:
					aviso.emit("Ahí ya hay una campana.")
					return
			if herramienta == "dorada":
				for c in campanas:
					if c[2] == "dorada":
						aviso.emit("Solo puede haber una campana dorada.")
						return
			var numero := 0
			if herramienta == "numerada":
				for c in campanas:
					if c[2] == "numerada":
						numero += 1
				numero += 1
				if numero > LIMITES["numeradas"]:
					aviso.emit("Como mucho 4 campanas numeradas.")
					return
			var tipo := "simple" if herramienta == "campana" else herramienta
			campanas.append([_id_libre(), [snappedf(p[0], 0.1), snappedf(p[1], 0.1)], tipo, numero])
		"espiral":
			if not nivel.has("e"):
				nivel["e"] = []
			var k := _espiral_cerca(p)
			if k >= 0:
				var e: Array = nivel["e"][k]
				e[1] = int(e[1]) + 2 if int(e[1]) + 2 <= RETARDO_MAXIMO else 2
				aviso.emit("Esta espiral retrasa %d tics." % int(e[1]))
			elif nivel["e"].size() >= LIMITES["espirales"]:
				aviso.emit("Como mucho 4 espirales por nivel.")
				return
			else:
				nivel["e"].append([[snappedf(p[0], 0.1), snappedf(p[1], 0.1)], RETARDO_NUEVO])
				aviso.emit("Retrasa %d tics lo que pase por ella. Tócala para cambiarlo." % RETARDO_NUEVO)
		"goma":
			if not _borrar_cerca(p):
				return
	_refrescar()
	editado.emit()


func _terminar_muro() -> void:
	if herramienta == "muelle":
		_terminar_muelle()
		return
	var a: Array = _muro_desde
	var b: Array = _muro_hasta
	_muro_desde = null
	_muro_hasta = null
	queue_redraw()
	var es_puerta := herramienta == "puerta"
	if Sim.dist(a, b) < MURO_MINIMO:
		aviso.emit("Arrastra el dedo para dibujar la puerta." if es_puerta else "Arrastra el dedo para dibujar el muro.")
		return
	var extremos := [[snappedf(a[0], 0.1), snappedf(a[1], 0.1)], [snappedf(b[0], 0.1), snappedf(b[1], 0.1)]]
	if es_puerta:
		if nivel["p"].size() >= LIMITES["puertas"]:
			aviso.emit("Como mucho 6 puertas por nivel.")
			return
		nivel["p"].append(extremos + PUERTA_NUEVA.duplicate())
	else:
		if nivel["mu"].size() >= LIMITES["muros"]:
			aviso.emit("Como mucho 12 muros por nivel.")
			return
		nivel["mu"].append(extremos)
	_refrescar()
	editado.emit()


## Quita la campana más cercana (o el muro, si no hay campana cerca). Las numeradas que quedan se
## vuelven a numerar 1, 2, 3… para que el nivel siga siendo válido.
func _borrar_cerca(p: Array) -> bool:
	var mejor := -1
	var mejor_d := Sim.RADIO_CAMPANA + 2.0
	for k in nivel["c"].size():
		var d := Sim.dist(p, nivel["c"][k][1])
		if d < mejor_d:
			mejor_d = d
			mejor = k
	if mejor >= 0:
		nivel["c"].remove_at(mejor)
		var n := 0
		for c in nivel["c"]:
			if c[2] == "numerada":
				n += 1
				c[3] = n
		return true
	var puerta := _puerta_cerca(p)
	if puerta >= 0:
		nivel["p"].remove_at(puerta)
		return true
	var espiral := _espiral_cerca(p)
	if espiral >= 0:
		nivel["e"].remove_at(espiral)
		return true
	var muelle := _muelle_cerca(p)
	if muelle >= 0:
		nivel["ml"].remove_at(muelle)
		return true
	var muro := -1
	var muro_d := 4.0
	for k in nivel["mu"].size():
		var m: Array = nivel["mu"][k]
		var d := _distancia_segmento(p, m[0], m[1])
		if d < muro_d:
			muro_d = d
			muro = k
	if muro >= 0:
		nivel["mu"].remove_at(muro)
		return true
	aviso.emit("Toca una campana, una puerta, una espiral, un muelle o un muro para quitarlo.")
	return false


func _puerta_cerca(p: Array) -> int:
	var mejor := -1
	var mejor_d := 4.0
	for k in nivel["p"].size():
		var d := _distancia_segmento(p, nivel["p"][k][0], nivel["p"][k][1])
		if d < mejor_d:
			mejor_d = d
			mejor = k
	return mejor


## Tocar una puerta con la herramienta de puerta adelanta su apertura PASO_FASE tics.
func _cambiar_ritmo(p: Array) -> bool:
	var k := _puerta_cerca(p)
	if k < 0:
		return false
	var puerta: Array = nivel["p"][k]
	puerta[4] = posmod(int(puerta[4]) + PASO_FASE, int(puerta[2]))
	aviso.emit("Ahora se abre en el tic %d de cada %d." % [int(puerta[4]), int(puerta[2])])
	_refrescar()
	editado.emit()
	return true


## Muelle nuevo: se arrastra de la entrada a la salida.
func _terminar_muelle() -> void:
	var desde: Array = _muro_desde
	var hasta: Array = _muro_hasta
	_muro_desde = null
	_muro_hasta = null
	if not nivel.has("ml"):
		nivel["ml"] = []
	if Sim.dist(desde, hasta) < 2 * Sim.RADIO_MUELLE + 2:
		aviso.emit("Arrastra desde la entrada hasta donde quieras que salga la cadena.")
		queue_redraw()
		return
	if nivel["ml"].size() >= LIMITES["muelles"]:
		aviso.emit("Como mucho 4 muelles por nivel.")
		queue_redraw()
		return
	nivel["ml"].append([[snappedf(desde[0], 0.1), snappedf(desde[1], 0.1)], [snappedf(hasta[0], 0.1), snappedf(hasta[1], 0.1)], SALTO_NUEVO])
	aviso.emit("La cadena salta en %d tics. Toca la entrada para cambiarlo." % SALTO_NUEVO)
	_refrescar()
	editado.emit()


## Tocar la entrada de un muelle con su herramienta cambia el salto.
func _cambiar_salto(p: Array) -> bool:
	var lista: Array = nivel.get("ml", [])
	for m in lista:
		if Sim.dist(p, m[0]) <= Sim.RADIO_MUELLE + 2.0:
			m[2] = int(m[2]) + 2 if int(m[2]) + 2 <= SALTO_MAXIMO else 2
			aviso.emit("Este muelle salta en %d tics." % int(m[2]))
			_refrescar()
			editado.emit()
			return true
	return false


func _muelle_cerca(p: Array) -> int:
	var lista: Array = nivel.get("ml", [])
	for k in lista.size():
		if Sim.dist(p, lista[k][0]) <= Sim.RADIO_MUELLE + 2.0 or Sim.dist(p, lista[k][1]) <= Sim.RADIO_MUELLE + 2.0:
			return k
	return -1


func _espiral_cerca(p: Array) -> int:
	var mejor := -1
	var mejor_d := Sim.RADIO_ESPIRAL + 2.0
	var lista: Array = nivel.get("e", [])
	for k in lista.size():
		var d := Sim.dist(p, lista[k][0])
		if d < mejor_d:
			mejor_d = d
			mejor = k
	return mejor


func _id_libre() -> String:
	var usados := {}
	for c in nivel["c"]:
		usados[c[0]] = true
	for k in range(1, 20):
		if not usados.has("c%d" % k):
			return "c%d" % k
	return "c0"


static func _distancia_segmento(p: Array, a: Array, b: Array) -> float:
	var ab := Vector2(b[0] - a[0], b[1] - a[1])
	var ap := Vector2(p[0] - a[0], p[1] - a[1])
	var t := 0.0 if ab.length_squared() == 0.0 else clampf(ap.dot(ab) / ab.length_squared(), 0.0, 1.0)
	return (ap - ab * t).length()


func _draw() -> void:
	super()
	if _muro_desde != null and _muro_hasta != null:
		draw_line(a_pantalla(_muro_desde), a_pantalla(_muro_hasta), Color(TINTA, 0.55), 2.2 * _k, true)
