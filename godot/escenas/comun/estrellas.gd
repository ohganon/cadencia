## Fila de estrellas de la ventana de resultado (DESIGN.md › Result window): la central más grande y
## las no conseguidas, apagadas. En el prototipo hay 2 posibles; la tercera (campana dorada) llegará
## con los niveles definitivos, y entonces bastará con poner `maximo = 3`.
extends Control

const Iconos = preload("res://escenas/comun/iconos.gd")
const Temas = preload("res://nucleo/temas.gd")
const Animar = preload("res://escenas/comun/animar.gd")

var conseguidas := 0:
	set(v):
		conseguidas = v
		queue_redraw()
var maximo := 2:
	set(v):
		maximo = v
		update_minimum_size()
		queue_redraw()

var _aparicion := 99.0      # para animar(): cuántas estrellas han salido ya (con decimales)

const LADO := 84.0
const LADO_CENTRAL := 108.0
const HUECO := 12.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _get_minimum_size() -> Vector2:
	return Vector2(_ancho(), LADO_CENTRAL + 6)


func _lados() -> Array:
	var r := []
	for k in maximo:
		var central := maximo % 2 == 1 and k == maximo / 2
		r.append(LADO_CENTRAL if central else LADO)
	return r


func _ancho() -> float:
	var w := 0.0
	for l in _lados():
		w += l
	return w + HUECO * maxi(maximo - 1, 0)


func _draw() -> void:
	var x := (size.x - _ancho()) / 2
	var lados := _lados()
	for k in maximo:
		var l: float = lados[k]
		# Alineadas por abajo; la central sube un poco (como en la maqueta)
		var y := size.y - l - (6.0 if l == LADO_CENTRAL else 0.0)
		var caja := Rect2(Vector2(x, y), Vector2(l, l))
		var p := clampf(_aparicion - k, 0.0, 1.0)
		if k >= conseguidas or p < 1.0:
			Iconos.dibujar(self, "estrella_apagada", caja)
		if k < conseguidas and p > 0.0:
			# Sale con un pequeño rebote: crece un poco más de la cuenta y vuelve a su tamaño
			var s := _rebote(p)
			Iconos.dibujar(self, "estrella", Rect2(caja.get_center() - caja.size * s / 2.0, caja.size * s))
		x += l + HUECO


## Las estrellas conseguidas salen una a una (con «reducir movimiento», todas a la vez).
func animar() -> void:
	if Temas.reducir_movimiento:
		_aparicion = 99.0
		queue_redraw()
		return
	_aparicion = 0.0
	var t := create_tween()
	t.tween_interval(0.15)
	t.tween_method(func(v): _aparicion = v; queue_redraw(), 0.0, float(conseguidas), 0.32 * conseguidas)


static func _rebote(x: float) -> float:
	var c1 := 1.70158
	var c3 := c1 + 1.0
	return 1.0 + c3 * pow(x - 1.0, 3) + c1 * pow(x - 1.0, 2)
