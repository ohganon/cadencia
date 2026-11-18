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
const Temas = preload("res://nucleo/temas.gd")
const Fuentes = preload("res://escenas/comun/fuentes.gd")
const Registro = preload("res://nucleo/registro.gd")
const Cuerda = preload("res://nucleo/cuerda.gd")
const BotonPop = preload("res://escenas/comun/boton_pop.gd")
const Pastilla = preload("res://escenas/comun/pastilla.gd")
const Iconos = preload("res://escenas/comun/iconos.gd")
const Camino = preload("res://escenas/mapa/camino.gd")

const ESCENA_PARTIDA := "res://escenas/partida/partida.tscn"
const ESCENA_TALLER := "res://escenas/taller/taller.tscn"
# Colores del tema activo (nucleo/temas.gd)
var AZUL: Color = Temas.ui("pantalla")
var TINTA: Color = Temas.ui("ventana_t")
var TINTA_SUAVE: Color = Temas.ui("ventana_s")
var TEXTO_CLARO: Color = Temas.ui("suave")
var MARFIL: Color = Temas.ui("ventana")
var VERDE: Color = Temas.ui("prim")
var LABIO_VERDE: Color = Temas.ui("prim_labio")
var AMARILLO: Color = Temas.ui("nodo_h")
var LABIO_AMARILLO: Color = Temas.ui("nodo_h").darkened(0.15)
var BLOQUEADO: Color = Temas.ui("nodo_c")
var VELO: Color = Temas.ui("velo")
var TEXTO: Color = Temas.ui("texto")          # texto sobre la pantalla
var MARCO: Color = Temas.ui("marco")          # borde y sombra de las ventanas
var ESTRELLA: Color = Temas.ui("estrella")
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
var ventana_apariencia: PanelContainer
var boton_apariencia: Control
var aviso_prueba: Control            # aviso honesto cuando el tema elegido es del Club
var boton_sonido: Control
var boton_vibracion: Control
var botones_accesibilidad := {}     # clave del ajuste -> botón
const ACCESIBILIDAD := [["alto_contraste", "Alto contraste"], ["reducir_movimiento", "Reducir movimiento"],
	["texto_grande", "Texto grande"]]
var resumen_prueba: Label
var fuente_titulos: Font
var fuente_botones: Font
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
	elif estado != null and estado.pendiente.get("modo") == "apariencia":
		estado.pendiente = {}
		_abrir_apariencia()
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
	_centrar(ventana_cuerda)


func _cerrar_ventanas() -> void:
	velo.visible = false
	ventana_cuerda.visible = false
	ventana_ajustes.visible = false
	ventana_apariencia.visible = false


func _abrir_apariencia() -> void:
	ventana_ajustes.visible = false
	velo.visible = true
	ventana_apariencia.visible = true
	_centrar(ventana_apariencia)


## Cambia de tema y vuelve a construir el mapa con sus colores (con la ventana de Apariencia abierta).
func _elegir_tema(id: String) -> void:
	if id == Temas.id_activo():
		return
	progreso.tema = id
	progreso.guardar()
	Temas.usar(id)
	var estado := get_node_or_null("/root/Estado")
	if estado != null:
		estado.pendiente = {"modo": "apariencia"}
	get_tree().reload_current_scene()


func _abrir_ajustes() -> void:
	_textos_ajustes()
	resumen_prueba.visible = false
	velo.visible = true
	ventana_ajustes.visible = true
	_centrar(ventana_ajustes)


## Centra una ventana cuando ya ha recalculado su tamaño (los textos de los botones acaban de cambiar).
func _centrar(v: Control) -> void:
	# A mano: el preajuste de Godot centra con un tamaño mínimo antiguo si el contenido acaba de cambiar
	await get_tree().process_frame
	v.set_anchors_preset(Control.PRESET_TOP_LEFT)
	v.size = v.get_combined_minimum_size()
	v.position = ((v.get_parent() as Control).size - v.size) / 2.0


func _textos_ajustes() -> void:
	boton_apariencia.texto = "Apariencia: " + Temas.activo.get("nombre", "")
	boton_sonido.texto = "Sonido: " + ("sí" if progreso.ajustes["sonido"] else "no")
	boton_vibracion.texto = "Vibración: " + ("sí" if progreso.ajustes["vibracion"] else "no")
	for par in ACCESIBILIDAD:
		var b: Control = botones_accesibilidad[par[0]]
		b.texto = "%s: %s" % [par[1], "sí" if progreso.ajustes.get(par[0], false) else "no"]
		b.update_minimum_size()
		b.queue_redraw()
	for b in [boton_sonido, boton_vibracion, boton_apariencia]:
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
	_centrar(ventana_ajustes)


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
	pastilla_cuerda.color_icono = ESTRELLA
	pastilla_cuerda.fuente = fuente_negrita
	hud.add_child(pastilla_cuerda)
	var hueco := Control.new()
	hueco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.add_child(hueco)
	pastilla_estrellas = Pastilla.new()
	pastilla_estrellas.icono = "estrella"
	pastilla_estrellas.color_icono = ESTRELLA
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
	etiqueta_nombre = _etiqueta(56, TEXTO, true)
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
	aviso_cerrado = _etiqueta(28, TEXTO)
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
	_construir_apariencia()


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
			Iconos.dibujar(icono, tipo, Rect2(c - Vector2(20, 20), Vector2(40, 40)), Color(0, 0, 0, 0),
				Temas.tinta_sobre(MARFIL) if activa else TEXTO_CLARO))
		celda.add_child(icono)
		var l := _etiqueta(22, TEXTO if activa else TEXTO_CLARO)
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
	t.text = Temas.texto("sinTitulo", "Sin cuerda")
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
	boton_apariencia = _boton("Apariencia", false, 32)
	boton_apariencia.pulsado.connect(_abrir_apariencia)
	caja.add_child(boton_apariencia)
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
	for h in [boton_sonido, boton_vibracion]:
		caja.add_child(h)
	var titulo_acc := _etiqueta(34, TINTA, true)
	titulo_acc.text = "Accesibilidad"
	caja.add_child(titulo_acc)
	for par in ACCESIBILIDAD:
		var clave: String = par[0]
		var b := _boton(par[1], false, 30)
		b.pulsado.connect(func():
			progreso.ajustar(clave, not progreso.ajustes.get(clave, false))
			_textos_ajustes())
		botones_accesibilidad[clave] = b
		caja.add_child(b)
	for h in [b_resumen, resumen_prueba, cerrar]:
		caja.add_child(h)


## Ajustes › Apariencia: los 11 temas en dos columnas. Dominó Pop es gratis; los demás son del
## Dingclub. Como el Club aún no existe, se pueden usar gratis, y el aviso lo dice tal cual: sin
## cuentas atrás ni precios de algo que no se puede comprar.
func _construir_apariencia() -> void:
	ventana_apariencia = _ventana()
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 14)
	ventana_apariencia.add_child(caja)
	var t := _etiqueta(48, TINTA, true)
	t.text = "Apariencia"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(t)
	var nota := _etiqueta(24, TINTA_SUAVE)
	nota.text = "Solo cambia el aspecto: tus niveles y estrellas se quedan."
	nota.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nota.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nota.custom_minimum_size = Vector2(560, 0)
	caja.add_child(nota)
	var rejilla := GridContainer.new()
	rejilla.columns = 2
	rejilla.add_theme_constant_override("h_separation", 12)
	rejilla.add_theme_constant_override("v_separation", 8)
	caja.add_child(rejilla)
	for datos in Temas.todos():
		rejilla.add_child(_muestra_tema(Temas.de(datos["id"])))
	if Temas.activo.get("club", false):
		aviso_prueba = _aviso_prueba()
		caja.add_child(aviso_prueba)
	var cerrar := _boton("Volver al mapa", true, 34)
	cerrar.pulsado.connect(_cerrar_ventanas)
	caja.add_child(cerrar)


## Botón de un tema: una miniatura con su pantalla, su tablero y tres fichas, el nombre y si es
## gratis o del Club. El tema en uso lleva un anillo y una marca.
func _muestra_tema(tema: Dictionary) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(284, 88)
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	var id: String = tema["id"]
	var elegido := id == Temas.id_activo()
	var letra_titulos: Font = Fuentes.de(tema.get("letras", {}))["titulos"]
	c.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and not e.pressed:
			_elegir_tema(id))
	c.draw.connect(func():
		var ui: Dictionary = tema["ui"]
		var tab: Dictionary = tema["tablero"]
		var caja := StyleBoxFlat.new()
		caja.bg_color = Color(TINTA, 0.06)
		caja.set_corner_radius_all(14)
		caja.border_color = TINTA if elegido else Color(TINTA, 0.18)
		caja.set_border_width_all(4 if elegido else 2)
		c.draw_style_box(caja, Rect2(Vector2.ZERO, c.size))
		# Miniatura: pantalla, tablero y tres fichas de pie (la del medio, cayendo)
		var mini := Rect2(Vector2(9, 9), Vector2(70, 70))
		var fondo := StyleBoxFlat.new()
		fondo.bg_color = ui["pantalla"]
		fondo.set_corner_radius_all(10)
		c.draw_style_box(fondo, mini)
		var tablero := StyleBoxFlat.new()
		tablero.bg_color = tab["tablero"]
		tablero.set_corner_radius_all(6)
		c.draw_style_box(tablero, mini.grow(-9))
		for k in 3:
			var ficha := Rect2(mini.position + Vector2(19 + k * 12, 22), Vector2(8, 22))
			var cuerpo := StyleBoxFlat.new()
			cuerpo.bg_color = tab["cae"] if k == 1 else tab["ficha"]
			cuerpo.set_corner_radius_all(3)
			if tab["borde_ficha"].a > 0.3:
				cuerpo.border_color = tab["borde_ficha"]
				cuerpo.set_border_width_all(1)
			c.draw_style_box(cuerpo, ficha)
		c.draw_circle(mini.position + Vector2(15, 54), 5, tab["inicio"])
		c.draw_circle(mini.position + Vector2(55, 54), 5, tab["campana"])
		var f: Font = letra_titulos         # el nombre, con la letra de títulos de ese tema
		c.draw_string(f, Vector2(90, 40), tema["nombre"], HORIZONTAL_ALIGNMENT_LEFT, c.size.x - 94, 23, TINTA)
		var etiqueta := "Gratis · por defecto" if not tema["club"] else "Dingclub"
		c.draw_string(fuente_texto, Vector2(90, 70), etiqueta, HORIZONTAL_ALIGNMENT_LEFT, c.size.x - 94 - (30 if elegido else 0), 19, TINTA_SUAVE)
		if elegido:
			var m := Vector2(c.size.x - 20, c.size.y - 20)
			c.draw_circle(m, 12, TINTA)
			c.draw_polyline(PackedVector2Array([m + Vector2(-6, 0), m + Vector2(-2, 5), m + Vector2(6, -5)]), MARFIL, 3.0, true))
	return c


## Aviso de la prueba: el tema es del Club, que aún no está abierto, así que se puede usar gratis.
func _aviso_prueba() -> Control:
	var panel := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color = Color(TINTA, 0.06)
	s.set_corner_radius_all(14)
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", s)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 10)
	panel.add_child(caja)
	var titulo := _etiqueta(30, TINTA, true)
	titulo.text = "Probando «%s»" % Temas.activo.get("nombre", "")
	caja.add_child(titulo)
	var texto := _etiqueta(23, TINTA_SUAVE)
	texto.text = "Este tema será del Dingclub, que todavía no está abierto. Mientras tanto, úsalo gratis todo lo que quieras."
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.custom_minimum_size = Vector2(540, 0)
	caja.add_child(texto)
	var volver := _boton("Volver a Dominó Pop", false, 28)
	volver.pulsado.connect(func(): _elegir_tema(Temas.POR_DEFECTO))
	caja.add_child(volver)
	return panel


func _ventana() -> PanelContainer:
	var v := PanelContainer.new()
	v.set_meta("ventana", true)
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
	b.fuente = fuente_botones
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
	if args.has("ajustes"):
		progreso.ajustes["alto_contraste"] = true
		_abrir_ajustes()
		await get_tree().create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(prefijo + "_3_ajustes.png")
	if args.has("apariencia"):
		_cerrar_ventanas()
		_abrir_apariencia()
		await get_tree().create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(prefijo + "_4_apariencia.png")
	print("DEMO mapa: actual ", _actual + 1, " cuerdas ", progreso.cuerdas(ahora()))
	if args.has("entrar"):
		_jugar(_actual)          # cambia a la partida; allí se hace la captura y se cierra
		return
	for r in ["user://demo_progreso.json", "user://demo_progreso.anterior.json", "user://demo_registro.jsonl"]:
		if FileAccess.file_exists(r):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(r))
	get_tree().quit()
