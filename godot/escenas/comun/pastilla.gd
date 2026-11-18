## Pastilla del HUD de Dominó Pop: un icono en un círculo de color y una cifra en Nunito 800, sobre
## tinta translúcida (DESIGN.md › HUD pill). En la partida muestra las fichas que quedan.
extends Control

const Iconos = preload("res://escenas/comun/iconos.gd")
const Temas = preload("res://nucleo/temas.gd")

# Colores del tema activo (nucleo/temas.gd)
var FONDO: Color = Temas.ui("chip")
var TEXTO: Color = Temas.ui("chip_t")

var icono := "ficha"
var color_icono: Color = Temas.ui("ventana")
var texto := "":
	set(v):
		texto = v
		update_minimum_size()
		queue_redraw()
		queue_accessibility_update()
var subtexto := "":
	set(v):
		subtexto = v
		update_minimum_size()
		queue_redraw()
		queue_accessibility_update()
## Qué cuenta la pastilla, para el lector de pantalla («Cuerda», «Estrellas», «Fichas que quedan»)
var nombre_accesible := ""
var fuente: Font
var tam := 34


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _notification(que: int) -> void:
	if que == NOTIFICATION_ACCESSIBILITY_UPDATE:
		var ae := get_accessibility_element()
		if ae.is_valid():
			DisplayServer.accessibility_update_set_role(ae, DisplayServer.ROLE_STATIC_TEXT)
			var frase := "%s: %s" % [nombre_accesible, texto] if nombre_accesible != "" else texto
			if subtexto != "":
				frase += ", la siguiente en " + subtexto
			DisplayServer.accessibility_update_set_name(ae, frase)


func _tam() -> int:
	return Temas.tam(tam)


func _fuente() -> Font:
	return fuente if fuente != null else get_theme_default_font()


func _get_minimum_size() -> Vector2:
	var f := _fuente()
	var w := f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, _tam()).x
	if subtexto != "":
		w += 8 + f.get_string_size(subtexto, HORIZONTAL_ALIGNMENT_LEFT, -1, int(_tam() * 0.75)).x
	return Vector2(8 + 48 + 12 + w + 20, 64)


func _draw() -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = FONDO
	s.set_corner_radius_all(999)
	s.anti_aliasing = true
	draw_style_box(s, Rect2(Vector2.ZERO, size))
	var c := Vector2(8 + 24, size.y / 2)
	draw_circle(c, 24, color_icono)
	Iconos.dibujar(self, icono, Rect2(c - Vector2(15, 15), Vector2(30, 30)), Color(0, 0, 0, 0), Temas.tinta_sobre(color_icono))
	var f := _fuente()
	var base := size.y / 2 + (f.get_ascent(_tam()) - f.get_descent(_tam())) / 2
	var x := c.x + 24 + 12
	draw_string(f, Vector2(x, base), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, _tam(), TEXTO)
	if subtexto != "":
		x += f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, _tam()).x + 8
		draw_string(f, Vector2(x, base), subtexto, HORIZONTAL_ALIGNMENT_LEFT, -1, int(_tam() * 0.75), Color(TEXTO, 0.85))
