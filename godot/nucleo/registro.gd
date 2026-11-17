## Registro local de partidas para las pruebas con personas (puerta 0 del lanzamiento).
##
## Guarda una línea JSON por evento en el propio teléfono (user://registro_pruebas.jsonl).
## **No sale del dispositivo y no contiene datos personales**: ni nombre, ni identificadores, ni
## ubicación. Solo nivel, resultado, fichas, tiempo y ayudas usadas. Sirve para ver dónde se atasca
## la gente; en la Fase 9 lo sustituirá la analítica, con su consentimiento.
extends RefCounted

const RUTA := "user://registro_pruebas.jsonl"
const TAMANO_MAXIMO := 2 * 1024 * 1024     # 2 MB: a partir de ahí deja de escribir

var ruta := RUTA


func _init(ruta_archivo: String = RUTA) -> void:
	ruta = ruta_archivo


func anotar(evento: String, datos: Dictionary = {}) -> void:
	var linea := datos.duplicate()
	linea["evento"] = evento
	linea["t"] = int(Time.get_unix_time_from_system())
	var f: FileAccess
	if FileAccess.file_exists(ruta):
		f = FileAccess.open(ruta, FileAccess.READ_WRITE)
		if f == null or f.get_length() > TAMANO_MAXIMO:
			return
		f.seek_end()
	else:
		f = FileAccess.open(ruta, FileAccess.WRITE)
		if f == null:
			return
	f.store_line(JSON.stringify(linea))


## Todas las líneas registradas (para revisar una sesión de prueba).
func leer() -> Array:
	var r := []
	if not FileAccess.file_exists(ruta):
		return r
	var f := FileAccess.open(ruta, FileAccess.READ)
	while not f.eof_reached():
		var linea := f.get_line()
		if linea.strip_edges() == "":
			continue
		var json := JSON.new()
		if json.parse(linea) == OK:
			r.append(json.data)
	return r


## Resumen por nivel: intentos, superado, intentos hasta superarlo y pistas.
func resumen() -> Dictionary:
	var por_nivel := {}
	for e in leer():
		if e.get("evento") != "intento":
			continue
		var k := str(int(e.get("nivel", 0)))
		var r: Dictionary = por_nivel.get_or_add(k, {"intentos": 0, "superado": false, "intentos_hasta_superar": 0, "pistas": 0})
		r["intentos"] += 1
		r["pistas"] = maxi(r["pistas"], int(e.get("pistas", 0)))
		if not r["superado"]:
			r["intentos_hasta_superar"] += 1
			if e.get("exito", false):
				r["superado"] = true
	return por_nivel
