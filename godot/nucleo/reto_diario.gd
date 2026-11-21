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
	"puerta": "Cruza la [b]puerta[/b] cuando esté abierta y haz sonar la campana.",
	"dos_puertas": "Cruza [b]las dos puertas[/b], cada una en su momento.",
	"espiral": "Pasa por la [b]espiral[/b] si necesitas llegar más tarde a la puerta.",
	"espiral_doble": "Haz sonar la [b]campana doble[/b]: una espiral retrasa la rama que llegaría antes.",
	"muelle": "Hay un muro de lado a lado: llega al [b]muelle[/b] y sigue dibujando desde su salida.",
	"muelle_doble": "Haz sonar la [b]campana doble[/b]: una rama rodea el muro y la otra salta con el muelle.",
	"interruptor": "Pisa la [b]placa[/b] con una rama para abrir la compuerta, y crúzala después.",
	"noria": "Un muro de lado a lado: la [b]noria[/b] lleva la cadena al otro lado en su siguiente vuelta.",
	"noria_doble": "Haz sonar la [b]campana doble[/b]: las dos norias sueltan las ramas a la vez, aunque lleguen a destiempo.",
	"globo": "La campana queda lejos de tus fichas: revienta el [b]globo[/b] y su camino llegará por ti.",
	"globo_doble": "Revienta los dos [b]globos[/b], cada uno a su tiempo, para que sus caminos lleguen a la vez a la campana doble.",
	"cristal": "Una rama rompe el [b]cristal[/b] (y se queda ahí); la otra tiene que llegar después.",
	"cristal_espiral": "Una rama rompe el [b]cristal[/b]; la otra puede esperar en la [b]espiral[/b] para cruzar después.",
	"interruptor_espiral": "Pisa la [b]placa[/b] con una rama; la otra puede esperar en la [b]espiral[/b] a que se abra la compuerta.",
	"muelle_puerta": "Salta el muro con el [b]muelle[/b], pero llega a él a tiempo: detrás hay una [b]puerta[/b].",
	"globo_puerta": "El camino del [b]globo[/b] cruza una [b]puerta[/b]: revienta el globo en el momento justo.",
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
