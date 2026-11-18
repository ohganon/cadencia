## Progreso del jugador: estrellas por nivel. Se guarda en el propio teléfono (user://).
##
## Sin datos personales. Si el archivo falta o está dañado, se empieza de cero sin romper nada;
## antes de sobrescribir se guarda una copia del archivo anterior.
extends RefCounted

const RUTA := "user://progreso.json"
const VERSION := 1

var estrellas := {}     # id de nivel (String) -> 0..3
var ajustes := {"sonido": true, "vibracion": true}
var ruta := RUTA


func _init(ruta_archivo: String = RUTA) -> void:
	ruta = ruta_archivo
	cargar()


func cargar() -> void:
	estrellas = {}
	ajustes = {"sonido": true, "vibracion": true}
	if not FileAccess.file_exists(ruta):
		return
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(ruta)) != OK:
		return          # archivo dañado: se empieza de cero (la copia anterior sigue en disco)
	var datos = json.data
	if typeof(datos) != TYPE_DICTIONARY or int(datos.get("version", 0)) != VERSION:
		return
	var a = datos.get("ajustes", {})
	if typeof(a) == TYPE_DICTIONARY:
		for k in ajustes:
			if typeof(a.get(k)) == TYPE_BOOL:
				ajustes[k] = a[k]
	var e = datos.get("estrellas", {})
	if typeof(e) == TYPE_DICTIONARY:
		for k in e:
			estrellas[str(k)] = clampi(int(e[k]), 0, 3)


func guardar() -> void:
	if FileAccess.file_exists(ruta):
		DirAccess.copy_absolute(ProjectSettings.globalize_path(ruta), ProjectSettings.globalize_path(ruta.get_basename() + ".anterior.json"))
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		push_warning("No se pudo guardar el progreso en %s" % ruta)
		return
	f.store_string(JSON.stringify({"version": VERSION, "estrellas": estrellas, "ajustes": ajustes}, " "))


## Guarda las estrellas de un nivel solo si mejoran las que ya tenía. `id` es el número del nivel o
## una clave de texto (por ejemplo «dia:2026-11-18» para la Caída del Día).
func registrar(id, n: int) -> void:
	var k := str(id)
	if n > int(estrellas.get(k, 0)):
		estrellas[k] = n
		guardar()


func ajustar(clave: String, valor: bool) -> void:
	ajustes[clave] = valor
	guardar()


func de(id) -> int:
	return int(estrellas.get(str(id), 0))


## Un nivel está abierto si es el primero o si el anterior está superado.
func abierto(id: int) -> bool:
	return id <= 1 or de(id - 1) > 0


func total() -> int:
	var s := 0
	for k in estrellas:
		s += int(estrellas[k])
	return s
