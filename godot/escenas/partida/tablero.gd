## Tablero de juego: dibuja el nivel, recoge el dedo y anima la caída.
##
## Todo se calcula en unidades lógicas (partida.gd y simulacion.gd); aquí solo se convierten a
## píxeles para dibujar. Colores y medidas de Dominó Pop (DESIGN.md y docs/fase6/tablero/index.html).
extends Control

signal cambio                 # el dibujo ha cambiado (fichas usadas, botones)
signal caida_terminada        # ha terminado la animación de la caída
signal cae(cuantas: int)      # en este tic caen `cuantas` fichas (para el sonido)
signal suena(campana: Array)  # una campana acaba de sonar: [id, pos, tipo, numero]

const Sim = preload("res://nucleo/simulacion.gd")
const Iconos = preload("res://escenas/comun/iconos.gd")

const DURACION_TIC := 0.075   # segundos que tarda en caer cada ficha
const PAUSA_FINAL := 0.5

# Paleta Dominó Pop (DESIGN.md)
const HIELO := Color("#eaf3ff")
const PUNTO := Color("#cfe0ff")
const TINTA := Color("#142554")
const MARFIL := Color("#fffdf6")
const CAYENDO := Color("#ffc83d")
const CAIDA := Color("#c9d6f2")
const CORAL := Color("#ff5470")
const VERDE := Color("#3ddc6b")
const BLANCO := Color.WHITE

# Medidas de la maqueta, en unidades lógicas (allí 1 unidad = 2,8 px)
const FICHA_ANCHO := 2.5      # de pie: grosor a lo largo del camino
const FICHA_ALTO := 5.7       # de pie: de lado a lado del camino
const TRAZO := 0.72
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


func preparar(nueva_partida) -> void:
	partida = nueva_partida
	modo = Modo.EDITAR
	pista = []
	_detalle = {}
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
	if modo == Modo.CAYENDO and _tic_actual() > _ultimo_tic + 1 and _tiempo > (_ultimo_tic + 1) * DURACION_TIC + PAUSA_FINAL:
		modo = Modo.RESULTADO
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
	draw_style_box(_caja(HIELO, 18, TINTA, 2), tablero)
	var paso := 24.0
	var y := tablero.position.y + paso / 2
	while y < tablero.end.y:
		var x := tablero.position.x + paso / 2
		while x < tablero.end.x:
			draw_circle(Vector2(x, y), 1.6, PUNTO)
			x += paso
		y += paso

	for m in nivel["mu"]:
		draw_line(a_pantalla(m[0]), a_pantalla(m[1]), TINTA, 2.2 * _k, true)
		draw_circle(a_pantalla(m[0]), 1.1 * _k, TINTA)
		draw_circle(a_pantalla(m[1]), 1.1 * _k, TINTA)
	for p in nivel["p"]:
		_puerta(p)

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
			if modo != Modo.EDITAR and not _detalle.get("caidas", []).is_empty():
				var t: int = _detalle["tics"][i][j]
				if j <= _detalle["caidas"][i]:
					if t < tic:
						estado = 2
					elif t == tic:
						estado = 1
			_ficha(f, j, estado, avance)

	_empujador(nivel["i"])
	# Las campanas van encima de las fichas para que siempre se vean
	for c in nivel["c"]:
		_campana(c)

	if modo == Modo.EDITAR:
		var tics := _tics_de(todas)
		for i in todas.size():
			for j in range(1, todas[i].size()):
				if tics[i][j] > 0 and tics[i][j] % 4 == 0:
					_marca_cuenta(todas[i], j, tics[i][j])
		for p in partida.curvas_cerradas():
			draw_arc(a_pantalla(p), 3.4 * _k, 0, TAU, 28, CORAL, 0.6 * _k, true)
	if modo == Modo.RESULTADO:
		_parada()


## Tic en que cae cada ficha, igual que en la simulación: así la cuenta que se ve al dibujar es el
## orden real de caída, y las dos ramas de una campana doble muestran el mismo número al llegar.
func _tics_de(todas: Array) -> Array:
	var r := []
	for i in todas.size():
		var base := -1
		if i < partida.tramos.size() and partida.tramos[i]["padre"] != null:
			var padre := int(partida.tramos[i]["padre"])
			var desde := int(partida.tramos[i]["desde"])
			if padre < r.size() and desde < r[padre].size():
				base = r[padre][desde]
		var t := []
		for j in todas[i].size():
			t.append(base + 1 + j)
		r.append(t)
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


func _ficha(f: Array, j: int, estado: int, avance: float) -> void:
	var c := a_pantalla(f[j])
	var eje := _direccion(f, j)
	var n := Vector2(-eje.y, eje.x)
	var radio := 0.9 * _k
	var forma: PackedVector2Array
	var color := MARFIL
	var alto := FICHA_ALTO
	match estado:
		1:   # cayendo: se acorta mientras cae, como en la maqueta
			alto = FICHA_ALTO * (1.0 - avance * 0.55)
			color = CAYENDO
			forma = _rect_redondo(c, eje, FICHA_ANCHO * _k, alto * _k, radio)
		2:   # tumbada: ahora es larga a lo largo del camino
			color = CAIDA
			forma = _rect_redondo(c + eje * 1.4 * _k, eje, FICHA_ALTO * _k, FICHA_ANCHO * 0.9 * _k, radio)
		_:
			forma = _rect_redondo(c, eje, FICHA_ANCHO * _k, alto * _k, radio)
	draw_colored_polygon(forma, color)
	draw_polyline(_cerrar(forma), TINTA, maxf(1.0, TRAZO * _k), true)
	if estado != 2:
		draw_circle(c + n * alto * 0.22 * _k, 0.5 * _k, TINTA)
		draw_circle(c - n * alto * 0.22 * _k, 0.5 * _k, TINTA)


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
		var pulso := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 260.0)
		draw_circle(c, r + (1.2 + pulso * 1.6) * _k, Color(BLANCO, 0.35 + 0.25 * pulso))
		queue_redraw()   # el pulso invita a empezar por aquí
	draw_circle(c + Vector2(0, 1.07 * _k), r * 17.0 / 16.0, TINTA)
	draw_circle(c, r, VERDE)
	draw_arc(c, r, 0, TAU, 40, TINTA, maxf(1.5, 0.78 * _k), true)
	var e := _k / 2.8
	draw_colored_polygon(PackedVector2Array([c + Vector2(-5, -7) * e, c + Vector2(8, 0) * e, c + Vector2(-5, 7) * e]), BLANCO)


func _marca_cuenta(f: Array, j: int, numero: int) -> void:
	var eje := _direccion(f, j)
	var n := Vector2(-eje.y, eje.x)
	var c := a_pantalla(f[j]) + n * (FICHA_ALTO / 2 + MARCA_RADIO + 0.4) * _k
	draw_circle(c, MARCA_RADIO * _k, TINTA)
	var fuente := get_theme_default_font()
	var tam := int(3.2 * _k)
	var texto := str(numero)
	var medida := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam)
	draw_string(fuente, c + Vector2(-medida.x / 2, fuente.get_ascent(tam) / 2 - 0.15 * _k), texto,
		HORIZONTAL_ALIGNMENT_LEFT, -1, tam, BLANCO)


func _campana(c: Array) -> void:
	var centro := a_pantalla(c[1])
	var id: String = c[0]
	var sono = resultado().get("campanas", {}).get(id) if modo != Modo.EDITAR else null
	var suena: bool = sono != null and _tic_actual() >= int(sono)
	if suena:
		var t := _tiempo - int(sono) * DURACION_TIC
		var halo := clampf(1.0 - t / 0.8, 0.0, 1.0)
		draw_circle(centro, (Sim.RADIO_CAMPANA + 2.0 + 3.0 * (1.0 - halo)) * _k, Color(CAYENDO, 0.35 + 0.4 * halo))
	draw_arc(centro, Sim.RADIO_CAMPANA * _k, 0, TAU, 40, Color(CORAL, 0.4), maxf(1.0, 0.25 * _k), true)
	var tipo: String = c[2]
	var lado := 9.0 * _k
	var cajas := [Rect2(centro - Vector2(lado, lado) / 2, Vector2(lado, lado))]
	if tipo == "doble":
		lado = 7.6 * _k
		cajas = [Rect2(centro - Vector2(lado * 0.82, lado / 2), Vector2(lado, lado)),
			Rect2(centro - Vector2(lado * 0.18, lado / 2), Vector2(lado, lado))]
	for r in cajas:
		Iconos.dibujar(self, "campana", r, CORAL)
	if tipo == "numerada":
		# El número va dentro de la campana, en blanco, para que ninguna ficha lo tape
		var fuente := get_theme_default_font()
		var tam := int(3.4 * _k)
		var texto := str(int(c[3]))
		var medida := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam)
		var base := centro + Vector2(-medida.x / 2, fuente.get_ascent(tam) / 2 - 0.6 * _k)
		draw_string_outline(fuente, base, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, maxi(2, int(0.5 * _k)), TINTA)
		draw_string(fuente, base, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, BLANCO)


func _puerta(p: Array) -> void:
	var a := a_pantalla(p[0])
	var b := a_pantalla(p[1])
	draw_dashed_line(a, b, TINTA, 1.4 * _k, 2.0 * _k, true)


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
	var i := int(parada["tramo"])
	var j := int(parada["ficha"])
	var todas: Array = _detalle.get("fichas", [])
	if i >= todas.size() or j >= todas[i].size():
		return
	var c := a_pantalla(todas[i][j])
	var lado := 2.4 * _k
	draw_circle(c, 4.4 * _k, Color(BLANCO, 0.8))
	draw_line(c + Vector2(-lado, -lado), c + Vector2(lado, lado), CORAL, 0.9 * _k, true)
	draw_line(c + Vector2(-lado, lado), c + Vector2(lado, -lado), CORAL, 0.9 * _k, true)
	draw_arc(c, 4.4 * _k, 0, TAU, 32, CORAL, 0.5 * _k, true)
