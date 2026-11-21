## Ilustración de un barrio en el mapa (elegida por el cliente el 21/11/2026 en la propuesta «Barrios de
## Villa Cadencia»): siluetas sencillas dibujadas en código, del color del texto del tema y muy suaves.
## - Al pie del barrio, el perfil de sus edificios (perfil_N), detrás de los primeros niveles.
## - A los lados del camino, objetos sueltos (lados_N), cada cuatro niveles, alternando en espejo.
## Cada barrio recoge algo de la pieza que estrena: los globos del Jardín, el cristal del Faro…
##
## Se dibuja en un solo color opaco dentro de un CanvasGroup (mapa.gd) que le da la transparencia: así
## las siluetas que se tocan no se oscurecen, como en la propuesta. Las medidas son las de la propuesta
## (un teléfono de 270 px de ancho, con el suelo en y = 412) y se escalan al ancho del mapa.
extends Node2D

const SUELO := 412.0
const ALTO_LADOS := 760.0      # px del mapa entre dos grupos de objetos (cuatro niveles)

var barrio := 1
var ancho := 600.0
var alto := 1000.0
var color := Color.WHITE

var _g := 1.6                  # grosor de las líneas, en unidades de la propuesta


func _draw() -> void:
	var k := ancho / 270.0
	var suelo_y := alto - 20.0
	# Perfil, al pie
	draw_set_transform(Vector2(0, suelo_y - SUELO * k), 0.0, Vector2(k, k))
	call("_perfil_%d" % barrio)
	# Objetos de los lados, subiendo; uno de cada dos grupos, en espejo
	var b := 0
	while true:
		var y := suelo_y - SUELO * k - b * ALTO_LADOS
		if y + 340.0 * k < 0.0:
			break
		if b % 2 == 0:
			draw_set_transform(Vector2(0, y), 0.0, Vector2(k, k))
		else:
			draw_set_transform(Vector2(ancho, y), 0.0, Vector2(-k, k))
		call("_lados_%d" % barrio)
		b += 1
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ---------------------------------------------------------------- piezas de dibujo

func _r(x: float, y: float, w: float, h: float) -> void:
	draw_rect(Rect2(x, y, w, h), color)


func _c(x: float, y: float, r: float) -> void:
	draw_circle(Vector2(x, y), r, color)


func _p(puntos: Array, c := Color(0, 0, 0, 0)) -> void:
	var v := PackedVector2Array()
	for i in range(0, puntos.size(), 2):
		v.append(Vector2(puntos[i], puntos[i + 1]))
	draw_colored_polygon(v, color if c.a == 0.0 else c)


func _l(puntos: Array, grosor := -1.0) -> void:
	var g := _g if grosor < 0.0 else grosor
	var v := PackedVector2Array()
	for i in range(0, puntos.size(), 2):
		v.append(Vector2(puntos[i], puntos[i + 1]))
	draw_polyline(v, color, g, true)
	for q in [v[0], v[v.size() - 1]]:
		draw_circle(q, g / 2.0, color)


func _aro(x: float, y: float, r: float, grosor: float) -> void:
	draw_arc(Vector2(x, y), r, 0, TAU, 32, color, grosor, true)


## Curva cuadrática muestreada (como quadraticCurveTo).
static func _curva(a: Vector2, control: Vector2, b: Vector2, n := 12) -> PackedVector2Array:
	var r := PackedVector2Array()
	for i in n + 1:
		var t := float(i) / n
		r.append(a.lerp(control, t).lerp(control.lerp(b, t), t))
	return r


func _tejado(x: float, y: float, w: float, h: float) -> void:
	_p([x, y, x + w / 2.0, y - h, x + w, y])


func _arbol(x: float, y: float, r: float) -> void:
	_r(x - 2.5, y, 5, r * 1.2)
	_c(x, y - r * 0.2, r)


func _farola(x: float, y: float, h: float) -> void:
	_r(x - 1.5, y - h, 3, h)
	_c(x, y - h - 4, 5)
	_r(x - 6, y - 3, 12, 3)


func _olas(y: float, amp: float, paso: float) -> void:
	var v := PackedVector2Array([Vector2(270, 480), Vector2(0, 480)])
	var x := 0.0
	while x <= 270.0 + paso:
		v.append_array(_curva(Vector2(x, y), Vector2(x + paso / 4.0, y - amp), Vector2(x + paso / 2.0, y), 6))
		v.append_array(_curva(Vector2(x + paso / 2.0, y), Vector2(x + paso * 0.75, y + amp), Vector2(x + paso, y), 6))
		x += paso
	draw_colored_polygon(v, color)


func _gaviota(x: float, y: float, s: float) -> void:
	_l([x - s, y - s * 0.4, x - s * 0.45, y, x, y - s * 0.3, x + s * 0.45, y, x + s, y - s * 0.4])


func _engranaje(x: float, y: float, r: float, dientes: int) -> void:
	var v := PackedVector2Array()
	for i in dientes * 2:
		var a := i * PI / dientes
		var rr := r if i % 2 == 1 else r * 1.22
		v.append(Vector2(x + cos(a) * rr, y + sin(a) * rr))
	draw_colored_polygon(v, color)


func _guirnalda(y0: float, cae: float) -> PackedVector2Array:
	return _curva(Vector2(0, y0), Vector2(135, y0 + cae * 2.0), Vector2(270, y0), 24)


func _suelo() -> void:
	_r(0, SUELO, 270, 480 - SUELO)


# ---------------------------------------------------------------- 1. La Plaza (campanas)

func _perfil_1() -> void:
	_suelo()
	# Quiosco de música
	_r(30, SUELO - 8, 86, 8)
	for x in [36, 58, 80, 104]:
		_r(x, SUELO - 46, 4, 40)
	_r(30, SUELO - 52, 86, 6)
	_tejado(26, SUELO - 52, 94, 30)
	_r(71, SUELO - 92, 4, 12)
	_c(73, SUELO - 94, 3.5)
	# Fuente de tres pisos
	_p([150, SUELO, 156, SUELO - 14, 214, SUELO - 14, 220, SUELO])
	_r(182, SUELO - 34, 6, 20)
	_p([166, SUELO - 34, 204, SUELO - 34, 196, SUELO - 40, 174, SUELO - 40])
	_r(183, SUELO - 52, 4, 12)
	_p([174, SUELO - 52, 196, SUELO - 52, 191, SUELO - 56, 179, SUELO - 56])
	for s in [-1.0, 1.0]:
		draw_polyline(_curva(Vector2(185, SUELO - 58), Vector2(185 + s * 16, SUELO - 66), Vector2(185 + s * 22, SUELO - 40)), color, _g, true)
	_farola(134, SUELO, 44)
	_farola(240, SUELO, 44)


func _lados_1() -> void:
	_arbol(18, 250, 18)
	_arbol(254, 180, 16)
	_r(226, 300, 36, 4)
	_r(230, 304, 3, 8)
	_r(255, 304, 3, 8)


# ---------------------------------------------------------------- 2. El Puerto (puerta de vaivén)

func _perfil_2() -> void:
	_olas(SUELO + 6, 4, 30)
	# Velero
	_p([36, SUELO - 2, 104, SUELO - 2, 96, SUELO + 10, 44, SUELO + 10])
	_r(68, SUELO - 74, 3, 72)
	_p([72, SUELO - 72, 72, SUELO - 10, 104, SUELO - 10])
	_p([66, SUELO - 60, 66, SUELO - 10, 44, SUELO - 10])
	# Barca
	_p([122, SUELO + 2, 152, SUELO + 2, 146, SUELO + 10, 128, SUELO + 10])
	# Grúa del muelle
	_r(202, SUELO - 110, 6, 112)
	_r(168, SUELO - 110, 92, 5)
	_l([205, SUELO - 110, 240, SUELO - 130, 258, SUELO - 110], 2.0)
	_l([176, SUELO - 105, 176, SUELO - 70], 1.5)
	_r(170, SUELO - 70, 12, 8)
	# Casetas
	_r(160, SUELO - 26, 30, 26)
	_tejado(156, SUELO - 26, 38, 12)
	_r(226, SUELO - 30, 40, 30)


func _lados_2() -> void:
	_gaviota(32, 170, 9)
	_gaviota(52, 186, 6)
	_gaviota(244, 250, 8)
	# Ancla
	_aro(18, 296, 4.5, 2.5)
	_r(16.5, 300, 3, 26)
	_l([8, 318, 18, 330, 28, 318], 3.0)
	# Boya
	_c(252, 330, 9)
	_r(250, 312, 4, 12)


# ---------------------------------------------------------------- 3. La Relojería (espiral)

func _perfil_3() -> void:
	_suelo()
	_r(10, SUELO - 34, 50, 34)
	_tejado(6, SUELO - 34, 58, 18)
	_r(190, SUELO - 40, 70, 40)
	_tejado(186, SUELO - 40, 78, 20)
	# Torre del reloj: la esfera se ve por un hueco (el cuerpo va en cuatro piezas a su alrededor)
	_r(100, SUELO - 150, 52, 15)
	_r(100, SUELO - 135, 9, 34)
	_r(143, SUELO - 135, 9, 34)
	_r(100, SUELO - 101, 52, 101)
	_tejado(94, SUELO - 150, 64, 34)
	_aro(126, SUELO - 118, 15, 2.6)
	_l([126, SUELO - 118, 126, SUELO - 129], 2.4)
	_l([126, SUELO - 118, 134, SUELO - 113], 2.4)
	_engranaje(74, SUELO - 58, 16, 9)
	_engranaje(172, SUELO - 74, 12, 8)


func _lados_3() -> void:
	_engranaje(250, 200, 22, 10)
	_engranaje(18, 140, 14, 8)
	# Reloj de bolsillo colgando
	_l([30, 250, 30, 282])
	_aro(30, 296, 13, 3.0)
	_c(30, 281, 3)


# ---------------------------------------------------------------- 4. La Feria (muelle)

func _perfil_4() -> void:
	_suelo()
	# Tiovivo
	_r(24, SUELO - 10, 96, 10)
	for x in [34, 56, 78, 100, 112]:
		_r(x, SUELO - 60, 3, 50)
	_p([20, SUELO - 60, 72, SUELO - 96, 124, SUELO - 60])
	_r(70, SUELO - 108, 4, 12)
	_p([74, SUELO - 108, 86, SUELO - 104, 74, SUELO - 100])
	for x in [45, 89]:
		_r(x - 8, SUELO - 38, 16, 8)
	# Carpa a rayas: gajos alternos desde la punta
	var punta := Vector2(206, SUELO - 76)
	for i in 8:
		if i % 2 == 0:
			_p([punta.x, punta.y, 150 + i * 14.0, SUELO, 150 + (i + 1) * 14.0, SUELO])
	draw_polyline(PackedVector2Array([Vector2(150, SUELO), punta, Vector2(262, SUELO)]), color, 2.0, true)


func _lados_4() -> void:
	# Banderines
	draw_polyline(_guirnalda(250, 20), color, 1.4, true)
	for i in range(1, 10):
		var x := i * 27.0
		var y := 250.0 + 80.0 * (i / 10.0) * (1.0 - i / 10.0)
		_p([x - 6, y, x + 6, y, x, y + 10])
	# Globo
	_c(246, 160, 13)
	_l([246, 173, 242, 200, 248, 222], 1.4)
	# Muelle de juguete
	_l([14, 330, 28, 322, 14, 314, 28, 306, 14, 298, 28, 290], 2.4)
	_r(10, 330, 22, 4)


# ---------------------------------------------------------------- 5. La Estación (interruptor)

func _perfil_5() -> void:
	_r(0, SUELO + 8, 270, 480 - SUELO)
	_r(0, SUELO, 270, 3)
	# Andén cubierto
	_r(150, SUELO - 60, 116, 6)
	_p([146, SUELO - 60, 208, SUELO - 80, 270, SUELO - 60])
	for x in [158, 200, 242]:
		_r(x, SUELO - 54, 4, 54)
	# Locomotora, con su humo
	_r(14, SUELO - 34, 60, 30)
	_r(52, SUELO - 52, 22, 18)
	_r(22, SUELO - 52, 8, 18)
	_r(18, SUELO - 58, 16, 6)
	for x in [26, 48, 66]:
		_c(x, SUELO - 3, 7)
	_c(22, SUELO - 68, 6)
	_c(12, SUELO - 80, 8)
	# Vagón con ventanas (barras alrededor de los huecos)
	_r(80, SUELO - 30, 62, 4)
	_r(80, SUELO - 17, 62, 13)
	for x in [80, 100, 118, 136]:
		_r(x, SUELO - 26, 6, 9)
	for x in [92, 128]:
		_c(x, SUELO - 3, 6)
	# Reloj de la estación
	_r(213, SUELO - 120, 4, 60)
	_aro(215, SUELO - 132, 11, 3.0)
	_l([215, SUELO - 132, 215, SUELO - 139], 2.0)
	_l([215, SUELO - 132, 220, SUELO - 130], 2.0)


func _lados_5() -> void:
	# Semáforo de tren
	_r(246, 180, 4, 110)
	_r(240, 180, 16, 30)
	_r(234, 288, 28, 4)


# ---------------------------------------------------------------- 6. La Fábrica (noria)

func _perfil_6() -> void:
	_suelo()
	# Naves con tejado de sierra
	var v := PackedVector2Array([Vector2(0, SUELO), Vector2(0, SUELO - 40)])
	var x := 0.0
	while x < 150.0:
		v.append(Vector2(x + 30, SUELO - 62))
		v.append(Vector2(x + 30, SUELO - 40))
		x += 30.0
	v.append(Vector2(150, SUELO))
	draw_colored_polygon(v, color)
	# Chimeneas y humo
	_r(160, SUELO - 120, 14, 120)
	_r(186, SUELO - 96, 12, 96)
	for h in [[170, SUELO - 132, 8], [180, SUELO - 148, 11], [194, SUELO - 166, 13], [196, SUELO - 108, 6], [204, SUELO - 120, 8]]:
		_c(h[0], h[1], h[2])
	# Depósito de agua
	_r(218, SUELO - 78, 42, 30)
	_tejado(214, SUELO - 78, 50, 12)
	for xx in [222, 254]:
		_r(xx, SUELO - 48, 3, 48)


func _lados_6() -> void:
	# La rueda de la noria
	_aro(30, 250, 24, 3.0)
	for i in 6:
		var a := i * PI / 3.0
		var q := Vector2(30, 250) + Vector2(cos(a), sin(a)) * 24.0
		_l([30, 250, q.x, q.y], 2.0)
		_r(q.x - 4, q.y - 4, 8, 8)


# ---------------------------------------------------------------- 7. El Jardín (globo)

func _perfil_7() -> void:
	_suelo()
	# Invernadero: la estructura de cristal (marco y barras)
	var arco := PackedVector2Array([Vector2(126, SUELO), Vector2(126, SUELO - 40)])
	arco.append_array(_curva(Vector2(126, SUELO - 40), Vector2(126, SUELO - 84), Vector2(182, SUELO - 84)))
	arco.append_array(_curva(Vector2(182, SUELO - 84), Vector2(238, SUELO - 84), Vector2(238, SUELO - 40)))
	arco.append(Vector2(238, SUELO))
	draw_polyline(arco, color, 3.0, true)
	for bx in range(144, 230, 18):
		var tope := SUELO
		for q in arco:
			if absf(q.x - bx) < 4.0:
				tope = minf(tope, q.y)
		_r(bx - 1.2, tope, 2.4, SUELO - tope)
	for by in [SUELO - 20, SUELO - 40, SUELO - 60]:
		var izq := 238.0
		var der := 126.0
		for q in arco:
			if q.y <= by + 0.5:
				izq = minf(izq, q.x)
				der = maxf(der, q.x)
		if der > izq:
			_r(izq, by - 1.2, der - izq, 2.4)
	# Árboles, setos y flores
	_arbol(30, SUELO - 40, 26)
	_arbol(92, SUELO - 30, 18)
	var hx := 0.0
	while hx < 270.0:
		_c(hx + 8, SUELO, 9)
		hx += 16.0
	for fx in [250, 262]:
		_r(fx - 1, SUELO - 22, 2, 22)
		_c(fx, SUELO - 24, 5)


func _lados_7() -> void:
	# Globos atados que suben
	for g in [[22, 180, 12], [44, 150, 10], [246, 240, 13]]:
		_c(g[0], g[1], g[2])
		_l([g[0], g[1] + g[2], g[0] - 3, g[1] + g[2] + 18, g[0] + 2, g[1] + g[2] + 34], 1.3)


# ---------------------------------------------------------------- 8. El Faro (cristal)

func _perfil_8() -> void:
	# Haz de luz, más suave que el resto
	_p([170, SUELO - 140, 0, SUELO - 210, 0, SUELO - 150], Color(color, 0.55))
	# Rocas
	_p([120, SUELO + 10, 140, SUELO - 24, 176, SUELO - 34, 206, SUELO - 18, 226, SUELO + 10])
	# Torre a franjas: piezas con huecos entre ellas
	var franjas := [[SUELO - 132, SUELO - 110], [SUELO - 104, SUELO - 80], [SUELO - 74, SUELO - 50], [SUELO - 44, SUELO - 30]]
	for f in franjas:
		var arriba: float = f[0]
		var abajo: float = f[1]
		var ancho_arriba := lerpf(16.0, 28.0, (arriba - (SUELO - 132)) / 102.0)
		var ancho_abajo := lerpf(16.0, 28.0, (abajo - (SUELO - 132)) / 102.0)
		_p([170 - ancho_arriba / 2, arriba, 170 + ancho_arriba / 2, arriba, 170 + ancho_abajo / 2, abajo, 170 - ancho_abajo / 2, abajo])
	# Linterna (el cristal): marco alrededor del hueco de la luz
	_r(158, SUELO - 146, 24, 2)
	_r(158, SUELO - 136, 24, 4)
	_r(158, SUELO - 144, 4, 8)
	_r(178, SUELO - 144, 4, 8)
	_tejado(154, SUELO - 146, 32, 14)
	_olas(SUELO + 8, 4, 26)
	# Barca
	_p([34, SUELO + 2, 74, SUELO + 2, 66, SUELO + 12, 42, SUELO + 12])
	_r(52, SUELO - 26, 2, 28)
	_p([55, SUELO - 26, 55, SUELO - 2, 74, SUELO - 2])


func _lados_8() -> void:
	_gaviota(230, 190, 9)
	_gaviota(248, 206, 6)
	_gaviota(26, 280, 8)


# ---------------------------------------------------------------- 9. La Verbena (combinaciones)

func _perfil_9() -> void:
	_suelo()
	# Escenario
	_r(70, SUELO - 20, 130, 20)
	_r(74, SUELO - 86, 4, 66)
	_r(192, SUELO - 86, 4, 66)
	_p([64, SUELO - 86, 135, SUELO - 106, 206, SUELO - 86])
	# Guirnaldas de bombillas
	for par in [[SUELO - 120, 26.0], [SUELO - 150, 20.0]]:
		var y0: float = par[0]
		var cae: float = par[1]
		draw_polyline(_guirnalda(y0, cae), color, 1.3, true)
		for i in range(1, 12):
			var t := i / 12.0
			_c(t * 270.0, y0 + cae * 4.0 * t * (1.0 - t) + 4.0, 3.2)
	# Farolillos de papel
	for fx in [28, 242]:
		_r(fx - 1, SUELO - 70, 2, 8)
		var caja := StyleBoxFlat.new()
		caja.bg_color = color
		caja.set_corner_radius_all(8)
		draw_style_box(caja, Rect2(fx - 9, SUELO - 62, 18, 24))
		_r(fx - 6, SUELO - 40, 12, 3)


func _lados_9() -> void:
	# Banderines
	for i in 5:
		_p([8 + i * 12, 200 + i * 4, 18 + i * 12, 202 + i * 4, 12 + i * 12, 212 + i * 4])
	# Cohete y su estallido
	_l([244, 300, 252, 262], 2.0)
	_p([252, 254, 248, 266, 256, 266])
	for i in 8:
		var a := i * PI / 4.0
		_l([250 + cos(a) * 8, 180 + sin(a) * 8, 250 + cos(a) * 18, 180 + sin(a) * 18], 1.6)
