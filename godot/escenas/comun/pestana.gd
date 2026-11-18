## Pestaña de la barra de abajo del mapa (Inicio, Reto, Taller, Ajustes): icono y nombre, se pulsa
## con el dedo o desde el lector de pantalla.
extends VBoxContainer

signal pulsado

var nombre := "":
	set(v):
		nombre = v
		queue_accessibility_update()
var activa := false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ACCESSIBILITY


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and not e.pressed:
		pulsado.emit()
		accept_event()
	elif e.is_action_pressed("ui_accept"):
		pulsado.emit()
		accept_event()


func _notification(que: int) -> void:
	if que == NOTIFICATION_ACCESSIBILITY_UPDATE:
		var ae := get_accessibility_element()
		if ae.is_valid():
			DisplayServer.accessibility_update_set_role(ae, DisplayServer.ROLE_TAB)
			DisplayServer.accessibility_update_set_name(ae, nombre + (", pantalla actual" if activa else ""))
			DisplayServer.accessibility_update_add_action(ae, DisplayServer.ACTION_CLICK, func(_datos): pulsado.emit())
