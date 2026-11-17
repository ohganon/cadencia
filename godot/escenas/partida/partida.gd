## Pantalla de partida de la entrega 1: los 10 niveles, dibujar, tumbar y ver el resultado.
##
## La interfaz se construye en código para que se pueda revisar como texto. Estilo Dominó Pop
## (DESIGN.md): fondo azul piscina, botón principal verde, el resto marfil, ventanas marfil sobre
## un velo azul. Fuentes: de momento la de Godot; Lilita One y Nunito (SIL OFL) están pendientes.
##
## Modo demostración, para capturas automáticas (ver godot/README.md):
##   Godot_v4.7.2-stable_win64_console.exe --path godot --resolution 540x960 -- --demo=7 --captura=C:/ruta/prefijo [--incompleto | --recto]
## Usa un archivo de progreso aparte y lo borra al terminar: nunca toca el del jugador.
extends Control

const Partida = preload("res://nucleo/partida.gd")
const Progreso = preload("res://nucleo/progreso.gd")
const Tablero = preload("res://escenas/partida/tablero.gd")

const AZUL := Color("#2462d6")
const TINTA := Color("#142554")
const TINTA_SUAVE := Color("#3a4f86")
const TEXTO_CLARO := Color("#e8f0ff")
const MARFIL := Color("#fffdf6")
const LABIO_MARFIL := Color("#d9e2f2")
const VERDE := Color("#3ddc6b")
const LABIO_VERDE := Color("#22a552")
const AMARILLO := Color("#ffc83d")
const BLOQUEADO := Color("#9db4e6")
const DESACTIVADO := Color("#b7c4df")

## Cómo se explica cada fallo. Frases cortas, sin culpar y recordando que reintentar es gratis.
const EXPLICACIONES := {
	"curva demasiado cerrada": "La curva era demasiado cerrada y la cadena se rompió.",
	"choca con un muro": "La cadena chocó con un muro.",
	"sale del tablero": "La cadena se salió del tablero.",
	"puerta cerrada": "La puerta estaba cerrada cuando llegó la cadena.",
	"faltan fichas": "No hay fichas para tanto camino.",
	"no empieza en el inicio": "Empieza a dibujar desde la ficha amarilla.",
	"bifurcador no válido": "Las ramas tienen que salir de una ficha ya puesta.",
	"no llegaron a la vez": "Las dos ramas no llegaron a la vez a la campana doble.",
	"solo llegó una rama": "A la campana doble solo llegó una rama. Necesita dos a la vez.",
	"no llegó ninguna rama": "Ninguna rama llegó a la campana doble.",
	"no llegó": "La cadena no llegó a la campana.",
	"orden": "Las campanas numeradas sonaron en otro orden.",
}

var niveles: Array = []
var indice := 0
var partida = null
var progreso = null

var tablero: Control
var titulo: Label
var ayuda: Label
var contador: Label
var estrellas_hud: Label
var boton_tumbar: Button
var boton_deshacer: Button
var boton_borrar: Button
var boton_pista: Button
var velo: ColorRect
var ventana: PanelContainer
var ventana_titulo: Label
var ventana_estrellas: Label
var ventana_texto: Label
var boton_repetir: Button
var boton_siguiente: Button
var lista_niveles: PanelContainer
var rejilla: GridContainer
var _pista_paso := 0


func _ready() -> void:
	var datos = JSON.parse_string(FileAccess.get_file_as_string("res://datos/niveles_entrega1.json"))
	niveles = datos["niveles"]
	# En el modo demostración el progreso va a un archivo aparte: nunca toca el del jugador
	var demo := false
	for a in OS.get_cmdline_user_args():
		demo = demo or a.begins_with("--demo")
	progreso = Progreso.new("user://demo_progreso.json" if demo else Progreso.RUTA)
	_construir()
	var primero := 0
	for n in niveles:
		if progreso.de(int(n["id"])) == 0:
			break
		primero = mini(primero + 1, niveles.size() - 1)
	cargar(primero)
	_demo_si_toca()


# ---------------------------------------------------------------- niveles

func cargar(i: int) -> void:
	indice = clampi(i, 0, niveles.size() - 1)
	var n: Dictionary = niveles[indice]
	partida = Partida.new(n["nivel"])
	tablero.preparar(partida)
	_pista_paso = 0
	titulo.text = "Nivel %d · %s" % [n["id"], n["titulo"]]
	ayuda.text = n["ayuda"]
	_cerrar_ventanas()
	_actualizar()


func _actualizar() -> void:
	var usadas: int = partida.usadas()
	var n: Dictionary = niveles[indice]
	contador.text = "Fichas %d / %d   ·   marca %d" % [usadas, partida.disponibles(), int(n["nivel"]["m"])]
	estrellas_hud.text = "★ %d" % progreso.total()
	var editando: bool = tablero.modo == Tablero.Modo.EDITAR
	boton_tumbar.disabled = not editando or partida.tramos.is_empty()
	boton_deshacer.disabled = not editando or partida.tramos.is_empty()
	boton_borrar.disabled = not editando or partida.tramos.is_empty()
	boton_pista.disabled = not editando


func _al_tumbar() -> void:
	tablero.tumbar()
	_actualizar()


func _al_terminar_caida() -> void:
	var r: Dictionary = tablero.resultado()
	var n: Dictionary = niveles[indice]
	var e: int = Partida.estrellas(r, int(n["nivel"]["m"]))
	if e > 0:
		progreso.registrar(int(n["id"]), e)
		ventana_titulo.text = "¡Nivel superado!"
		ventana_estrellas.text = "★ ★" if e >= 2 else "★ ☆"
		var linea := "%d fichas. " % int(r["fichas_usadas"])
		if e >= 2:
			linea += "Sin pasarte de la marca (%d)." % int(n["nivel"]["m"])
		else:
			linea += "La marca es %d: inténtalo con menos para la segunda estrella." % int(n["nivel"]["m"])
		ventana_texto.text = linea
		boton_siguiente.visible = indice < niveles.size() - 1
		boton_siguiente.text = "Siguiente"
	else:
		ventana_titulo.text = "¡Casi!"
		ventana_estrellas.text = ""
		ventana_texto.text = _explicacion(r) + "\nPrueba otra vez, es gratis."
		boton_siguiente.visible = false
	boton_repetir.text = "Repetir" if e > 0 else "Corregir"
	ventana_estrellas.visible = e > 0
	if e > 0:
		# Superado: ventana centrada sobre el velo, «Siguiente» es la acción principal
		_estilo_boton(boton_repetir, MARFIL, LABIO_MARFIL, 24)
		velo.visible = true
		ventana.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	else:
		# Fallo: la ventana baja y no hay velo, para que se vea la X donde se paró la cadena
		_estilo_boton(boton_repetir, VERDE, LABIO_VERDE, 30)
		velo.visible = false
		ventana.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 130)
	ventana.visible = true
	_actualizar()


func _explicacion(r: Dictionary) -> String:
	var parada = r.get("parada")
	if parada != null and EXPLICACIONES.has(parada["motivo"]) and r["motivos"].size() > 0:
		return EXPLICACIONES[parada["motivo"]]
	for k in r["motivos"]:
		var m: String = r["motivos"][k] if k != "orden" else "orden"
		if EXPLICACIONES.has(m):
			return EXPLICACIONES[m]
	return "La cadena no hizo sonar todas las campanas."


func _al_repetir() -> void:
	_cerrar_ventanas()
	tablero.editar()
	_actualizar()


func _al_siguiente() -> void:
	cargar(indice + 1)


func _al_deshacer() -> void:
	partida.deshacer()
	tablero.queue_redraw()
	_actualizar()


func _al_borrar() -> void:
	partida.borrar_todo()
	tablero.queue_redraw()
	_actualizar()


## La pista dibuja en fantasma el siguiente tramo de la solución de referencia.
func _al_pista() -> void:
	var sol: Array = niveles[indice]["solucion"]
	tablero.pista = sol[_pista_paso % sol.size()]["puntos"]
	_pista_paso += 1
	tablero.queue_redraw()


func _abrir_lista() -> void:
	for h in rejilla.get_children():
		h.queue_free()
	for i in niveles.size():
		var id := int(niveles[i]["id"])
		var e: int = progreso.de(id)
		var b := Button.new()
		b.custom_minimum_size = Vector2(112, 112)
		b.text = "%d\n%s" % [id, "★".repeat(e) if e > 0 else " "]
		var abierto: bool = progreso.abierto(id)
		var color := AMARILLO if e > 0 else (VERDE if abierto else BLOQUEADO)
		_estilo_boton(b, color, color.darkened(0.25), 24)
		b.disabled = not abierto
		b.pressed.connect(cargar.bind(i))
		rejilla.add_child(b)
	velo.visible = true
	lista_niveles.visible = true


func _cerrar_ventanas() -> void:
	velo.visible = false
	ventana.visible = false
	lista_niveles.visible = false


# ---------------------------------------------------------------- construcción de la interfaz

func _construir() -> void:
	var fondo := ColorRect.new()
	fondo.color = AZUL
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var margen := MarginContainer.new()
	margen.set_anchors_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "right"]:
		margen.add_theme_constant_override("margin_" + lado, 24)
	margen.add_theme_constant_override("margin_top", 28)
	margen.add_theme_constant_override("margin_bottom", 28)
	add_child(margen)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 14)
	margen.add_child(columna)

	var arriba := HBoxContainer.new()
	arriba.add_theme_constant_override("separation", 12)
	columna.add_child(arriba)
	var b_niveles := _boton("Niveles", false)
	b_niveles.pressed.connect(_abrir_lista)
	arriba.add_child(b_niveles)
	titulo = _etiqueta(30, Color.WHITE)
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titulo.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	arriba.add_child(titulo)
	estrellas_hud = _etiqueta(26, Color.WHITE)
	arriba.add_child(estrellas_hud)

	ayuda = _etiqueta(22, TEXTO_CLARO)
	ayuda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	columna.add_child(ayuda)

	tablero = Tablero.new()
	tablero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tablero.mouse_filter = Control.MOUSE_FILTER_STOP
	tablero.cambio.connect(_actualizar)
	tablero.caida_terminada.connect(_al_terminar_caida)
	columna.add_child(tablero)

	contador = _etiqueta(22, Color.WHITE)
	contador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(contador)

	var abajo := HBoxContainer.new()
	abajo.add_theme_constant_override("separation", 10)
	columna.add_child(abajo)
	boton_deshacer = _boton("Deshacer", false)
	boton_deshacer.pressed.connect(_al_deshacer)
	boton_borrar = _boton("Borrar", false)
	boton_borrar.pressed.connect(_al_borrar)
	boton_pista = _boton("Pista", false)
	boton_pista.pressed.connect(_al_pista)
	boton_tumbar = _boton("¡A tumbar!", true)
	boton_tumbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boton_tumbar.pressed.connect(_al_tumbar)
	for b in [boton_deshacer, boton_borrar, boton_pista, boton_tumbar]:
		abajo.add_child(b)

	velo = ColorRect.new()
	velo.color = Color(0.08, 0.16, 0.38, 0.55)
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	velo.visible = false
	add_child(velo)

	ventana = _ventana()
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 14)
	ventana.add_child(caja)
	ventana_titulo = _etiqueta(40, TINTA)
	ventana_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ventana_estrellas = _etiqueta(48, AMARILLO.darkened(0.15))
	ventana_estrellas.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ventana_texto = _etiqueta(24, TINTA_SUAVE)
	ventana_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ventana_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ventana_texto.custom_minimum_size = Vector2(520, 0)
	var botones := HBoxContainer.new()
	botones.add_theme_constant_override("separation", 12)
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	boton_repetir = _boton("Repetir", false)
	boton_repetir.pressed.connect(_al_repetir)
	boton_siguiente = _boton("Siguiente", true)
	boton_siguiente.pressed.connect(_al_siguiente)
	botones.add_child(boton_repetir)
	botones.add_child(boton_siguiente)
	for h in [ventana_titulo, ventana_estrellas, ventana_texto, botones]:
		caja.add_child(h)

	lista_niveles = _ventana()
	var caja_lista := VBoxContainer.new()
	caja_lista.add_theme_constant_override("separation", 16)
	lista_niveles.add_child(caja_lista)
	var t := _etiqueta(36, TINTA)
	t.text = "La Plaza"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja_lista.add_child(t)
	rejilla = GridContainer.new()
	rejilla.columns = 4
	rejilla.add_theme_constant_override("h_separation", 12)
	rejilla.add_theme_constant_override("v_separation", 12)
	caja_lista.add_child(rejilla)
	var cerrar := _boton("Volver", false)
	cerrar.pressed.connect(_cerrar_ventanas)
	caja_lista.add_child(cerrar)


func _ventana() -> PanelContainer:
	var v := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color = MARFIL
	s.set_corner_radius_all(22)
	s.set_border_width_all(2)
	s.border_color = TINTA
	s.content_margin_left = 28
	s.content_margin_right = 28
	s.content_margin_top = 28
	s.content_margin_bottom = 24
	s.shadow_color = TINTA
	s.shadow_offset = Vector2(0, 3)
	s.shadow_size = 1
	v.add_theme_stylebox_override("panel", s)
	v.set_anchors_preset(Control.PRESET_CENTER)
	v.grow_horizontal = Control.GROW_DIRECTION_BOTH
	v.grow_vertical = Control.GROW_DIRECTION_BOTH
	v.visible = false
	add_child(v)
	return v


func _etiqueta(tam: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	return l


func _boton(texto: String, principal: bool) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(0, 76)
	b.focus_mode = Control.FOCUS_NONE
	if principal:
		_estilo_boton(b, VERDE, LABIO_VERDE, 30)
	else:
		_estilo_boton(b, MARFIL, LABIO_MARFIL, 24)
	return b


## Botón que se hunde un poco al pulsarlo: labio inferior de 5 px que pasa a 2 px.
func _estilo_boton(b: Button, color: Color, labio: Color, tam: int) -> void:
	for estado in ["normal", "hover", "pressed", "disabled", "focus"]:
		var s := StyleBoxFlat.new()
		s.bg_color = color if estado != "disabled" else DESACTIVADO
		s.set_corner_radius_all(16)
		s.border_color = labio if estado != "disabled" else DESACTIVADO.darkened(0.15)
		s.border_width_bottom = 2 if estado == "pressed" else 5
		s.content_margin_left = 18
		s.content_margin_right = 18
		s.content_margin_top = 10 + (3 if estado == "pressed" else 0)
		s.content_margin_bottom = 10
		if estado == "focus":
			s.draw_center = false
			s.border_width_bottom = 0
		b.add_theme_stylebox_override(estado, s)
	b.add_theme_font_size_override("font_size", tam)
	for clave in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(clave, TINTA)
	b.add_theme_color_override("font_disabled_color", Color("#43557f"))


# ---------------------------------------------------------------- demostración y capturas

func _demo_si_toca() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var partes: PackedStringArray = a.trim_prefix("--").split("=", true, 1)
		args[partes[0]] = partes[1] if partes.size() > 1 else "1"
	if not args.has("demo"):
		return
	var prefijo: String = args.get("captura", "user://captura")
	await get_tree().process_frame
	cargar(int(args["demo"]) - 1)
	await _capturar(prefijo + "_1_vacio.png")
	var sol: Array = niveles[indice]["solucion"]
	if args.has("incompleto"):
		sol = sol.slice(0, 1)
	if args.has("recto"):      # en línea recta del inicio a la primera campana: suele fallar
		var nivel: Dictionary = niveles[indice]["nivel"]
		sol = [{"puntos": [nivel["i"], nivel["c"][0][1]]}]
	for tr in sol:
		_trazar(tr["puntos"])
	tablero.queue_redraw()
	_actualizar()
	await _capturar(prefijo + "_2_dibujado.png")
	_al_tumbar()
	await get_tree().create_timer(0.5).timeout
	await _capturar(prefijo + "_3_cayendo.png")
	await tablero.caida_terminada
	await get_tree().create_timer(0.6).timeout
	await _capturar(prefijo + "_4_resultado.png")
	print("DEMO resultado: ", JSON.stringify(tablero.resultado()))
	for r in ["user://demo_progreso.json", "user://demo_progreso.anterior.json"]:
		if FileAccess.file_exists(r):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(r))
	get_tree().quit()


## Dibuja un trazo como lo haría un dedo: empieza en el primer punto y sigue punto a punto.
func _trazar(puntos: Array) -> void:
	partida.empezar(puntos[0])
	for p in puntos.slice(1):
		partida.seguir(p)
	partida.terminar()


func _capturar(ruta: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(ruta)
	print("captura: ", ruta)
