## Pío, el pájaro de hojalata de Dominó Pop, dibujado en código con las formas de la maqueta
## (docs/fase6/tablero/index.html, símbolo «pio», caja de 60 × 60): cuerpo y cabeza cian con contorno
## de tinta, ojo con brillo, pico amarillo, ala azul y los dos trazos con el círculo amarillo con los
## que señala el camino.
##
## En el mapa se pone entre el nivel que toca y el siguiente, mirando hacia el siguiente. Animaciones
## (todas lentas y pequeñas; con «reducir movimiento», quieto):
## - respira (sube y baja un poco), parpadea y de vez en cuando aletea;
## - vuela() de un sitio a otro en arco, batiendo las alas, y al llegar da un saltito.
## Es decoración: no recoge el dedo, así que nunca tapa un nivel.
extends Control

const Temas = preload("res://nucleo/temas.gd")

const CIAN := Color("#29d3f5")
const CIAN_ALA := Color("#0d8fb5")
const AMARILLO := Color("#ffc83d")
const TINTA := Color("#142554")
const DURACION_VUELO := 0.9

## Mira a la izquierda (si el nivel siguiente está a ese lado)
var a_la_izquierda := false:
	set(v):
		a_la_izquierda = v
		queue_redraw()

var _t := 0.0
var _vuelo := -1.0               # progreso del vuelo de 0 a 1 (-1: no vuela)
var _desde := Vector2.ZERO
var _hasta := Vector2.ZERO
var _salto := -1.0               # saltito al llegar, de 0 a 1


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	set_process(not Temas.reducir_movimiento)


## Vuela desde `desde` hasta su posición actual (las dos, esquina de arriba a la izquierda).
func vuela(desde: Vector2) -> void:
	_hasta = position
	if Temas.reducir_movimiento or desde.distance_to(_hasta) < 1.0:
		return
	_desde = desde
	position = desde
	_vuelo = 0.0
	a_la_izquierda = _hasta.x < _desde.x
	set_process(true)


func _process(delta: float) -> void:
	_t += delta
	if _vuelo >= 0.0:
		_vuelo = minf(_vuelo + delta / DURACION_VUELO, 1.0)
		var u := _vuelo * _vuelo * (3.0 - 2.0 * _vuelo)
		var alto := minf(_desde.distance_to(_hasta) * 0.35, 160.0)
		position = _desde.lerp(_hasta, u) + Vector2(0, -alto * 4.0 * u * (1.0 - u))
		if _vuelo >= 1.0:
			_vuelo = -1.0
			position = _hasta
			_salto = 0.0
	elif _salto >= 0.0:
		_salto += delta / 0.45
		if _salto >= 1.0:
			_salto = -1.0
	queue_redraw()


func _draw() -> void:
	var e := minf(size.x, size.y) / 60.0
	# Respira: sube y baja 1,5 unidades cada 2,4 s; el saltito al llegar, con un poco de aplastamiento
	var dy := 0.0
	var aplasta := 1.0
	if not Temas.reducir_movimiento:
		dy = sin(_t * TAU / 2.4) * 1.5
		if _salto >= 0.0:
			dy -= sin(_salto * PI) * 8.0
			aplasta = 1.0 - 0.12 * sin(minf(_salto * 2.0, 1.0) * PI)
	var centro := Vector2(30, 60)          # los pies: de ahí se aplasta
	var escala := Vector2((2.0 - aplasta) * e, aplasta * e)
	if a_la_izquierda:
		escala.x = -escala.x
	var origen := Vector2(size.x / 2.0, size.y) - Vector2(centro.x * escala.x, centro.y * escala.y) + Vector2(0, dy * e)
	draw_set_transform(origen, 0.0, escala)
	var g := 2.4                             # grosor del contorno, en unidades de la caja
	# Cuerpo y cabeza
	_elipse(Vector2(30, 36), Vector2(18, 16), CIAN, g)
	_elipse(Vector2(30, 20), Vector2(12, 12), CIAN, g)
	# Ojo (cierra los ojos un momento cada 3,7 s)
	var parpadeo := not Temas.reducir_movimiento and fposmod(_t, 3.7) < 0.12
	if parpadeo:
		draw_line(Vector2(23, 18), Vector2(29, 18), TINTA, 2.0, true)
	else:
		draw_circle(Vector2(26, 18), 3.2, TINTA)
		draw_circle(Vector2(25, 17), 1.0, Color.WHITE)
	# Pico
	var pico := PackedVector2Array([Vector2(33, 21), Vector2(42, 24), Vector2(33, 27)])
	draw_colored_polygon(pico, AMARILLO)
	draw_polyline(_cerrar(pico), TINTA, 2.5, true)
	# Ala: aletea al volar y, quieto, un momento cada 4 s
	var giro := 0.0
	if _vuelo >= 0.0:
		giro = sin(_t * 28.0) * 0.55
	elif not Temas.reducir_movimiento and fposmod(_t, 4.0) < 0.5:
		giro = sin(fposmod(_t, 4.0) / 0.5 * TAU * 2.0) * 0.3
	var ala := _bezier([Vector2(16, 34), Vector2(10, 34), Vector2(7, 38), Vector2(8, 43)]) \
		+ _bezier([Vector2(8, 43), Vector2(13, 43), Vector2(17, 40), Vector2(18, 37)])
	var pivote := Vector2(17, 35)
	var girada := PackedVector2Array()
	for p in ala:
		girada.append(pivote + (p - pivote).rotated(-giro))
	draw_colored_polygon(girada, CIAN_ALA)
	draw_polyline(_cerrar(girada), TINTA, g, true)
	# Señala el camino: dos trazos y el círculo amarillo (al volar, no)
	if _vuelo < 0.0:
		draw_line(Vector2(47, 30), Vector2(54, 26), TINTA, g, true)
		draw_line(Vector2(47, 34), Vector2(55, 34), TINTA, g, true)
		for p in [Vector2(47, 30), Vector2(54, 26), Vector2(47, 34), Vector2(55, 34)]:
			draw_circle(p, g / 2.0, TINTA)
		draw_circle(Vector2(52, 23), 4.0, AMARILLO)
		draw_arc(Vector2(52, 23), 4.0, 0, TAU, 20, TINTA, 2.5, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _elipse(c: Vector2, r: Vector2, relleno: Color, grosor: float) -> void:
	var puntos := PackedVector2Array()
	for k in 40:
		var a := TAU * k / 40.0
		puntos.append(c + Vector2(cos(a) * r.x, sin(a) * r.y))
	draw_colored_polygon(puntos, relleno)
	draw_polyline(_cerrar(puntos), TINTA, grosor, true)


static func _cerrar(p: PackedVector2Array) -> PackedVector2Array:
	var r := p.duplicate()
	r.append(p[0])
	return r


static func _bezier(c: Array) -> PackedVector2Array:
	var r := PackedVector2Array()
	for k in 13:
		var u := k / 12.0
		var v := 1.0 - u
		r.append(c[0] * v * v * v + c[1] * 3.0 * v * v * u + c[2] * 3.0 * v * u * u + c[3] * u * u * u)
	return r
