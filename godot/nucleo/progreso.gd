## Progreso del jugador: estrellas por nivel, cuerda y ajustes. Se guarda en el propio teléfono (user://).
##
## Sin datos personales. Si el archivo falta o está dañado, se empieza de cero sin romper nada;
## antes de sobrescribir se guarda una copia del archivo anterior.
extends RefCounted

const Cuerda = preload("res://nucleo/cuerda.gd")

const RUTA := "user://progreso.json"
const VERSION := 1

var estrellas := {}     # id de nivel (String) -> 0..3
var ajustes := {"sonido": true, "vibracion": true, "alto_contraste": false, "reducir_movimiento": false, "texto_grande": false}
var cuerda := {"n": Cuerda.MAXIMO, "t": 0}
var en_curso := 0        # nivel nuevo ya pagado y aún sin superar (no se vuelve a cobrar)
var tema := "pop"        # tema elegido en Ajustes › Apariencia (nucleo/temas.gd)
var ruta := RUTA


func _init(ruta_archivo: String = RUTA) -> void:
	ruta = ruta_archivo
	cargar()


func cargar() -> void:
	estrellas = {}
	ajustes = {"sonido": true, "vibracion": true, "alto_contraste": false, "reducir_movimiento": false, "texto_grande": false}
	cuerda = {"n": Cuerda.MAXIMO, "t": 0}
	en_curso = 0
	tema = "pop"
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
	var c = datos.get("cuerda", {})
	if typeof(c) == TYPE_DICTIONARY and c.has("n") and c.has("t"):
		cuerda = {"n": clampi(int(c["n"]), 0, Cuerda.MAXIMO), "t": int(c["t"])}
	en_curso = int(datos.get("en_curso", 0))
	if typeof(datos.get("tema")) == TYPE_STRING:
		tema = datos["tema"]


func guardar() -> void:
	if FileAccess.file_exists(ruta):
		DirAccess.copy_absolute(ProjectSettings.globalize_path(ruta), ProjectSettings.globalize_path(ruta.get_basename() + ".anterior.json"))
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		push_warning("No se pudo guardar el progreso en %s" % ruta)
		return
	f.store_string(JSON.stringify({"version": VERSION, "estrellas": estrellas, "ajustes": ajustes,
		"cuerda": cuerda, "en_curso": en_curso, "tema": tema}, " "))


## Guarda las estrellas de un nivel solo si mejoran las que ya tenía. `id` es el número del nivel o
## una clave de texto (por ejemplo «dia:2026-11-18» para la Caída del Día).
func registrar(id, n: int) -> void:
	var k := str(id)
	var cambia := false
	if n > int(estrellas.get(k, 0)):
		estrellas[k] = n
		cambia = true
	if n > 0 and typeof(id) == TYPE_INT and id == en_curso:
		en_curso = 0
		cambia = true
	if cambia:
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
		if not str(k).begins_with("dia:"):
			s += int(estrellas[k])
	return s


# ---------------------------------------------------------------- cuerda

func cuerdas(ahora: int) -> int:
	return Cuerda.al_dia(cuerda, ahora)["n"]


func falta_cuerda(ahora: int) -> int:
	return Cuerda.falta(cuerda, ahora)


## ¿Cuesta cuerda empezar este nivel ahora? Solo los nuevos (sin superar), a partir del 16, y no si
## ya se pagó al entrar antes.
func cobra(id: int) -> bool:
	return Cuerda.necesita(id) and de(id) == 0 and en_curso != id


## Empieza un nivel de la campaña: cobra la cuerda si toca. Devuelve false si no queda cuerda.
func empezar(id: int, ahora: int) -> bool:
	if not cobra(id):
		return true
	var nueva := Cuerda.gastar(cuerda, ahora)
	if nueva.is_empty():
		return false
	cuerda = nueva
	en_curso = id
	guardar()
	return true
