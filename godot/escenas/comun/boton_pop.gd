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
const Temas = preload("res://nucleo/temas.gd")
const Animar = preload("res://escenas/comun/animar.gd")

# Colores y forma del tema activo (nucleo/temas.gd)
var TINTA: Color = Temas.ui("marco")
var VERDE: Color = Temas.ui("prim")
var LABIO_VERDE: Color = Temas.ui("prim_labio")
var MARFIL: Color = Temas.ui("sec")
var LABIO_MARFIL: Color = Temas.ui("sec_labio")
var RADIO: int = Temas.numero("radio_boton", 16)
var SOMBRA_SOLIDA: bool = Temas.sombra_solida()
const SOMBRA := 3.0
const MANTENER := 0.6

@export var texto := "":
	set(v):
		texto = v
		queue_accessibility_update()
@export var icono := ""
## Lo que dice el lector de pantalla. Si está vacío, el texto del botón o el nombre de su icono.
var nombre_accesible := "":
	set(v):
		nombre_accesible = v
		queue_accessibility_update()
## Nombres de los botones que solo llevan icono, para el lector de pantalla
const NOMBRES_ICONO := {"volver": "Volver", "adelante": "Siguiente", "deshacer": "Deshacer. Mantén pulsado para borrar todo",
	"bombilla": "Pista", "lento": "Cámara lenta", "inicio": "Inicio de la cadena", "campana_simple": "Campana",
	"campana": "Campana", "doble": "Campana doble", "numerada": "Campana numerada", "dorada": "Campana dorada",
	"muro": "Muro", "puerta": "Puerta de vaivén", "espiral": "Espiral de retardo", "muelle": "Muelle", "interruptor": "Interruptor", "noria": "Noria", "globo": "Globo", "cristal": "Cristal", "goma": "Goma", "llave": "Ajustes", "estrella": "Estrellas"}
@export var principal := false
@export var redondo := false        # cuadrado con radio 16 (botón de icono); con `circular`, círculo
@export var circular := false
@export var tam_fuente := 36
@export var desactivado := false:
	set(v):
		desactivado = v
		queue_redraw()
		queue_accessibility_update()
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
var _h := 0.0                     # cuánto está hundido, de 0 a 1 (animado; ver _process)
var _en_ventana = null            # se averigua al dibujar: ¿está dentro de una ventana?
var _tiempo_pulsado := -1.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Con el dedo no se queda «seleccionado»; el lector de pantalla sí puede llegar a él
	focus_mode = Control.FOCUS_ACCESSIBILITY


func nombre_para_lector() -> String:
	if nombre_accesible != "":
		return nombre_accesible
	if texto != "":
		return texto
	return NOMBRES_ICONO.get(icono, icono)


func _get_minimum_size() -> Vector2:
	var f := _fuente()
	var ancho := 0.0
	if texto != "":
		ancho = f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, _tf()).x + 48
	if icono != "":
		ancho += 52
	if texto == "":
		return Vector2(56, 56)        # solo icono: manda el tamaño que le dé la pantalla
	return Vector2(maxf(ancho, 96.0), 96.0)


## Tamaño de letra con el ajuste de texto grande.
func _tf() -> int:
	return Temas.tam(tam_fuente)


func _fuente() -> Font:
	return fuente if fuente != null else get_theme_default_font()


func _gui_input(evento: InputEvent) -> void:
	if desactivado:
		return
	if evento.is_action_pressed("ui_accept"):
		pulsado.emit()
		accept_event()
		return
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.pressed:
			_hundido = true
			_tiempo_pulsado = 0.0
			set_process(true)
		elif _hundido:
			_hundido = false
			set_process(true)            # sigue para que el botón suba con suavidad
			if _tiempo_pulsado >= 0.0 and Rect2(Vector2.ZERO, size).has_point(evento.position):
				pulsado.emit()
			_tiempo_pulsado = -1.0
		accept_event()
		queue_redraw()


func _process(delta: float) -> void:
	# El botón baja y sube con una curva suave (unos 140 ms); con «reducir movimiento», de golpe
	var objetivo := 1.0 if _hundido else 0.0
	if Temas.reducir_movimiento:
		_h = objetivo
	else:
		_h = move_toward(_h, objetivo, delta / 0.14)
	queue_redraw()
	if _tiempo_pulsado >= 0.0:
		_tiempo_pulsado += delta
		if _tiempo_pulsado >= MANTENER:
			_tiempo_pulsado = -1.0          # ya no cuenta como pulsación corta
			mantenido.emit()
	if _tiempo_pulsado < 0.0 and _h == objetivo:
		set_process(false)


func _notification(que: int) -> void:
	if que == NOTIFICATION_ACCESSIBILITY_UPDATE:
		# Para el lector de pantalla (TalkBack, VoiceOver, Narrador): es un botón, con su nombre
		var ae := get_accessibility_element()
		if ae.is_valid():
			DisplayServer.accessibility_update_set_role(ae, DisplayServer.ROLE_BUTTON)
			DisplayServer.accessibility_update_set_name(ae, nombre_para_lector())
			DisplayServer.accessibility_update_set_flag(ae, DisplayServer.FLAG_DISABLED, desactivado)
			DisplayServer.accessibility_update_add_action(ae, DisplayServer.ACTION_CLICK, _pulsado_por_lector)
		return
	if que == NOTIFICATION_MOUSE_EXIT and _hundido:
		_hundido = false
		_tiempo_pulsado = -1.0
		queue_redraw()


## ¿Está el botón dentro de una ventana (meta «ventana» en algún antecesor)? Los botones
## transparentes de algunos temas cambian de tinta dentro de las ventanas, como en la maqueta.
func _dentro_de_ventana() -> bool:
	if _en_ventana == null:
		_en_ventana = false
		var n := get_parent()
		while n != null:
			if n.has_meta("ventana"):
				_en_ventana = true
				break
			n = n.get_parent()
	return _en_ventana


func _draw() -> void:
	var fondo := VERDE if principal else MARFIL
	var labio := LABIO_VERDE if principal else LABIO_MARFIL
	var color_texto: Color = Temas.ui("prim_t") if principal else Temas.ui("sec_t")
	if color_fondo.a > 0:
		fondo = color_fondo
		labio = color_labio
		color_texto = Temas.tinta_sobre(fondo)
	if fondo.a < 0.5 and _dentro_de_ventana():
		color_texto = Temas.ui("ventana_t")
	if desactivado:
		# Apagado: el mismo botón, mezclado con el fondo de la pantalla (vale para todos los temas)
		var pantalla := Temas.ui("pantalla")
		fondo = fondo.lerp(pantalla, 0.55) if fondo.a >= 0.5 else fondo
		labio = labio.lerp(pantalla, 0.55) if labio.a >= 0.5 else labio
		color_texto = Color(color_texto, 0.45)
	# Botón sin fondo (algunos temas): solo el contorno, del color del texto
	var borde := TINTA if fondo.a >= 0.5 else color_texto
	# Temas planos: sin sombra sólida ni labio; al pulsar, el fondo se oscurece un poco
	var sombra := SOMBRA if SOMBRA_SOLIDA else 0.0
	if _hundido and not SOMBRA_SOLIDA:
		fondo = fondo.darkened(0.12) if fondo.a >= 0.5 else Color(color_texto, 0.12)
	if not SOMBRA_SOLIDA:
		labio = fondo
	var h := Animar.suave(_h) if _hundido else 1.0 - Animar.suave(1.0 - _h)
	var baja := sombra * h
	var cuerpo := Rect2(Vector2(0, baja), size - Vector2(0, sombra))
	var mitad := int(minf(cuerpo.size.x, cuerpo.size.y) / 2)
	var radio := mitad if circular else mini(RADIO, mitad)
	if h < 1.0 and not sin_sombra and sombra > 0:
		draw_style_box(_caja(TINTA, radio), Rect2(Vector2(0, sombra), cuerpo.size))
	var dentro := cuerpo.grow(-2)
	var alto_labio := lerpf(4.0, 2.0, h) if SOMBRA_SOLIDA else 0.0
	if fondo.a >= 0.5:
		draw_style_box(_caja(borde, radio), cuerpo)                     # borde de 2 px
		draw_style_box(_caja(labio, radio - 2), dentro)                  # labio
		draw_style_box(_caja(fondo, radio - 2), Rect2(dentro.position, dentro.size - Vector2(0, alto_labio)))
	else:
		# Sin fondo (o casi): solo el contorno, con lo que haya detrás a la vista
		var s := _caja(fondo, radio)
		s.border_color = borde
		s.set_border_width_all(2)
		draw_style_box(s, cuerpo)
	if resaltado:
		draw_style_box(_anillo(radio + 4), cuerpo.grow(5))

	var centro := Rect2(dentro.position, dentro.size - Vector2(0, alto_labio))
	var f := _fuente()
	var ancho_texto := f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, _tf()).x if texto != "" else 0.0
	var lado_icono := minf(centro.size.y * 0.5, 48.0)
	var hueco := 12.0 if texto != "" and icono != "" else 0.0
	var total := ancho_texto + (lado_icono if icono != "" else 0.0) + hueco
	var x := centro.position.x + (centro.size.x - total) / 2
	if icono != "":
		var r := Rect2(Vector2(x, centro.get_center().y - lado_icono / 2), Vector2(lado_icono, lado_icono))
		Iconos.dibujar(self, icono, r, Color(0, 0, 0, 0), color_texto)
		x += lado_icono + hueco
	if texto != "":
		var base := centro.get_center().y + (f.get_ascent(_tf()) - f.get_descent(_tf())) / 2
		draw_string(f, Vector2(x, base), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, _tf(), color_texto)


func _caja(color: Color, radio: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(maxi(radio, 0))
	s.anti_aliasing = true
	return s


func _anillo(radio: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.border_color = Temas.ui("texto")
	s.set_border_width_all(4)
	s.set_corner_radius_all(radio)
	return s


func _pulsado_por_lector(_datos) -> void:
	if not desactivado:
		pulsado.emit()
