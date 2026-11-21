## Pastilla del HUD de Dominó Pop: un icono en un círculo de color y una cifra en Nunito 800, sobre
## tinta translúcida (DESIGN.md › HUD pill). En la partida muestra las fichas que quedan.
extends Control

const Iconos = preload("res://escenas/comun/iconos.gd")
const Temas = preload("res://nucleo/temas.gd")
const Caja = preload("res://escenas/comun/caja.gd")
const Animar = preload("res://escenas/comun/animar.gd")

# Colores del tema activo (nucleo/temas.gd)
var FONDO: Color = Temas.ui("chip")
var TEXTO: Color = Temas.ui("chip_t")

var icono := "ficha"
var color_icono: Color = Temas.ui("ventana")
var texto := "":
	set(v):
		if v != texto and texto != "" and is_inside_tree():
			Animar.latido(self)          # la cifra cambia: un pequeño latido
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
	# La «chip» de la maqueta: fondo, borde y radio del tema
	var caja := Temas.caja("chip")
	var texto_chip: Color = caja["texto"] if caja["texto"].a > 0.0 and not Temas.alto_contraste else TEXTO
	Caja.dibujar(self, Rect2(Vector2.ZERO, size), caja)
	var c := Vector2(8 + 24, size.y / 2)
	if Temas.id_activo() == "pop" or Temas.alto_contraste:
		# Dominó Pop (tablero completo): el icono dentro de un círculo de color
		draw_circle(c, 24, color_icono)
		Iconos.dibujar(self, icono, Rect2(c - Vector2(15, 15), Vector2(30, 30)), Color(0, 0, 0, 0), Temas.tinta_sobre(color_icono))
	else:
		# Resto de temas: el icono suelto, del color del texto (la estrella, del color de las estrellas)
		# (la estrella de la maqueta no lleva contorno: relleno y contorno del mismo color)
		if icono == "estrella":
			Iconos.dibujar(self, icono, Rect2(c - Vector2(19, 19), Vector2(38, 38)), color_icono, color_icono)
		else:
			Iconos.dibujar(self, icono, Rect2(c - Vector2(19, 19), Vector2(38, 38)), Color(0, 0, 0, 0), texto_chip)
	var f := _fuente()
	var base := size.y / 2 + (f.get_ascent(_tam()) - f.get_descent(_tam())) / 2
	var x := c.x + 24 + 12
	draw_string(f, Vector2(x, base), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, _tam(), texto_chip)
	if subtexto != "":
		x += f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, _tam()).x + 8
		draw_string(f, Vector2(x, base), subtexto, HORIZONTAL_ALIGNMENT_LEFT, -1, int(_tam() * 0.75), Color(texto_chip, 0.85))
