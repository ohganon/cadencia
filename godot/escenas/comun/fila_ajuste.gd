## Fila de una lista de ajustes (Ajustes, Juego responsable). Tres formas, según lo que lleve:
## - interruptor: el nombre a la izquierda y un interruptor que se desliza a la derecha (sí / no);
## - valor: el nombre y su valor actual con una flecha (al pulsar, pasa al siguiente valor);
## - enlace: el nombre y una flecha (abre otra ventana).
## Toda la fila se pulsa (mide al menos 76 px, por encima de los 48 dp de Android). Las filas de un
## mismo grupo van juntas dentro de una tarjeta (grupo()) separadas por una línea fina.
##
## El estado nunca depende solo del color: el interruptor encendido lleva la bola a la derecha y una
## marca dentro. Para el lector de pantalla es un interruptor con su estado, o un botón con su valor.
extends Control

signal pulsado

const Temas = preload("res://nucleo/temas.gd")
const Iconos = preload("res://escenas/comun/iconos.gd")
const Animar = preload("res://escenas/comun/animar.gd")
const BotonPop = preload("res://escenas/comun/boton_pop.gd")

var TINTA: Color = Temas.ui("ventana_t")
var TINTA_SUAVE: Color = Temas.ui("ventana_s")
var PAPEL: Color = Temas.ui("ventana")
var ACENTO: Color = Temas.ui("prim")
var ACENTO_T: Color = Temas.ui("prim_t")

var texto := "":
	set(v):
		texto = v
		queue_redraw()
		queue_accessibility_update()
var valor := "":                   # forma «valor»
	set(v):
		var cambia := valor != "" and v != valor
		valor = v
		queue_redraw()
		queue_accessibility_update()
		if cambia:
			_destello = 1.0
			set_process(true)
var interruptor := false           # forma «interruptor»
var encendido := false:
	set(v):
		encendido = v
		set_process(true)            # la bola se desliza
		queue_accessibility_update()
var primera := false               # la primera del grupo no lleva línea encima
var fuente: Font
var fuente_valor: Font
var tam_fuente := 30

var _pos := -1.0                   # posición de la bola, de 0 (no) a 1 (sí); -1 = aún sin colocar
var _hundido := false
var _encima := false
var _destello := 0.0               # el valor recién cambiado se ilumina un momento


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ACCESSIBILITY
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	set_process(false)


func _get_minimum_size() -> Vector2:
	return Vector2(0, maxf(76.0, Temas.tam(tam_fuente) + 40.0))


func _gui_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_accept"):
		pulsado.emit()
		accept_event()
		return
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			_hundido = true
		elif _hundido:
			_hundido = false
			if Rect2(Vector2.ZERO, size).has_point(e.position):
				pulsado.emit()
		accept_event()
		queue_redraw()


func _notification(que: int) -> void:
	match que:
		NOTIFICATION_ACCESSIBILITY_UPDATE:
			var ae := get_accessibility_element()
			if not ae.is_valid():
				return
			if interruptor:
				DisplayServer.accessibility_update_set_role(ae, DisplayServer.ROLE_CHECK_BUTTON)
				DisplayServer.accessibility_update_set_name(ae, texto)
				DisplayServer.accessibility_update_set_checked(ae, encendido)
			else:
				DisplayServer.accessibility_update_set_role(ae, DisplayServer.ROLE_BUTTON)
				DisplayServer.accessibility_update_set_name(ae, texto + (": " + valor if valor != "" else ""))
			DisplayServer.accessibility_update_add_action(ae, DisplayServer.ACTION_CLICK, func(_d): pulsado.emit())
		NOTIFICATION_MOUSE_ENTER:
			_encima = BotonPop.con_raton()
			queue_redraw()
		NOTIFICATION_MOUSE_EXIT:
			_encima = false
			_hundido = false
			queue_redraw()


func _process(delta: float) -> void:
	var objetivo := 1.0 if encendido else 0.0
	if _pos < 0.0 or Temas.reducir_movimiento:
		_pos = objetivo
	else:
		_pos = move_toward(_pos, objetivo, delta / 0.18)
	_destello = maxf(_destello - delta / 0.4, 0.0) if not Temas.reducir_movimiento else 0.0
	queue_redraw()
	if _pos == objetivo and _destello == 0.0:
		set_process(false)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if _hundido or _encima:
		var s := StyleBoxFlat.new()
		s.bg_color = Color(TINTA, 0.09 if _hundido else 0.05)
		s.set_corner_radius_all(12)
		draw_style_box(s, r.grow_individual(-4, -3, -4, -3))
	if not primera:
		draw_line(Vector2(20, 0), Vector2(size.x - 20, 0), Color(TINTA, 0.12), 2.0)
	var f := fuente if fuente != null else get_theme_default_font()
	var tf := Temas.tam(tam_fuente)
	var base := size.y / 2 + (f.get_ascent(tf) - f.get_descent(tf)) / 2
	var derecha := size.x - 22.0
	if interruptor:
		derecha = _dibujar_interruptor(Vector2(size.x - 22.0, size.y / 2)) - 16.0
	else:
		var flecha := Rect2(Vector2(size.x - 50, size.y / 2 - 14), Vector2(28, 28))
		Iconos.dibujar(self, "adelante", flecha, Color(0, 0, 0, 0), Color(TINTA, 0.55))
		derecha = flecha.position.x - 8.0
		if valor != "":
			var fv := fuente_valor if fuente_valor != null else f
			var tv := Temas.tam(tam_fuente - 4)
			var ancho := fv.get_string_size(valor, HORIZONTAL_ALIGNMENT_LEFT, -1, tv).x
			var color_valor := TINTA_SUAVE.lerp(TINTA, _destello)
			var bv := size.y / 2 + (fv.get_ascent(tv) - fv.get_descent(tv)) / 2
			draw_string(fv, Vector2(derecha - ancho, bv), valor, HORIZONTAL_ALIGNMENT_LEFT, -1, tv, color_valor)
			derecha -= ancho + 16.0
	draw_string(f, Vector2(22, base), texto, HORIZONTAL_ALIGNMENT_LEFT, maxf(derecha - 22.0, 40.0), tf, TINTA,
		TextServer.JUSTIFICATION_NONE)


## Interruptor de 76 × 44 con su borde derecho en `fin`. Devuelve dónde empieza (x).
func _dibujar_interruptor(fin: Vector2) -> float:
	if _pos < 0.0:
		_pos = 1.0 if encendido else 0.0
	var t := Animar.suave(_pos) if not Temas.reducir_movimiento else _pos
	var caja := Rect2(fin - Vector2(76, 22), Vector2(76, 44))
	var pista := StyleBoxFlat.new()
	pista.bg_color = Color(TINTA, 0.16).lerp(ACENTO, t)
	pista.set_corner_radius_all(22)
	pista.border_color = Color(TINTA, 0.35).lerp(Temas.ui("marco") if Temas.contraste(ACENTO, PAPEL) < 1.6 else ACENTO, t)
	pista.set_border_width_all(2)
	pista.anti_aliasing = true
	draw_style_box(pista, caja)
	var centro := Vector2(lerpf(caja.position.x + 22, caja.end.x - 22, t), caja.get_center().y)
	var papel := PAPEL
	papel.a = 1.0
	draw_circle(centro + Vector2(0, 1.5), 16.5, Color(0, 0, 0, 0.12))
	draw_circle(centro, 16.0, papel)
	draw_arc(centro, 16.0, 0, TAU, 32, Color(TINTA, 0.35), 2.0, true)
	if t > 0.5:
		# Marca dentro de la bola: el «sí» no depende del color
		var a := clampf((t - 0.5) * 2.0, 0.0, 1.0)
		var marca := Temas.sobre(papel, TINTA, Color.WHITE)
		draw_polyline(PackedVector2Array([centro + Vector2(-6, 0), centro + Vector2(-2, 5), centro + Vector2(7, -5)]),
			Color(marca, a), 3.0, true)
	return caja.position.x


## Tarjeta que agrupa filas: un fondo muy suave de la tinta de la ventana y esquinas redondeadas.
static func grupo(filas: Array) -> PanelContainer:
	var panel := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color = Color(Temas.ui("ventana_t"), 0.05)
	s.set_corner_radius_all(16)
	s.border_color = Color(Temas.ui("ventana_t"), 0.10)
	s.set_border_width_all(2)
	s.content_margin_top = 2
	s.content_margin_bottom = 2
	panel.add_theme_stylebox_override("panel", s)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 0)
	panel.add_child(caja)
	for k in filas.size():
		filas[k].primera = k == 0
		caja.add_child(filas[k])
	return panel
