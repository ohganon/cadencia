## Fondo de una pantalla, como el de la maqueta (docs/fase6/temas/index.html, .pant): el color o el
## degradado vertical del tema y, en cuatro temas, su textura fija:
## - Gráfico y limpio: papel cuadriculado (líneas de 1 px cada 24 px);
## - Risografía: trama de puntos azules muy suaves (cada 5 px);
## - Nocturno: dos capas de estrellas pequeñas sobre azul medianoche;
## - Cine negro: grano fino de película.
## Las medidas de la maqueta se multiplican por Temas.ESCALA. La textura se crea una vez y se repite.
## Con alto contraste, el fondo es liso.
##
## Animación de fondo (elegida por el cliente el 21/11/2026, propuesta en la página «Fondos animados»):
## una por tema, lenta y con muy poco contraste, encima del fondo de la maqueta. Solo se mueve en las
## pantallas que la piden (`animado`: el mapa, Ajustes y Apariencia); en la partida y en el Taller se
## queda quieta para no distraer de la cadena. Con «reducir movimiento» se ve quieta y con alto
## contraste no se dibuja. Se redibuja a 30 imágenes por segundo y solo mientras se ve.
## Las medidas de la propuesta son de un teléfono de 270 × 480; aquí se escalan al tamaño del fondo.
extends Control

const Temas = preload("res://nucleo/temas.gd")
const Fuentes = preload("res://escenas/comun/fuentes.gd")

static var _cache := {}        # id del tema -> [ImageTexture...] de su textura
static var _texturas_anim := {} # texturas de las animaciones (halo, gota, grano…), creadas una vez

const FPS := 30.0
const T_QUIETO := 4.0          # instante que se dibuja cuando el fondo no se mueve
## Calma: los colores hacia los que se desplaza el atardecer
const CALMA_TARDE := ["#f4cfc9", "#dccfe6", "#c4cde8"]

## ¿Se anima esta pantalla? (el mapa y Apariencia sí; la partida y el Taller, no)
var animado := false:
	set(v):
		animado = v
		set_process(_se_mueve())
		queue_redraw()
var _t := T_QUIETO
var _espera := 0.0
var _particulas := {}          # puntos fijos de cada animación (estrellas, copos, motas…)
var _caja_ficha: StyleBoxFlat
var _letra_marquesina: Font


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	set_process(false)


## Godot enciende _process al entrar en escena: aquí se deja encendido solo si el fondo se mueve.
func _ready() -> void:
	set_process(_se_mueve())


func _se_mueve() -> bool:
	return animado and not Temas.reducir_movimiento and not Temas.alto_contraste


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_t += delta
	_espera += delta
	if _espera >= 1.0 / FPS:
		_espera = 0.0
		queue_redraw()


func _notification(que: int) -> void:
	if que == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var pantalla: Dictionary = Temas.estilo("pantalla", {})
	if Temas.alto_contraste or pantalla.is_empty():
		draw_rect(rect, Temas.ui("pantalla"))
		return
	var id := Temas.id_activo()
	var t := _t if _se_mueve() else T_QUIETO
	var paradas: Array = pantalla.get("degradado", [])
	if animado and id == "calma":
		paradas = _atardecer(paradas, t)
	_degradado(rect, paradas)
	var textura: Dictionary = pantalla.get("textura", {})
	if not textura.is_empty():
		for capa in _texturas(textura):
			var desde: Vector2 = capa[1]
			if animado and str(textura.get("textura")) == "rejilla":
				# Gráfico: el papel sube una cuadrícula cada 6 s
				var paso: float = capa[0].get_height()
				desde.y += fposmod(t * paso / 6.0, paso)
			draw_texture_rect(capa[0], Rect2(-desde, rect.size + desde + Vector2(0, 64)), true)
	if animado:
		_animacion(id, t)


## Degradado vertical por bandas (como linear-gradient(180deg, …)).
func _degradado(rect: Rect2, paradas: Array) -> void:
	if paradas.is_empty():
		draw_rect(rect, Temas.ui("pantalla"))
		return
	if paradas.size() == 1:
		draw_rect(rect, Color(paradas[0][1]))
		return
	for k in range(paradas.size() - 1):
		var y0: float = rect.size.y * float(paradas[k][0])
		var y1: float = rect.size.y * float(paradas[k + 1][0])
		var c0 := Color(paradas[k][1])
		var c1 := Color(paradas[k + 1][1])
		draw_polygon(PackedVector2Array([Vector2(0, y0), Vector2(rect.size.x, y0), Vector2(rect.size.x, y1), Vector2(0, y1)]),
			PackedColorArray([c0, c0, c1, c1]))


## Texturas que se repiten, con el desplazamiento de cada capa: [[ImageTexture, Vector2], ...].
func _texturas(t: Dictionary) -> Array:
	var id := Temas.id_activo()
	if _cache.has(id):
		return _cache[id]
	var e := Temas.ESCALA
	var capas := []
	match str(t.get("textura", "")):
		"rejilla":
			var paso := int(round(float(t["paso"]) * e))
			var img := Image.create(paso, paso, false, Image.FORMAT_RGBA8)
			var c := Color(t["color"])
			var grosor := maxi(1, int(round(e)))
			for i in paso:
				for g in grosor:
					img.set_pixel(i, g, c)
					img.set_pixel(g, i, c)
			capas.append([ImageTexture.create_from_image(img), Vector2.ZERO])
		"trama", "grano":
			var paso := maxi(3, int(round(float(t["paso"]) * e)))
			capas.append([_puntos(Vector2i(paso, paso), Vector2.ZERO, float(t["radio"]) * e, Color(t["color"])), Vector2.ZERO])
		"estrellas":
			for capa in t.get("capas", []):
				var tile := Vector2i(int(round(float(capa["tile"][0]) * e)), int(round(float(capa["tile"][1]) * e)))
				var desde := Vector2(float(capa["desde"][0]), float(capa["desde"][1])) * e
				capas.append([_puntos(tile, Vector2.ZERO, float(capa["radio"]) * e, Color(capa["color"])), -desde])
	_cache[id] = capas
	return capas


## Una baldosa con un punto redondo y suave (radial-gradient de la maqueta) en `centro`.
static func _puntos(tile: Vector2i, centro: Vector2, radio: float, color: Color) -> ImageTexture:
	var img := Image.create(tile.x, tile.y, false, Image.FORMAT_RGBA8)
	var alcance := int(ceil(radio + 1.0))
	for dy in range(-alcance, alcance + 1):
		for dx in range(-alcance, alcance + 1):
			var d := Vector2(dx, dy).length()
			var a := clampf(radio + 0.5 - d, 0.0, 1.0)
			if a <= 0.0:
				continue
			var x := posmod(int(centro.x) + dx, tile.x)
			var y := posmod(int(centro.y) + dy, tile.y)
			img.set_pixel(x, y, Color(color, color.a * a))
	return ImageTexture.create_from_image(img)


# ---------------------------------------------------------------- animaciones de fondo

func _animacion(id: String, t: float) -> void:
	var k := size.x / 270.0            # escala de la propuesta (teléfono de 270 × 480)
	var ky := size.y / 480.0
	match id:
		"pop":
			_pop(t, k, ky)
		"mesa":
			_mesa(t, k, ky)
		"negro":
			_negro(t, k)
		"tinta":
			_tinta(t, k, ky)
		"bauhaus":
			_bauhaus(t, k, ky)
		"brutal":
			_brutal(t, k, ky)
		"riso":
			_riso(t, k)
		"nocturno":
			_nocturno(t, k, ky)
		"nordico":
			_nordico(t, k, ky)


## Puntos fijos de una animación: `n` filas de valores entre 0 y 1, siempre los mismos.
func _puntos_fijos(nombre: String, n: int, valores: int, semilla: int) -> Array:
	if not _particulas.has(nombre):
		var rng := RandomNumberGenerator.new()
		rng.seed = semilla
		var lista := []
		for i in n:
			var fila := []
			for j in valores:
				fila.append(rng.randf())
			lista.append(fila)
		_particulas[nombre] = lista
	return _particulas[nombre]


## Dominó Pop · Fichas a lo lejos: tres filas de fichas marfil, casi transparentes, caen en ola y se
## vuelven a levantar despacio (ciclo de 10 s).
func _pop(t: float, k: float, ky: float) -> void:
	if _caja_ficha == null:
		_caja_ficha = StyleBoxFlat.new()
		_caja_ficha.bg_color = Color(1.0, 0.992, 0.965, 0.11)
		_caja_ficha.set_corner_radius_all(int(2 * k))
		_caja_ficha.anti_aliasing = true
	var ciclo := fposmod(t, 10.0)
	var filas := [[-30.0, 150.0], [-10.0, 300.0], [20.0, 430.0]]
	var n := int(ceil(size.x / k / 22.0)) + 3
	for fi in filas.size():
		var f: Array = filas[fi]
		var cabeza := clampf((ciclo - fi * 0.6) / 6.0, 0.0, 1.0) * (n + 2)
		var sube := clampf((ciclo - 7.2) / 2.6, 0.0, 1.0)
		for i in n:
			var cae := clampf(cabeza - i, 0.0, 1.0)
			var angulo := -0.27 + deg_to_rad(78.0 * cae * (1.0 - sube))
			draw_set_transform(Vector2((f[0] + i * 22.0) * k, (f[1] - i * 6.0) * ky), angulo, Vector2.ONE)
			draw_style_box(_caja_ficha, Rect2(Vector2(-4, -18) * k, Vector2(8, 18) * k))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Mesa de juego · Luz de lámpara: un halo de latón que respira (8 s) y motas de polvo que suben.
func _mesa(t: float, k: float, ky: float) -> void:
	var halo := _degradado_radial("halo_mesa", Color("#c2a36b"), [[0.0, 1.0], [0.55, 0.4], [1.0, 0.0]])
	var a := 0.11 + 0.05 * sin(t * TAU / 8.0)
	var radio := size.y * 0.95
	var centro := Vector2(size.x / 2.0, -40.0 * ky)
	draw_texture_rect(halo, Rect2(centro - Vector2(radio, radio), Vector2(radio, radio) * 2.0), false, Color(1, 1, 1, a + 0.08))
	for m in _puntos_fijos("motas", 16, 4, 11):
		var y: float = fposmod(m[1] * 480.0 - t * (0.2 + m[2] * 0.5) * 8.0, 480.0) * ky
		var x: float = m[0] * size.x + sin(t * 0.4 + m[3] * 6.0) * 6.0 * k
		draw_circle(Vector2(x, y), 1.1 * k, Color(0.925, 0.902, 0.855, 0.10 + 0.08 * sin(t + m[3] * 6.0)))


## Calma premium · Atardecer que respira: el degradado se desplaza hacia rosa y bruma y vuelve (30 s).
func _atardecer(paradas: Array, t: float) -> Array:
	var s := (1.0 - cos(TAU * t / 30.0)) / 2.0
	var r := []
	for i in paradas.size():
		var hacia := Color(CALMA_TARDE[mini(i, CALMA_TARDE.size() - 1)])
		r.append([paradas[i][0], Color(paradas[i][1]).lerp(hacia, s)])
	return r


## Cine negro · Proyector: grano que se mueve (12 imágenes por segundo), un leve parpadeo y, de vez
## en cuando, una raya fina como en una copia vieja.
func _negro(t: float, k: float) -> void:
	if not _texturas_anim.has("grano_0"):
		for v in 4:
			var lado := 160
			var img := Image.create(lado, lado, false, Image.FORMAT_RGBA8)
			var rng := RandomNumberGenerator.new()
			rng.seed = 7919 + v
			var punto := maxi(1, int(round(k)))
			for i in 20:
				var x := rng.randi_range(0, lado - punto)
				var y := rng.randi_range(0, lado - punto)
				img.fill_rect(Rect2i(x, y, punto, punto), Color(1, 1, 1, 0.07))
			_texturas_anim["grano_%d" % v] = ImageTexture.create_from_image(img)
	var cuadro := int(floor(t * 12.0))
	var rng := RandomNumberGenerator.new()
	rng.seed = cuadro * 7919
	var grano: Texture2D = _texturas_anim["grano_%d" % (cuadro % 4)]
	var desde := Vector2(rng.randf() * 160.0, rng.randf() * 160.0)
	draw_texture_rect(grano, Rect2(-desde, size + desde), true)
	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.012 + 0.018 * rng.randf()))
	if fposmod(t, 5.0) < 0.45:
		var r2 := RandomNumberGenerator.new()
		r2.seed = int(floor(t / 5.0)) + 3
		draw_rect(Rect2(r2.randf() * size.x, 0, maxf(1.0, k * 0.8), size.y), Color(1, 1, 1, 0.10))


## Tinta japonesa · Gota de tinta: una gota de sumi se abre y se desvanece; luego otra, en otro sitio
## (una cada 9 s, dos a la vez desfasadas).
func _tinta(t: float, k: float, ky: float) -> void:
	var gota := _degradado_radial("gota_tinta", Color("#1c1c1c"), [[0.0, 1.0], [0.2, 1.0], [0.8, 0.7], [1.0, 0.0]])
	for i in 2:
		var tt := t + i * 4.5
		var n := int(floor(tt / 9.0))
		var f := fposmod(tt, 9.0) / 9.0
		var rng := RandomNumberGenerator.new()
		rng.seed = n * 131 + i * 17
		var centro := Vector2((30.0 + rng.randf() * 210.0) * k, (60.0 + rng.randf() * 360.0) * ky)
		var radio := (8.0 + 82.0 * (1.0 - pow(1.0 - f, 3.0))) * k
		draw_texture_rect(gota, Rect2(centro - Vector2(radio, radio), Vector2(radio, radio) * 2.0), false, Color(1, 1, 1, 0.13 * (1.0 - f)))


## Bauhaus · Formas que giran: círculo rojo, cuadrado azul y triángulo amarillo, grandes y muy
## pálidos, que giran y se desplazan (una vuelta por minuto).
func _bauhaus(t: float, k: float, ky: float) -> void:
	var g := t * TAU / 60.0
	draw_circle(Vector2(size.x * 0.78 + sin(g) * 14.0 * k, size.y * 0.24 + cos(g) * 10.0 * ky), 62.0 * k, Color("#e1251b", 0.12))
	draw_set_transform(Vector2(size.x * 0.2 + cos(g) * 10.0 * k, size.y * 0.62), g, Vector2.ONE)
	draw_rect(Rect2(Vector2(-42, -42) * k, Vector2(84, 84) * k), Color("#1b4fbf", 0.12))
	draw_set_transform(Vector2(size.x * 0.7, size.y * 0.84 + sin(g) * 10.0 * ky), -g * 0.8, Vector2.ONE)
	draw_colored_polygon(PackedVector2Array([Vector2(0, -56) * k, Vector2(50, 30) * k, Vector2(-50, 30) * k]), Color("#f7c600", 0.12))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Brutalista · Marquesina: «TUMBAR · DINGFALL» gigante en gris, en dos filas que pasan de lado a lado.
func _brutal(t: float, k: float, ky: float) -> void:
	if _letra_marquesina == null:
		_letra_marquesina = Fuentes.del_tema()["titulos"]
	var f := _letra_marquesina
	var tam := int(120.0 * k)
	var texto := "TUMBAR · DINGFALL · "
	var ancho := f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
	var medio := (f.get_ascent(tam) - f.get_descent(tam)) / 2.0
	var color := Color(0, 0, 0, 0.065)
	var x := -fposmod(t * 20.0 * k, ancho)
	while x < size.x:
		draw_string(f, Vector2(x, size.y * 0.52 + medio), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, color)
		x += ancho
	x = fposmod(t * 14.0 * k, ancho) - ancho
	while x < size.x:
		draw_string(f, Vector2(x, size.y * 0.86 + medio), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, color)
		x += ancho


## Risografía · Registro que se mueve: una trama rosa se desplaza un poco sobre la azul (vaivén de 7 s).
func _riso(t: float, k: float) -> void:
	if not _texturas_anim.has("trama_rosa"):
		var paso := maxi(3, int(round(6.0 * k)))
		_texturas_anim["trama_rosa"] = _puntos(Vector2i(paso, paso), Vector2(paso / 2.0, paso / 2.0), 1.3 * k, Color("#ff4fa3", 0.13))
	var s := TAU * t / 7.0
	var desde := Vector2(2.4 * sin(s), 1.8 * cos(s)) * k + Vector2(8, 8) * k
	draw_texture_rect(_texturas_anim["trama_rosa"], Rect2(-desde, size + desde * 2.0), true)


## Nocturno · Cielo vivo: estrellas que titilan cada una a su ritmo y una estrella fugaz cada 14 s.
func _nocturno(t: float, k: float, ky: float) -> void:
	for s in _puntos_fijos("estrellas", 70, 5, 5):
		var a: float = 0.25 + 0.6 * (sin(t * (0.6 + s[4] * 1.6) + s[3] * 6.0) + 1.0) / 2.0
		draw_circle(Vector2(s[0] * size.x, s[1] * size.y), (0.4 + s[2] * 0.9) * k, Color(1, 1, 1, a))
	var f := fposmod(t, 14.0)
	if f < 1.0:
		var rng := RandomNumberGenerator.new()
		rng.seed = int(floor(t / 14.0)) + 41
		var cabeza := Vector2((40.0 + rng.randf() * 150.0 + f * 130.0) * k, (20.0 + rng.randf() * 120.0 + f * 70.0) * ky)
		var cola := cabeza - Vector2(60, 32) * k
		draw_polyline_colors(PackedVector2Array([cola, cabeza]), PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0.85 * (1.0 - f))]), 1.4 * k, true)


## Nórdico · Nieve: pocos copos, grandes y lentos, que caen balanceándose.
func _nordico(t: float, k: float, ky: float) -> void:
	for p in _puntos_fijos("copos", 26, 5, 9):
		var y: float = (fposmod(p[1] * 480.0 + t * (14.0 + p[3] * 16.0), 490.0) - 5.0) * ky
		var x: float = p[0] * size.x + sin(t * 0.5 + p[4] * 6.0) * 9.0 * k
		var radio: float = (1.6 + p[2] * 2.2) * k
		draw_circle(Vector2(x, y), radio, Color.WHITE)
		draw_arc(Vector2(x, y), radio, 0, TAU, 16, Color("#22302b", 0.13), maxf(1.0, k * 0.6), true)


## Degradado radial de un color hacia transparente (halo de Mesa, gota de Tinta), creado una vez.
func _degradado_radial(nombre: String, color: Color, paradas: Array) -> Texture2D:
	if not _texturas_anim.has(nombre):
		var g := Gradient.new()
		g.offsets = PackedFloat32Array(paradas.map(func(p): return float(p[0])))
		g.colors = PackedColorArray(paradas.map(func(p): return Color(color, float(p[1]))))
		var tex := GradientTexture2D.new()
		tex.gradient = g
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(1.0, 0.5)
		tex.width = 256
		tex.height = 256
		_texturas_anim[nombre] = tex
	return _texturas_anim[nombre]
