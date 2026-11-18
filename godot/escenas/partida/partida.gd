## Pantalla de partida de la entrega 1: los 10 niveles, dibujar, tumbar y ver el resultado.
##
## Sigue la maqueta de Dominó Pop (docs/fase6/tablero/index.html) y DESIGN.md:
## - HUD: volver (redondo), «Nivel N» centrado y la pastilla con las fichas que quedan;
## - tarjeta del objetivo marfil con la campana y la palabra clave en negrita;
## - tablero de hielo con borde de tinta;
## - mandos: deshacer (mantener = borrar todo), «¡A tumbar!» y la bombilla de la pista;
## - ventana de resultado con título, estrellas dibujadas (la central más grande), el dato que
##   importa, el premio y Repetir / Siguiente.
## La interfaz se construye en código para que se pueda revisar como texto. Fuentes: las del tema
## activo (escenas/comun/fuentes.gd; todas SIL OFL, con sus licencias en res://fuentes/).
##
## Modo demostración, para capturas automáticas (ver godot/README.md):
##   Godot_v4.7.2-stable_win64_console.exe --path godot --resolution 540x960 -- --demo=7 --captura=C:/ruta/prefijo [--incompleto | --recto]
## Usa un archivo de progreso aparte y lo borra al terminar: nunca toca el del jugador.
extends Control

const Partida = preload("res://nucleo/partida.gd")
const Temas = preload("res://nucleo/temas.gd")
const Fuentes = preload("res://escenas/comun/fuentes.gd")
const Progreso = preload("res://nucleo/progreso.gd")
const Registro = preload("res://nucleo/registro.gd")
const Tablero = preload("res://escenas/partida/tablero.gd")
const BotonPop = preload("res://escenas/comun/boton_pop.gd")
const Pastilla = preload("res://escenas/comun/pastilla.gd")
const Estrellas = preload("res://escenas/comun/estrellas.gd")
const Iconos = preload("res://escenas/comun/iconos.gd")
const RetoDiario = preload("res://nucleo/reto_diario.gd")
const Taller = preload("res://nucleo/taller.gd")
const ESCENA_TALLER := "res://escenas/taller/taller.tscn"
const ESCENA_MAPA := "res://escenas/mapa/mapa.tscn"

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
var LABIO_BLOQUEADO: Color = Temas.ui("nodo_c")
var PUNTO: Color = Temas.ui("nodo_h")
var VELO: Color = Temas.ui("velo")
var TEXTO: Color = Temas.ui("texto")          # texto sobre la pantalla
var MARCO: Color = Temas.ui("marco")          # borde y sombra de las ventanas
var ESTRELLA: Color = Temas.ui("estrella")

## Cómo se explica cada fallo. Frases cortas, sin culpar y recordando que reintentar es gratis.
const EXPLICACIONES := {
	"curva demasiado cerrada": "La curva era demasiado cerrada y la cadena se rompió.",
	"choca con un muro": "La cadena chocó con un muro.",
	"sale del tablero": "La cadena se salió del tablero.",
	"puerta cerrada": "La puerta estaba cerrada cuando llegó la cadena.",
	"faltan fichas": "No hay fichas para tanto camino.",
	"no empieza en el inicio": "Empieza a dibujar desde el botón verde.",
	"bifurcador no válido": "Las ramas tienen que salir de una ficha ya puesta.",
	"no llegaron a la vez": "Las dos ramas no llegaron a la vez a la campana doble.",
	"solo llegó una rama": "A la campana doble solo llegó una rama. Necesita dos a la vez.",
	"no llegó ninguna rama": "Ninguna rama llegó a la campana doble.",
	"no llegó": "La cadena no llegó a la campana.",
	"orden": "Las campanas numeradas sonaron en otro orden.",
}

var niveles: Array = []
var indice := 0
var actual: Dictionary = {}     # el nivel en juego: uno de la campaña o la Caída del Día
var modo_diario := false
var modo_taller := ""           # "" (campaña o Caída del Día), "prueba", "codigo" o "publicado"
var ruta_taller := Taller.RUTA
var reto = null
var partida = null
var progreso = null
var registro = null

var tablero: Control
var titulo: Label
var pastilla: Control
var objetivo: RichTextLabel
var boton_tumbar: Control
var boton_deshacer: Control
var boton_pista: Control
var boton_lento: Control
var velo: ColorRect
var ventana: PanelContainer
var ventana_titulo: Label
var ventana_estrellas: Control
var ventana_dato: Label
var ventana_detalle: Label
var ventana_premio: HBoxContainer
var ventana_premio_texto: Label
var boton_repetir: Control
var boton_siguiente: Control
var fuente_titulos: Font
var fuente_botones: Font
var fuente_texto: Font          # Nunito 700
var fuente_negrita: Font        # Nunito 900
var _pista_paso := 0
var _fallos_nivel := 0          # fallos seguidos en este nivel (a los 5 se destaca la cámara lenta)
var _abierto_en := 0            # ms en que se abrió el nivel
var _sonidos := {}              # nombre -> AudioStreamPlayer


func _ready() -> void:
	# La campaña: los barrios en orden (La Plaza 1–20, El Puerto 21–40)
	niveles = []
	for ruta in ["res://datos/barrio_1.json", "res://datos/barrio_2.json", "res://datos/barrio_3.json"]:
		var barrio = JSON.parse_string(FileAccess.get_file_as_string(ruta))
		for n in barrio["niveles"]:
			n["barrio"] = barrio["nombre"]          # para «+2 estrellas para El Puerto»
		niveles += barrio["niveles"]
	# En el modo demostración el progreso va a un archivo aparte: nunca toca el del jugador
	var demo := false
	for a in OS.get_cmdline_user_args():
		demo = demo or a.begins_with("--demo")
	progreso = Progreso.new("user://demo_progreso.json" if demo else Progreso.RUTA)
	registro = Registro.new("user://demo_registro.jsonl" if demo else Registro.RUTA)
	reto = RetoDiario.new()
	ruta_taller = "user://demo_taller.json" if demo else Taller.RUTA
	_construir()
	# Demostración: ajustes de accesibilidad pedidos por la línea de órdenes (en el progreso de demo)
	for a in OS.get_cmdline_user_args():
		for par in [["--contraste", "alto_contraste"], ["--sin-movimiento", "reducir_movimiento"], ["--texto-grande", "texto_grande"]]:
			if demo and a == par[0]:
				progreso.ajustes[par[1]] = true
	aplicar_accesibilidad()
	var estado := get_node_or_null("/root/Estado")
	var pendiente: Dictionary = estado.pendiente if estado != null else {}
	if estado != null:
		estado.pendiente = {}
	if pendiente.get("modo") == "campana":
		cargar(int(pendiente["indice"]))         # viene del mapa (la cuerda ya se cobró allí)
	elif pendiente.get("modo") == "diario":
		cargar_diario()
	elif pendiente.get("modo") in ["prueba", "codigo"]:
		cargar_taller(pendiente)                  # viene del Taller: probar o jugar un código
	else:
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
	modo_diario = false
	modo_taller = ""
	_abrir(niveles[indice], "Nivel %d" % int(niveles[indice]["id"]))


## La Caída del Día: el nivel de la fecha UTC (o de `fecha`, para las pruebas).
func cargar_diario(fecha := "") -> void:
	var e: Dictionary = reto.de(fecha) if fecha != "" else reto.de_hoy()
	if e.is_empty():
		return
	modo_diario = true
	modo_taller = ""
	_abrir({"id": 0, "titulo": "Caída del Día", "ayuda": RetoDiario.objetivo(e["tipo"]), "nivel": e["nivel"],
		"solucion": e["solucion"], "fecha": e["fecha_jugada"]}, "Caída del Día")


## Un nivel del Taller: «prueba» (el autor prueba el suyo antes de publicarlo) o «codigo» (uno recibido).
func cargar_taller(p: Dictionary) -> void:
	modo_diario = false
	modo_taller = p["modo"]
	var prueba: bool = modo_taller == "prueba"
	var titulo_texto := "Prueba del Taller" if prueba else "Nivel del Taller"
	var ayuda := "Supera tu nivel para poder [b]compartirlo[/b]." if prueba else Taller.objetivo(p["nivel"])
	_abrir({"id": 0, "titulo": titulo_texto, "ayuda": ayuda, "nivel": p["nivel"], "solucion": p.get("solucion", []),
		"codigo": p.get("codigo", "")}, titulo_texto)


func _ir_taller() -> void:
	get_tree().change_scene_to_file(ESCENA_TALLER)


## Ajustes de accesibilidad del tablero (alto contraste y reducir movimiento) y tamaños de la tarjeta
## del objetivo y la ventana de resultado. El resto de la interfaz los toma de nucleo/temas.gd.
func aplicar_accesibilidad() -> void:
	tablero.aplicar_accesibilidad(progreso.ajustes)
	for clave in ["normal_font_size", "bold_font_size"]:
		objetivo.add_theme_font_size_override(clave, Temas.tam(29))
	ventana_dato.add_theme_font_size_override("font_size", Temas.tam(36))
	ventana_detalle.add_theme_font_size_override("font_size", Temas.tam(27))
	ventana_premio_texto.add_theme_font_size_override("font_size", Temas.tam(28))


func _al_volver() -> void:
	if modo_taller != "":
		_ir_taller()
	else:
		get_tree().change_scene_to_file(ESCENA_MAPA)


func _abrir(n: Dictionary, texto_titulo: String) -> void:
	actual = n
	partida = Partida.new(n["nivel"])
	tablero.preparar(partida)
	_pista_paso = 0
	_fallos_nivel = 0
	_abierto_en = Time.get_ticks_msec()
	boton_lento.resaltado = false
	registro.anotar("nivel", {"nivel": int(n["id"])})
	titulo.text = texto_titulo
	objetivo.text = n["ayuda"]
	# En la campaña, mientras el jugador no tenga ninguna tercera estrella, se le cuenta para qué sirve
	# la dorada. En la Caída del Día, siempre (cada día es un nivel nuevo)
	if modo_taller == "" and Partida.maximo_estrellas(n["nivel"]) == 3 and (modo_diario or not progreso.estrellas.values().has(3)):
		objetivo.text += " [b]Extra:[/b] la campana dorada da la tercera estrella."
	_cerrar_ventanas()
	_actualizar()


func _actualizar() -> void:
	if modo_taller == "prueba":
		pastilla.texto = str(partida.usadas())           # al probar no hay límite: se cuentan las usadas
	else:
		pastilla.texto = str(partida.disponibles() - partida.usadas())
	var editando: bool = tablero.modo == Tablero.Modo.EDITAR
	boton_tumbar.desactivado = not editando or partida.tramos.is_empty()
	boton_deshacer.desactivado = not editando or partida.tramos.is_empty()
	boton_pista.desactivado = not editando or actual.get("solucion", []).is_empty()


func _al_tumbar() -> void:
	tablero.tumbar()
	_actualizar()


func _al_terminar_caida() -> void:
	var r: Dictionary = tablero.resultado()
	var n: Dictionary = actual
	var id := int(n["id"])
	var clave = ("dia:" + n["fecha"]) if modo_diario else id
	var marca := int(n["nivel"]["m"])
	var e: int = Partida.estrellas(r, marca, n["nivel"])
	registro.anotar("intento", {"nivel": id, "exito": bool(r["exito"]), "fichas": int(r["fichas_usadas"]),
		"estrellas": e, "segundos": int((Time.get_ticks_msec() - _abierto_en) / 1000), "pistas": _pista_paso,
		"lento": tablero.velocidad < 1.0, "motivo": _motivo(r)})
	_sonar("superado" if e > 0 else "fallo")
	if e > 0:
		_fallos_nivel = 0
		var antes: int = progreso.de(clave) if modo_taller == "" else 0
		if modo_taller == "":
			progreso.registrar(clave, e)
		ventana_titulo.text = Temas.texto("superado", "¡Nivel superado!")
		ventana_estrellas.maximo = Partida.maximo_estrellas(n["nivel"])
		ventana_estrellas.conseguidas = e
		ventana_dato.text = "%d fichas" % int(r["fichas_usadas"])
		var de_que := "del día" if modo_diario else "del nivel"
		if int(r["fichas_usadas"]) <= marca:
			ventana_detalle.text = "Sin pasarte de la marca %s (%d)." % [de_que, marca]
		else:
			ventana_detalle.text = "La marca %s es %d: con menos fichas, una estrella más." % [de_que, marca]
		if Partida.maximo_estrellas(n["nivel"]) == 3:
			ventana_detalle.text += "\n¡Y sonó la campana dorada!" if Partida.dorada_sono(r, n["nivel"]) \
				else "\nLa campana dorada da la tercera estrella."
		if not modo_diario and indice == niveles.size() - 1:
			ventana_detalle.text += "\nHas terminado los niveles de esta prueba. ¡Gracias por jugar!"
		var ganadas := maxi(e - antes, 0)
		ventana_premio.visible = ganadas > 0 and not modo_diario
		ventana_premio_texto.text = "+%d %s para %s" % [ganadas, "estrella" if ganadas == 1 else "estrellas", n.get("barrio", "La Plaza")]
		if modo_taller == "prueba" and Partida.maximo_estrellas(n["nivel"]) == 3 and not Partida.dorada_sono(r, n["nivel"]):
			# Si el autor no hace sonar la dorada, su marca no la incluye y nadie podría sacar las 3 estrellas
			ventana_titulo.text = "Falta la dorada"
			ventana_detalle.text = "Tu nivel funciona. Para publicarlo, haz sonar también la campana dorada: así las tres estrellas se pueden conseguir."
			ventana_premio.visible = false
			boton_siguiente.visible = false
		elif modo_taller == "prueba":
			ventana_titulo.text = "¡Tu nivel funciona!"
			ventana_detalle.text = "Al publicarlo, %d fichas será la marca y habrá 8 de margen." % int(r["fichas_usadas"])
			ventana_premio.visible = false
			_tipo_boton(boton_siguiente, "Publicar código", true)
			boton_siguiente.visible = true
		elif modo_taller == "codigo":
			ventana_premio.visible = false
			_tipo_boton(boton_siguiente, "Volver al Taller", true)
			boton_siguiente.visible = true
		elif modo_diario:
			# En la Caída del Día, «Siguiente» se convierte en compartir el resultado
			ventana_titulo.text = "¡Caída del Día superada!"
			_tipo_boton(boton_siguiente, "Copiar resultado", true)
			boton_siguiente.visible = true
		else:
			_tipo_boton(boton_siguiente, "Siguiente", true)
			boton_siguiente.visible = indice < niveles.size() - 1
		_tipo_boton(boton_repetir, "Repetir", false)
		velo.visible = true
		ventana.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	else:
		_fallos_nivel += 1
		# Tras 5 fallos se destaca la cámara lenta, sin cambiar el nivel (P-05)
		boton_lento.resaltado = _fallos_nivel >= 5 and tablero.velocidad == 1.0
		ventana_titulo.text = "¡Casi!"
		ventana_dato.text = _explicacion(r)
		ventana_detalle.text = "Prueba otra vez, es gratis."
		ventana_premio.visible = false
		boton_siguiente.visible = false
		_tipo_boton(boton_repetir, "Corregir", true)
		# Sin velo y en la mitad de la pantalla donde no está la X: así se ve dónde se paró la cadena
		velo.visible = false
		var x = tablero.posicion_parada()
		var alto_pantalla := get_viewport_rect().size.y
		if x != null and x.y > alto_pantalla * 0.5:
			ventana.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 30)
		else:
			ventana.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 30)
	ventana_estrellas.visible = e > 0 and modo_taller != "prueba"
	ventana.reset_size()
	ventana.visible = true
	_actualizar()


func _tipo_boton(b: Control, texto: String, principal: bool) -> void:
	b.texto = texto
	b.principal = principal
	b.tam_fuente = 38 if principal else 34
	b.update_minimum_size()
	b.queue_redraw()


func _motivo(r: Dictionary) -> String:
	var parada = r.get("parada")
	if parada != null:
		return str(parada["motivo"])
	for k in r["motivos"]:
		return "orden" if k == "orden" else str(r["motivos"][k])
	return ""


func _explicacion(r: Dictionary) -> String:
	var parada = r.get("parada")
	if parada != null and EXPLICACIONES.has(parada["motivo"]) and r["motivos"].size() > 0:
		return EXPLICACIONES[parada["motivo"]]
	for k in r["motivos"]:
		var m: String = r["motivos"][k] if k != "orden" else "orden"
		if EXPLICACIONES.has(m):
			return EXPLICACIONES[m]
	return "La cadena no hizo sonar todas las campanas."


var ultimo_copiado := ""


## Copia al portapapeles del sistema. En el modo demostración no lo toca: solo lo recuerda.
func _copiar(texto: String) -> void:
	ultimo_copiado = texto
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--demo"):
			return
	DisplayServer.clipboard_set(texto)


## Publica el nivel probado: la marca es lo que usó el autor, con 8 fichas de margen, y el código
## lleva su solución (simplificada y comprobada). Se guarda en la lista y se copia al portapapeles.
func _publicar() -> void:
	var r: Dictionary = tablero.resultado()
	var marca := int(r["fichas_usadas"])
	var nivel: Dictionary = actual["nivel"].duplicate(true)
	nivel["m"] = marca
	nivel["f"] = mini(marca + 8, Taller.LIMITES["fichas"])
	var solucion: Array = Taller.solucion_para_codigo(nivel, partida.tramos)
	if solucion.is_empty():
		ventana_detalle.text = "No se pudo preparar el código. Prueba a dibujar la solución otra vez."
		return
	var codigo := Taller.codificar(nivel, solucion)
	var fecha := Time.get_date_string_from_system()
	Taller.guardar_en_lista({"codigo": codigo, "titulo": "Mi nivel del " + fecha, "propio": true, "fecha": fecha}, ruta_taller)
	_copiar(codigo)
	modo_taller = "publicado"
	ventana_titulo.text = "¡Código copiado!"
	ventana_dato.text = "%d caracteres" % codigo.length()
	ventana_detalle.text = "Pégalo en un mensaje para retar a quien quieras. También lo tienes en Taller › Códigos."
	_tipo_boton(boton_siguiente, "Volver al Taller", true)
	ventana.reset_size()


func _al_repetir() -> void:
	_cerrar_ventanas()
	tablero.editar()
	_actualizar()


func _al_siguiente() -> void:
	if modo_taller == "prueba":
		_publicar()
		return
	if modo_taller in ["codigo", "publicado"]:
		_ir_taller()
		return
	if modo_diario:
		var r: Dictionary = tablero.resultado()
		var e: int = Partida.estrellas(r, int(actual["nivel"]["m"]), actual["nivel"])
		_copiar(RetoDiario.texto_compartir(actual["fecha"], bool(r["exito"]), int(r["fichas_usadas"]), e, _pista_paso > 0))
		_tipo_boton(boton_siguiente, "¡Copiado!", true)
		return
	# El siguiente nivel de la campaña: si es nuevo y no queda cuerda, el mapa muestra las opciones
	var siguiente := indice + 1
	if not progreso.empezar(int(niveles[siguiente]["id"]), int(Time.get_unix_time_from_system())):
		var estado := get_node_or_null("/root/Estado")
		if estado != null:
			estado.pendiente = {"modo": "sin_cuerda"}
		get_tree().change_scene_to_file(ESCENA_MAPA)
		return
	cargar(siguiente)


func _al_deshacer() -> void:
	partida.deshacer()
	tablero.queue_redraw()
	_actualizar()


## Mantener pulsado deshacer borra todo el dibujo.
func _al_borrar() -> void:
	partida.borrar_todo()
	tablero.queue_redraw()
	_actualizar()


## La pista dibuja en fantasma el siguiente tramo de la solución de referencia.
func _al_pista() -> void:
	var sol: Array = actual["solucion"]
	tablero.pista = sol[_pista_paso % sol.size()]["puntos"]
	_pista_paso += 1
	tablero.queue_redraw()


func _al_lento() -> void:
	tablero.velocidad = 0.5 if tablero.velocidad == 1.0 else 1.0
	var lento: bool = tablero.velocidad < 1.0
	boton_lento.texto = "Lento: sí" if lento else "Lento"
	# Siempre opaco: va encima del tablero, que en algunos temas (o con alto contraste) es claro
	boton_lento.color_fondo = PUNTO if lento else MARFIL
	boton_lento.color_labio = boton_lento.color_fondo.darkened(0.12)
	boton_lento.resaltado = false
	boton_lento.update_minimum_size()
	boton_lento.queue_redraw()


func _al_caer(cuantas: int) -> void:
	# Como mucho dos clics por tic, con un poco de variación para que no suene a metralleta
	for k in mini(cuantas, 2):
		_sonar("ficha", randf_range(0.9, 1.1), -4.0 if k > 0 else 0.0)


func _al_sonar_campana(c: Array) -> void:
	var tipo: String = c[2]
	if tipo == "doble":
		_sonar("campana", 1.0)
		_sonar("campana", 1.335)          # una cuarta por encima: dos golpes a la vez
	elif tipo == "numerada":
		_sonar("campana", 1.0 + 0.125 * (int(c[3]) - 1))
	elif tipo == "dorada":
		_sonar("campana", 1.5)            # más aguda y brillante
		_sonar("campana", 2.0, -6.0)
	else:
		_sonar("campana", 1.0)
	if progreso.ajustes["vibracion"] and OS.has_feature("mobile"):
		Input.vibrate_handheld(35)


func _sonar(nombre: String, tono := 1.0, volumen_db := 0.0) -> void:
	var r: AudioStreamPlayer = _sonidos.get(nombre)
	if r == null or r.stream == null or not progreso.ajustes["sonido"]:
		return
	r.pitch_scale = tono
	r.volume_db = volumen_db
	r.play()


func _cerrar_ventanas() -> void:
	velo.visible = false
	ventana.visible = false


# ---------------------------------------------------------------- construcción de la interfaz

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
	margen.add_theme_constant_override("margin_left", 28)
	margen.add_theme_constant_override("margin_right", 28)
	margen.add_theme_constant_override("margin_top", 32)
	margen.add_theme_constant_override("margin_bottom", 36)
	add_child(margen)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 16)
	margen.add_child(columna)

	# HUD: volver, «Nivel N» centrado y la pastilla de fichas
	var hud := HBoxContainer.new()
	hud.add_theme_constant_override("separation", 16)
	columna.add_child(hud)
	var volver := _boton("", false)
	volver.icono = "volver"
	volver.redondo = true
	volver.custom_minimum_size = Vector2(96, 96)
	volver.tooltip_text = "Niveles"
	volver.pulsado.connect(_al_volver)
	hud.add_child(volver)
	titulo = _etiqueta(50, TEXTO, true)
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.add_child(titulo)
	pastilla = Pastilla.new()
	pastilla.fuente = fuente_negrita
	pastilla.nombre_accesible = "Fichas que quedan"
	pastilla.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pastilla.tooltip_text = "Fichas que quedan"
	hud.add_child(pastilla)
	# Contrapeso invisible para que el título quede centrado de verdad
	hud.add_child(Control.new())

	# Tarjeta del objetivo
	var tarjeta := PanelContainer.new()
	tarjeta.add_theme_stylebox_override("panel", _caja(MARFIL, 14, 2, Vector4(24, 16, 24, 16)))
	columna.add_child(tarjeta)
	var fila_obj := HBoxContainer.new()
	fila_obj.add_theme_constant_override("separation", 20)
	tarjeta.add_child(fila_obj)
	fila_obj.add_child(_icono("campana", 56))
	objetivo = RichTextLabel.new()
	objetivo.bbcode_enabled = true
	objetivo.fit_content = true
	objetivo.scroll_active = false
	objetivo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	objetivo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	objetivo.add_theme_font_override("normal_font", fuente_texto)
	objetivo.add_theme_font_override("bold_font", fuente_negrita)
	objetivo.add_theme_font_size_override("normal_font_size", Temas.tam(29))
	objetivo.add_theme_font_size_override("bold_font_size", Temas.tam(29))
	objetivo.add_theme_color_override("default_color", TINTA)
	objetivo.add_theme_constant_override("line_separation", 4)
	objetivo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila_obj.add_child(objetivo)

	# Tablero, con el botón de cámara lenta en la esquina
	var zona := Control.new()
	zona.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columna.add_child(zona)
	tablero = Tablero.new()
	tablero.set_anchors_preset(Control.PRESET_FULL_RECT)
	tablero.mouse_filter = Control.MOUSE_FILTER_STOP
	tablero.cambio.connect(_actualizar)
	tablero.caida_terminada.connect(_al_terminar_caida)
	tablero.cae.connect(_al_caer)
	tablero.suena.connect(_al_sonar_campana)
	zona.add_child(tablero)
	boton_lento = _boton("Lento", false, 28)
	boton_lento.color_fondo = MARFIL
	boton_lento.color_labio = MARFIL.darkened(0.12)
	boton_lento.icono = "lento"
	boton_lento.custom_minimum_size = Vector2(0, 76)
	boton_lento.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 16)
	boton_lento.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	boton_lento.grow_vertical = Control.GROW_DIRECTION_BEGIN
	boton_lento.pulsado.connect(_al_lento)
	zona.add_child(boton_lento)
	for nombre in ["ficha", "campana", "superado", "fallo"]:
		var r := AudioStreamPlayer.new()
		r.stream = load("res://sonidos/%s.wav" % nombre)
		r.max_polyphony = 6 if nombre == "ficha" else 3
		add_child(r)
		_sonidos[nombre] = r

	# Mandos: deshacer, ¡A tumbar! y la bombilla
	var mandos := HBoxContainer.new()
	mandos.add_theme_constant_override("separation", 24)
	columna.add_child(mandos)
	boton_deshacer = _boton("", false)
	boton_deshacer.icono = "deshacer"
	boton_deshacer.redondo = true
	boton_deshacer.custom_minimum_size = Vector2(108, 108)
	boton_deshacer.tooltip_text = "Deshacer (mantén pulsado para borrar todo)"
	boton_deshacer.pulsado.connect(_al_deshacer)
	boton_deshacer.mantenido.connect(_al_borrar)
	boton_tumbar = _boton(Temas.texto("ya", "¡A tumbar!"), true, 42)
	boton_tumbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boton_tumbar.custom_minimum_size = Vector2(0, 108)
	boton_tumbar.pulsado.connect(_al_tumbar)
	boton_pista = _boton("", false)
	boton_pista.icono = "bombilla"
	boton_pista.redondo = true
	boton_pista.custom_minimum_size = Vector2(108, 108)
	boton_pista.tooltip_text = "Pista"
	boton_pista.pulsado.connect(_al_pista)
	for b in [boton_deshacer, boton_tumbar, boton_pista]:
		mandos.add_child(b)

	velo = ColorRect.new()
	velo.color = VELO
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	velo.visible = false
	add_child(velo)

	_construir_resultado()


func _construir_resultado() -> void:
	ventana = _ventana()
	ventana.custom_minimum_size = Vector2(640, 0)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 10)
	caja.alignment = BoxContainer.ALIGNMENT_CENTER
	ventana.add_child(caja)
	ventana_titulo = _etiqueta(54, TINTA, true)
	ventana_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ventana_estrellas = Estrellas.new()
	ventana_dato = _etiqueta(36, TINTA)
	ventana_dato.add_theme_font_override("font", fuente_negrita)
	ventana_dato.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ventana_dato.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ventana_dato.custom_minimum_size = Vector2(560, 0)   # sin ancho mínimo, el ajuste de línea dispara la altura
	ventana_detalle = _etiqueta(27, TINTA_SUAVE)
	ventana_detalle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ventana_detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ventana_detalle.custom_minimum_size = Vector2(560, 0)
	ventana_premio = HBoxContainer.new()
	ventana_premio.alignment = BoxContainer.ALIGNMENT_CENTER
	ventana_premio.add_theme_constant_override("separation", 10)
	ventana_premio.add_child(_icono("estrella", 34))
	ventana_premio_texto = _etiqueta(28, TINTA_SUAVE)
	ventana_premio.add_child(ventana_premio_texto)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 20)
	boton_repetir = _boton("Repetir", false, 34)
	boton_repetir.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boton_repetir.pulsado.connect(_al_repetir)
	boton_siguiente = _boton("Siguiente", true, 38)
	boton_siguiente.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boton_siguiente.pulsado.connect(_al_siguiente)
	fila.add_child(boton_repetir)
	fila.add_child(boton_siguiente)
	var aire := Control.new()
	aire.custom_minimum_size = Vector2(0, 8)
	for h in [ventana_titulo, ventana_estrellas, ventana_dato, ventana_detalle, ventana_premio, aire, fila]:
		caja.add_child(h)


func _caja(color: Color, radio: int, borde: int, margenes := Vector4.ZERO) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radio)
	s.set_border_width_all(borde)
	s.border_color = MARCO
	s.content_margin_left = margenes.x
	s.content_margin_top = margenes.y
	s.content_margin_right = margenes.z
	s.content_margin_bottom = margenes.w
	s.anti_aliasing = true
	return s


## Ventana marfil con borde de tinta y sombra sólida de 4 px (DESIGN.md › window).
func _ventana() -> PanelContainer:
	var v := PanelContainer.new()
	v.set_meta("ventana", true)
	var s := _caja(MARFIL, Temas.numero("radio_ventana", 22), 2, Vector4(32, 40, 32, 32))
	s.shadow_color = MARCO
	s.shadow_offset = Vector2(0, 4)
	s.shadow_size = 1
	v.add_theme_stylebox_override("panel", s)
	v.set_anchors_preset(Control.PRESET_CENTER)
	v.grow_horizontal = Control.GROW_DIRECTION_BOTH
	v.grow_vertical = Control.GROW_DIRECTION_BOTH
	v.visible = false
	add_child(v)
	return v


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


## Icono suelto (campana de la tarjeta, estrella del premio).
func _icono(tipo: String, lado: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(lado, lado)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func(): Iconos.dibujar(c, tipo, Rect2(Vector2.ZERO, Vector2(lado, lado))))
	return c


# ---------------------------------------------------------------- demostración y capturas

func _demo_si_toca() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var partes: PackedStringArray = a.trim_prefix("--").split("=", true, 1)
		args[partes[0]] = partes[1] if partes.size() > 1 else "1"
	if args.has("demo-mapa") and args.has("entrar"):
		# Llegada desde la demostración del mapa: comprobar que se abrió el nivel que tocaba
		await get_tree().create_timer(0.4).timeout
		await _capturar(args.get("captura", "user://captura") + "_3_partida.png")
		print("DEMO desde el mapa: ", titulo.text, ", cuerdas ", progreso.cuerdas(int(Time.get_unix_time_from_system())))
		for r in ["user://demo_progreso.json", "user://demo_progreso.anterior.json", "user://demo_registro.jsonl"]:
			if FileAccess.file_exists(r):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(r))
		get_tree().quit()
		return
	if not args.has("demo"):
		return
	var prefijo: String = args.get("captura", "user://captura")
	await get_tree().process_frame
	if args.has("diario"):
		cargar_diario(args.get("fecha", ""))
	elif args.has("codigo"):
		var abierto: Dictionary = Taller.decodificar(args["codigo"])
		if not abierto["ok"]:
			print("DEMO código rechazado: ", abierto["error"])
			get_tree().quit(1)
			return
		cargar_taller({"modo": "codigo", "nivel": abierto["nivel"], "solucion": abierto["solucion"], "codigo": args["codigo"]})
	elif args.has("taller"):
		# Probar un nivel del Taller: el del nivel 8, sin límite de fichas, como si lo hubiera hecho el jugador
		var n: Dictionary = niveles[int(args["demo"]) - 1]
		var nivel: Dictionary = n["nivel"].duplicate(true)
		nivel["f"] = 400
		nivel["m"] = 0
		cargar_taller({"modo": "prueba", "nivel": nivel, "solucion": n["solucion"]})
	else:
		cargar(int(args["demo"]) - 1)
	await _capturar(prefijo + "_1_vacio.png")
	var sol: Array = actual["solucion"]
	if args.has("incompleto"):
		sol = sol.slice(0, 1)
	if args.has("recto"):      # en línea recta del inicio a la primera campana: suele fallar
		var nivel: Dictionary = actual["nivel"]
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
	if args.has("publicar"):
		_al_siguiente()
		await get_tree().create_timer(0.2).timeout
		await _capturar(prefijo + "_5_publicado.png")
		print("DEMO código: ", ultimo_copiado)
	print("DEMO resultado: ", JSON.stringify(tablero.resultado()))
	for r in ["user://demo_progreso.json", "user://demo_progreso.anterior.json", "user://demo_registro.jsonl", "user://demo_taller.json"]:
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
