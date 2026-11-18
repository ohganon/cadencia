## Botón de Dominó Pop (DESIGN.md › Pressable button): borde de tinta de 2 px, sombra sólida de 3 px
## hacia abajo y labio interior de 4 px. Al pulsarlo baja 3 px, la sombra desaparece y el labio pasa a
## 2 px. Solo hay dos tipos: verde (acción principal) y marfil (todo lo demás).
##
## Se dibuja entero aquí, en vez de con StyleBoxFlat, porque Godot no permite combinar en un solo
## estilo el borde de tinta, el labio de otro color y la sombra sólida.
extends Control

signal pulsado
signal mantenido          # se mantiene pulsado 0,6 s (por ejemplo, para borrar todo)

const Iconos = preload("res://escenas/comun/iconos.gd")

const TINTA := Color("#142554")
const VERDE := Color("#3ddc6b")
const LABIO_VERDE := Color("#22a552")
const MARFIL := Color("#fffdf6")
const LABIO_MARFIL := Color("#d9e2f2")
const DESACTIVADO := Color("#b7c4df")
const LABIO_DESACTIVADO := Color("#97a7c8")
const TEXTO_DESACTIVADO := Color("#43557f")
const SOMBRA := 3.0
const MANTENER := 0.6

@export var texto := ""
@export var icono := ""
@export var principal := false
@export var redondo := false        # cuadrado con radio 16 (botón de icono); con `circular`, círculo
@export var circular := false
@export var tam_fuente := 36
@export var desactivado := false:
	set(v):
		desactivado = v
		queue_redraw()
## Colores propios (para los nodos de nivel: amarillo, verde o bloqueado)
var color_fondo := Color(0, 0, 0, 0)
var color_labio := Color(0, 0, 0, 0)
var fuente: Font
var sin_sombra := false      # los nodos cerrados del mapa no tienen sombra (DESIGN.md)
var resaltado := false:
	set(v):
		resaltado = v
		queue_redraw()

var _hundido := false
var _tiempo_pulsado := -1.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE


func _get_minimum_size() -> Vector2:
	var f := _fuente()
	var ancho := 0.0
	if texto != "":
		ancho = f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_fuente).x + 48
	if icono != "":
		ancho += 52
	return Vector2(maxf(ancho, 96.0), 96.0)


func _fuente() -> Font:
	return fuente if fuente != null else get_theme_default_font()


func _gui_input(evento: InputEvent) -> void:
	if desactivado:
		return
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.pressed:
			_hundido = true
			_tiempo_pulsado = 0.0
			set_process(true)
		elif _hundido:
			_hundido = false
			set_process(false)
			if _tiempo_pulsado >= 0.0 and Rect2(Vector2.ZERO, size).has_point(evento.position):
				pulsado.emit()
			_tiempo_pulsado = -1.0
		accept_event()
		queue_redraw()


func _process(delta: float) -> void:
	if _tiempo_pulsado < 0.0:
		set_process(false)
		return
	_tiempo_pulsado += delta
	if _tiempo_pulsado >= MANTENER:
		_tiempo_pulsado = -1.0          # ya no cuenta como pulsación corta
		mantenido.emit()


func _notification(que: int) -> void:
	if que == NOTIFICATION_MOUSE_EXIT and _hundido:
		_hundido = false
		_tiempo_pulsado = -1.0
		queue_redraw()


func _draw() -> void:
	var fondo := VERDE if principal else MARFIL
	var labio := LABIO_VERDE if principal else LABIO_MARFIL
	if color_fondo.a > 0:
		fondo = color_fondo
		labio = color_labio
	if desactivado:
		fondo = DESACTIVADO
		labio = LABIO_DESACTIVADO
	var baja := SOMBRA if _hundido else 0.0
	var cuerpo := Rect2(Vector2(0, baja), size - Vector2(0, SOMBRA))
	var radio := int(minf(cuerpo.size.x, cuerpo.size.y) / 2) if circular else 16
	if not _hundido and not sin_sombra:
		draw_style_box(_caja(TINTA, radio), Rect2(Vector2(0, SOMBRA), cuerpo.size))
	draw_style_box(_caja(TINTA, radio), cuerpo)                         # borde de 2 px
	var dentro := cuerpo.grow(-2)
	draw_style_box(_caja(labio, radio - 2), dentro)                      # labio
	var alto_labio := 2.0 if _hundido else 4.0
	draw_style_box(_caja(fondo, radio - 2), Rect2(dentro.position, dentro.size - Vector2(0, alto_labio)))
	if resaltado:
		draw_style_box(_anillo(radio + 4), cuerpo.grow(5))

	var color_texto := TEXTO_DESACTIVADO if desactivado else TINTA
	var centro := Rect2(dentro.position, dentro.size - Vector2(0, alto_labio))
	var f := _fuente()
	var ancho_texto := f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_fuente).x if texto != "" else 0.0
	var lado_icono := minf(centro.size.y * 0.5, 48.0)
	var hueco := 12.0 if texto != "" and icono != "" else 0.0
	var total := ancho_texto + (lado_icono if icono != "" else 0.0) + hueco
	var x := centro.position.x + (centro.size.x - total) / 2
	if icono != "":
		var r := Rect2(Vector2(x, centro.get_center().y - lado_icono / 2), Vector2(lado_icono, lado_icono))
		Iconos.dibujar(self, icono, r)
		x += lado_icono + hueco
	if texto != "":
		var base := centro.get_center().y + (f.get_ascent(tam_fuente) - f.get_descent(tam_fuente)) / 2
		draw_string(f, Vector2(x, base), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_fuente, color_texto)


func _caja(color: Color, radio: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(maxi(radio, 0))
	s.anti_aliasing = true
	return s


func _anillo(radio: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.border_color = Color.WHITE
	s.set_border_width_all(4)
	s.set_corner_radius_all(radio)
	return s
