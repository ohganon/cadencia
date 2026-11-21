## Fondo de una pantalla, como el de la maqueta (docs/fase6/temas/index.html, .pant): el color o el
## degradado vertical del tema y, en cuatro temas, su textura fija:
## - Gráfico y limpio: papel cuadriculado (líneas de 1 px cada 24 px);
## - Risografía: trama de puntos azules muy suaves (cada 5 px);
## - Nocturno: dos capas de estrellas pequeñas sobre azul medianoche;
## - Cine negro: grano fino de película.
## Las medidas de la maqueta se multiplican por Temas.ESCALA. La textura se crea una vez y se repite.
## Con alto contraste, el fondo es liso.
extends Control

const Temas = preload("res://nucleo/temas.gd")

static var _cache := {}        # id del tema -> [ImageTexture...] de su textura


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)


func _notification(que: int) -> void:
	if que == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var pantalla: Dictionary = Temas.estilo("pantalla", {})
	if Temas.alto_contraste or pantalla.is_empty():
		draw_rect(rect, Temas.ui("pantalla"))
		return
	_degradado(rect, pantalla.get("degradado", []))
	var textura: Dictionary = pantalla.get("textura", {})
	if textura.is_empty():
		return
	for capa in _texturas(textura):
		draw_texture_rect(capa[0], Rect2(-capa[1], rect.size + capa[1]), true)


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
