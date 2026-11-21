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

const Caja = preload("res://escenas/comun/caja.gd")
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
		mouse_default_cursor_shape = Control.CURSOR_ARROW if v else Control.CURSOR_POINTING_HAND
		queue_redraw()
		queue_accessibility_update()
## Colores propios (para los nodos de nivel: amarillo, verde o bloqueado)
var color_fondo := Color(0, 0, 0, 0)
var color_labio := Color(0, 0, 0, 0)
var fuente: Font
var sin_sombra := false      # los nodos cerrados del mapa no tienen sombra (DESIGN.md)
## Caja de la maqueta que usa en vez de la de botón: "nodo_h", "nodo_a" o "nodo_c" (nodos del mapa)
var estilo_caja := ""
var resaltado := false:
	set(v):
		resaltado = v
		queue_redraw()

var _hundido := false
var _encima := false              # el ratón está encima (solo con ratón: en el móvil no hay «encima»)
var _h := 0.0                     # cuánto está hundido, de 0 a 1 (animado; ver _process)
var _en_ventana = null            # se averigua al dibujar: ¿está dentro de una ventana?
var _tiempo_pulsado := -1.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Con el dedo no se queda «seleccionado»; el lector de pantalla sí puede llegar a él
	focus_mode = Control.FOCUS_ACCESSIBILITY
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


## ¿Se juega con ratón? En el móvil el dedo también genera «entrar», y el resalte se quedaría puesto.
static func con_raton() -> bool:
	return not DisplayServer.is_touchscreen_available()


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
		ancho = f.get_string_size(_texto_visible(), HORIZONTAL_ALIGNMENT_LEFT, -1, _tf()).x + 48
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
	if que == NOTIFICATION_MOUSE_ENTER and con_raton():
		_encima = true
		queue_redraw()
	if que == NOTIFICATION_MOUSE_EXIT:
		_encima = false
		if _hundido:
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
	var c := _caja_del_boton()
	var texto_color: Color = c["texto"]
	# Lo que el tema dice para este momento (maqueta): brillo con el ratón encima, gris o 60 % apagado
	var opacidad := 1.0
	var apagado: Dictionary = Temas.estilo("desactivado", {})
	if desactivado:
		if apagado.has("fondo") and not Temas.alto_contraste:
			c["fondo"] = Color(apagado["fondo"])
			for s in c["sombras"]:
				if s["dentro"]:
					s["color"] = Color(apagado["labio"])
			texto_color = Color(apagado["texto"])
		else:
			opacidad = float(apagado.get("opacidad", 0.6))
	elif _encima and not _hundido:
		var brillo := float(Temas.estilo("brillo", 1.05))
		c["fondo"] = _brillar(c["fondo"], brillo)
		c["borde_color"] = _brillar(c["borde_color"], brillo)
		texto_color = _brillar(texto_color, brillo)
	if sin_sombra:
		c["sombras"] = c["sombras"].filter(func(s): return s["dentro"])
	# El hueco del botón deja sitio a su sombra dura (abajo o en diagonal)
	var hueco := Caja.hueco_sombra(c)
	var cuerpo := Rect2(Vector2.ZERO, size - hueco)
	# Al pulsar: baja 2 px (maqueta); en Dominó Pop baja 3 px y la sombra se recoge, con el labio a la mitad
	var h := 0.0 if desactivado else (Animar.suave(_h) if _hundido else 1.0 - Animar.suave(1.0 - _h))
	var baja := float(Temas.estilo("pulsar", 2)) * Temas.ESCALA * h
	var recoge := int(Temas.estilo("pulsar", 2)) == 3
	if recoge:
		cuerpo.position.y += minf(baja, hueco.y)
		for s in c["sombras"]:
			if s["dentro"]:
				s["pos"] = s["pos"] * (1.0 - 0.5 * h)
			elif s["desenfoque"] <= 0.0:
				s["pos"] = s["pos"] * (1.0 - h)
	else:
		cuerpo.position.y += baja
	var detras: Color = Temas.ui("ventana") if _dentro_de_ventana() else Temas.ui("pantalla")
	detras.a = 1.0
	Caja.dibujar(self, cuerpo, c, opacidad, detras)
	if opacidad < 1.0:
		texto_color = detras.lerp(Color(texto_color, 1.0), opacidad * texto_color.a)
		opacidad = 1.0
	var radio := Caja.radio_de(c, cuerpo)
	if resaltado:
		draw_style_box(_anillo(int(radio) + 4), cuerpo.grow(5))

	# Contenido: centrado en la cara del botón (sin el labio)
	var labio := 0.0
	for s in c["sombras"]:
		if s["dentro"] and s["desenfoque"] <= 0.0:
			labio = maxf(labio, -s["pos"].y)
	var centro := Rect2(cuerpo.position + Vector2(c["borde"], c["borde"]), cuerpo.size - Vector2(c["borde"], c["borde"]) * 2 - Vector2(0, labio))
	texto_color.a *= opacidad
	var f := _fuente()
	var visible := _texto_visible()
	var ancho_texto := f.get_string_size(visible, HORIZONTAL_ALIGNMENT_LEFT, -1, _tf()).x if visible != "" else 0.0
	var lado_icono := minf(centro.size.y * 0.5, 48.0)
	var separacion := 12.0 if visible != "" and icono != "" else 0.0
	var total := ancho_texto + (lado_icono if icono != "" else 0.0) + separacion
	var x := centro.position.x + (centro.size.x - total) / 2
	if icono != "":
		var r := Rect2(Vector2(x, centro.get_center().y - lado_icono / 2), Vector2(lado_icono, lado_icono))
		Iconos.dibujar(self, icono, r, Color(0, 0, 0, 0), texto_color)
		x += lado_icono + separacion
	if visible != "":
		var base := centro.get_center().y + (f.get_ascent(_tf()) - f.get_descent(_tf())) / 2
		draw_string(f, Vector2(x, base), visible, HORIZONTAL_ALIGNMENT_LEFT, -1, _tf(), texto_color)


## La caja de la maqueta que le toca a este botón (Temas.caja), con sus ajustes: principal o
## secundario (dentro de una ventana, el secundario es un contorno), el estilo propio de los nodos del
## mapa, la forma (redondo, círculo) y los colores propios si se le han dado.
func _caja_del_boton() -> Dictionary:
	var nombre := estilo_caja
	if nombre == "":
		nombre = "boton_p" if principal else ("boton_s_ventana" if _dentro_de_ventana() else "boton_s")
	var c := Temas.caja(nombre)
	if c["texto"].a <= 0.0:
		c["texto"] = Temas.ui("prim_t") if principal else Temas.ui("sec_t")
	if redondo and estilo_caja == "":
		var rr := float(Temas.estilo("radio_redondo", 10))
		c["radio"] = -1.0 if rr < 0.0 or rr >= 999.0 else rr * Temas.ESCALA
	if circular:
		c["radio"] = -1.0
	if color_fondo.a > 0.0:
		c["fondo"] = color_fondo
		for s in c["sombras"]:
			if s["dentro"]:
				s["color"] = color_labio
		c["texto"] = Temas.tinta_sobre(color_fondo)
	# Un secundario sin fondo fuera de una ventana: el texto, del color de la pantalla
	if c["fondo"].a < 0.5 and c["texto"].a <= 0.0:
		c["texto"] = Temas.ui("sec_t")
	return c


## Texto tal como se ve: en mayúsculas si el tema las usa en los botones (Mesa, Cine negro, Bauhaus…).
func _texto_visible() -> String:
	return texto.to_upper() if Temas.mayus("botones") else texto


## filter: brightness(b) de CSS.
static func _brillar(c: Color, b: float) -> Color:
	return Color(minf(c.r * b, 1.0), minf(c.g * b, 1.0), minf(c.b * b, 1.0), c.a)


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
