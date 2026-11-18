## Tablero del editor del Taller: el mismo dibujo que en la partida, pero el dedo coloca piezas.
##
## Herramientas: «inicio», «campana», «doble», «numerada», «muro» (arrastrar) y «goma».
## Cada cambio emite `editado`; la pantalla del Taller guarda el borrador y valida.
extends "res://escenas/partida/tablero.gd"

signal editado
signal aviso(texto: String)

const Partida = preload("res://nucleo/partida.gd")
const LIMITES := {"campanas": 6, "numeradas": 4, "muros": 12}
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
			if herramienta == "muro":
				_muro_desde = p
				_muro_hasta = p
			else:
				_aplicar(p)
		elif herramienta == "muro" and _muro_desde != null:
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
		"campana", "doble", "numerada":
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
		"goma":
			if not _borrar_cerca(p):
				return
	_refrescar()
	editado.emit()


func _terminar_muro() -> void:
	var a: Array = _muro_desde
	var b: Array = _muro_hasta
	_muro_desde = null
	_muro_hasta = null
	queue_redraw()
	if Sim.dist(a, b) < MURO_MINIMO:
		aviso.emit("Arrastra el dedo para dibujar el muro.")
		return
	if nivel["mu"].size() >= LIMITES["muros"]:
		aviso.emit("Como mucho 12 muros por nivel.")
		return
	nivel["mu"].append([[snappedf(a[0], 0.1), snappedf(a[1], 0.1)], [snappedf(b[0], 0.1), snappedf(b[1], 0.1)]])
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
	aviso.emit("Toca una campana o un muro para quitarlo.")
	return false


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
