## Ejecuta los casos compartidos con la versión de Python y termina con código 0 si todos pasan.
##
## Uso (desde la raíz del repositorio):
##   Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://pruebas/ejecutar_pruebas.gd
##
## Es un ejecutor mínimo sin dependencias. GUT se añadirá cuando haga falta probar escenas.
extends SceneTree

## Se carga en tiempo de ejecución para poder salir con error si no compila (con preload,
## un fallo de compilación dejaría Godot esperando sin terminar).
var sim: GDScript


func _init() -> void:
	sim = load("res://nucleo/simulacion.gd")
	if sim == null or not sim.can_instantiate():
		printerr("simulacion.gd no compila: revisa los errores de arriba")
		quit(3)
		return
	var texto := FileAccess.get_file_as_string("res://datos/casos_compartidos.json")
	var datos = JSON.parse_string(texto)
	if datos == null:
		printerr("No se pudo leer res://datos/casos_compartidos.json")
		quit(2)
		return
	var fallos := 0
	for caso in datos["casos"]:
		var obtenido: Dictionary = sim.simular(caso["nivel"], caso["tramos"])
		if iguales(obtenido, caso["esperado"]):
			print("ok    ", caso["nombre"])
		else:
			fallos += 1
			print("FALLA ", caso["nombre"])
			print("      esperado: ", JSON.stringify(caso["esperado"]))
			print("      obtenido: ", JSON.stringify(obtenido))
	var total: int = datos["casos"].size()
	print("%d de %d casos iguales que en Python" % [total - fallos, total])
	quit(0 if fallos == 0 and total > 0 else 1)


## Igualdad profunda. JSON convierte todos los números en float, así que 3 y 3.0 son iguales.
func iguales(a, b) -> bool:
	if a == null or b == null:
		return a == null and b == null
	if (typeof(a) == TYPE_INT or typeof(a) == TYPE_FLOAT) and (typeof(b) == TYPE_INT or typeof(b) == TYPE_FLOAT):
		return float(a) == float(b)
	if typeof(a) != typeof(b):
		return false
	if a is Dictionary:
		if a.size() != b.size():
			return false
		for k in a:
			if not b.has(k) or not iguales(a[k], b[k]):
				return false
		return true
	if a is Array:
		if a.size() != b.size():
			return false
		for i in a.size():
			if not iguales(a[i], b[i]):
				return false
		return true
	return a == b
