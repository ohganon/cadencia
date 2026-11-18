## Elige el tema al arrancar (autoload «Tema»): el guardado en el progreso o, en la demostración,
## el de `--tema=<id>` (sin guardar nada). El tema activo vive en nucleo/temas.gd.
extends Node

const Temas = preload("res://nucleo/temas.gd")
const Progreso = preload("res://nucleo/progreso.gd")


func _init() -> void:
	var elegido: String = Progreso.new().tema
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tema="):
			elegido = a.substr(7)
	Temas.usar(elegido)
