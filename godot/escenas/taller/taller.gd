## Pantalla del Taller: crear un nivel, probarlo, compartirlo con un código y jugar los de otros.
##
## Flujo: se colocan piezas en el tablero → «Probar» abre el nivel en la pantalla de partida → si el
## autor lo supera, puede publicarlo: el código lleva su solución, así que todo nivel compartido
## tiene solución. «Códigos» permite pegar el de un amigo y ver los niveles guardados.
##
## Modo demostración para capturas: -- --demo-taller --captura=C:/ruta/prefijo
extends Control

const Taller = preload("res://nucleo/taller.gd")
const Temas = preload("res://nucleo/temas.gd")
const Animar = preload("res://escenas/comun/animar.gd")
const Fuentes = preload("res://escenas/comun/fuentes.gd")
const Progreso = preload("res://nucleo/progreso.gd")
const TableroEditor = preload("res://escenas/taller/tablero_editor.gd")
const BotonPop = preload("res://escenas/comun/boton_pop.gd")
const Iconos = preload("res://escenas/comun/iconos.gd")

const ESCENA_PARTIDA := "res://escenas/partida/partida.tscn"
# Colores del tema activo (nucleo/temas.gd)
var AZUL: Color = Temas.ui("pantalla")
var TINTA: Color = Temas.ui("ventana_t")
var TINTA_SUAVE: Color = Temas.ui("ventana_s")
var TEXTO_CLARO: Color = Temas.ui("suave")
var MARFIL: Color = Temas.ui("ventana")
const CORAL := Color("#ff5470")
var VELO: Color = Temas.ui("velo")
var TEXTO: Color = Temas.ui("texto")          # texto sobre la pantalla
var MARCO: Color = Temas.ui("marco")          # borde y sombra de las ventanas
var ESTRELLA: Color = Temas.ui("estrella")

const HERRAMIENTAS := [
	["inicio", "Inicio: toca donde empieza la cadena."],
	["campana", "Campana: toca para ponerla."],
	["doble", "Campana doble: necesita dos ramas a la vez."],
	["numerada", "Numerada: suenan en el orden en que las pones."],
	["dorada", "Dorada: opcional, da la tercera estrella. Solo una, y no puede ser la única."],
	["muro", "Muro: arrastra el dedo para dibujarlo."],
	["puerta", "Puerta: arrástrala para ponerla; tócala para cambiar cuándo se abre."],
	["espiral", "Espiral: retrasa lo que pasa por ella. Tócala otra vez para cambiar cuántos tics."],
	["muelle", "Muelle: arrastra de la entrada a la salida. La cadena salta por encima; toca la entrada para cambiar el tiempo."],
	["interruptor", "Interruptor: arrastra para dibujar la compuerta; toca para mover su placa. Se abre al pisar la placa."],
	["noria", "Noria: arrastra de la entrada a la salida. Suelta la cadena en su siguiente vuelta; toca la entrada para cambiar cada cuánto."],
	["globo", "Globo: arrastra desde el globo hasta donde llega su camino. Al tocarlo la cadena, revienta y su camino cae solo."],
	["cristal", "Cristal: arrástralo como un muro. La primera ficha que choca lo rompe y se para; las siguientes pasan."],
	["goma", "Goma: toca cualquier pieza para quitarla."],
]

var tablero: Control
var botones_herramienta := {}
var ayuda: Label
var boton_probar: Control
var velo: ColorRect
var ventana: PanelContainer
var campo_codigo: LineEdit
var error_codigo: Label
var lista_caja: VBoxContainer
var fuente_titulos: Font
var fuente_botones: Font
var fuente_texto: Font
var fuente_negrita: Font


func _ready() -> void:
	_construir()
	# Los mismos ajustes de accesibilidad que en la partida (solo se leen)
	var ajustes: Dictionary = Progreso.new().ajustes
	tablero.aplicar_accesibilidad(ajustes)
	var estado := get_node_or_null("/root/Estado")
	var nivel: Dictionary = estado.borrador if estado != null and not estado.borrador.is_empty() else Taller.cargar_borrador()
	tablero.editar_nivel(nivel.duplicate(true))
	_elegir("campana")
	_validar()
	Animar.fundido_entrada(self)
	_demo_si_toca()


func _elegir(h: String) -> void:
	tablero.herramienta = h
	for k in botones_herramienta:
		botones_herramienta[k].resaltado = k == h
	for par in HERRAMIENTAS:
		if par[0] == h:
			ayuda.text = par[1]
	ayuda.remove_theme_color_override("font_color")
	ayuda.add_theme_color_override("font_color", TEXTO_CLARO)


func _al_editar() -> void:
	if not "--demo-taller" in OS.get_cmdline_user_args():     # la demo nunca toca el borrador real
		Taller.guardar_borrador(tablero.nivel)
	var estado := get_node_or_null("/root/Estado")
	if estado != null:
		estado.borrador = tablero.nivel.duplicate(true)
	_validar()


func _al_aviso(texto: String) -> void:
	ayuda.text = texto
	ayuda.add_theme_color_override("font_color", Color("#ffd2da"))


## Para probar hace falta al menos una campana; el resto ya lo garantiza el editor.
func _validar() -> void:
	boton_probar.desactivado = tablero.nivel["c"].is_empty()


func _al_probar() -> void:
	var nivel: Dictionary = tablero.nivel.duplicate(true)
	nivel["f"] = 400
	nivel["m"] = 0
	_ir_a_partida({"modo": "prueba", "nivel": nivel, "solucion": [], "titulo": "Prueba de tu nivel"})


func _al_vaciar() -> void:
	tablero.editar_nivel(Taller.nivel_vacio())
	_al_editar()


func _ir_a_partida(pendiente: Dictionary) -> void:
	var estado := get_node_or_null("/root/Estado")
	if estado != null:
		estado.pendiente = pendiente
		estado.borrador = tablero.nivel.duplicate(true)
	get_tree().change_scene_to_file(ESCENA_PARTIDA)


func _volver() -> void:
	var estado := get_node_or_null("/root/Estado")
	if estado != null:
		estado.pendiente = {}
	get_tree().change_scene_to_file("res://escenas/mapa/mapa.tscn")


# ---------------------------------------------------------------- códigos

func _abrir_codigos() -> void:
	error_codigo.text = ""
	_rellenar_lista()
	velo.visible = true
	ventana.reset_size()
	ventana.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	ventana.visible = true
	Animar.entrar(ventana)
	Animar.aparecer(velo)


func _cerrar_codigos() -> void:
	velo.visible = false
	ventana.visible = false


func _al_pegar() -> void:
	campo_codigo.text = DisplayServer.clipboard_get().strip_edges()


func _jugar_codigo(codigo: String) -> void:
	var r: Dictionary = Taller.decodificar(codigo)
	if not r["ok"]:
		error_codigo.text = r["error"]
		return
	Taller.guardar_en_lista({"codigo": codigo.strip_edges(), "titulo": "Nivel recibido", "propio": false,
		"fecha": Time.get_date_string_from_system()})
	_ir_a_partida({"modo": "codigo", "nivel": r["nivel"], "solucion": r["solucion"], "codigo": codigo.strip_edges(),
		"titulo": "Nivel del Taller"})


func _rellenar_lista() -> void:
	for h in lista_caja.get_children():
		h.queue_free()
	var lista := Taller.cargar_lista()
	if lista.is_empty():
		var vacio := _etiqueta(26, TINTA_SUAVE)
		vacio.text = "Aún no hay niveles guardados. Crea uno y publícalo, o pega el código de un amigo."
		vacio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vacio.custom_minimum_size = Vector2(560, 0)
		lista_caja.add_child(vacio)
		return
	for e in lista.slice(0, 5):
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 12)
		var t := _etiqueta(28, TINTA)
		t.text = "%s%s" % [e.get("titulo", "Nivel"), "  · tuyo" if e.get("propio", false) else ""]
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		fila.add_child(t)
		var jugar := _boton("Jugar", true, 28)
		jugar.custom_minimum_size = Vector2(0, 76)
		jugar.pulsado.connect(_jugar_codigo.bind(e["codigo"]))
		var copiar := _boton("Copiar", false, 28)
		copiar.custom_minimum_size = Vector2(0, 76)
		copiar.pulsado.connect(func():
			DisplayServer.clipboard_set(e["codigo"])
			copiar.texto = "¡Copiado!"
			copiar.queue_redraw())
		fila.add_child(jugar)
		fila.add_child(copiar)
		lista_caja.add_child(fila)


# ---------------------------------------------------------------- interfaz

func _fuentes() -> void:
	# Las letras del tema activo (escenas/comun/fuentes.gd)
	var f := Fuentes.del_tema()
	fuente_titulos = f["titulos"]
	fuente_botones = f["botones"]
	fuente_texto = f["texto"]
	fuente_negrita = f["negrita"]
	var tema := Theme.new()
	tema.default_font = fuente_texto
	theme = tema


func _construir() -> void:
	_fuentes()
	var fondo := ColorRect.new()
	fondo.color = AZUL
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)
	Animar.luz_de_fondo(fondo)
	var margen := MarginContainer.new()
	margen.set_anchors_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "right"]:
		margen.add_theme_constant_override("margin_" + lado, 28)
	margen.add_theme_constant_override("margin_top", 32)
	margen.add_theme_constant_override("margin_bottom", 36)
	add_child(margen)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 14)
	margen.add_child(columna)

	var hud := HBoxContainer.new()
	hud.add_theme_constant_override("separation", 16)
	columna.add_child(hud)
	var volver := _boton("", false)
	volver.icono = "volver"
	volver.redondo = true
	volver.custom_minimum_size = Vector2(96, 96)
	volver.pulsado.connect(_volver)
	hud.add_child(volver)
	var titulo := _etiqueta(50, TEXTO, true)
	titulo.text = "Taller"
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.add_child(titulo)
	var hueco := Control.new()
	hueco.custom_minimum_size = Vector2(96, 0)
	hud.add_child(hueco)

	# Las herramientas, en dos filas de botones grandes (más fáciles de tocar que una fila apretada)
	var centrado := CenterContainer.new()
	columna.add_child(centrado)
	var barra := GridContainer.new()
	barra.columns = 7
	barra.add_theme_constant_override("h_separation", 10)
	barra.add_theme_constant_override("v_separation", 10)
	centrado.add_child(barra)
	for par in HERRAMIENTAS:
		var b := _boton("", false)
		b.icono = "campana_simple" if par[0] == "campana" else par[0]     # que no se confunda con la dorada
		b.redondo = true
		b.custom_minimum_size = Vector2(68, 68)      # catorce herramientas en dos filas de siete
		b.pulsado.connect(_elegir.bind(par[0]))
		barra.add_child(b)
		botones_herramienta[par[0]] = b

	ayuda = _etiqueta(27, TEXTO_CLARO)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ayuda.custom_minimum_size = Vector2(600, 72)
	columna.add_child(ayuda)

	tablero = TableroEditor.new()
	tablero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tablero.mouse_filter = Control.MOUSE_FILTER_STOP
	tablero.editado.connect(_al_editar)
	tablero.aviso.connect(_al_aviso)
	columna.add_child(tablero)

	var abajo := HBoxContainer.new()
	abajo.add_theme_constant_override("separation", 16)
	columna.add_child(abajo)
	var vaciar := _boton("Vaciar", false, 32)
	vaciar.custom_minimum_size = Vector2(0, 108)
	vaciar.pulsado.connect(_al_vaciar)
	boton_probar = _boton("Probar", true, 42)
	boton_probar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boton_probar.custom_minimum_size = Vector2(0, 108)
	boton_probar.pulsado.connect(_al_probar)
	var codigos := _boton("Códigos", false, 32)
	codigos.custom_minimum_size = Vector2(0, 108)
	codigos.pulsado.connect(_abrir_codigos)
	for b in [vaciar, boton_probar, codigos]:
		abajo.add_child(b)

	velo = ColorRect.new()
	velo.color = VELO
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	velo.visible = false
	add_child(velo)
	_construir_codigos()


func _construir_codigos() -> void:
	ventana = PanelContainer.new()
	ventana.set_meta("ventana", true)
	var s := StyleBoxFlat.new()
	s.bg_color = MARFIL
	s.set_corner_radius_all(Temas.numero("radio_ventana", 22))
	s.set_border_width_all(2)
	s.border_color = MARCO
	s.shadow_color = MARCO
	s.shadow_offset = Vector2(0, 4)
	s.shadow_size = 1
	s.content_margin_left = 32
	s.content_margin_right = 32
	s.content_margin_top = 36
	s.content_margin_bottom = 32
	ventana.add_theme_stylebox_override("panel", s)
	ventana.custom_minimum_size = Vector2(640, 0)
	ventana.visible = false
	add_child(ventana)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 16)
	ventana.add_child(caja)
	var t := _etiqueta(48, TINTA, true)
	t.text = "Códigos"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(t)
	var explica := _etiqueta(26, TINTA_SUAVE)
	explica.text = "Pega el código que te han pasado para jugar su nivel."
	explica.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explica.custom_minimum_size = Vector2(560, 0)
	caja.add_child(explica)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	caja.add_child(fila)
	campo_codigo = LineEdit.new()
	campo_codigo.placeholder_text = "DING1-…"
	campo_codigo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	campo_codigo.custom_minimum_size = Vector2(0, 76)
	campo_codigo.add_theme_font_size_override("font_size", Temas.tam(26))
	campo_codigo.add_theme_color_override("font_color", TINTA)
	var sc := StyleBoxFlat.new()
	sc.bg_color = Color(TINTA, 0.06)
	sc.set_corner_radius_all(14)
	sc.set_border_width_all(2)
	sc.border_color = TINTA
	sc.content_margin_left = 16
	sc.content_margin_right = 16
	campo_codigo.add_theme_stylebox_override("normal", sc)
	campo_codigo.add_theme_stylebox_override("focus", sc)
	fila.add_child(campo_codigo)
	var pegar := _boton("Pegar", false, 28)
	pegar.custom_minimum_size = Vector2(0, 76)
	pegar.pulsado.connect(_al_pegar)
	fila.add_child(pegar)
	error_codigo = _etiqueta(24, CORAL.darkened(0.2))
	error_codigo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	error_codigo.custom_minimum_size = Vector2(560, 0)
	caja.add_child(error_codigo)
	var jugar := _boton("Jugar este código", true, 34)
	jugar.pulsado.connect(func(): _jugar_codigo(campo_codigo.text))
	caja.add_child(jugar)
	var sub := _etiqueta(34, TINTA, true)
	sub.text = "Guardados"
	caja.add_child(sub)
	lista_caja = VBoxContainer.new()
	lista_caja.add_theme_constant_override("separation", 10)
	caja.add_child(lista_caja)
	var cerrar := _boton("Cerrar", false, 32)
	cerrar.pulsado.connect(_cerrar_codigos)
	caja.add_child(cerrar)


func _etiqueta(tam: int, color: Color, titular := false) -> Label:
	var l := Label.new()
	if titular:
		l.add_theme_font_override("font", fuente_titulos)
	l.add_theme_font_size_override("font_size", Temas.tam(tam))
	l.add_theme_color_override("font_color", color)
	return l


func _boton(texto: String, principal: bool, tam := 36) -> Control:
	var b = BotonPop.new()
	b.texto = texto
	b.principal = principal
	b.tam_fuente = tam
	b.fuente = fuente_botones
	return b


# ---------------------------------------------------------------- demostración

func _demo_si_toca() -> void:
	var args := OS.get_cmdline_user_args()
	if not "--demo-taller" in args:
		return
	var prefijo := "user://taller"
	for a in args:
		if a.begins_with("--captura="):
			prefijo = a.trim_prefix("--captura=")
	await get_tree().create_timer(0.3).timeout      # que termine el fundido de entrada
	_al_vaciar()
	# Un nivel como el 8: campana doble arriba a la derecha y un muro
	var pasos := [["doble", [74.0, 30.0]], ["campana", [18.0, 70.0]], ["dorada", [22.0, 28.0]], ["espiral", [62.0, 124.0]], ["inicio", [50.0, 150.0]]]
	for p in pasos:
		_elegir(p[0])
		tablero._aplicar(p[1])
	tablero._muro_desde = [62.0, 44.0]
	tablero._muro_hasta = [88.0, 44.0]
	tablero._terminar_muro()
	_elegir("puerta")
	tablero._muro_desde = [30.0, 100.0]
	tablero._muro_hasta = [56.0, 100.0]
	tablero._terminar_muro()
	_elegir("muelle")
	tablero._muro_desde = [80.0, 112.0]
	tablero._muro_hasta = [80.0, 82.0]
	tablero._terminar_muro()
	_elegir("interruptor")
	tablero._muro_desde = [10.0, 132.0]
	tablero._muro_hasta = [34.0, 132.0]
	tablero._terminar_muro()
	_elegir("noria")
	tablero._muro_desde = [30.0, 60.0]
	tablero._muro_hasta = [30.0, 40.0]
	tablero._terminar_muro()
	_elegir("globo")
	tablero._muro_desde = [70.0, 150.0]
	tablero._muro_hasta = [90.0, 120.0]
	tablero._terminar_muro()
	_elegir("cristal")
	tablero._muro_desde = [10.0, 80.0]
	tablero._muro_hasta = [40.0, 80.0]
	tablero._terminar_muro()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(prefijo + "_1_editor.png")
	_abrir_codigos()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(prefijo + "_2_codigos.png")
	print("DEMO taller: ", JSON.stringify(tablero.nivel))
	get_tree().quit()
