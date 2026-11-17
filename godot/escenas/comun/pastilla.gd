## Pastilla del HUD de Dominó Pop: un icono en un círculo de color y una cifra en Nunito 800, sobre
## tinta translúcida (DESIGN.md › HUD pill). En la partida muestra las fichas que quedan.
extends Control

const Iconos = preload("res://escenas/comun/iconos.gd")

const FONDO := Color(0.078, 0.145, 0.329, 0.38)      # rgba(20,37,84,.38)
const MARFIL := Color("#fffdf6")
const CLARO := Color("#e8f0ff")

var icono := "ficha"
var color_icono := MARFIL
var texto := "":
	set(v):
		texto = v
		update_minimum_size()
		queue_redraw()
var subtexto := "":
	set(v):
		subtexto = v
		update_minimum_size()
		queue_redraw()
var fuente: Font
var tam := 34


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _fuente() -> Font:
	return fuente if fuente != null else get_theme_default_font()


func _get_minimum_size() -> Vector2:
	var f := _fuente()
	var w := f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
	if subtexto != "":
		w += 8 + f.get_string_size(subtexto, HORIZONTAL_ALIGNMENT_LEFT, -1, int(tam * 0.75)).x
	return Vector2(8 + 48 + 12 + w + 20, 64)


func _draw() -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = FONDO
	s.set_corner_radius_all(999)
	s.anti_aliasing = true
	draw_style_box(s, Rect2(Vector2.ZERO, size))
	var c := Vector2(8 + 24, size.y / 2)
	draw_circle(c, 24, color_icono)
	Iconos.dibujar(self, icono, Rect2(c - Vector2(15, 15), Vector2(30, 30)))
	var f := _fuente()
	var base := size.y / 2 + (f.get_ascent(tam) - f.get_descent(tam)) / 2
	var x := c.x + 24 + 12
	draw_string(f, Vector2(x, base), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, Color.WHITE)
	if subtexto != "":
		x += f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x + 8
		draw_string(f, Vector2(x, base), subtexto, HORIZONTAL_ALIGNMENT_LEFT, -1, int(tam * 0.75), CLARO)
