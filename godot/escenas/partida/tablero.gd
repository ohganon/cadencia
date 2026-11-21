## Tablero de juego: dibuja el nivel, recoge el dedo y anima la caída.
##
## Todo se calcula en unidades lógicas (partida.gd y simulacion.gd); aquí solo se convierten a
## píxeles para dibujar. Medidas de Dominó Pop (DESIGN.md y docs/fase6/tablero/index.html); los colores
## son los del tema activo (nucleo/temas.gd), salvo con alto contraste.
extends Control

signal cambio                 # el dibujo ha cambiado (fichas usadas, botones)
signal caida_terminada        # ha terminado la animación de la caída
signal cae(cuantas: int)      # en este tic caen `cuantas` fichas (para el sonido)
signal suena(campana: Array)  # una campana acaba de sonar: [id, pos, tipo, numero]

const Sim = preload("res://nucleo/simulacion.gd")
const Iconos = preload("res://escenas/comun/iconos.gd")
const Temas = preload("res://nucleo/temas.gd")
const Caja = preload("res://escenas/comun/caja.gd")

const DURACION_TIC := 0.075   # segundos que tarda en caer cada ficha
const PAUSA_FINAL := 0.5

## Alto contraste: fondo blanco, contornos negros y colores más saturados (contraste 7:1 o más con
## el fondo en las piezas y las marcas). Manda sobre el tema.
const PALETA_CONTRASTE := {"HIELO": "#ffffff", "PUNTO": "#e2e2e2", "TINTA": "#000000", "MARFIL": "#ffffff",
	"PIP": "#000000", "BORDE_FICHA": "#000000", "SOMBRA_FICHA": "#00000000", "CAYENDO": "#ffb000",
	"CAIDA": "#6f7f9f", "CAMPANA": "#c8002a", "DORADA": "#ffb000", "INICIO": "#00873a", "INICIO_ICO": "#ffffff",
	"CIFRA": "#000000", "CIFRA_T": "#ffffff", "BORDE_TABLERO": "#000000", "ETIQUETA": "#ffffff",
	"ETIQUETA_T": "#000000", "CORAL": "#c8002a", "VERDE": "#00873a", "PUERTA": "#7a3e00", "TINTA_SEM": "#000000"}
# Colores del tema (se rellenan en aplicar_accesibilidad)
var HIELO := Color("#eaf3ff")      # fondo del tablero
var PUNTO := Color("#cfe0ff")      # rejilla de puntos
var TINTA := Color("#142554")      # muros, postes y pista
var MARFIL := Color("#fffdf6")     # ficha de pie
var PIP := Color("#142554")        # puntos de la ficha
var BORDE_FICHA := Color("#142554")
var SOMBRA_FICHA := Color(0, 0, 0, 0)
var CAYENDO := Color("#ffc83d")
var CAIDA := Color("#c9d6f2")
var CAMPANA := Color("#ff5470")
var DORADA := Color("#ffc83d")
var INICIO := Color("#3ddc6b")     # empujador
var INICIO_ICO := Color("#142554")
var CIFRA := Color("#142554")      # marcas de cuenta
var CIFRA_T := Color.WHITE
var BORDE_TABLERO := Color("#142554")
var GROSOR_BORDE := 2
var RADIO_TABLERO := 18
var ETIQUETA := Color("#fffdf6")   # cartel de la puerta
var ETIQUETA_T := Color("#142554")
# Colores con significado (abierta / cerrada, bien / aviso): iguales en todos los temas
var CORAL := Color("#ff5470")
var VERDE := Color("#3ddc6b")
var TINTA_SEM := Color("#142554")
const BLANCO := Color.WHITE
var PUERTA := Color("#c98a4b")     # madera de la puerta de vaivén
## Accesibilidad (Ajustes): sin efectos decorativos que se mueven. La información (la puerta que se
## abre y se cierra, la caída) se mantiene.
var reducir_movimiento := false
## Dedo que enseña a dibujar (nivel 1): va del botón verde a la primera campana hasta que se dibuja algo
var guia := false
var _contraste := false       # con alto contraste no hay sombras, brillos ni luz en el tablero

# Medidas de la maqueta, en unidades lógicas (allí 1 unidad = 2,8 px)
const FICHA_ANCHO := 2.5      # de pie: grosor a lo largo del camino
const FICHA_ALTO := 5.7       # de pie: de lado a lado del camino
var TRAZO := 0.72
const EMPUJADOR := 5.7        # radio del empujador verde
const MARCA_RADIO := 2.9      # círculo de cuenta cada 4 fichas

enum Modo { EDITAR, CAYENDO, RESULTADO }

var partida = null            # nucleo/partida.gd
var modo := Modo.EDITAR
var pista: Array = []         # puntos del tramo de la pista (fantasma), o vacío
var velocidad := 1.0          # 0,5 = cámara lenta
var _detalle := {}
var _eventos := {}            # tic -> {"fichas": n, "campanas": [...]}
var _tic_avisado := -1
var _tiempo := 0.0
var _ultimo_tic := 0
var _k := 1.0                 # píxeles por unidad lógica
var _origen := Vector2.ZERO
## Cámara que sigue la caída (pasada estética): durante la caída se acerca al frente de fichas que
## caen y lo sigue con suavidad; al terminar vuelve a la vista completa antes del resultado. Nunca
## enseña fuera del tablero y nunca deja fuera nada de lo que está cayendo. Con «reducir
## movimiento», no se mueve. Va dentro de _medir(): todo lo que se dibuja (y la X de la parada)
## pasa por a_pantalla() y _k, así que queda siempre en su sitio.
const CAMARA_FICHA := 40.0     # tamaño en px al que se acerca una ficha de pie, como mucho
const CAMARA_ZOOM_MAX := 1.6
const CAMARA_MARGEN := 16.0    # unidades lógicas alrededor de lo que cae
const CAMARA_SIGUE := 3.0      # rapidez con que sigue el frente (1/s)
const CAMARA_VUELVE := 6.0     # rapidez con que vuelve a la vista completa
var _cam_z := 1.0
var _cam_c := Vector2(-1, -1)  # centro de la vista, en unidades lógicas (-1: el centro del tablero)
var _cam_objetivo_z := 1.0
var _cam_objetivo_c := Vector2(-1, -1)


func _init() -> void:
	aplicar_accesibilidad({})


## Colores del tablero del tema activo.
static func paleta_tema() -> Dictionary:
	var p := {}
	for par in [["HIELO", "tablero"], ["PUNTO", "punto"], ["TINTA", "tinta"], ["MARFIL", "ficha"], ["PIP", "pip"],
			["BORDE_FICHA", "borde_ficha"], ["SOMBRA_FICHA", "sombra"], ["CAYENDO", "cae"], ["CAIDA", "caida"],
			["CAMPANA", "campana"], ["DORADA", "dorada"], ["INICIO", "inicio"], ["INICIO_ICO", "inicio_ico"],
			["CIFRA", "cifra"], ["CIFRA_T", "cifra_t"], ["BORDE_TABLERO", "borde"]]:
		p[par[0]] = Temas.tablero(par[1])
	p["ETIQUETA"] = Temas.ui("ventana")
	p["ETIQUETA_T"] = Temas.ui("ventana_t")
	p["CORAL"] = Color("#ff5470")
	p["VERDE"] = Color("#3ddc6b")
	p["PUERTA"] = Color("#c98a4b")
	p["TINTA_SEM"] = Color("#142554")
	return p


## Aplica el tema y los ajustes de accesibilidad guardados en el progreso.
func aplicar_accesibilidad(ajustes: Dictionary) -> void:
	var contraste: bool = ajustes.get("alto_contraste", false)
	var paleta := paleta_tema()
	if contraste:
		paleta.merge(PALETA_CONTRASTE, true)
	for clave in paleta:
		set(clave, Color(paleta[clave]))
	_contraste = contraste
	GROSOR_BORDE = 2 if contraste else Temas.numero("grosor_borde", 2)
	RADIO_TABLERO = clampi(Temas.numero("radio_ventana", 18), 0, 18)
	TRAZO = 1.1 if contraste else 0.72
	reducir_movimiento = ajustes.get("reducir_movimiento", false)
	queue_redraw()


func preparar(nueva_partida) -> void:
	partida = nueva_partida
	modo = Modo.EDITAR
	pista = []
	_detalle = {}
	_camara_en_reposo()
	set_process(false)
	queue_redraw()


func tumbar() -> void:
	_detalle = partida.tumbar()
	_tiempo = 0.0
	_ultimo_tic = 0
	var caidas: Array = _detalle["caidas"]
	_eventos = {}
	for i in _detalle["tics"].size():
		if i >= caidas.size() or caidas[i] < 0:
			continue
		_ultimo_tic = maxi(_ultimo_tic, _detalle["tics"][i][caidas[i]])
		for j in range(0, caidas[i] + 1):
			var tic_j: int = _detalle["tics"][i][j]
			_eventos.get_or_add(tic_j, {"fichas": 0, "campanas": []})["fichas"] += 1
	var sonaron: Dictionary = _detalle["resultado"]["campanas"]
	for c in partida.nivel["c"]:
		if sonaron.get(c[0]) != null:
			_eventos.get_or_add(int(sonaron[c[0]]), {"fichas": 0, "campanas": []})["campanas"].append(c)
	_tic_avisado = -1
	modo = Modo.CAYENDO
	pista = []
	set_process(true)
	queue_redraw()


func resultado() -> Dictionary:
	return _detalle.get("resultado", {})


## Vuelve a editar el mismo dibujo tras ver el resultado.
func editar() -> void:
	modo = Modo.EDITAR
	_detalle = {}
	_camara_en_reposo()
	set_process(false)
	queue_redraw()


func _process(delta: float) -> void:
	_tiempo += delta * velocidad
	if modo == Modo.CAYENDO:
		var tic := _tic_actual()
		while _tic_avisado < tic:
			_tic_avisado += 1
			var e: Dictionary = _eventos.get(_tic_avisado, {})
			if e.get("fichas", 0) > 0:
				cae.emit(e["fichas"])
			for c in e.get("campanas", []):
				suena.emit(c)
	if modo == Modo.CAYENDO and not reducir_movimiento:
		_apuntar_camara(_tic_actual())
		_mover_camara(delta)
	if modo == Modo.CAYENDO and _tic_actual() > _ultimo_tic + 1 and _tiempo > (_ultimo_tic + 1) * DURACION_TIC + PAUSA_FINAL:
		modo = Modo.RESULTADO
		_camara_en_reposo()         # el resultado (y la X de la parada) se ven con el tablero entero
		caida_terminada.emit()
	if modo == Modo.RESULTADO and _tiempo > (_ultimo_tic + 1) * DURACION_TIC + 2.0:
		set_process(false)    # ya no hay nada que animar
	queue_redraw()


func _tic_actual() -> int:
	return int(floor(_tiempo / DURACION_TIC))


# ---------------------------------------------------------------- coordenadas

func _medir() -> void:
	var w: float = partida.nivel["w"]
	var h: float = partida.nivel["h"]
	_k = minf(size.x / w, size.y / h)
	_origen = (size - Vector2(w, h) * _k) / 2.0
	if _cam_z > 1.0001:
		# La cámara: más px por unidad y la vista centrada en _cam_c
		var c := _cam_c if _cam_c.x >= 0.0 else Vector2(w, h) / 2.0
		_k *= _cam_z
		_origen = size / 2.0 - c * _k


## Cuánto puede acercarse la cámara en este tablero: hasta que una ficha de pie mida CAMARA_FICHA px.
func _zoom_maximo(k_base: float) -> float:
	return clampf(CAMARA_FICHA / (FICHA_ALTO * k_base), 1.0, CAMARA_ZOOM_MAX)


## A dónde quiere ir la cámara en este momento de la caída: lo que cae ahora (y lo que acaba de caer
## o está a punto) dentro de la vista, lo más cerca posible.
func _apuntar_camara(tic: int) -> void:
	var w: float = partida.nivel["w"]
	var h: float = partida.nivel["h"]
	var k_base := minf(size.x / w, size.y / h)
	var centro := Vector2(w, h) / 2.0
	if tic > _ultimo_tic:
		_cam_objetivo_z = 1.0
		_cam_objetivo_c = centro
		return
	var caja := Rect2()
	var hay := false
	var tics: Array = _detalle.get("tics", [])
	var caidas: Array = _detalle.get("caidas", [])
	var fichas: Array = _detalle.get("fichas", [])
	for i in mini(tics.size(), fichas.size()):
		if i >= caidas.size() or caidas[i] < 0:
			continue
		for j in range(0, mini(int(caidas[i]) + 1, fichas[i].size())):
			var tj: int = tics[i][j]
			if tj < tic - 3 or tj > tic + 1:
				continue
			var q := Vector2(fichas[i][j][0], fichas[i][j][1])
			if hay:
				caja = caja.expand(q)
			else:
				caja = Rect2(q, Vector2.ZERO)
				hay = true
	if not hay:
		return                       # entre dos tramos: la cámara se queda donde está
	caja = caja.grow(CAMARA_MARGEN)
	var z := minf(_zoom_maximo(k_base), minf(size.x / (k_base * caja.size.x), size.y / (k_base * caja.size.y)))
	z = maxf(z, 1.0)
	# Centro de la vista, sin enseñar fuera del tablero
	var media := size / (2.0 * k_base * z)
	var c := caja.get_center()
	c.x = clampf(c.x, media.x, w - media.x) if w > 2.0 * media.x else w / 2.0
	c.y = clampf(c.y, media.y, h - media.y) if h > 2.0 * media.y else h / 2.0
	_cam_objetivo_z = z
	_cam_objetivo_c = c


func _mover_camara(delta: float) -> void:
	var w: float = partida.nivel["w"]
	var h: float = partida.nivel["h"]
	if _cam_c.x < 0.0:
		_cam_c = Vector2(w, h) / 2.0
	if _cam_objetivo_c.x < 0.0:
		_cam_objetivo_c = Vector2(w, h) / 2.0
	var rapidez := CAMARA_VUELVE if _cam_objetivo_z <= 1.0 else CAMARA_SIGUE
	var a := 1.0 - exp(-delta * rapidez)
	_cam_z = lerpf(_cam_z, _cam_objetivo_z, a)
	_cam_c = _cam_c.lerp(_cam_objetivo_c, a)
	clip_contents = _cam_z > 1.001


## Vista completa del tablero, al momento (al empezar a dibujar, al ver el resultado).
func _camara_en_reposo() -> void:
	_cam_z = 1.0
	_cam_c = Vector2(-1, -1)
	_cam_objetivo_z = 1.0
	_cam_objetivo_c = Vector2(-1, -1)
	clip_contents = false


func a_pantalla(p: Array) -> Vector2:
	return _origen + Vector2(p[0], p[1]) * _k


func a_logico(v: Vector2) -> Array:
	var q := (v - _origen) / _k
	return [q.x, q.y]


# ---------------------------------------------------------------- dedo

func _gui_input(evento: InputEvent) -> void:
	if partida == null or modo != Modo.EDITAR:
		return
	_medir()
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.pressed:
			if partida.empezar(a_logico(evento.position)):
				pista = []
				accept_event()
		else:
			if partida.dibujando():
				partida.terminar()
				accept_event()
		cambio.emit()
		queue_redraw()
	elif evento is InputEventMouseMotion and partida.dibujando():
		partida.seguir(a_logico(evento.position))
		accept_event()
		cambio.emit()
		queue_redraw()


# ---------------------------------------------------------------- dibujo

func _draw() -> void:
	# En el primer fotograma el tablero aún mide 0 px: no hay nada que dibujar (y los textos
	# de las campanas numeradas saldrían con tamaño 0)
	if partida == null or size.x < 2.0 or size.y < 2.0:
		return
	_medir()
	var nivel: Dictionary = partida.nivel
	var tablero := Rect2(_origen, Vector2(nivel["w"], nivel["h"]) * _k)
	dibujar_marco(self, tablero, HIELO, PUNTO, _contraste, _cam_z)

	for m in nivel["mu"]:
		draw_line(a_pantalla(m[0]), a_pantalla(m[1]), TINTA, 2.2 * _k, true)
		draw_circle(a_pantalla(m[0]), 1.1 * _k, TINTA)
		draw_circle(a_pantalla(m[1]), 1.1 * _k, TINTA)

	# Las espirales y los muelles van debajo de las fichas: no ocupan sitio, la cadena pasa por encima
	for e in nivel.get("e", []):
		_espiral(e)
	for m in nivel.get("ml", []):
		_muelle(m)
	for m in nivel.get("nr", []):
		_muelle(m)

	if not pista.is_empty():
		var fantasma := Sim.repartir(pista)
		for j in range(1, fantasma.size()):
			_ficha_borrador(fantasma, j)

	var todas: Array = _detalle.get("fichas", partida.fichas()) if modo != Modo.EDITAR else partida.fichas()
	var tic := _tic_actual()
	var avance := fposmod(_tiempo / DURACION_TIC, 1.0)
	for i in todas.size():
		var f: Array = todas[i]
		# La primera ficha del tronco es el empujador y la de cada rama está en su bifurcador
		for j in range(1, f.size()):
			var estado := 0      # 0 de pie, 1 cayendo, 2 caída
			var recien := false   # se acaba de tumbar (el tic anterior): rebota un poco
			if modo != Modo.EDITAR and not _detalle.get("caidas", []).is_empty():
				var t: int = _detalle["tics"][i][j]
				if j <= _detalle["caidas"][i]:
					if t < tic:
						estado = 2
						recien = t == tic - 1
					elif t == tic:
						estado = 1
			_ficha(f, j, estado, avance, recien)

	# Mientras se dibuja, los caminos de los globos ya están puestos (en la caída van con los demás)
	if modo == Modo.EDITAR:
		for g in nivel.get("gl", []):
			var regalo := Sim.repartir(g[1])
			for j in range(1, regalo.size()):
				_ficha(regalo, j, 0, 0.0)
	_empujador(nivel["i"])
	if guia and modo == Modo.EDITAR and partida.tramos.is_empty() and not nivel["c"].is_empty():
		_guia(nivel["i"], nivel["c"][0][1])
	# Las campanas van encima de las fichas para que siempre se vean
	for c in nivel["c"]:
		_campana(c)
	# Las puertas, encima de las fichas, para que se vea su ritmo
	for p in nivel["p"]:
		_puerta(p)
	# Los cristales: enteros hasta que algo choca con ellos; después, solo quedan sus marcos
	var cristales: Array = nivel.get("cr", [])
	for k in cristales.size():
		_cristal(cristales[k], k)
	# Los interruptores: la placa y su compuerta (abierta desde el tic siguiente a pisar la placa)
	var interruptores: Array = nivel.get("in", [])
	for k in interruptores.size():
		_interruptor(interruptores[k], k)

	if modo == Modo.EDITAR:
		var tics := _tics_de(todas)
		# Los caminos de los globos que revientan con lo dibujado, con su cuenta (y sus cruces)
		var caen := []
		for f in todas:
			caen.append(f.size() - 1)
		todas = todas.duplicate()
		for g in nivel.get("gl", []):
			var reventon := Sim.disparo_placa(g[0], todas, tics, caen)
			if reventon < 0:
				continue
			var regalo := Sim.repartir(g[1])
			todas.append(regalo)
			tics.append(Sim.tics_tramo(nivel, regalo, reventon))
			caen.append(regalo.size() - 1)
		for i in todas.size():
			for j in range(1, todas[i].size()):
				if tics[i][j] > 0 and tics[i][j] % 4 == 0:
					_marca_cuenta(todas[i], j, tics[i][j])
		for p in partida.curvas_cerradas():
			var c := a_pantalla(p)
			draw_arc(c, 3.4 * _k, 0, TAU, 28, CORAL, 0.6 * _k, true)
			_simbolo(c + Vector2(3.0, -3.0) * _k, "!")      # aviso con forma, no solo con color
		_cruces_de_puertas(todas, tics)
	# Los globos, encima de todo (hasta que revientan)
	var globos: Array = nivel.get("gl", [])
	for k in globos.size():
		_globo(globos[k], k)
	# El aro y el retraso de cada espiral, encima de todo: si la cadena pasa por ella, se sigue viendo
	for e in nivel.get("e", []):
		_espiral_etiqueta(e)
	for m in nivel.get("ml", []):
		_muelle_etiqueta(m)
	for m in nivel.get("nr", []):
		_muelle_etiqueta(m)
	if not nivel.get("nr", []).is_empty() and modo == Modo.EDITAR and not reducir_movimiento:
		queue_redraw()          # las norias giran a su ritmo mientras se planifica
	if modo == Modo.RESULTADO:
		_parada()


## Mientras se dibuja: dónde cruza el camino cada puerta y si en ese tic estará abierta (verde) o
## cerrada (coral). Con las marcas de cuenta, permite planificar en vez de probar a ciegas.
func _cruces_de_puertas(todas: Array, tics: Array) -> void:
	# Cristales: el primer cruce lo rompe (coral: esa rama se para ahí); los que llegan después pasan (verde)
	for c in partida.nivel.get("cr", []):
		var cruces := []
		for i in todas.size():
			var f: Array = todas[i]
			for j in range(1, f.size()):
				if Sim.cruza(f[j - 1], f[j], c[0], c[1]):
					cruces.append([tics[i][j], f[j]])
					break
		if cruces.is_empty():
			continue
		var primero := 1 << 30
		for x in cruces:
			primero = mini(primero, int(x[0]))
		for x in cruces:
			_marca_cruce(x[1], int(x[0]), int(x[0]) > primero)
	# Compuertas: si se cruzan después de que se pise su placa (según lo dibujado), estarán abiertas
	var caen := []
	for f in todas:
		caen.append(f.size() - 1)
	for it in partida.nivel.get("in", []):
		var pisada := Sim.disparo_placa(it[0], todas, tics, caen)
		for i in todas.size():
			var f: Array = todas[i]
			for j in range(1, f.size()):
				if Sim.cruza(f[j - 1], f[j], it[1], it[2]):
					var abierta: bool = pisada >= 0 and tics[i][j] > pisada
					_marca_cruce(f[j], tics[i][j], abierta)
					break
	for p in partida.nivel["p"]:
		for i in todas.size():
			var f: Array = todas[i]
			for j in range(1, f.size()):
				if Sim.cruza(f[j - 1], f[j], p[0], p[1]):
					_marca_cruce(f[j], tics[i][j], Sim.puerta_abierta(p, tics[i][j]))
					break


## Marca dónde el camino cruza una puerta o una compuerta: el tic, y verde (abierta) o coral (cerrada).
func _marca_cruce(punto: Array, t: int, abierta: bool) -> void:
	var c := a_pantalla(punto)
	draw_circle(c, MARCA_RADIO * 1.15 * _k, VERDE if abierta else CORAL)
	draw_arc(c, MARCA_RADIO * 1.15 * _k, 0, TAU, 24, TINTA_SEM, maxf(1.0, 0.35 * _k), true)
	var fuente := get_theme_default_font()
	var tam := int(3.2 * _k)
	var texto := str(t)
	var medida := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam)
	draw_string(fuente, c + Vector2(-medida.x / 2, fuente.get_ascent(tam) / 2 - 0.15 * _k), texto,
		HORIZONTAL_ALIGNMENT_LEFT, -1, tam, TINTA_SEM)
	_simbolo(c + Vector2(3.0, -3.0) * _k, "si" if abierta else "no")


## Tic en que cae cada ficha, igual que en la simulación (con el retraso de las espirales y el salto
## de los muelles): así la cuenta que se ve al dibujar es el orden real de caída, y las dos ramas de
## una campana doble muestran el mismo número al llegar. Mientras se dibuja se supone que no se para.
func _tics_de(todas: Array) -> Array:
	var r := []
	var todas_caen := []
	for i in todas.size():
		var base := -1
		if i < partida.tramos.size() and partida.tramos[i]["padre"] != null:
			var padre := int(partida.tramos[i]["padre"])
			var desde := int(partida.tramos[i]["desde"])
			if padre < r.size() and desde < r[padre].size():
				base = r[padre][desde]
		elif not todas[i].is_empty() and Sim.dist(todas[i][0], partida.nivel["i"]) > Sim.PASO:
			var k := Sim.salida_de(partida.nivel, todas[i][0])
			if k >= 0:
				var m: Array = Sim.lanzadores(partida.nivel)[k]
				var disparo := Sim.disparo_muelle(m, todas, r, todas_caen)
				if disparo >= 0:
					base = Sim.primera_salida(m, disparo) - 1
		todas_caen.append(todas[i].size() - 1)
		r.append(Sim.tics_tramo(partida.nivel, todas[i], base))
	return r


func _caja(color: Color, radio: int, borde := Color(0, 0, 0, 0), grosor := 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radio)
	if grosor > 0:
		s.border_color = borde
		s.set_border_width_all(grosor)
	s.anti_aliasing = true
	return s


func _direccion(f: Array, j: int) -> Vector2:
	var a: Array = f[maxi(j - 1, 0)]
	var b: Array = f[mini(j + 1, f.size() - 1)]
	var d := Vector2(b[0] - a[0], b[1] - a[1])
	return d.normalized() if d.length() > 0.0001 else Vector2.UP


## Rectángulo redondeado girado: `largo` a lo largo de `eje` y `ancho` en perpendicular.
func _rect_redondo(centro: Vector2, eje: Vector2, largo: float, ancho: float, radio: float) -> PackedVector2Array:
	var n := Vector2(-eje.y, eje.x)
	var r := minf(radio, minf(largo, ancho) / 2)
	var p := PackedVector2Array()
	var esquinas := [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
	for k in 4:
		var e: Vector2 = esquinas[k]
		var c := Vector2(e.x * (largo / 2 - r), e.y * (ancho / 2 - r))
		for s in 5:
			var a := PI / 2 * k + PI / 2 * s / 4.0
			var q := c + Vector2(cos(a), sin(a)) * r
			p.append(centro + eje * q.x + n * q.y)
	return p


func _cerrar(p: PackedVector2Array) -> PackedVector2Array:
	var b := p.duplicate()
	b.append(p[0])
	return b


func _ficha(f: Array, j: int, estado: int, avance: float, recien := false) -> void:
	var c := a_pantalla(f[j])
	var eje := _direccion(f, j)
	var n := Vector2(-eje.y, eje.x)
	var radio := 0.9 * _k
	var forma: PackedVector2Array
	var color := MARFIL
	var alto := FICHA_ALTO
	var elevada := 1.0          # cuánto «levanta» la ficha del tablero (para la sombra)
	match estado:
		1:   # cayendo: vuelca hacia delante, cada vez más deprisa (como con la gravedad)
			color = CAYENDO
			if reducir_movimiento:
				alto = FICHA_ALTO * 0.7
				forma = _rect_redondo(c, eje, FICHA_ANCHO * _k, alto * _k, radio)
			else:
				var p := avance * avance
				var largo := lerpf(FICHA_ANCHO, FICHA_ALTO, p)
				alto = lerpf(FICHA_ALTO, FICHA_ANCHO * 0.9, p)
				forma = _rect_redondo(c + eje * 1.4 * p * _k, eje, largo * _k, alto * _k, radio)
				elevada = 1.0 - p
		2:   # tumbada: ahora es larga a lo largo del camino; al caer, un pequeño rebote
			color = CAIDA
			var largo := FICHA_ALTO
			if recien and not reducir_movimiento:
				largo *= 1.0 + 0.08 * sin(PI * avance)
			forma = _rect_redondo(c + eje * 1.4 * _k, eje, largo * _k, FICHA_ANCHO * 0.9 * _k, radio)
			elevada = 0.0
		_:
			forma = _rect_redondo(c, eje, FICHA_ANCHO * _k, alto * _k, radio)
	# Sombra: la del tema o, si no tiene, una muy suave bajo las fichas de pie
	var sombra_color := SOMBRA_FICHA if SOMBRA_FICHA.a > 0 else Color(0, 0, 0, 0.10 * elevada)
	if sombra_color.a > 0 and not _contraste:
		var abajo := Vector2(0.45, 0.8) * _k * (0.4 + 0.6 * elevada)
		var sombra := PackedVector2Array()
		for v in forma:
			sombra.append(v + abajo)
		draw_colored_polygon(sombra, sombra_color)
	draw_colored_polygon(forma, color)
	# Relieve: un brillo en la cara de las fichas de pie
	if estado == 0 and not _contraste:
		var brillo := _rect_redondo(c - n * alto * 0.12 * _k, eje, FICHA_ANCHO * 0.45 * _k, alto * 0.5 * _k, radio * 0.6)
		draw_colored_polygon(brillo, Color(1, 1, 1, 0.20))
	if BORDE_FICHA.a > 0:
		draw_polyline(_cerrar(forma), BORDE_FICHA, maxf(1.0, TRAZO * _k), true)
	if estado != 2:
		draw_circle(c + n * alto * 0.22 * _k, 0.5 * _k, PIP)
		draw_circle(c - n * alto * 0.22 * _k, 0.5 * _k, PIP)


## Ficha de la pista: solo el contorno, discontinuo y suave.
func _ficha_borrador(f: Array, j: int) -> void:
	var c := a_pantalla(f[j])
	var forma := _rect_redondo(c, _direccion(f, j), FICHA_ANCHO * _k, FICHA_ALTO * _k, 0.9 * _k)
	var borde := _cerrar(forma)
	for k in range(0, borde.size() - 1, 2):
		draw_line(borde[k], borde[k + 1], Color(TINTA, 0.45), maxf(1.0, 0.45 * _k), true)


## Empujador verde con el triángulo de «empezar», sobre una sombra de tinta (maqueta).
func _empujador(p: Array) -> void:
	var c := a_pantalla(p)
	var r := EMPUJADOR * _k
	if modo == Modo.EDITAR and partida.tramos.is_empty():
		var pulso := 1.0 if reducir_movimiento else 0.5 + 0.5 * sin(Time.get_ticks_msec() / 260.0)
		draw_circle(c, r + (1.2 + pulso * 1.6) * _k, Color(INICIO, 0.2 + 0.2 * pulso))
		if not reducir_movimiento:
			queue_redraw()   # el pulso invita a empezar por aquí
	var contorno := BORDE_FICHA if BORDE_FICHA.a >= 0.5 else Color(0, 0, 0, 0)
	draw_circle(c + Vector2(0, 1.07 * _k), r * 17.0 / 16.0, contorno if contorno.a > 0 else Color(0, 0, 0, 0.3))
	draw_circle(c, r, INICIO)
	if contorno.a > 0:
		draw_arc(c, r, 0, TAU, 40, contorno, maxf(1.5, 0.78 * _k), true)
	var e := _k / 2.8
	draw_colored_polygon(PackedVector2Array([c + Vector2(-5, -7) * e, c + Vector2(8, 0) * e, c + Vector2(-5, 7) * e]), INICIO_ICO)


func _marca_cuenta(f: Array, j: int, numero: int) -> void:
	var eje := _direccion(f, j)
	var n := Vector2(-eje.y, eje.x)
	var c := a_pantalla(f[j]) + n * (FICHA_ALTO / 2 + MARCA_RADIO + 0.4) * _k
	draw_circle(c, MARCA_RADIO * _k, CIFRA)
	var fuente := get_theme_default_font()
	var tam := int(3.2 * _k)
	var texto := str(numero)
	var medida := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam)
	draw_string(fuente, c + Vector2(-medida.x / 2, fuente.get_ascent(tam) / 2 - 0.15 * _k), texto,
		HORIZONTAL_ALIGNMENT_LEFT, -1, tam, CIFRA_T)


func _campana(c: Array) -> void:
	var centro := a_pantalla(c[1])
	var id: String = c[0]
	var sono = resultado().get("campanas", {}).get(id) if modo != Modo.EDITAR else null
	var suena: bool = sono != null and _tic_actual() >= int(sono)
	var giro := 0.0             # balanceo de la campana al sonar (radianes)
	if suena:
		var t := _tiempo - int(sono) * DURACION_TIC
		var halo := 0.6 if reducir_movimiento else clampf(1.0 - t / 0.8, 0.0, 1.0)
		draw_circle(centro, (Sim.RADIO_CAMPANA + 2.0 + 3.0 * (1.0 - halo)) * _k, Color(CAYENDO, 0.35 + 0.4 * halo))
		if not reducir_movimiento:
			giro = sin(t * 18.0) * 0.4 * exp(-t * 3.0)
			_destellos(centro, t, DORADA if c[2] == "dorada" else CAYENDO)
	draw_arc(centro, Sim.RADIO_CAMPANA * _k, 0, TAU, 40, Color(CAMPANA, 0.4), maxf(1.0, 0.25 * _k), true)
	var tipo: String = c[2]
	var lado := 9.0 * _k
	var cajas := [Rect2(centro - Vector2(lado, lado) / 2, Vector2(lado, lado))]
	if tipo == "doble":
		lado = 7.6 * _k
		cajas = [Rect2(centro - Vector2(lado * 0.82, lado / 2), Vector2(lado, lado)),
			Rect2(centro - Vector2(lado * 0.18, lado / 2), Vector2(lado, lado))]
	if tipo == "dorada":
		# La dorada brilla con suavidad para que se vea que es especial (y opcional)
		var brillo := 0.5 if reducir_movimiento else 0.5 + 0.5 * sin(Time.get_ticks_msec() / 420.0)
		draw_circle(centro, (Sim.RADIO_CAMPANA + 0.6 + brillo) * _k, Color(DORADA, 0.18 + 0.12 * brillo))
		if modo == Modo.EDITAR and not reducir_movimiento:
			queue_redraw()
	for k in cajas.size():
		var r: Rect2 = cajas[k]
		# En la doble, las dos campanas se balancean una hacia la otra
		var a := giro * (1.0 if k == 0 else -1.0)
		var pivote := r.position + Vector2(r.size.x / 2, r.size.y * 0.15)
		draw_set_transform(pivote, a, Vector2.ONE)
		Iconos.dibujar(self, "campana", Rect2(r.position - pivote, r.size), DORADA if tipo == "dorada" else CAMPANA)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if tipo == "dorada":
		# Una estrella pequeña: se distingue por la forma, no solo por el color
		var lado_e := 4.0 * _k
		Iconos.dibujar(self, "estrella", Rect2(centro + Vector2(1.6, -5.4) * _k, Vector2(lado_e, lado_e)), DORADA)
	if tipo == "numerada":
		# El número va dentro de la campana, con la tinta que mejor se lea sobre ella
		var fuente := get_theme_default_font()
		var tam := int(3.4 * _k)
		var texto := str(int(c[3]))
		var medida := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam)
		var base := centro + Vector2(-medida.x / 2, fuente.get_ascent(tam) / 2 - 0.6 * _k)
		var letra := Temas.sobre(CAMPANA, Color("#142554"), BLANCO)
		draw_string_outline(fuente, base, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, maxi(2, int(0.5 * _k)), CAMPANA)
		draw_string(fuente, base, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, letra)


## Destellos al sonar una campana: ocho chispas que salen hacia fuera y se apagan en 0,7 s.
func _destellos(centro: Vector2, t: float, color: Color) -> void:
	if t >= 0.7:
		return
	var u := t / 0.7
	var ida := 1.0 - pow(1.0 - u, 3.0)
	for k in 8:
		var a := TAU * k / 8.0 + 0.3
		var d := (Sim.RADIO_CAMPANA + 1.5 + 7.0 * ida) * _k
		var p := centro + Vector2(cos(a), sin(a)) * d
		var tam := (0.9 - 0.6 * u) * _k
		var c := Color(color, 1.0 - u)
		draw_line(p - Vector2(tam, 0), p + Vector2(tam, 0), c, maxf(1.0, 0.35 * _k), true)
		draw_line(p - Vector2(0, tam), p + Vector2(0, tam), c, maxf(1.0, 0.35 * _k), true)


## Pequeña insignia con forma (✓, ✗ o !) para que la información no dependa solo del color.
func _simbolo(c: Vector2, cual: String) -> void:
	var r := 1.7 * _k
	var fondo := VERDE if cual == "si" else CORAL
	draw_circle(c, r, fondo)
	draw_arc(c, r, 0, TAU, 20, TINTA_SEM, maxf(1.0, 0.3 * _k), true)
	var g := maxf(1.5, 0.45 * _k)
	match cual:
		"si":
			draw_polyline(PackedVector2Array([c + Vector2(-0.8, 0.0) * _k, c + Vector2(-0.2, 0.7) * _k, c + Vector2(0.9, -0.7) * _k]), BLANCO, g, true)
		"no":
			draw_line(c + Vector2(-0.7, -0.7) * _k, c + Vector2(0.7, 0.7) * _k, BLANCO, g, true)
			draw_line(c + Vector2(-0.7, 0.7) * _k, c + Vector2(0.7, -0.7) * _k, BLANCO, g, true)
		_:
			draw_line(c + Vector2(0, -0.9) * _k, c + Vector2(0, 0.25) * _k, BLANCO, g, true)
			draw_circle(c + Vector2(0, 0.8) * _k, g * 0.55, BLANCO)


## Tamaño de letra de los carteles del tablero: crece con el tablero, pero nunca baja de 19 px
## (en tableros grandes, con muchas piezas, se leía con dificultad).
func _tam_etiqueta(unidades: float) -> int:
	return maxi(int(unidades * _k), Temas.tam(19))


## Puerta de vaivén: cerrada es una barra de madera entre dos postes; abierta, sus dos hojas giran
## hacia los lados. Mientras se dibuja, se abre y se cierra a su ritmo en tiempo real (un tic cada
## DURACION_TIC); durante la caída sigue el tic de la cadena. Encima, cuándo se abre.
func _puerta(p: Array) -> void:
	var a := a_pantalla(p[0])
	var b := a_pantalla(p[1])
	var tic := _tic_actual()
	if modo == Modo.EDITAR:
		tic = int(Time.get_ticks_msec() / (DURACION_TIC * 1000.0))
		queue_redraw()                       # la puerta se mueve sola mientras se planifica
	var abierta: bool = Sim.puerta_abierta(p, tic)
	var eje := (b - a).normalized()
	var normal := Vector2(-eje.y, eje.x)
	var largo := a.distance_to(b)
	if abierta:
		# Dos hojas abiertas hacia el lado de la cadena, en tono suave
		for extremo in [[a, eje], [b, -eje]]:
			var desde: Vector2 = extremo[0]
			var hacia: Vector2 = (extremo[1] * 0.35 + normal).normalized()
			draw_line(desde, desde + hacia * largo * 0.42, Color(PUERTA, 0.7), 1.6 * _k, true)
	else:
		draw_line(a, b, PUERTA, 1.8 * _k, true)
		draw_line(a, b, TINTA, 0.35 * _k, true)
	for poste in [a, b]:
		draw_circle(poste, 1.3 * _k, TINTA)
	# Cuándo se abre: las tres primeras ventanas, en tics (las marcas de cuenta usan la misma escala)
	var periodo := int(p[2])
	var dura := int(p[3])
	var inicio := posmod(int(p[4]), periodo)
	var ventanas := []
	for k in 3:
		var t0 := inicio + k * periodo
		ventanas.append("%d–%d" % [t0, t0 + dura - 1])
	var fuente := get_theme_default_font()
	var tam := _tam_etiqueta(3.0)
	# Al lado del hueco (no encima: por ahí pasa la cadena y va la marca de cruce), hacia el lado con
	# más sitio. Si en una línea no cabe, un letrero en columna: «abre» y debajo cada ventana.
	var izquierda := a if a.x < b.x else b
	var derecha := b if a.x < b.x else a
	var tablero_der := _origen.x + float(partida.nivel["w"]) * _k
	var hueco_der := tablero_der - derecha.x
	var hueco_izq := izquierda.x - _origen.x
	var sitio := maxf(hueco_der, hueco_izq) - 2.6 * _k
	var lineas := ["abre " + " · ".join(ventanas)]
	if fuente.get_string_size(lineas[0], HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x > sitio:
		lineas = ["abre"] + ventanas
	var ancho := 0.0
	for l in lineas:
		ancho = maxf(ancho, fuente.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x)
	var alto_linea := fuente.get_height(tam)
	var x := derecha.x + 1.6 * _k if hueco_der >= hueco_izq else izquierda.x - 1.6 * _k - ancho
	x = clampf(x, _origen.x + 1.0 * _k, tablero_der - ancho - 1.0 * _k)
	var abajo := minf(a.y, b.y) - 1.6 * _k                  # el letrero se apoya encima de la puerta
	var caja := Rect2(Vector2(x - 0.8 * _k, abajo - alto_linea * lineas.size() - 0.6 * _k),
		Vector2(ancho + 1.6 * _k, alto_linea * lineas.size() + 0.6 * _k))
	caja.position.y = maxf(caja.position.y, _origen.y + 1.0 * _k)
	draw_style_box(_caja(Color(ETIQUETA, 0.95), 6, ETIQUETA_T, 1), caja)
	var verde := Temas.sobre(ETIQUETA, VERDE.darkened(0.45), VERDE)
	var color := verde if abierta else ETIQUETA_T
	for k in lineas.size():
		var base := Vector2(x, caja.position.y + 0.3 * _k + alto_linea * k + fuente.get_ascent(tam))
		# En columna, las cifras van centradas bajo «abre»
		var w := fuente.get_string_size(lineas[k], HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
		draw_string(fuente, base + Vector2((ancho - w) / 2.0, 0), lineas[k], HORIZONTAL_ALIGNMENT_LEFT, -1, tam, color)


## Espiral de retardo: una espiral dentro de su círculo y, al lado, cuántos tics retrasa («+4»).
func _espiral(e: Array) -> void:
	var c := a_pantalla(e[0])
	var r := Sim.RADIO_ESPIRAL * _k
	draw_circle(c, r, Color(DORADA, 0.22))
	var puntos := PackedVector2Array()
	for k in 49:
		var a := k * 0.42
		puntos.append(c + Vector2(cos(a), sin(a)) * r * 0.85 * k / 48.0)
	draw_polyline(puntos, TINTA, maxf(1.2, 0.4 * _k), true)


func _espiral_etiqueta(e: Array) -> void:
	var c := a_pantalla(e[0])
	var r := Sim.RADIO_ESPIRAL * _k
	draw_arc(c, r, 0, TAU, 32, Color(DORADA, 0.9), maxf(1.5, 0.45 * _k), true)
	var fuente := get_theme_default_font()
	var tam := _tam_etiqueta(3.6)
	var texto := "+%d" % int(e[1])
	var medida := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam)
	var base := c + Vector2(-medida.x / 2, -r - 1.0 * _k)     # encima del aro, centrado
	var caja := Rect2(base - Vector2(0.6 * _k, fuente.get_ascent(tam) + 0.2 * _k), Vector2(medida.x + 1.2 * _k, tam + 0.4 * _k))
	draw_style_box(_caja(Color(ETIQUETA, 0.94), 6, ETIQUETA_T, 1), caja)
	draw_string(fuente, base, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, ETIQUETA_T)


## Muelle: la entrada es un muelle en zigzag dentro de su círculo; la salida, un anillo donde se
## empieza a dibujar; entre las dos, un arco discontinuo (el salto por encima de lo que haya).
func _muelle(m: Array) -> void:
	var a := a_pantalla(m[0])
	var b := a_pantalla(m[1])
	var r := Sim.RADIO_MUELLE * _k
	var es_noria := m.size() == 4
	var fondo := Color(PUERTA, 0.25) if es_noria else Color(VERDE, 0.22)
	draw_circle(a, r, fondo)
	draw_circle(b, r, fondo)
	if es_noria:
		# Noria: una rueda con cuatro cangilones que da una vuelta cada `periodo` tics
		var giro := 0.0 if reducir_movimiento else TAU * fposmod(Time.get_ticks_msec() / 1000.0 / (int(m[2]) * DURACION_TIC), 1.0)
		draw_arc(a, r * 0.75, 0, TAU, 28, TINTA, maxf(1.2, 0.4 * _k), true)
		for k in 4:
			var ang := giro + TAU * k / 4.0
			var punta := a + Vector2(cos(ang), sin(ang)) * r * 0.75
			draw_line(a, punta, TINTA, maxf(1.0, 0.3 * _k), true)
			draw_circle(punta, 0.6 * _k, PUERTA)
		draw_circle(a, 0.5 * _k, TINTA)
	else:
		var zig := PackedVector2Array()
		for k in 7:
			zig.append(a + Vector2((-1.0 if k % 2 == 0 else 1.0) * r * 0.55, -r * 0.7 + k * r * 1.4 / 6.0))
		draw_polyline(zig, TINTA, maxf(1.2, 0.45 * _k), true)
	# Arco del salto: una parábola entre la entrada y la salida
	var medio := (a + b) / 2.0
	var altura := maxf(a.distance_to(b) * 0.35, 4.0 * _k)
	var normal := (b - a).orthogonal().normalized()
	if normal.y > 0:
		normal = -normal
	var anterior := a
	for k in range(1, 21):
		var u := k / 20.0
		var q := a.lerp(b, u) + normal * altura * 4.0 * u * (1.0 - u)
		if k % 2 == 1:
			draw_line(anterior, q, Color(TINTA, 0.6), maxf(1.0, 0.3 * _k), true)
		anterior = q


func _muelle_etiqueta(m: Array) -> void:
	var a := a_pantalla(m[0])
	var b := a_pantalla(m[1])
	var r := Sim.RADIO_MUELLE * _k
	var es_noria := m.size() == 4
	var aro := PUERTA.darkened(0.2) if es_noria else VERDE.darkened(0.3)
	draw_arc(a, r, 0, TAU, 32, Color(aro, 0.95), maxf(1.5, 0.45 * _k), true)
	draw_arc(b, r, 0, TAU, 32, Color(aro, 0.95), maxf(1.5, 0.45 * _k), true)
	draw_circle(b, r * 0.3, aro)
	var fuente := get_theme_default_font()
	var tam := _tam_etiqueta(3.6)
	var texto := ("cada %d" % int(m[2])) if es_noria else ("+%d" % int(m[2]))
	var medida := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam)
	var normal := (b - a).orthogonal().normalized()
	if normal.y > 0:
		normal = -normal
	var cima := (a + b) / 2.0 + normal * maxf(a.distance_to(b) * 0.35, 4.0 * _k)
	var base := cima + Vector2(-medida.x / 2, -0.8 * _k)
	var caja := Rect2(base - Vector2(0.6 * _k, fuente.get_ascent(tam) + 0.2 * _k), Vector2(medida.x + 1.2 * _k, tam + 0.4 * _k))
	draw_style_box(_caja(Color(ETIQUETA, 0.94), 6, ETIQUETA_T, 1), caja)
	draw_string(fuente, base, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, ETIQUETA_T)


## Cristal: una barra azul clara y translúcida con dos brillos. Cuando algo choca con él (en la caída)
## salta en pedazos y solo quedan sus dos marcos.
func _cristal(c: Array, k: int) -> void:
	var a := a_pantalla(c[0])
	var b := a_pantalla(c[1])
	var roto := -1
	if modo != Modo.EDITAR:
		var disparos: Array = _detalle.get("interruptores", [])
		var indice: int = partida.nivel.get("in", []).size() + k
		if indice < disparos.size():
			roto = int(disparos[indice])
	var azul := Color("#8fd3ff")
	for poste in [a, b]:
		draw_circle(poste, 1.2 * _k, TINTA)
	if roto >= 0 and _tic_actual() > roto:
		var t := _tiempo - (roto + 1) * DURACION_TIC
		if t < 0.6 and not reducir_movimiento:
			var u := t / 0.6
			var eje := (b - a).normalized()
			var normal := Vector2(-eje.y, eje.x)
			for s in 10:
				var base := a.lerp(b, (s + 0.5) / 10.0)
				var lado := 1.0 if s % 2 == 0 else -1.0
				var p := base + normal * lado * (1.5 + 5.0 * u) * _k + eje * (s % 3 - 1) * 1.5 * u * _k
				var trozo := PackedVector2Array([p + Vector2(-0.8, -0.5) * _k, p + Vector2(0.9, -0.2) * _k, p + Vector2(0.1, 0.9) * _k])
				draw_colored_polygon(trozo, Color(azul, 1.0 - u))
		return
	draw_line(a, b, Color(azul, 0.75), 1.6 * _k, true)
	draw_line(a, b, Color(TINTA, 0.55), maxf(1.0, 0.25 * _k), true)
	var eje2 := (b - a)
	for f in [0.25, 0.6]:
		var p: Vector2 = a + eje2 * f
		var d := eje2.normalized() * 1.6 * _k
		draw_line(p - d * 0.5 + Vector2(0, -0.5 * _k), p + d * 0.5 + Vector2(0, 0.5 * _k), Color(1, 1, 1, 0.9), maxf(1.0, 0.3 * _k), true)


## Interruptor: una placa redonda con un botón y, unida por una línea de puntos, su compuerta: una
## barra a rayas mientras está cerrada; abierta, solo quedan sus dos postes.
func _interruptor(it: Array, k: int) -> void:
	var placa := a_pantalla(it[0])
	var a := a_pantalla(it[1])
	var b := a_pantalla(it[2])
	var disparos: Array = _detalle.get("interruptores", [])
	var pisada: int = int(disparos[k]) if modo != Modo.EDITAR and k < disparos.size() else -1
	var abierta := pisada >= 0 and _tic_actual() > pisada
	var pulsada := pisada >= 0 and _tic_actual() >= pisada
	# Línea de puntos de la placa al centro de la compuerta
	var medio := (a + b) / 2.0
	var pasos := int(placa.distance_to(medio) / (2.2 * _k))
	for s in range(1, pasos):
		if s % 2 == 0:
			draw_circle(placa.lerp(medio, float(s) / pasos), 0.35 * _k, Color(TINTA, 0.45))
	var r := Sim.RADIO_INTERRUPTOR * _k
	draw_circle(placa, r, Color(CAYENDO, 0.35))
	draw_arc(placa, r, 0, TAU, 32, TINTA, maxf(1.2, 0.35 * _k), true)
	draw_circle(placa, r * (0.35 if pulsada else 0.55), TINTA if pulsada else CAYENDO.darkened(0.25))
	if abierta:
		for poste in [a, b]:
			draw_circle(poste, 1.3 * _k, TINTA)
		draw_line(a, b, Color(TINTA, 0.25), 0.4 * _k, true)
		return
	draw_line(a, b, CAYENDO.darkened(0.1), 1.8 * _k, true)
	var largo := a.distance_to(b)
	var eje := (b - a) / maxf(largo, 0.001)
	var raya := 2.4 * _k
	var d := 0.0
	while d < largo:
		draw_line(a + eje * d, a + eje * minf(d + raya * 0.5, largo), TINTA, 1.8 * _k, true)
		d += raya
	for poste in [a, b]:
		draw_circle(poste, 1.3 * _k, TINTA)


## Globo: un globo rosa con su brillo y su cuerda, atado al principio de su camino. Al reventar
## (durante la caída), unos trocitos salen volando y desaparece.
func _globo(g: Array, k: int) -> void:
	var c := a_pantalla(g[0])
	var reventon := -1
	if modo != Modo.EDITAR:
		var tics_todas: Array = _detalle.get("tics", [])
		var indice: int = partida.tramos.size() + k
		var caidas: Array = _detalle.get("caidas", [])
		if indice < tics_todas.size() and indice < caidas.size() and int(caidas[indice]) >= 0:
			reventon = int(tics_todas[indice][0]) - 1
	var color := Color("#ff7eb6")
	if reventon >= 0 and _tic_actual() > reventon:
		var t := _tiempo - (reventon + 1) * DURACION_TIC
		if t < 0.5 and not reducir_movimiento:
			var u := t / 0.5
			for s in 8:
				var a := TAU * s / 8.0 + 0.2
				var p := c + Vector2(0, -3.0 * _k) + Vector2(cos(a), sin(a)) * (2.0 + 6.0 * u) * _k
				draw_circle(p, (0.8 - 0.5 * u) * _k, Color(color, 1.0 - u))
		return
	var centro := c + Vector2(0, -4.2 * _k)
	var r := 3.2 * _k
	draw_line(c, centro + Vector2(0, r), Color(TINTA, 0.7), maxf(1.0, 0.25 * _k), true)
	draw_circle(centro, r, color)
	draw_arc(centro, r, 0, TAU, 28, TINTA, maxf(1.0, 0.3 * _k), true)
	draw_circle(centro + Vector2(-1.0, -1.1) * _k, 0.8 * _k, Color(1, 1, 1, 0.6))
	draw_colored_polygon(PackedVector2Array([centro + Vector2(-0.7, r / _k) * _k, centro + Vector2(0.7, r / _k) * _k,
		centro + Vector2(0, r / _k + 1.0) * _k]), color)


## El dedo de la guía: aparece en el botón verde, arrastra hasta la campana dejando un rastro y vuelve
## a empezar. Con «reducir movimiento», una flecha quieta del botón a la campana.
func _guia(desde: Array, hasta: Array) -> void:
	var a := a_pantalla(desde)
	var b := a_pantalla(hasta)
	var color := Color(TINTA, 0.55)
	if reducir_movimiento:
		var eje := (b - a).normalized()
		var largo := a.distance_to(b)
		var d := 6.0 * _k
		while d < largo - 8.0 * _k:
			draw_line(a + eje * d, a + eje * minf(d + 2.0 * _k, largo), color, 0.8 * _k, true)
			d += 4.0 * _k
		var punta := b - eje * 7.0 * _k
		var n := Vector2(-eje.y, eje.x)
		draw_colored_polygon(PackedVector2Array([punta + eje * 2.5 * _k, punta - eje * 1.5 * _k + n * 2.0 * _k,
			punta - eje * 1.5 * _k - n * 2.0 * _k]), color)
		return
	var t := fposmod(Time.get_ticks_msec() / 1000.0, 2.4) / 2.4
	var u := clampf((t - 0.12) / 0.7, 0.0, 1.0)
	u = u * u * (3.0 - 2.0 * u)
	var p := a.lerp(b, u)
	for k in 8:
		var q := a.lerp(b, maxf(u - 0.04 * k, 0.0))
		if u > 0.0:
			draw_circle(q, (1.9 - 0.15 * k) * _k, Color(TINTA, 0.25 - 0.03 * k))
	var alfa := 1.0 - clampf((t - 0.85) / 0.15, 0.0, 1.0)
	draw_circle(p + Vector2(0.5, 0.8) * _k, 4.6 * _k, Color(0, 0, 0, 0.15 * alfa))
	draw_circle(p, 4.6 * _k, Color(1, 1, 1, 0.9 * alfa))
	draw_arc(p, 4.6 * _k, 0, TAU, 28, Color(TINTA, alfa), maxf(1.2, 0.4 * _k), true)
	draw_circle(p, 1.7 * _k, Color(TINTA, 0.5 * alfa))
	queue_redraw()


## Marco del tablero como en la maqueta (.tablero y su lienzo): el color del tablero, el borde, el radio y
## la sombra del tema (viñeta del tapete en Mesa, sombra suave en Calma, sombra dura en Brutalista) y la
## rejilla de puntos (cada 24 px de la maqueta, de 1,4 px de radio). Lo usa también el editor del Taller.
static func dibujar_marco(ci: CanvasItem, rect: Rect2, hielo: Color, punto: Color, contraste: bool, zoom := 1.0) -> void:
	var c := Temas.caja("tablero")
	# Un tablero translúcido (Calma) se compone sobre la pantalla: así su sombra no se ve por debajo
	var pantalla := Temas.ui("pantalla")
	c["fondo"] = Color(Color(pantalla, 1.0).lerp(Color(hielo, 1.0), hielo.a), 1.0) if hielo.a < 1.0 else hielo
	if contraste:
		c["borde"] = 2.0
		c["borde_color"] = Color.BLACK
		c["sombras"] = []
	Caja.dibujar(ci, rect, c)
	var paso := 24.0 * Temas.ESCALA * zoom
	var y := rect.position.y + paso / 2
	while y < rect.end.y - 4.0:      # sin pisar el borde del tablero
		var x := rect.position.x + paso / 2
		while x < rect.end.x - 4.0:
			ci.draw_circle(Vector2(x, y), 1.4 * Temas.ESCALA * zoom, punto)
			x += paso
		y += paso


## Posición en pantalla (global) de la X donde se paró la cadena, o null si no se paró.
func posicion_parada():
	var parada = resultado().get("parada")
	if parada == null or parada.get("tramo") == null:
		return null
	var todas: Array = _detalle.get("fichas", [])
	var i := int(parada["tramo"])
	var j := int(parada["ficha"])
	if i >= todas.size() or j >= todas[i].size():
		return null
	_medir()
	return get_global_transform() * a_pantalla(todas[i][j])


## Marca dónde se paró la cadena, si se paró.
func _parada() -> void:
	var r := resultado()
	var parada = r.get("parada")
	if parada == null or parada.get("tramo") == null:
		return
	if r.get("exito", false) and parada.get("motivo") == "rompe el cristal":
		return       # romper el cristal era parte de la solución: no es un fallo que marcar
	var i := int(parada["tramo"])
	var j := int(parada["ficha"])
	var todas: Array = _detalle.get("fichas", [])
	if i >= todas.size() or j >= todas[i].size():
		return
	var c := a_pantalla(todas[i][j])
	var lado := 2.4 * _k
	draw_circle(c, 4.4 * _k, Color(HIELO, 0.85))
	draw_line(c + Vector2(-lado, -lado), c + Vector2(lado, lado), CORAL, 0.9 * _k, true)
	draw_line(c + Vector2(-lado, lado), c + Vector2(lado, -lado), CORAL, 0.9 * _k, true)
	draw_arc(c, 4.4 * _k, 0, TAU, 32, CORAL, 0.5 * _k, true)
