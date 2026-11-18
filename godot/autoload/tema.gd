## Prepara el aspecto al arrancar (autoload «Tema»): el tema guardado en el progreso y los ajustes de
## alto contraste y texto grande. El tema activo vive en nucleo/temas.gd.
##
## La primera vez que se abre el juego, el alto contraste y reducir movimiento siguen lo que el
## teléfono tenga pedido en sus ajustes de accesibilidad (el jugador lo puede cambiar luego).
## En la demostración, `--tema=<id>`, `--contraste` y `--texto-grande` cambian el aspecto sin
## guardar nada.
extends Node

const Temas = preload("res://nucleo/temas.gd")
const Progreso = preload("res://nucleo/progreso.gd")


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var demo := false
	for a in args:
		demo = demo or a.begins_with("--demo")
	var progreso = Progreso.new()
	if not demo and not FileAccess.file_exists(progreso.ruta):
		progreso.ajustes["alto_contraste"] = DisplayServer.accessibility_should_increase_contrast() == 1
		progreso.ajustes["reducir_movimiento"] = DisplayServer.accessibility_should_reduce_animation() == 1
		progreso.guardar()
	var elegido: String = progreso.tema
	var ajustes: Dictionary = progreso.ajustes.duplicate()
	if demo:
		ajustes = {}
	for a in args:
		if a.begins_with("--tema="):
			elegido = a.substr(7)
		elif a == "--contraste":
			ajustes["alto_contraste"] = true
		elif a == "--texto-grande":
			ajustes["texto_grande"] = true
	Temas.usar(elegido)
	Temas.accesibilidad(ajustes)
