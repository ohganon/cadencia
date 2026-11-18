## Juego responsable (P-09, DFA art. 17): tiempo jugado y avisos que elige el jugador.
##
## Todo se queda en el teléfono (user://juego_responsable.json): segundos jugados por día (solo los
## últimos DIAS_GUARDADOS), cada cuánto avisar de un descanso y un límite diario opcional. Nada se
## envía a ningún sitio. Los avisos son suaves: el jugador puede seguir si quiere.
##
## Va en un archivo aparte del progreso porque lo actualiza el autoload Estado mientras se juega,
## y cada pantalla tiene su propia copia del progreso.
extends RefCounted

const RUTA := "user://juego_responsable.json"
const VERSION := 1
const DESCANSOS := [0, 20, 30, 45, 60]       # minutos de juego seguido antes de sugerir un descanso (0 = no)
const LIMITES := [0, 30, 60, 90, 120]        # límite diario en minutos (0 = sin límite)
const DIAS_GUARDADOS := 14
const SEGUNDOS_DIA := 86400

var dias := {}          # "AAAA-MM-DD" (fecha local) -> segundos jugados
var descanso := 0
var limite := 0
var ruta := RUTA


func _init(ruta_archivo: String = RUTA) -> void:
	ruta = ruta_archivo
	cargar()


func cargar() -> void:
	dias = {}
	descanso = 0
	limite = 0
	if not FileAccess.file_exists(ruta):
		return
	var datos = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(datos) != TYPE_DICTIONARY or int(datos.get("version", 0)) != VERSION:
		return
	var d = datos.get("dias", {})
	if typeof(d) == TYPE_DICTIONARY:
		for k in d:
			if typeof(k) == TYPE_STRING and k.length() == 10 and typeof(d[k]) in [TYPE_INT, TYPE_FLOAT]:
				dias[k] = maxi(int(d[k]), 0)
	if int(datos.get("descanso", 0)) in DESCANSOS:
		descanso = int(datos["descanso"])
	if int(datos.get("limite", 0)) in LIMITES:
		limite = int(datos["limite"])


func guardar() -> void:
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"version": VERSION, "dias": dias, "descanso": descanso, "limite": limite}, " "))


## Suma tiempo jugado a una fecha y olvida los días de hace más de DIAS_GUARDADOS.
func sumar(fecha: String, segundos: float) -> void:
	dias[fecha] = int(dias.get(fecha, 0)) + int(round(segundos))
	var hoy_d := _dia(fecha)
	for k in dias.keys():
		if hoy_d - _dia(k) >= DIAS_GUARDADOS:
			dias.erase(k)


func hoy(fecha: String) -> int:
	return int(dias.get(fecha, 0))


## Segundos jugados en los 7 días que terminan en `fecha` (incluida).
func semana(fecha: String) -> int:
	var hoy_d := _dia(fecha)
	var total := 0
	for k in dias:
		var d := hoy_d - _dia(k)
		if d >= 0 and d < 7:
			total += int(dias[k])
	return total


func limite_alcanzado(fecha: String) -> bool:
	return limite > 0 and hoy(fecha) >= limite * 60


## ¿Toca sugerir un descanso? `sesion` son los segundos de juego seguido y `avisos` los que ya se
## dieron en esta sesión: el siguiente aviso llega tras otro intervalo completo.
static func toca_descanso(sesion: float, minutos: int, avisos: int) -> bool:
	return minutos > 0 and sesion >= minutos * 60 * (avisos + 1)


static func siguiente(opciones: Array, actual: int) -> int:
	var k := opciones.find(actual)
	return opciones[(k + 1) % opciones.size()] if k >= 0 else opciones[0]


## «12 min», «1 h», «2 h 05 min».
static func texto_tiempo(segundos: int) -> String:
	var minutos := segundos / 60
	if minutos < 60:
		return "%d min" % minutos
	if minutos % 60 == 0:
		return "%d h" % (minutos / 60)
	return "%d h %02d min" % [minutos / 60, minutos % 60]


static func _dia(fecha: String) -> int:
	return int(floor(Time.get_unix_time_from_datetime_string(fecha + "T00:00:00") / SEGUNDOS_DIA))


## Fecha local de hoy (el día del jugador, no el UTC de la Caída del Día).
static func fecha_local() -> String:
	return Time.get_date_string_from_system()
