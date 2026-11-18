## Escribe res://datos/codigos_godot.json: los códigos del Taller que hace Godot para los 10 niveles.
## Las pruebas de Python los abren (compatibilidad Godot → Python) y las de Godot comprueban que
## el codificador sigue produciendo exactamente los mismos (si cambia, cambió el formato).
##
## Uso (desde la raíz del repositorio), solo cuando cambien los niveles o el formato:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://pruebas/generar_codigos_godot.gd
extends SceneTree


func _init() -> void:
	var taller: GDScript = load("res://nucleo/taller.gd")
	var niveles: Array = JSON.parse_string(FileAccess.get_file_as_string("res://datos/niveles_entrega1.json"))["niveles"]
	var codigos := []
	for n in niveles:
		codigos.append({"id": int(n["id"]), "codigo": taller.codificar(n["nivel"], n["solucion"])})
	var f := FileAccess.open("res://datos/codigos_godot.json", FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 1, "nota": "Generado por godot/pruebas/generar_codigos_godot.gd", "codigos": codigos}, " ") + "\n")
	f.close()
	print("%d códigos escritos" % codigos.size())
	quit(0)
