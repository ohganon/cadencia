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
const Animar = preload("res://escenas/comun/animar.gd")
const Fuentes = preload("res://escenas/comun/fuentes.gd")
const Pestana = preload("res://escenas/comun/pestana.gd")
const JuegoResponsable = preload("res://nucleo/juego_responsable.gd")
const Piezas = preload("res://nucleo/piezas.gd")
const Creditos = preload("res://nucleo/creditos.gd")
const Registro = preload("res://nucleo/registro.gd")
const Cuerda = preload("res://nucleo/cuerda.gd")
const BotonPop = preload("res://escenas/comun/boton_pop.gd")
const Pastilla = preload("res://escenas/comun/pastilla.gd")
const FilaAjuste = preload("res://escenas/comun/fila_ajuste.gd")
const Iconos = preload("res://escenas/comun/iconos.gd")
const Camino = preload("res://escenas/mapa/camino.gd")
const Fondo = preload("res://escenas/comun/fondo.gd")
const Caja = preload("res://escenas/comun/caja.gd")

const ESCENA_PARTIDA := "res://escenas/partida/partida.tscn"
const ESCENA_TALLER := "res://escenas/taller/taller.tscn"
# Colores del tema activo (nucleo/temas.gd)
var AZUL: Color = Temas.ui("pantalla")
var TINTA: Color = Temas.ui("ventana_t")
var TINTA_SUAVE: Color = Temas.ui("ventana_s")
var TEXTO_CLARO: Color = Temas.ui("suave")
var MARFIL: Color = Temas.ui("ventana")
var VERDE: Color = Temas.ui("prim")
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
var ventana_apariencia: Control       # pantalla completa (maqueta › Apariencia)
var ventana_responsable: PanelContainer
var ventana_piezas: PanelContainer
var ventana_creditos: PanelContainer
var texto_tiempo: Label
var boton_descanso: Control
var boton_limite: Control
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
var _velo_abierto := false          # el velo ya está a la vista (al pasar de una ventana a otra no se vuelve a fundir)


func _ready() -> void:
	for ruta in ["res://datos/barrio_1.json", "res://datos/barrio_2.json", "res://datos/barrio_3.json", "res://datos/barrio_4.json", "res://datos/barrio_5.json", "res://datos/barrio_6.json", "res://datos/barrio_7.json", "res://datos/barrio_8.json", "res://datos/barrio_9.json"]:
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
	elif estado != null and estado.pendiente.get("modo") == "ajustes":
		estado.pendiente = {}
		_abrir_ajustes()
	Animar.fundido_entrada(self)
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
	boton_jugar.texto = Temas.texto_jugar(int(niveles[_actual]["id"]))
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
	_velo_abierto = false
	ventana_cuerda.visible = false
	ventana_ajustes.visible = false
	ventana_apariencia.visible = false
	ventana_responsable.visible = false
	ventana_piezas.visible = false
	ventana_creditos.visible = false


func _abrir_apariencia() -> void:
	ventana_ajustes.visible = false
	velo.visible = false
	_velo_abierto = false
	ventana_apariencia.visible = true
	Animar.fundido_entrada(ventana_apariencia)


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
	if not _velo_abierto:
		_velo_abierto = true
		Animar.aparecer(velo)
	Animar.entrar(v)


func _textos_ajustes() -> void:
	boton_apariencia.valor = Temas.activo.get("nombre", "")
	boton_sonido.encendido = progreso.ajustes["sonido"]
	boton_vibracion.encendido = progreso.ajustes["vibracion"]
	for par in ACCESIBILIDAD:
		botones_accesibilidad[par[0]].encendido = progreso.ajustes.get(par[0], false)


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
	etiqueta_barrio.text = Temas.texto_barrio(int(barrios[_visible]["barrio"])).to_upper()
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
	var radios := []
	for k in rango.size():
		radios.append(60.0 if rango[k] == _actual and abierto else 48.0)
	camino.radios = radios
	camino.recorrido = clampi(_actual - rango[0], 0, rango.size()) if abierto else 0
	camino.queue_redraw()
	for k in rango.size():
		var i: int = rango[k]
		var id := int(niveles[i]["id"])
		var hecho: bool = progreso.de(id) > 0
		var es_actual: bool = i == _actual and abierto
		var lado := 120.0 if es_actual else 96.0
		var b := _boton(str(id), false, 46 if es_actual else 40)
		# Forma, borde, sombra y anillo de cada nodo: los del tema (maqueta › .nodo.h / .a / .c)
		b.estilo_caja = "nodo_a" if es_actual else ("nodo_h" if hecho else "nodo_c")
		var hueco: Vector2 = Caja.hueco_sombra(Temas.caja(b.estilo_caja))
		b.custom_minimum_size = Vector2(lado, lado) + hueco
		b.size = b.custom_minimum_size
		b.position = centros[k] - Vector2(lado, lado) / 2
		if es_actual:
			b.ready.connect(func(): Animar.respirar.call_deferred(b))
		var e: int = progreso.de(id)
		if es_actual:
			b.nombre_accesible = "Nivel %d, el que toca" % id + (", %d de 3 estrellas" % e if hecho else "")
		elif hecho:
			b.nombre_accesible = "Nivel %d, %d de 3 estrellas" % [id, e]
		else:
			b.nombre_accesible = "Nivel %d, cerrado" % id
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
	# Fondo del tema: color o degradado y, en algunos, su textura (escenas/comun/fondo.gd)
	add_child(Fondo.new())
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
	pastilla_cuerda.nombre_accesible = "Cuerda"
	pastilla_cuerda.color_icono = ESTRELLA
	pastilla_cuerda.fuente = fuente_negrita
	hud.add_child(pastilla_cuerda)
	var hueco := Control.new()
	hueco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.add_child(hueco)
	pastilla_estrellas = Pastilla.new()
	pastilla_estrellas.icono = "estrella"
	pastilla_estrellas.nombre_accesible = "Estrellas"
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
	etiqueta_barrio = _etiqueta(22, TEXTO_CLARO)
	etiqueta_barrio.add_theme_font_override("font", _espaciada(fuente_negrita, 0.08 * 22))
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
	_construir_responsable()
	_construir_piezas()
	_construir_creditos()


## Barra de abajo (DESIGN.md: la pestaña activa se marca con una pastilla marfil y no se eleva).
func _barra_abajo() -> Control:
	var barra := HBoxContainer.new()
	barra.add_theme_constant_override("separation", 0)
	var pestanas := [["Inicio", "ficha", Callable()], ["Reto", "campana", func(): _ir_partida({"modo": "diario"})],
		["Taller", "muro", func(): get_tree().change_scene_to_file(ESCENA_TALLER)], ["Ajustes", "llave", _abrir_ajustes]]
	for k in pestanas.size():
		var p: Array = pestanas[k]
		var activa := k == 0
		var celda := Pestana.new()
		celda.nombre = p[0]
		celda.activa = activa
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
			celda.pulsado.connect(accion)
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
	caja.add_theme_constant_override("separation", 12)
	ventana_ajustes.add_child(caja)
	var t := _etiqueta(52, TINTA, true)
	t.text = "Ajustes"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(t)
	# Lo que abre otra ventana: una tarjeta con filas que llevan flecha
	boton_apariencia = _fila("Apariencia")
	boton_apariencia.pulsado.connect(_abrir_apariencia)
	var f_responsable := _fila("Juego responsable")
	f_responsable.pulsado.connect(_abrir_responsable)
	var f_piezas := _fila("Guía de piezas")
	f_piezas.pulsado.connect(_abrir_piezas)
	var f_creditos := _fila("Créditos y avisos legales")
	f_creditos.pulsado.connect(_abrir_creditos)
	caja.add_child(FilaAjuste.grupo([boton_apariencia, f_responsable, f_piezas, f_creditos]))
	# Interruptores: sonido y vibración; y la accesibilidad, en su propio grupo
	boton_sonido = _fila("Sonido", true)
	boton_sonido.pulsado.connect(func():
		progreso.ajustar("sonido", not progreso.ajustes["sonido"])
		_textos_ajustes())
	boton_vibracion = _fila("Vibración", true)
	boton_vibracion.pulsado.connect(func():
		progreso.ajustar("vibracion", not progreso.ajustes["vibracion"])
		_textos_ajustes())
	caja.add_child(_subtitulo("Sonido y vibración"))
	caja.add_child(FilaAjuste.grupo([boton_sonido, boton_vibracion]))
	caja.add_child(_subtitulo("Accesibilidad"))
	var filas_acc := []
	for par in ACCESIBILIDAD:
		var clave: String = par[0]
		var f := _fila(par[1], true)
		f.pulsado.connect(func():
			progreso.ajustar(clave, not progreso.ajustes.get(clave, false))
			if clave in ["alto_contraste", "texto_grande"]:
				# Cambian toda la interfaz: se vuelve a construir el mapa con la ventana abierta
				f.encendido = progreso.ajustes.get(clave, false)
				await get_tree().create_timer(0.0 if Temas.reducir_movimiento else 0.2).timeout
				Temas.accesibilidad(progreso.ajustes)
				var estado := get_node_or_null("/root/Estado")
				if estado != null:
					estado.pendiente = {"modo": "ajustes"}
				get_tree().reload_current_scene()
				return
			Temas.reducir_movimiento = progreso.ajustes.get("reducir_movimiento", false)
			_textos_ajustes())
		botones_accesibilidad[clave] = f
		filas_acc.append(f)
	caja.add_child(FilaAjuste.grupo(filas_acc))
	resumen_prueba = _etiqueta(24, TINTA_SUAVE)
	resumen_prueba.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resumen_prueba.visible = false
	caja.add_child(resumen_prueba)
	# Abajo: el resumen para quien dirige la prueba y volver, uno al lado del otro
	var fila_abajo := HBoxContainer.new()
	fila_abajo.add_theme_constant_override("separation", 12)
	var b_resumen := _boton("Resumen", false, 32)
	b_resumen.nombre_accesible = "Resumen de la prueba"
	b_resumen.pulsado.connect(_al_resumen)
	var cerrar := _boton("Volver al mapa", true, 34)
	cerrar.pulsado.connect(_cerrar_ventanas)
	b_resumen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cerrar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cerrar.size_flags_stretch_ratio = 1.6
	fila_abajo.add_child(b_resumen)
	fila_abajo.add_child(cerrar)
	caja.add_child(fila_abajo)


## Título pequeño de un grupo de filas, con más aire encima que debajo.
func _subtitulo(texto: String) -> Control:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_top", 6)
	m.add_theme_constant_override("margin_left", 6)
	var l := _etiqueta(28, TINTA_SUAVE, true)
	l.text = texto
	m.add_child(l)
	return m


func _fila(texto: String, interruptor := false) -> Control:
	var f = FilaAjuste.new()
	f.texto = texto
	f.interruptor = interruptor
	f.fuente = fuente_negrita
	f.fuente_valor = fuente_texto
	f.tam_fuente = 29
	return f


# ---------------------------------------------------------------- juego responsable

## Ajustes › Juego responsable (P-09, DFA art. 17): tiempo jugado, aviso de descanso y límite diario,
## todo elegido por el jugador y guardado solo en el teléfono. Dingfall no tiene rachas ni
## notificaciones; el panel lo dice en vez de enseñar interruptores vacíos.
func _construir_responsable() -> void:
	ventana_responsable = _ventana()
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 16)
	ventana_responsable.add_child(caja)
	var t := _etiqueta(48, TINTA, true)
	t.text = "Juego responsable"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(t)
	texto_tiempo = _etiqueta(28, TINTA)
	texto_tiempo.add_theme_font_override("font", fuente_negrita)
	texto_tiempo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(texto_tiempo)
	boton_descanso = _fila("Aviso de descanso")
	boton_descanso.pulsado.connect(func():
		var e := get_node_or_null("/root/Estado")
		if e != null:
			e.responsable.descanso = JuegoResponsable.siguiente(JuegoResponsable.DESCANSOS, e.responsable.descanso)
			e.avisos_descanso = int(e.sesion / (e.responsable.descanso * 60)) if e.responsable.descanso > 0 else 0
			e.responsable.guardar()
		_textos_responsable())
	boton_limite = _fila("Límite diario")
	boton_limite.pulsado.connect(func():
		var e := get_node_or_null("/root/Estado")
		if e != null:
			e.responsable.limite = JuegoResponsable.siguiente(JuegoResponsable.LIMITES, e.responsable.limite)
			e.limite_avisado = ""
			e.responsable.guardar()
		_textos_responsable())
	caja.add_child(FilaAjuste.grupo([boton_descanso, boton_limite]))
	var nota := _etiqueta(24, TINTA_SUAVE)
	nota.text = ("Los avisos salen al empezar un nivel, nunca a mitad, y siempre puedes seguir.\n\n"
		+ "Dingfall no tiene rachas que se pierdan ni notificaciones. Si algún día las tiene, se podrán apagar aquí.\n\n"
		+ "Gasto: 0 €. De momento no hay nada que comprar.\n\n"
		+ "Todo esto se guarda solo en este teléfono.")
	nota.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nota.custom_minimum_size = Vector2(560, 0)
	caja.add_child(nota)
	var volver := _boton("Volver a Ajustes", true, 34)
	volver.pulsado.connect(func():
		ventana_responsable.visible = false
		_abrir_ajustes())
	caja.add_child(volver)


## Ajustes › Guía de piezas: cada pieza con su dibujo, su nombre y qué hace, en una lista que se
## desliza con el dedo.
func _construir_piezas() -> void:
	ventana_piezas = _ventana()
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 14)
	ventana_piezas.add_child(caja)
	var t := _etiqueta(48, TINTA, true)
	t.text = "Guía de piezas"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(t)
	var desliza := ScrollContainer.new()
	desliza.custom_minimum_size = Vector2(580, 820)
	desliza.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	caja.add_child(desliza)
	var lista := VBoxContainer.new()
	lista.add_theme_constant_override("separation", 16)
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desliza.add_child(lista)
	for p in Piezas.PIEZAS:
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 14)
		var icono := Control.new()
		icono.custom_minimum_size = Vector2(76, 76)
		var nombre_icono: String = p["icono"]
		icono.draw.connect(func(): Iconos.dibujar(icono, nombre_icono, Rect2(Vector2(4, 4), Vector2(68, 68)), Color(0, 0, 0, 0), TINTA))
		fila.add_child(icono)
		var textos := VBoxContainer.new()
		textos.add_theme_constant_override("separation", 2)
		var nombre := _etiqueta(30, TINTA, true)
		nombre.text = p["nombre"]
		var texto := _etiqueta(23, TINTA_SUAVE)
		texto.text = p["texto"]
		texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		texto.custom_minimum_size = Vector2(470, 0)
		textos.add_child(nombre)
		textos.add_child(texto)
		fila.add_child(textos)
		lista.add_child(fila)
	var volver := _boton("Volver a Ajustes", true, 34)
	volver.pulsado.connect(func():
		ventana_piezas.visible = false
		_abrir_ajustes())
	caja.add_child(volver)


## Ajustes › Créditos y avisos legales: quién lo hace, privacidad y las licencias de Godot y de las
## fuentes (nucleo/creditos.gd), en un texto que se desliza.
func _construir_creditos() -> void:
	ventana_creditos = _ventana()
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 14)
	ventana_creditos.add_child(caja)
	var t := _etiqueta(44, TINTA, true)
	t.text = "Créditos y avisos legales"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(t)
	var desliza := ScrollContainer.new()
	desliza.custom_minimum_size = Vector2(580, 840)
	desliza.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	caja.add_child(desliza)
	var texto := RichTextLabel.new()
	texto.bbcode_enabled = true
	texto.fit_content = true
	texto.scroll_active = false
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.custom_minimum_size = Vector2(560, 0)
	texto.add_theme_color_override("default_color", TINTA_SUAVE)
	texto.add_theme_font_override("normal_font", fuente_texto)
	texto.add_theme_font_override("bold_font", fuente_titulos)
	texto.add_theme_font_size_override("normal_font_size", Temas.tam(21))
	texto.add_theme_font_size_override("bold_font_size", Temas.tam(26))
	texto.text = Creditos.texto()
	desliza.add_child(texto)
	var volver := _boton("Volver a Ajustes", true, 34)
	volver.pulsado.connect(func():
		ventana_creditos.visible = false
		_abrir_ajustes())
	caja.add_child(volver)


func _abrir_creditos() -> void:
	ventana_ajustes.visible = false
	velo.visible = true
	ventana_creditos.visible = true
	_centrar(ventana_creditos)


func _abrir_piezas() -> void:
	ventana_ajustes.visible = false
	velo.visible = true
	ventana_piezas.visible = true
	_centrar(ventana_piezas)


func _abrir_responsable() -> void:
	_textos_responsable()
	ventana_ajustes.visible = false
	velo.visible = true
	ventana_responsable.visible = true
	_centrar(ventana_responsable)


func _textos_responsable() -> void:
	var e := get_node_or_null("/root/Estado")
	if e == null or e.responsable == null:
		texto_tiempo.text = ""
		return
	texto_tiempo.text = "Hoy: %s · Últimos 7 días: %s" % [JuegoResponsable.texto_tiempo(e.hoy()), JuegoResponsable.texto_tiempo(e.semana())]
	var d: int = e.responsable.descanso
	boton_descanso.valor = "cada %d min" % d if d > 0 else "no"
	var l: int = e.responsable.limite
	boton_limite.valor = JuegoResponsable.texto_tiempo(l * 60) if l > 0 else "no"


## Ajustes › Apariencia, como en la maqueta (docs/fase6/temas/index.html): una pantalla entera con
## volver, el título, la nota y los 11 temas en dos columnas. Cada tema es una tarjeta con una franja de
## muestra (su pantalla, «Aa» con su letra de títulos, una ficha y una barra de su color principal), su
## nombre y la etiqueta «Club». El elegido lleva un anillo del color de acento y una marca en la
## esquina. Dominó Pop es gratis; los demás son del Dingclub. Como el Club aún no existe, se pueden usar
## gratis, y el aviso lo dice tal cual: sin cuentas atrás ni precios de algo que no se puede comprar.
func _construir_apariencia() -> void:
	ventana_apariencia = Control.new()
	ventana_apariencia.set_anchors_preset(Control.PRESET_FULL_RECT)
	ventana_apariencia.mouse_filter = Control.MOUSE_FILTER_STOP
	ventana_apariencia.visible = false
	add_child(ventana_apariencia)
	ventana_apariencia.add_child(Fondo.new())
	var margen := MarginContainer.new()
	margen.set_anchors_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "right"]:
		margen.add_theme_constant_override("margin_" + lado, 28)
	margen.add_theme_constant_override("margin_top", 32)
	margen.add_theme_constant_override("margin_bottom", 24)
	ventana_apariencia.add_child(margen)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 14)
	margen.add_child(columna)
	# Cabecera: volver a Ajustes, el título centrado y un contrapeso del mismo ancho
	var cabeza := HBoxContainer.new()
	columna.add_child(cabeza)
	var volver := _boton("", false)
	volver.icono = "volver"
	volver.redondo = true
	volver.nombre_accesible = "Volver a Ajustes"
	volver.custom_minimum_size = Vector2(84, 84)
	volver.pulsado.connect(func():
		ventana_apariencia.visible = false
		_abrir_ajustes())
	cabeza.add_child(volver)
	var t := _etiqueta(44, TEXTO, true)
	t.text = Temas.texto("apTitulo", "Apariencia")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cabeza.add_child(t)
	var contrapeso := Control.new()
	contrapeso.custom_minimum_size = Vector2(84, 0)
	cabeza.add_child(contrapeso)
	var nota := _etiqueta(25, TEXTO_CLARO)
	nota.text = "Dominó Pop es gratis. Los demás temas serán del Club; mientras tanto, tócalos para usarlos. Tus niveles y estrellas no cambian."
	nota.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	columna.add_child(nota)
	var desliza := ScrollContainer.new()
	desliza.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desliza.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	desliza.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	columna.add_child(desliza)
	var rejilla := GridContainer.new()
	rejilla.columns = 2
	rejilla.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rejilla.add_theme_constant_override("h_separation", 18)
	rejilla.add_theme_constant_override("v_separation", 18)
	var aire := MarginContainer.new()       # sitio para el anillo y la marca del elegido
	aire.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for lado in ["left", "right", "top", "bottom"]:
		aire.add_theme_constant_override("margin_" + lado, 14)
	aire.add_child(rejilla)
	desliza.add_child(aire)
	for datos in Temas.todos():
		rejilla.add_child(_muestra_tema(Temas.de(datos["id"])))
	if Temas.activo.get("club", false):
		aviso_prueba = _aviso_prueba()
		columna.add_child(aviso_prueba)


## Tarjeta de un tema (maqueta › .ap): franja de muestra con su pantalla, «Aa», una ficha y una barra
## del color principal; debajo, el nombre. «Club» en la esquina de los del Club.
func _muestra_tema(tema: Dictionary) -> Control:
	var e := Temas.ESCALA
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, 176)
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	c.focus_mode = Control.FOCUS_ACCESSIBILITY
	var id: String = tema["id"]
	var elegido := id == Temas.id_activo()
	var letras: Dictionary = Fuentes.de(tema.get("letras", {}))
	var letra_titulos: Font = letras["titulos"]
	var muestra_pantalla: Array = tema.get("estilo", {}).get("pantalla", {}).get("degradado", [])
	c.set_meta("pulsada", false)
	c.set_meta("encima", false)
	c.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			c.set_meta("pulsada", ev.pressed)
			c.queue_redraw()
			if not ev.pressed and Rect2(Vector2.ZERO, c.size).has_point(ev.position):
				_elegir_tema(id))
	c.mouse_entered.connect(func():
		c.set_meta("encima", BotonPop.con_raton())
		c.queue_redraw())
	c.mouse_exited.connect(func():
		c.set_meta("encima", false)
		c.set_meta("pulsada", false)
		c.queue_redraw())
	c.draw.connect(func():
		var ui: Dictionary = tema["ui"]
		var tab: Dictionary = tema["tablero"]
		var tarjeta := Temas.caja("panel")
		tarjeta["radio"] = maxf(tarjeta["radio"] - 2.0 * e, 0.0) if tarjeta["radio"] >= 0.0 else tarjeta["radio"]
		var rect := Rect2(Vector2(0, 2.0 * e if c.get_meta("pulsada") else 0.0), c.size)
		if elegido:
			# Anillo de 2 px del color de acento (box-shadow: 0 0 0 2px var(--acento))
			var aro := StyleBoxFlat.new()
			aro.draw_center = false
			aro.border_color = Temas.ui("acento")
			aro.set_border_width_all(int(round(2.0 * e)))
			aro.set_corner_radius_all(int(Caja.radio_de(tarjeta, rect) + 2.0 * e))
			aro.anti_aliasing = true
			c.draw_style_box(aro, rect.grow(2.0 * e))
		Caja.dibujar(c, rect, tarjeta, 1.0)
		if c.get_meta("encima"):
			Caja.draw_redondeado(c, rect, Color(1, 1, 1, 0.05), Caja.radio_de(tarjeta, rect))
		# Franja de muestra
		var vista := Rect2(rect.position + Vector2(5, 5) * e, Vector2(rect.size.x - 10 * e, 38 * e))
		var radio_vista := maxf(Caja.radio_de(tarjeta, rect) - 3.0 * e, 0.0)
		var pantalla: Color = Color(muestra_pantalla[muestra_pantalla.size() / 2][1]) if not muestra_pantalla.is_empty() else ui["pantalla"]
		Caja.draw_redondeado(c, vista, pantalla, radio_vista)
		var aa_tam := int(1.05 * 16 * e)
		var base := vista.get_center().y + (letra_titulos.get_ascent(aa_tam) - letra_titulos.get_descent(aa_tam)) / 2
		c.draw_string(letra_titulos, Vector2(vista.position.x + 8 * e, base), "Aa", HORIZONTAL_ALIGNMENT_LEFT, -1, aa_tam, ui["texto"])
		# La barra del color principal y, a su izquierda, una ficha de pie
		var barra := Rect2(Vector2(vista.end.x - 8 * e - 14 * e, vista.get_center().y - 3 * e), Vector2(14, 6) * e)
		Caja.draw_redondeado(c, barra, ui["prim"], 3 * e)
		var ficha := Rect2(Vector2(barra.position.x - 7 * e - 9 * e, vista.get_center().y - 8.5 * e), Vector2(9, 17) * e)
		Caja.draw_redondeado(c, ficha, tab["ficha"], 2 * e)
		if tab["borde_ficha"].a > 0.0:
			var borde := StyleBoxFlat.new()
			borde.draw_center = false
			borde.border_color = tab["borde_ficha"]
			borde.set_border_width_all(maxi(1, int(e)))
			borde.set_corner_radius_all(int(2 * e))
			c.draw_style_box(borde, ficha.grow(e))
		for py in [ficha.position.y + 4 * e, ficha.end.y - 4 * e]:
			c.draw_circle(Vector2(ficha.get_center().x, py), 1.1 * e, tab["pip"])
		# Nombre (y «Gratis · por defecto» en Dominó Pop)
		var tinta_tarjeta: Color = tarjeta["texto"] if tarjeta["texto"].a > 0.0 else TEXTO
		var y := vista.end.y + 5 * e + fuente_negrita.get_ascent(Temas.tam(24))
		c.draw_string(fuente_negrita, Vector2(rect.position.x + 8 * e, y), tema["nombre"], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 16 * e, Temas.tam(24), tinta_tarjeta)
		if not tema["club"]:
			c.draw_string(fuente_texto, Vector2(rect.position.x + 8 * e, y + 28), "Gratis · por defecto", HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 16 * e, Temas.tam(21), Color(tinta_tarjeta, 0.75))
		else:
			# Etiqueta «Club»: abajo a la derecha, blanca sobre negro translúcido
			var tam_club := 15
			var ancho := fuente_negrita.get_string_size("Club", HORIZONTAL_ALIGNMENT_LEFT, -1, tam_club).x
			var tam_etiqueta := Vector2(ancho + 10 * e, tam_club + 6 * e)
			var etiqueta := Rect2(rect.end - Vector2(7, 8) * e - tam_etiqueta, tam_etiqueta)
			Caja.draw_redondeado(c, etiqueta, Color(0, 0, 0, 0.62), 4 * e)
			c.draw_string(fuente_negrita, Vector2(etiqueta.position.x + 5 * e, etiqueta.get_center().y + (fuente_negrita.get_ascent(tam_club) - fuente_negrita.get_descent(tam_club)) / 2), "Club", HORIZONTAL_ALIGNMENT_LEFT, -1, tam_club, Color.WHITE)
		if elegido:
			# Marca en la esquina de arriba a la derecha (18 px, del color de acento, con la «v» blanca)
			var m := Vector2(rect.end.x - 3 * e, rect.position.y + 3 * e)
			c.draw_circle(m, 9 * e, Temas.ui("acento"))
			c.draw_polyline(PackedVector2Array([m + Vector2(-3.5, 0.5) * e, m + Vector2(-1, 3) * e, m + Vector2(3.5, -2.5) * e]), Color.WHITE, 1.6 * e, true))
	return c


## Aviso de la prueba (maqueta › .prueba): el tema es del Club, que aún no está abierto, así que se puede
## usar gratis. Una hoja con el estilo de las ventanas, abajo.
func _aviso_prueba() -> Control:
	var panel := PanelContainer.new()
	panel.set_meta("ventana", true)
	panel.add_theme_stylebox_override("panel", Temas.stylebox("ventana", Vector4(28, 24, 28, 24)))
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 10)
	panel.add_child(caja)
	var titulo := _etiqueta(32, TINTA, true)
	titulo.text = "Probando «%s»" % Temas.activo.get("nombre", "")
	caja.add_child(titulo)
	var texto := _etiqueta(23, TINTA_SUAVE)
	texto.text = "Este tema será del Dingclub, que todavía no está abierto. Mientras tanto, úsalo gratis todo lo que quieras."
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.custom_minimum_size = Vector2(560, 0)
	caja.add_child(texto)
	var volver := _boton("Volver a Dominó Pop", false, 28)
	volver.pulsado.connect(func(): _elegir_tema(Temas.POR_DEFECTO))
	caja.add_child(volver)
	return panel


func _ventana() -> PanelContainer:
	var v := PanelContainer.new()
	v.set_meta("ventana", true)
	# La ventana de la maqueta: fondo, borde, radio y sombra del tema
	v.add_theme_stylebox_override("panel", Temas.stylebox("ventana", Vector4(32, 40, 32, 32)))
	v.custom_minimum_size = Vector2(640, 0)
	v.visible = false
	add_child(v)
	return v


func _etiqueta(tam: int, color: Color, titular := false) -> Label:
	var l := Label.new()
	if titular:
		l.add_theme_font_override("font", fuente_titulos)
		l.uppercase = Temas.mayus("titulos")        # Mesa y Cine negro: títulos en mayúsculas
	l.add_theme_font_size_override("font_size", Temas.tam(tam))
	l.add_theme_color_override("font_color", color)
	return l


## La misma fuente con más espacio entre letras (letter-spacing de la maqueta).
func _espaciada(f: Font, px: float) -> Font:
	var v := FontVariation.new()
	v.base_font = f
	v.spacing_glyph = int(round(px))
	return v


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
	if args.has("creditos"):
		_cerrar_ventanas()
		_abrir_creditos()
		await get_tree().create_timer(0.4).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(prefijo + "_7_creditos.png")
	if args.has("piezas"):
		_cerrar_ventanas()
		_abrir_piezas()
		await get_tree().create_timer(0.4).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(prefijo + "_6_piezas.png")
	if args.has("responsable"):
		_cerrar_ventanas()
		_abrir_responsable()
		await get_tree().create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(prefijo + "_5_responsable.png")
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
