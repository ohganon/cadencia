## Fila de estrellas de la ventana de resultado (DESIGN.md › Result window): la central más grande y
## las no conseguidas, apagadas. En el prototipo hay 2 posibles; la tercera (campana dorada) llegará
## con los niveles definitivos, y entonces bastará con poner `maximo = 3`.
extends Control

const Iconos = preload("res://escenas/comun/iconos.gd")

var conseguidas := 0:
	set(v):
		conseguidas = v
		queue_redraw()
var maximo := 2:
	set(v):
		maximo = v
		update_minimum_size()
		queue_redraw()

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
		Iconos.dibujar(self, "estrella" if k < conseguidas else "estrella_apagada", Rect2(Vector2(x, y), Vector2(l, l)))
		x += l + HUECO
