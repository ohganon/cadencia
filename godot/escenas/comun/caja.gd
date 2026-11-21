## Dibuja una caja de la maqueta (nucleo/temas.gd › caja()) igual que el CSS del catálogo de temas:
## sombras de fuera (duras, suaves o anillos), fondo, sombras de dentro (el labio de Dominó Pop o la
## viñeta del tapete de Mesa) y el borde encima. Lo usan los botones, los nodos del mapa, las
## pastillas y el tablero.
extends RefCounted


## `c`: caja de Temas.caja(). `opacidad`: la del botón entero (apagado, al 60 %). Como en CSS, con
## opacidad la caja se compone primero y luego se funde con lo de detrás (`detras`): así su sombra no
## se ve a través de ella.
static func dibujar(ci: CanvasItem, rect: Rect2, c: Dictionary, opacidad := 1.0, detras := Color(0, 0, 0, 0)) -> void:
	var radio := radio_de(c, rect)
	if opacidad < 1.0 and detras.a > 0.0:
		c = c.duplicate(true)
		var f: Color = c.get("fondo", Color(0, 0, 0, 0))
		if f.a > 0.0:
			c["fondo"] = detras.lerp(Color(detras.lerp(f, f.a), 1.0), opacidad)
		var bc: Color = c.get("borde_color", Color(0, 0, 0, 0))
		if bc.a > 0.0:
			c["borde_color"] = detras.lerp(Color(bc, 1.0), opacidad * bc.a)
		for s in c["sombras"]:
			if s["dentro"]:
				s["color"] = detras.lerp(Color(s["color"], 1.0), opacidad * s["color"].a)
		opacidad_sombras(c, opacidad)
		opacidad = 1.0
	# Sombras de fuera: en CSS la primera de la lista queda encima, así que se pintan del revés
	var sombras: Array = c.get("sombras", [])
	for k in range(sombras.size() - 1, -1, -1):
		var s: Dictionary = sombras[k]
		if s["dentro"]:
			continue
		var col: Color = s["color"]
		col.a *= opacidad
		if col.a <= 0.0:
			continue
		var r := rect.grow(s["extension"])
		r.position += s["pos"]
		if s["desenfoque"] <= 0.0:
			draw_redondeado(ci, r, col, radio + s["extension"])
		else:
			# Sombra suave: un StyleBox sin relleno que solo pinta su sombra
			var sb := StyleBoxFlat.new()
			sb.draw_center = false
			sb.set_corner_radius_all(int(maxf(radio + s["extension"], 0.0)))
			sb.shadow_color = col
			sb.shadow_size = maxi(1, int(round(s["desenfoque"] * 0.5)))
			sb.anti_aliasing = true
			ci.draw_style_box(sb, r)
	# Fondo
	var fondo: Color = c.get("fondo", Color(0, 0, 0, 0))
	fondo.a *= opacidad
	if fondo.a > 0.0:
		draw_redondeado(ci, rect, fondo, radio)
	# Sombras de dentro, dentro del borde
	var b: float = c.get("borde", 0.0)
	var dentro := rect.grow(-b)
	var radio_dentro := maxf(radio - b, 0.0)
	for s in sombras:
		if not s["dentro"]:
			continue
		var col: Color = s["color"]
		col.a *= opacidad
		if s["desenfoque"] <= 0.0:
			# Labio: una franja del color de la sombra en el lado contrario al desplazamiento
			var pos: Vector2 = s["pos"]
			draw_redondeado(ci, dentro, col, radio_dentro)
			var cara := dentro
			if pos.y < 0:
				cara.size.y += pos.y
			elif pos.y > 0:
				cara.position.y += pos.y
				cara.size.y -= pos.y
			draw_redondeado(ci, cara, fondo, radio_dentro)
		else:
			# Viñeta: aros cada vez más transparentes desde el borde hacia dentro
			var pasos := 10
			var ancho: float = s["desenfoque"] / pasos
			for k in pasos:
				var sb := StyleBoxFlat.new()
				sb.draw_center = false
				sb.border_color = Color(col, col.a * (1.0 - float(k) / pasos) * 0.35)
				sb.set_border_width_all(int(ceil(ancho)))
				sb.set_corner_radius_all(int(maxf(radio_dentro - k * ancho, 0.0)))
				sb.anti_aliasing = true
				ci.draw_style_box(sb, dentro.grow(-k * ancho))
	# Borde
	if b > 0.0:
		var bc: Color = c.get("borde_color", Color(0, 0, 0, 0))
		bc.a *= opacidad
		if bc.a > 0.0:
			var sb := StyleBoxFlat.new()
			sb.draw_center = false
			sb.border_color = bc
			sb.set_border_width_all(int(round(b)))
			sb.set_corner_radius_all(int(radio))
			sb.anti_aliasing = true
			ci.draw_style_box(sb, rect)


static func opacidad_sombras(c: Dictionary, opacidad: float) -> void:
	for s in c["sombras"]:
		if not s["dentro"]:
			s["color"] = Color(s["color"], s["color"].a * opacidad)


## Radio en px para este rect (-1 en el estilo = círculo o pastilla: la mitad del lado corto).
static func radio_de(c: Dictionary, rect: Rect2) -> float:
	var mitad := minf(rect.size.x, rect.size.y) / 2.0
	var r: float = c.get("radio", 0.0)
	return mitad if r < 0.0 else minf(r, mitad)


static func draw_redondeado(ci: CanvasItem, rect: Rect2, color: Color, radio: float) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(int(maxf(radio, 0.0)))
	sb.anti_aliasing = true
	sb.corner_detail = 12
	ci.draw_style_box(sb, rect)


## Espacio que hay que dejar a la derecha y debajo para las sombras duras desplazadas (Brutalista,
## Risografía, el canto de Dominó Pop): así no se salen del hueco del botón.
static func hueco_sombra(c: Dictionary) -> Vector2:
	var h := Vector2.ZERO
	for s in c.get("sombras", []):
		if s["dentro"] or s["desenfoque"] > 0.0:
			continue
		h.x = maxf(h.x, s["pos"].x + s["extension"])
		h.y = maxf(h.y, s["pos"].y + s["extension"])
	return h
