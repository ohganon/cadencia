## Animaciones de la interfaz (pasada estética, ARQUITECTURA_BORRADOR.md › 6 bis).
##
## Todas respetan «reducir movimiento» (Temas.reducir_movimiento): con él activado, todo aparece
## en su sitio al momento. La curva de la maqueta es cubic-bezier(.22, 1, .36, 1), que se parece
## mucho a una salida «quint» (rápida al principio y muy suave al final).
extends RefCounted

const Temas = preload("res://nucleo/temas.gd")


## Curva de salida suave para animaciones hechas a mano (x de 0 a 1).
static func suave(x: float) -> float:
	return 1.0 - pow(1.0 - clampf(x, 0.0, 1.0), 5.0)


## Ventana que entra: crece un poco desde el centro y se hace visible.
static func entrar(c: Control) -> void:
	if Temas.reducir_movimiento or not c.is_inside_tree():
		c.scale = Vector2.ONE
		c.modulate.a = 1.0
		return
	c.modulate.a = 0.0
	await c.get_tree().process_frame          # el tamaño ya es el definitivo
	c.pivot_offset = c.size / 2.0
	c.scale = Vector2(0.9, 0.9)
	var t := c.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", Vector2.ONE, 0.28)
	t.tween_property(c, "modulate:a", 1.0, 0.16)


## El velo oscuro detrás de una ventana: aparece fundiéndose.
static func aparecer(c: CanvasItem, duracion := 0.18) -> void:
	if Temas.reducir_movimiento or not c.is_inside_tree():
		c.modulate.a = 1.0
		return
	c.modulate.a = 0.0
	c.create_tween().tween_property(c, "modulate:a", 1.0, duracion)


## Pequeño latido (por ejemplo, la cifra de una pastilla que cambia).
static func latido(c: Control, cuanto := 1.12) -> void:
	if Temas.reducir_movimiento or not c.is_inside_tree():
		return
	c.pivot_offset = c.size / 2.0
	var t := c.create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", Vector2(cuanto, cuanto), 0.08)
	t.tween_property(c, "scale", Vector2.ONE, 0.22)


## El nodo del nivel que toca «respira» despacio para que se vea dónde seguir.
static func respirar(c: Control) -> void:
	if Temas.reducir_movimiento or not c.is_inside_tree():
		return
	c.pivot_offset = c.size / 2.0
	var t := c.create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(c, "scale", Vector2(1.06, 1.06), 0.9)
	t.tween_property(c, "scale", Vector2.ONE, 0.9)


## Al abrir una pantalla, entra desde el color de fondo en un fundido corto.
static func fundido_entrada(pantalla: Control) -> void:
	if Temas.reducir_movimiento:
		return
	var tapa := ColorRect.new()
	tapa.color = Temas.ui("pantalla")
	tapa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tapa.set_anchors_preset(Control.PRESET_FULL_RECT)
	pantalla.add_child(tapa)
	var t := tapa.create_tween()
	t.tween_property(tapa, "modulate:a", 0.0, 0.22).set_trans(Tween.TRANS_SINE)
	t.tween_callback(tapa.queue_free)
