## Pantalla de inicio: el mapa del barrio (maqueta de Dominó Pop, «Inicio»).
##
## - HUD: la cuerda (cuántas quedan y cuándo llega la siguiente) y las estrellas del barrio.
## - Cinta «Barrio 1 · La Plaza» y el camino de fichas con los nodos: hechos en amarillo, el actual
##   más grande y verde con un anillo blanco, los cerrados en azul apagado y sin sombra.
## - «Jugar · nivel N» y la barra de abajo: Inicio, Reto (Caída del Día), Taller y Ajustes.
## - Sin cuerda: una ventana con opciones del mismo tamaño, sin cuentas atrás falsas (LR-06) y sin
##   presentar el rechazo como un error. Los anuncios (+3) y el Club llegan en las entregas 7 y 8.
##
## Pío (la mascota) llegará con el arte definitivo: ver la pasada estética en ARQUITECTURA_BORRADOR.md.
##
## Demostración: -- --demo-mapa --captura=C:/ruta/prefijo [--superados=15] [--sin-cuerda]
extends Control

const Progreso = preload("res://nucleo/progreso.gd")
const Registro = preload("res://nucleo/registro.gd")
const Cuerda = preload("res://nucleo/cuerda.gd")
const BotonPop = preload("res://escenas/comun/boton_pop.gd")
const Pastilla = preload("res://escenas/comun/pastilla.gd")
const Iconos = preload("res://escenas/comun/iconos.gd")
const Camino = preload("res://escenas/mapa/camino.gd")

const ESCENA_PARTIDA := "res://escenas/partida/partida.tscn"
const ESCENA_TALLER := "res://escenas/taller/taller.tscn"
const AZUL := Color("#2462d6")
const TINTA := Color("#142554")
const TINTA_SUAVE := Color("#3a4f86")
const TEXTO_CLARO := Color("#e8f0ff")
const MARFIL := Color("#fffdf6")
const VERDE := Color("#3ddc6b")
const LABIO_VERDE := Color("#22a552")
const AMARILLO := Color("#ffc83d")
const LABIO_AMARILLO := Color("#d9a21f")
const BLOQUEADO := Color("#9db4e6")
const VELO := Color(0.039, 0.11, 0.314, 0.55)
const ALTO_TRAMO := 190.0

var niveles: Array = []          # toda la campaña, barrio tras barrio
var barrios: Array = []
var _visible := 0                   # barrio que se está viendo
var etiqueta_barrio: Label
var etiqueta_nombre: Label
var aviso_cerrado: Label
var flecha_izq: Control
var flecha_der: Control
var progreso = null
var registro = null
var pastilla_cuerda: Control
var pastilla_estrellas: Control
var camino: Control
var scroll: ScrollContainer
var boton_jugar: Control
var velo: ColorRect
var ventana_cuerda: PanelContainer
var texto_espera: Label
var ventana_ajustes: PanelContainer
var boton_sonido: Control
var boton_vibracion: Control
var resumen_prueba: Label
var fuente_titulos: Font
var fuente_texto: Font
var fuente_negrita: Font
var _actual := 0                    # índice del nivel que toca
var _demo := false
var _reloj := 0.0


func _ready() -> void:
	for ruta in ["res://datos/barrio_1.json", "res://datos/barrio_2.json"]:
		var b = JSON.parse_string(FileAccess.get_file_as_string(ruta))
		barrios.append(b)
		niveles += b["niveles"]
	for a in OS.get_cmdline_user_args():
		_demo = _demo or a.begins_with("--demo")
	progreso = Progreso.new("user://demo_progreso.json" if _demo else Progreso.RUTA)
	registro = Registro.new("user://demo_registro.jsonl" if _demo else Registro.RUTA)
	_construir()
	_refrescar()
	var estado := get_node_or_null("/root/Estado")
	if estado != null and estado.pendiente.get("modo") == "sin_cuerda":
		estado.pendiente = {}
		_mostrar_sin_cuerda()
	_demo_si_toca()


func ahora() -> int:
	return int(Time.get_unix_time_from_system())


func _process(delta: float) -> void:
	_reloj += delta
	if _reloj >= 1.0:
		_reloj = 0.0
		_hud_cuerda()


# ---------------------------------------------------------------- estado

func _refrescar() -> void:
	_actual = 0
	for i in niveles.size():
		if progreso.de(int(niveles[i]["id"])) > 0:
			_actual = mini(i + 1, niveles.size() - 1)
	# Se abre el mapa en el barrio del nivel que toca
	var cuenta := 0
	for k in barrios.size():
		cuenta += barrios[k]["niveles"].size()
		if _actual < cuenta:
			_visible = k
			break
	_colocar_nodos()
	_hud_cuerda()
	pastilla_estrellas.texto = str(progreso.total())
	boton_jugar.texto = "Jugar · nivel %d" % int(niveles[_actual]["id"])
	boton_jugar.queue_redraw()


func _hud_cuerda() -> void:
	var n: int = progreso.cuerdas(ahora())
	pastilla_cuerda.texto = "%d/%d" % [n, Cuerda.MAXIMO]
	var falta: int = progreso.falta_cuerda(ahora())
	pastilla_cuerda.subtexto = Cuerda.reloj(falta) if falta > 0 else ""
	if texto_espera != null and ventana_cuerda.visible:
		texto_espera.text = "La siguiente cuerda llega en %s." % Cuerda.reloj(falta) if falta > 0 else "¡Ya tienes cuerda!"


func _jugar(i: int) -> void:
	var id := int(niveles[i]["id"])
	if not progreso.empezar(id, ahora()):
		_mostrar_sin_cuerda()
		return
	_ir_partida({"modo": "campana", "indice": i})


func _ir_partida(pendiente: Dictionary) -> void:
	var estado := get_node_or_null("/root/Estado")
	if estado != null:
		estado.pendiente = pendiente
	get_tree().change_scene_to_file(ESCENA_PARTIDA)


func _mostrar_sin_cuerda() -> void:
	velo.visible = true
	ventana_cuerda.visible = true
	_hud_cuerda()
	ventana_cuerda.reset_size()
	ventana_cuerda.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)


func _cerrar_ventanas() -> void:
	velo.visible = false
	ventana_cuerda.visible = false
	ventana_ajustes.visible = false


func _abrir_ajustes() -> void:
	_textos_ajustes()
	resumen_prueba.visible = false
	velo.visible = true
	ventana_ajustes.visible = true
	ventana_ajustes.reset_size()
	ventana_ajustes.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)


func _textos_ajustes() -> void:
	boton_sonido.texto = "Sonido: " + ("sí" if progreso.ajustes["sonido"] else "no")
	boton_vibracion.texto = "Vibración: " + ("sí" if progreso.ajustes["vibracion"] else "no")
	for b in [boton_sonido, boton_vibracion]:
		b.update_minimum_size()
		b.queue_redraw()


## Para quien dirige la prueba: intentos por nivel, leídos del registro local.
func _al_resumen() -> void:
	var s: Dictionary = registro.resumen()
	var lineas := ["Nivel · intentos · hasta superarlo · pistas"]
	for n in niveles:
		var k := str(int(n["id"]))
		if s.has(k):
			var r: Dictionary = s[k]
			lineas.append("%s · %d · %s · %d" % [k, r["intentos"], str(r["intentos_hasta_superar"]) if r["superado"] else "sin superar", r["pistas"]])
	if lineas.size() == 1:
		lineas.append("Aún no hay partidas registradas.")
	resumen_prueba.text = "\n".join(lineas)
	resumen_prueba.visible = not resumen_prueba.visible
	ventana_ajustes.reset_size()


# ---------------------------------------------------------------- mapa

## Índices (en la lista de toda la campaña) de los niveles del barrio que se ve.
func _rango_visible() -> Array:
	var desde := 0
	for k in _visible:
		desde += barrios[k]["niveles"].size()
	return range(desde, desde + barrios[_visible]["niveles"].size())


## Un barrio se abre al superar el último nivel del anterior.
func _barrio_abierto(k: int) -> bool:
	if k == 0:
		return true
	var anterior: Array = barrios[k - 1]["niveles"]
	return progreso.de(int(anterior[-1]["id"])) > 0


func _cambiar_barrio(paso: int) -> void:
	_visible = clampi(_visible + paso, 0, barrios.size() - 1)
	_colocar_nodos()


func _colocar_nodos() -> void:
	for h in camino.get_children():
		h.queue_free()
	var rango := _rango_visible()
	var abierto := _barrio_abierto(_visible)
	etiqueta_barrio.text = "Barrio %d" % int(barrios[_visible]["barrio"])
	etiqueta_nombre.text = barrios[_visible]["nombre"]
	flecha_izq.desactivado = _visible == 0
	flecha_der.desactivado = _visible == barrios.size() - 1
	aviso_cerrado.visible = not abierto
	if not abierto:
		aviso_cerrado.text = "Termina %s para abrir %s." % [barrios[_visible - 1]["nombre"], barrios[_visible]["nombre"]]
	var ancho: float = maxf(scroll.size.x, 600.0)
	var alto := ALTO_TRAMO * rango.size() + 120.0
	camino.custom_minimum_size = Vector2(ancho, alto)
	var centros := []
	for k in rango.size():
		var x := ancho * (0.3 if k % 2 == 0 else 0.7)
		var y := alto - 100.0 - k * ALTO_TRAMO
		centros.append(Vector2(x, y))
	camino.centros = centros
	camino.recorrido = clampi(_actual - rango[0], 0, rango.size()) if abierto else 0
	camino.queue_redraw()
	for k in rango.size():
		var i: int = rango[k]
		var id := int(niveles[i]["id"])
		var hecho: bool = progreso.de(id) > 0
		var es_actual: bool = i == _actual and abierto
		var lado := 120.0 if es_actual else 96.0
		var b := _boton(str(id), false, 46 if es_actual else 40)
		b.circular = true
		b.custom_minimum_size = Vector2(lado, lado)
		b.size = Vector2(lado, lado)
		b.position = centros[k] - Vector2(lado, lado) / 2
		if hecho and not es_actual:
			b.color_fondo = AMARILLO
			b.color_labio = LABIO_AMARILLO
		elif es_actual:
			b.color_fondo = VERDE
			b.color_labio = LABIO_VERDE
			b.resaltado = true
		else:
			b.color_fondo = BLOQUEADO
			b.color_labio = BLOQUEADO
			b.sin_sombra = true
		if hecho or es_actual:
			b.pulsado.connect(_jugar.bind(i))
		else:
			b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		camino.add_child(b)
	# El nivel que toca, a la vista (o el principio del barrio)
	await get_tree().process_frame
	var objetivo := clampi(_actual - rango[0], 0, rango.size() - 1) if abierto else 0
	scroll.scroll_vertical = int(centros[objetivo].y - scroll.size.y * 0.55)


# ---------------------------------------------------------------- interfaz

func _fuentes() -> void:
	var ts := TextServerManager.get_primary_interface()
	var nunito: FontFile = load("res://fuentes/Nunito-wght.ttf")
	var texto := FontVariation.new()
	texto.base_font = nunito
	texto.variation_opentype = {ts.name_to_tag("wght"): 700}
	fuente_texto = texto
	var negrita := FontVariation.new()
	negrita.base_font = nunito
	negrita.variation_opentype = {ts.name_to_tag("wght"): 900}
	fuente_negrita = negrita
	var titulos := FontVariation.new()
	titulos.base_font = load("res://fuentes/LilitaOne-Regular.ttf")
	titulos.fallbacks = [texto]
	fuente_titulos = titulos
	var tema := Theme.new()
	tema.default_font = fuente_texto
	theme = tema


func _construir() -> void:
	_fuentes()
	var fondo := ColorRect.new()
	fondo.color = AZUL
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)
	var margen := MarginContainer.new()
	margen.set_anchors_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "right"]:
		margen.add_theme_constant_override("margin_" + lado, 28)
	margen.add_theme_constant_override("margin_top", 32)
	margen.add_theme_constant_override("margin_bottom", 20)
	add_child(margen)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 12)
	margen.add_child(columna)

	var hud := HBoxContainer.new()
	columna.add_child(hud)
	pastilla_cuerda = Pastilla.new()
	pastilla_cuerda.icono = "llave"
	pastilla_cuerda.color_icono = AMARILLO
	pastilla_cuerda.fuente = fuente_negrita
	hud.add_child(pastilla_cuerda)
	var hueco := Control.new()
	hueco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.add_child(hueco)
	pastilla_estrellas = Pastilla.new()
	pastilla_estrellas.icono = "estrella"
	pastilla_estrellas.color_icono = AMARILLO
	pastilla_estrellas.fuente = fuente_negrita
	hud.add_child(pastilla_estrellas)

	var fila_cinta := HBoxContainer.new()
	fila_cinta.add_theme_constant_override("separation", 12)
	columna.add_child(fila_cinta)
	var cinta := VBoxContainer.new()
	cinta.add_theme_constant_override("separation", 0)
	cinta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_cinta.add_child(cinta)
	etiqueta_barrio = _etiqueta(24, TEXTO_CLARO)
	cinta.add_child(etiqueta_barrio)
	etiqueta_nombre = _etiqueta(56, Color.WHITE, true)
	cinta.add_child(etiqueta_nombre)
	flecha_izq = _boton("", false)
	flecha_izq.icono = "volver"
	flecha_izq.redondo = true
	flecha_izq.custom_minimum_size = Vector2(84, 84)
	flecha_izq.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	flecha_izq.tooltip_text = "Barrio anterior"
	flecha_izq.pulsado.connect(_cambiar_barrio.bind(-1))
	flecha_der = _boton("", false)
	flecha_der.icono = "adelante"
	flecha_der.redondo = true
	flecha_der.custom_minimum_size = Vector2(84, 84)
	flecha_der.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	flecha_der.tooltip_text = "Barrio siguiente"
	flecha_der.pulsado.connect(_cambiar_barrio.bind(1))
	fila_cinta.add_child(flecha_izq)
	fila_cinta.add_child(flecha_der)
	aviso_cerrado = _etiqueta(28, Color.WHITE)
	aviso_cerrado.add_theme_font_override("font", fuente_negrita)
	aviso_cerrado.visible = false
	columna.add_child(aviso_cerrado)

	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	columna.add_child(scroll)
	camino = Camino.new()
	scroll.add_child(camino)

	boton_jugar = _boton("Jugar", true, 44)
	boton_jugar.custom_minimum_size = Vector2(0, 112)
	boton_jugar.pulsado.connect(func(): _jugar(_actual))
	columna.add_child(boton_jugar)

	columna.add_child(_barra_abajo())

	velo = ColorRect.new()
	velo.color = VELO
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	velo.visible = false
	add_child(velo)
	_construir_sin_cuerda()
	_construir_ajustes()


## Barra de abajo (DESIGN.md: la pestaña activa se marca con una pastilla marfil y no se eleva).
func _barra_abajo() -> Control:
	var barra := HBoxContainer.new()
	barra.add_theme_constant_override("separation", 0)
	var pestanas := [["Inicio", "ficha", Callable()], ["Reto", "campana", func(): _ir_partida({"modo": "diario"})],
		["Taller", "muro", func(): get_tree().change_scene_to_file(ESCENA_TALLER)], ["Ajustes", "llave", _abrir_ajustes]]
	for k in pestanas.size():
		var p: Array = pestanas[k]
		var activa := k == 0
		var celda := VBoxContainer.new()
		celda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		celda.add_theme_constant_override("separation", 2)
		celda.mouse_filter = Control.MOUSE_FILTER_STOP
		var icono := Control.new()
		icono.custom_minimum_size = Vector2(0, 60)
		icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tipo: String = p[1]
		icono.draw.connect(func():
			var c := Vector2(icono.size.x / 2, 30)
			if activa:
				var s := StyleBoxFlat.new()
				s.bg_color = MARFIL
				s.set_corner_radius_all(999)
				icono.draw_style_box(s, Rect2(c - Vector2(46, 28), Vector2(92, 56)))
			Iconos.dibujar(icono, tipo, Rect2(c - Vector2(20, 20), Vector2(40, 40))))
		celda.add_child(icono)
		var l := _etiqueta(22, Color.WHITE if activa else TEXTO_CLARO)
		if activa:
			l.add_theme_font_override("font", fuente_negrita)
		l.text = p[0]
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		celda.add_child(l)
		var accion: Callable = p[2]
		if accion.is_valid():
			celda.gui_input.connect(func(e):
				if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and not e.pressed:
					accion.call())
		barra.add_child(celda)
	return barra


func _construir_sin_cuerda() -> void:
	ventana_cuerda = _ventana()
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 16)
	ventana_cuerda.add_child(caja)
	var t := _etiqueta(52, TINTA, true)
	t.text = "Sin cuerda"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(t)
	var d := _etiqueta(28, TINTA_SUAVE)
	d.text = "Pío necesita un respiro. Los niveles nuevos usan cuerda; repetir niveles, la Caída del Día y el Taller son gratis."
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	d.custom_minimum_size = Vector2(560, 0)
	caja.add_child(d)
	texto_espera = _etiqueta(30, TINTA)
	texto_espera.add_theme_font_override("font", fuente_negrita)
	texto_espera.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_espera.custom_minimum_size = Vector2(560, 0)
	caja.add_child(texto_espera)
	# Opciones del mismo tamaño y del mismo tipo: ninguna se destaca sobre las demás
	var opciones := [["Esperar", _cerrar_ventanas], ["Jugar la Caída del Día", func(): _ir_partida({"modo": "diario"})],
		["Ir al Taller", func(): get_tree().change_scene_to_file(ESCENA_TALLER)]]
	for o in opciones:
		var b := _boton(o[0], false, 34)
		b.custom_minimum_size = Vector2(0, 96)
		b.pulsado.connect(o[1])
		caja.add_child(b)


func _construir_ajustes() -> void:
	ventana_ajustes = _ventana()
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 16)
	ventana_ajustes.add_child(caja)
	var t := _etiqueta(52, TINTA, true)
	t.text = "Ajustes"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(t)
	boton_sonido = _boton("Sonido: sí", false, 32)
	boton_sonido.pulsado.connect(func():
		progreso.ajustar("sonido", not progreso.ajustes["sonido"])
		_textos_ajustes())
	boton_vibracion = _boton("Vibración: sí", false, 32)
	boton_vibracion.pulsado.connect(func():
		progreso.ajustar("vibracion", not progreso.ajustes["vibracion"])
		_textos_ajustes())
	var b_resumen := _boton("Resumen de la prueba", false, 32)
	b_resumen.pulsado.connect(_al_resumen)
	resumen_prueba = _etiqueta(24, TINTA_SUAVE)
	resumen_prueba.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resumen_prueba.visible = false
	var cerrar := _boton("Volver al mapa", true, 36)
	cerrar.pulsado.connect(_cerrar_ventanas)
	for h in [boton_sonido, boton_vibracion, b_resumen, resumen_prueba, cerrar]:
		caja.add_child(h)


func _ventana() -> PanelContainer:
	var v := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color = MARFIL
	s.set_corner_radius_all(22)
	s.set_border_width_all(2)
	s.border_color = TINTA
	s.shadow_color = TINTA
	s.shadow_offset = Vector2(0, 4)
	s.shadow_size = 1
	s.content_margin_left = 32
	s.content_margin_right = 32
	s.content_margin_top = 40
	s.content_margin_bottom = 32
	v.add_theme_stylebox_override("panel", s)
	v.custom_minimum_size = Vector2(640, 0)
	v.visible = false
	add_child(v)
	return v


func _etiqueta(tam: int, color: Color, titular := false) -> Label:
	var l := Label.new()
	if titular:
		l.add_theme_font_override("font", fuente_titulos)
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	return l


func _boton(texto: String, principal: bool, tam := 36) -> Control:
	var b = BotonPop.new()
	b.texto = texto
	b.principal = principal
	b.tam_fuente = tam
	b.fuente = fuente_titulos
	return b


# ---------------------------------------------------------------- demostración

func _demo_si_toca() -> void:
	if not _demo:
		return
	var args := {}
	for a in OS.get_cmdline_user_args():
		var partes: PackedStringArray = a.trim_prefix("--").split("=", true, 1)
		args[partes[0]] = partes[1] if partes.size() > 1 else "1"
	if not args.has("demo-mapa"):
		# Las demostraciones de partida (--demo=N) se hacen en su pantalla: el juego ahora empieza
		# en el mapa, así que se las pasa allí (si no, la ventana se quedaría esperando sin cerrar)
		if args.has("demo"):
			get_tree().change_scene_to_file.call_deferred(ESCENA_PARTIDA)
		return
	var prefijo: String = args.get("captura", "user://mapa")
	for id in range(1, int(args.get("superados", "0")) + 1):
		progreso.registrar(id, 2 if id % 3 else 1)
	if args.has("sin-cuerda"):
		progreso.cuerda = {"n": 0, "t": ahora() - 17 * 60}
	_refrescar()
	if args.has("ver-barrio"):
		_visible = clampi(int(args["ver-barrio"]) - 1, 0, barrios.size() - 1)
		_colocar_nodos()
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(prefijo + "_1_mapa.png")
	if args.has("sin-cuerda"):
		_jugar(_actual)
		await get_tree().create_timer(0.2).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(prefijo + "_2_sin_cuerda.png")
	print("DEMO mapa: actual ", _actual + 1, " cuerdas ", progreso.cuerdas(ahora()))
	if args.has("entrar"):
		_jugar(_actual)          # cambia a la partida; allí se hace la captura y se cierra
		return
	for r in ["user://demo_progreso.json", "user://demo_progreso.anterior.json", "user://demo_registro.jsonl"]:
		if FileAccess.file_exists(r):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(r))
	get_tree().quit()
