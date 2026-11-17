## Tablero de juego: dibuja el nivel, recoge el dedo y anima la caída.
##
## Todo se calcula en unidades lógicas (partida.gd y simulacion.gd); aquí solo se convierten a
## píxeles para dibujar. Los colores son los de Dominó Pop (DESIGN.md).
extends Control

signal cambio                 # el dibujo ha cambiado (fichas usadas, botones)
signal caida_terminada        # ha terminado la animación de la caída
signal cae(cuantas: int)      # en este tic caen `cuantas` fichas (para el sonido)
signal suena(campana: Array)  # una campana acaba de sonar: [id, pos, tipo, numero]

const Sim = preload("res://nucleo/simulacion.gd")

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

enum Modo { EDITAR, CAYENDO, RESULTADO }

var partida = null            # nucleo/partida.gd
var modo := Modo.EDITAR
var pista: Array = []         # puntos del tramo de la pista (fantasma), o vacío
var velocidad := 1.0           # 0,5 = cámara lenta
var _detalle := {}
var _eventos := {}             # tic -> {"fichas": n, "campanas": [...]}
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
	for i in _detalle["tics"].size():
		var caidas: Array = _detalle["caidas"]
		if i < caidas.size() and caidas[i] >= 0:
			_ultimo_tic = maxi(_ultimo_tic, _detalle["tics"][i][caidas[i]])
	_eventos = {}
	for i in _detalle["tics"].size():
		var caidas: Array = _detalle["caidas"]
		if i >= caidas.size():
			continue
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
	if partida == null:
		return
	_medir()
	var nivel: Dictionary = partida.nivel
	var tablero := Rect2(_origen, Vector2(nivel["w"], nivel["h"]) * _k)
	draw_style_box(_caja(HIELO, 18), tablero)
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

	_inicio(nivel["i"])

	if not pista.is_empty():
		for f in Sim.repartir(pista):
			draw_circle(a_pantalla(f), 1.3 * _k, Color(TINTA, 0.28))

	var todas: Array = _detalle.get("fichas", partida.fichas()) if modo != Modo.EDITAR else partida.fichas()
	var tic := _tic_actual()
	for i in todas.size():
		var f: Array = todas[i]
		# La primera ficha de una rama está en el mismo sitio que su bifurcador: no se dibuja dos veces
		var desde := 1 if i < partida.tramos.size() and partida.tramos[i]["padre"] != null else 0
		for j in range(desde, f.size()):
			var estado := 0      # 0 de pie, 1 cayendo, 2 caída
			if modo != Modo.EDITAR and not _detalle.get("caidas", []).is_empty():
				var t: int = _detalle["tics"][i][j]
				if j <= _detalle["caidas"][i]:
					if t < tic:
						estado = 2
					elif t == tic:
						estado = 1
			_ficha(f, j, estado)

	# Las campanas van encima de las fichas para que siempre se vean
	for c in nivel["c"]:
		_campana(c)

	if modo == Modo.EDITAR:
		for p in partida.curvas_cerradas():
			draw_arc(a_pantalla(p), 3.2 * _k, 0, TAU, 24, CORAL, 0.6 * _k, true)
	if modo == Modo.RESULTADO:
		_parada()


func _caja(color: Color, radio: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radio)
	return s


func _direccion(f: Array, j: int) -> Vector2:
	var a: Array = f[maxi(j - 1, 0)]
	var b: Array = f[mini(j + 1, f.size() - 1)]
	var d := Vector2(b[0] - a[0], b[1] - a[1])
	return d.normalized() if d.length() > 0.0001 else Vector2.UP


## Rectángulo girado: largo a lo largo de `eje`, ancho en perpendicular.
func _rect(centro: Vector2, eje: Vector2, largo: float, ancho: float) -> PackedVector2Array:
	var a := eje * largo / 2
	var b := Vector2(-eje.y, eje.x) * ancho / 2
	return PackedVector2Array([centro - a - b, centro + a - b, centro + a + b, centro - a + b])


func _ficha(f: Array, j: int, estado: int) -> void:
	var c := a_pantalla(f[j])
	var eje := _direccion(f, j)
	var forma: PackedVector2Array
	var color := MARFIL
	match estado:
		0:   # de pie: se ve el canto, de lado a lado del camino
			forma = _rect(c, eje, 1.5 * _k, 4.2 * _k)
		1:   # cayendo
			forma = _rect(c, eje, 3.0 * _k, 4.2 * _k)
			color = CAYENDO
		_:   # tumbada: se ve la cara con sus dos puntos
			forma = _rect(c + eje * 1.2 * _k, eje, 4.4 * _k, 2.8 * _k)
			color = CAIDA
	draw_colored_polygon(forma, color)
	var borde := forma.duplicate()
	borde.append(forma[0])
	draw_polyline(borde, TINTA, maxf(1.0, 0.32 * _k), true)
	if estado == 2:
		var centro := c + eje * 1.2 * _k
		draw_circle(centro - eje * 1.0 * _k, 0.38 * _k, TINTA)
		draw_circle(centro + eje * 1.0 * _k, 0.38 * _k, TINTA)


func _inicio(p: Array) -> void:
	var c := a_pantalla(p)
	var forma := _rect(c, Vector2.UP, 2.2 * _k, 5.0 * _k)
	draw_colored_polygon(forma, CAYENDO)
	var borde := forma.duplicate()
	borde.append(forma[0])
	draw_polyline(borde, TINTA, maxf(1.5, 0.4 * _k), true)
	if modo == Modo.EDITAR and partida.tramos.is_empty():
		var pulso := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 260.0)
		draw_arc(c, (4.5 + pulso * 1.5) * _k, 0, TAU, 32, Color(TINTA, 0.35), 0.4 * _k, true)
		queue_redraw()   # el pulso invita a empezar por aquí


func _campana(c: Array) -> void:
	var centro := a_pantalla(c[1])
	var id: String = c[0]
	var sono = resultado().get("campanas", {}).get(id) if modo != Modo.EDITAR else null
	var suena: bool = sono != null and _tic_actual() >= int(sono)
	if suena:
		var t := _tiempo - int(sono) * DURACION_TIC
		var halo := clampf(1.0 - t / 0.8, 0.0, 1.0)
		draw_circle(centro, (Sim.RADIO_CAMPANA + 2.0 + 3.0 * (1.0 - halo)) * _k, Color(CAYENDO, 0.55 * halo + 0.25))
	var r := 3.6 * _k
	var tipo: String = c[2]
	var centros := [centro]
	if tipo == "doble":
		centros = [centro - Vector2(2.4 * _k, 0), centro + Vector2(2.4 * _k, 0)]
		r = 2.9 * _k
	for cc in centros:
		var cuerpo := PackedVector2Array([cc + Vector2(-r, r * 0.8), cc + Vector2(-r * 0.75, -r * 0.4),
			cc + Vector2(0, -r), cc + Vector2(r * 0.75, -r * 0.4), cc + Vector2(r, r * 0.8)])
		draw_colored_polygon(cuerpo, CORAL)
		var borde := cuerpo.duplicate()
		borde.append(cuerpo[0])
		draw_polyline(borde, TINTA, maxf(1.2, 0.3 * _k), true)
		draw_circle(cc + Vector2(0, r * 0.95), r * 0.22, TINTA)
	draw_arc(centro, Sim.RADIO_CAMPANA * _k, 0, TAU, 40, Color(CORAL, 0.35), maxf(1.0, 0.25 * _k), true)
	if tipo == "numerada":
		# El número va dentro de la campana, en blanco, para que ninguna ficha lo tape
		var fuente := get_theme_default_font()
		var tam := int(3.4 * _k)
		var texto := str(int(c[3]))
		var medida := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam)
		var base := centro + Vector2(-medida.x / 2, fuente.get_ascent(tam) / 2 - 0.1 * _k)
		draw_string_outline(fuente, base, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, maxi(2, int(0.5 * _k)), TINTA)
		draw_string(fuente, base, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, Color.WHITE)


func _puerta(p: Array) -> void:
	var a := a_pantalla(p[0])
	var b := a_pantalla(p[1])
	draw_dashed_line(a, b, TINTA, 1.4 * _k, 2.0 * _k, true)


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
	draw_line(c + Vector2(-lado, -lado), c + Vector2(lado, lado), CORAL, 0.9 * _k, true)
	draw_line(c + Vector2(-lado, lado), c + Vector2(lado, -lado), CORAL, 0.9 * _k, true)
	draw_arc(c, 4.2 * _k, 0, TAU, 32, CORAL, 0.5 * _k, true)
