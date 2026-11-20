## Confeti de fichas de dominó para celebrar (nivel superado o barrio terminado).
##
## Se pone encima de todo, no recibe toques y se borra solo al acabar. Las fichas salen de arriba,
## giran y caen con los colores del tema. Con «reducir movimiento» no se crea.
extends Control

const Temas = preload("res://nucleo/temas.gd")
const DURACION := 1.9

var _piezas: Array = []        # {x, retraso, velocidad, giro, vuelta, color, tam}
var _tiempo := 0.0


## Crea el confeti sobre `padre` (normalmente la pantalla). `grande` lanza el doble de fichas.
static func lanzar(padre: Control, grande := false) -> void:
	if Temas.reducir_movimiento:
		return
	var c = load("res://escenas/comun/confeti.gd").new()
	c._preparar(60 if grande else 30)
	padre.add_child(c)


func _preparar(cuantas: int) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var colores := [Temas.ui("prim"), Temas.ui("nodo_h"), Temas.ui("estrella"), Temas.tablero("campana"),
		Temas.tablero("ficha"), Temas.tablero("cae")]
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 2026            # siempre igual: el confeti es decoración, no azar del juego
	for k in cuantas:
		_piezas.append({"x": rnd.randf(), "retraso": rnd.randf_range(0.0, 0.45), "velocidad": rnd.randf_range(0.8, 1.25),
			"giro": rnd.randf_range(-7.0, 7.0), "vuelta": rnd.randf() * TAU, "deriva": rnd.randf_range(-40.0, 40.0),
			"color": colores[k % colores.size()], "tam": rnd.randf_range(0.8, 1.2)})


func _process(delta: float) -> void:
	_tiempo += delta
	if _tiempo > DURACION + 0.5:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var alto := size.y
	for p in _piezas:
		var t: float = _tiempo - p["retraso"]
		if t <= 0.0:
			continue
		var u: float = t / DURACION
		var y: float = -40.0 + (alto + 80.0) * u * u * p["velocidad"]      # cae acelerando
		var x: float = size.x * p["x"] + p["deriva"] * sin(t * 2.5)
		var a: float = p["vuelta"] + p["giro"] * t
		var alfa := clampf(2.0 - u * 2.0, 0.0, 1.0)
		var largo: float = 26.0 * p["tam"]
		var ancho: float = 13.0 * p["tam"]
		draw_set_transform(Vector2(x, y), a, Vector2.ONE)
		var cuerpo := StyleBoxFlat.new()
		cuerpo.bg_color = Color(p["color"], alfa)
		cuerpo.border_color = Color(Temas.ui("marco"), alfa)
		cuerpo.set_border_width_all(2)
		cuerpo.set_corner_radius_all(4)
		draw_style_box(cuerpo, Rect2(-ancho / 2, -largo / 2, ancho, largo))
		draw_line(Vector2(-ancho * 0.3, 0), Vector2(ancho * 0.3, 0), Color(Temas.ui("marco"), alfa * 0.8), 1.5)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
