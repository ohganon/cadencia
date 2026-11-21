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


## Texto del resumen para enviar desde una prueba a distancia (Ajustes › Resumen › Copiar resumen).
## Lleva lo que necesita la puerta 0 (docs/fase8/PRUEBA_PUERTA_0.md) y nada que identifique a nadie:
## fecha, plataforma, tiempo jugado, las medidas de la prueba y los intentos por nivel.
## `ids`: los niveles de la campaña en orden. `datos`: {plataforma, minutos, tema, ajustes, fecha}.
func texto_resumen(ids: Array, datos: Dictionary) -> String:
	var s := resumen()
	var eventos := leer()
	var dias := {}
	for e in eventos:
		if e.has("t"):
			dias[Time.get_date_string_from_unix_time(int(e["t"]))] = true
	var superados := 0
	var pistas := 0
	var mas_alla := 0          # niveles jugados después del 10 (¿quiso seguir?)
	for k in s:
		var r: Dictionary = s[k]
		if r["superado"]:
			superados += 1
		pistas += int(r["pistas"])
		if int(k) > 10:
			mas_alla += 1
	var sin_pista := func(desde: int, hasta: int) -> String:
		var n := 0
		for id in range(desde, hasta + 1):
			var r: Dictionary = s.get(str(id), {})
			if r.get("superado", false) and int(r.get("pistas", 0)) == 0:
				n += 1
		return "%d de %d" % [n, hasta - desde + 1]
	var l := []
	l.append("Dingfall · resumen de la prueba")
	l.append("Fecha: %s · %s" % [datos.get("fecha", Time.get_date_string_from_system()), datos.get("plataforma", OS.get_name())])
	l.append("Tiempo jugado (7 días): %d min · días con partidas: %d" % [int(datos.get("minutos", 0)), dias.size()])
	l.append("Niveles superados: %d · pistas usadas: %d" % [superados, pistas])
	l.append("Niveles 1–3 sin pista: %s" % sin_pista.call(1, 3))
	l.append("Niveles 7–9 sin pista: %s" % sin_pista.call(7, 9))
	l.append("Niveles jugados después del 10: %d" % mas_alla)
	l.append("Tema: %s · %s" % [datos.get("tema", ""), datos.get("ajustes", "")])
	l.append("")
	l.append("Nivel · intentos · hasta superarlo · pistas")
	var alguno := false
	for id in ids:
		var k := str(int(id))
		if s.has(k):
			alguno = true
			var r: Dictionary = s[k]
			l.append("%s · %d · %s · %d" % [k, r["intentos"], str(r["intentos_hasta_superar"]) if r["superado"] else "sin superar", r["pistas"]])
	if not alguno:
		l.append("Aún no hay partidas registradas.")
	return "\n".join(l)


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
