## Iconos de Dominó Pop dibujados con código, a partir de los símbolos SVG de la maqueta
## (docs/fase6/tablero/index.html). Así no dependen de archivos de imagen y escalan sin perder nitidez.
##
## Uso: Iconos.dibujar(canvas_item, "estrella", rect) dentro de un _draw().
extends RefCounted

const TINTA := Color("#142554")
const MARFIL := Color("#fffdf6")
const AMARILLO := Color("#ffc83d")
const CORAL := Color("#ff5470")
const APAGADA := Color("#c9d6f2")
const BLANCO := Color.WHITE

# Puntos de la estrella del SVG (caja de 40 × 40)
const ESTRELLA := [Vector2(20, 3.5), Vector2(25.1, 13.9), Vector2(36.5, 15.6), Vector2(28.2, 23.6),
	Vector2(30.2, 34.9), Vector2(20, 29.5), Vector2(9.8, 34.9), Vector2(11.8, 23.6), Vector2(3.5, 15.6),
	Vector2(14.9, 13.9)]
# Cuerpo de la campana del SVG (caja de 40 × 40), con las curvas muestreadas
const CAMPANA := [Vector2(20, 5), Vector2(15.4, 6.2), Vector2(12, 9.2), Vector2(10.1, 12.9), Vector2(9.5, 16),
	Vector2(9.5, 23.5), Vector2(6, 28.5), Vector2(34, 28.5), Vector2(30.5, 23.5), Vector2(30.5, 16),
	Vector2(29.9, 12.9), Vector2(28, 9.2), Vector2(24.6, 6.2)]


## Dibuja el icono `tipo` ajustado a `rect`. `color` cambia el relleno principal cuando tiene sentido.
static func dibujar(ci: CanvasItem, tipo: String, rect: Rect2, color := Color(0, 0, 0, 0)) -> void:
	match tipo:
		"estrella":
			_forma(ci, ESTRELLA, 40.0, rect, AMARILLO if color.a == 0 else color, 2.4)
		"estrella_apagada":
			_forma(ci, ESTRELLA, 40.0, rect, APAGADA, 2.4)
		"campana":
			_forma(ci, CAMPANA, 40.0, rect, AMARILLO if color.a == 0 else color, 2.4)
			var e := rect.size.x / 40.0
			var c := rect.position + Vector2(20, 32) * e
			ci.draw_circle(c, 3.5 * e, CORAL)
			ci.draw_arc(c, 3.5 * e, 0, TAU, 20, TINTA, maxf(1.0, 2.4 * e), true)
		"ficha":
			_ficha(ci, rect)
		"volver":
			_trazos(ci, rect, [[Vector2(15, 5), Vector2(8, 12), Vector2(15, 19)]])
		"deshacer":
			var arco := [Vector2(4, 9), Vector2(14, 9)]
			for k in range(1, 13):        # semicírculo de radio 6 centrado en (14, 15), por la derecha
				var a := -PI / 2 + PI * k / 12.0
				arco.append(Vector2(14, 15) + Vector2(cos(a), sin(a)) * 6)
			arco.append(Vector2(11, 21))
			_trazos(ci, rect, [[Vector2(9, 14), Vector2(4, 9), Vector2(9, 4)], arco])
		"bombilla":
			var bombilla := []
			for k in range(0, 17):        # cabeza redonda de radio 6 centrada en (12, 9)
				var a := deg_to_rad(135 + 270.0 * k / 16.0)
				bombilla.append(Vector2(12, 9) + Vector2(cos(a), sin(a)) * 6)
			bombilla.append(Vector2(14.5, 16))
			bombilla.append(Vector2(9.5, 16))
			bombilla.append(bombilla[0])
			_trazos(ci, rect, [[Vector2(9, 18), Vector2(15, 18)], [Vector2(10, 21), Vector2(14, 21)], bombilla])
		"lento":                          # caracol sencillo: espiral y cuerpo
			var espiral := []
			for k in range(0, 40):
				var a := k * 0.42
				espiral.append(Vector2(13, 12) + Vector2(cos(a), sin(a)) * (0.6 + k * 0.17))
			_trazos(ci, rect, [espiral, [Vector2(4, 19), Vector2(20, 19), Vector2(21, 16)], [Vector2(5, 19), Vector2(4, 15)]])


static func _forma(ci: CanvasItem, puntos: Array, caja: float, rect: Rect2, relleno: Color, trazo: float) -> void:
	var e := rect.size.x / caja
	var p := PackedVector2Array()
	for v in puntos:
		p.append(rect.position + v * e)
	ci.draw_colored_polygon(p, relleno)
	var borde := p.duplicate()
	borde.append(p[0])
	ci.draw_polyline(borde, TINTA, maxf(1.0, trazo * e), true)


static func _trazos(ci: CanvasItem, rect: Rect2, lineas: Array) -> void:
	var e := rect.size.x / 24.0
	for linea in lineas:
		var p := PackedVector2Array()
		for v in linea:
			p.append(rect.position + v * e)
		ci.draw_polyline(p, TINTA, maxf(1.5, 2.6 * e), true)
		for extremo in [p[0], p[p.size() - 1]]:      # puntas redondeadas
			ci.draw_circle(extremo, maxf(0.75, 1.3 * e), TINTA)


static func _ficha(ci: CanvasItem, rect: Rect2) -> void:
	# Caja de 24 × 40, centrada en el rect
	var e := minf(rect.size.x / 24.0, rect.size.y / 40.0)
	var o := rect.position + (rect.size - Vector2(24, 40) * e) / 2
	var caja := StyleBoxFlat.new()
	caja.bg_color = MARFIL
	caja.border_color = TINTA
	caja.set_border_width_all(maxi(1, int(round(2.4 * e))))
	caja.set_corner_radius_all(int(5 * e))
	ci.draw_style_box(caja, Rect2(o + Vector2(2, 2) * e, Vector2(20, 36) * e))
	ci.draw_circle(o + Vector2(12, 11) * e, 2.6 * e, TINTA)
	ci.draw_circle(o + Vector2(12, 29) * e, 2.6 * e, TINTA)
