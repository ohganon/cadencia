## La Caída del Día: un nivel por fecha UTC, el mismo para todo el mundo y sin servidor.
##
## Los niveles se generan en el ordenador (prototipos/generador/generador.py) y viajan con el juego
## en res://datos/caida_del_dia.json, un año cada vez. Así son idénticos en todos los teléfonos sin
## depender de que Godot y Python hagan las mismas cuentas al generar. Si la fecha se sale del
## calendario (una versión antigua del juego), se repite el calendario en bucle, también igual para
## todos. Se renueva con cada actualización del juego.
extends RefCounted

const RUTA := "res://datos/caida_del_dia.json"
const SEGUNDOS_DIA := 86400

## Texto del objetivo según el tipo de nivel generado
const OBJETIVOS := {
	"simple": "Llega a la [b]campana[/b] esquivando los muros.",
	"dos": "Haz sonar [b]las dos campanas[/b]: abre una rama desde una ficha puesta.",
	"numeradas": "Las campanas suenan [b]en orden[/b]: la 1 antes que la 2.",
	"doble": "Haz sonar la [b]campana doble[/b]: las dos ramas tienen que llegar a la vez.",
	"doble_y_simple": "Haz sonar la [b]campana[/b] y la [b]campana doble[/b].",
}

var desde := ""
var niveles: Array = []


func _init(ruta := RUTA) -> void:
	var datos = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(datos) == TYPE_DICTIONARY:
		desde = datos["desde"]
		niveles = datos["niveles"]


## Fecha UTC de hoy en formato AAAA-MM-DD.
static func hoy_utc() -> String:
	var f := Time.get_date_dict_from_system(true)
	return "%04d-%02d-%02d" % [f["year"], f["month"], f["day"]]


static func _dia(fecha: String) -> int:
	return int(floor(Time.get_unix_time_from_datetime_string(fecha + "T00:00:00") / SEGUNDOS_DIA))


## Entrada del calendario para una fecha (AAAA-MM-DD): {fecha, tipo, dificultad, nivel, solucion...}.
func de(fecha: String) -> Dictionary:
	if niveles.is_empty():
		return {}
	var i := posmod(_dia(fecha) - _dia(desde), niveles.size())
	var e: Dictionary = niveles[i].duplicate()
	e["fecha_jugada"] = fecha
	return e


func de_hoy() -> Dictionary:
	return de(hoy_utc())


## Texto para compartir el resultado (sin enlaces ni datos personales). Si se usó la pista, se dice:
## la comparación con los amigos tiene que ser honesta.
static func texto_compartir(fecha: String, exito: bool, fichas: int, estrellas: int, con_pista := false) -> String:
	var partes := fecha.split("-")
	var bonita := "%s/%s/%s" % [partes[2], partes[1], partes[0]]
	if exito:
		return "Dingfall · Caída del Día %s\nSuperada con %d fichas %s%s" % [bonita, fichas, "★".repeat(estrellas),
			" (con pista)" if con_pista else ""]
	return "Dingfall · Caída del Día %s\nHoy se me ha resistido" % bonita


static func objetivo(tipo: String) -> String:
	return OBJETIVOS.get(tipo, "Haz sonar todas las campanas.")
