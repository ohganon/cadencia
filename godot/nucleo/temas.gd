## Los 11 temas de Dingfall (datos/temas.json, generado por prototipos/generador/temas.py a partir
## de la maqueta docs/fase6/temas/index.html).
##
## Un tema cambia colores, radios y el tono de unos pocos textos; nunca las reglas, los niveles ni el
## progreso. Dominó Pop es gratis y el tema por defecto; los otros diez son del Dingclub.
##
## El tema activo vive aquí, en variables estáticas, para que cualquier script lo lea con
## `Temas.ui("pantalla")` (los autoloads no se pueden nombrar al compilar las pruebas sin pantalla).
## Lo elige el autoload Tema al arrancar; las pantallas leen sus colores al construirse.
extends RefCounted

const RUTA := "res://datos/temas.json"
const POR_DEFECTO := "pop"
const Iconos = preload("res://escenas/comun/iconos.gd")

## Alto contraste en la interfaz (Ajustes › Accesibilidad): pantalla negra, ventanas y botones
## blancos con tinta negra y amarillo para lo principal. Manda sobre el tema elegido; el tablero
## tiene su propia paleta de alto contraste (escenas/partida/tablero.gd).
const UI_CONTRASTE := {"pantalla": "#000000", "texto": "#ffffff", "suave": "#e6e6e6", "marco": "#000000",
	"chip": "#ffffff", "chip_t": "#000000", "prim": "#ffd400", "prim_t": "#000000", "prim_labio": "#c9a700",
	"sec": "#ffffff", "sec_t": "#000000", "sec_labio": "#cccccc", "nodo_h": "#ffd400", "nodo_c": "#5c5c5c",
	"ventana": "#ffffff", "ventana_t": "#000000", "ventana_s": "#1f1f1f", "velo": "#000000cc",
	"estrella": "#ffd400", "camino": "#ffffff", "camino_no": "#7a7a7a"}
## Texto grande (Ajustes › Accesibilidad): todos los textos de la interfaz, un 15 % más grandes
const ESCALA_GRANDE := 1.15

static var _todos: Array = []
static var activo: Dictionary = {}     # tema en uso, con los colores ya convertidos
static var alto_contraste := false
static var texto_grande := false


## Cambia el tema activo (no lo guarda: eso lo hace quien tenga el progreso abierto).
static func usar(id) -> void:
	activo = de(id)
	if alto_contraste:
		for clave in UI_CONTRASTE:
			activo["ui"][clave] = Color(UI_CONTRASTE[clave])
		activo["sombra_solida"] = true
	# Los iconos se dibujan con funciones estáticas: se les da la tinta y la estrella del tema
	Iconos.tinta = ui("marco")
	Iconos.estrella = ui("estrella")


## Aplica los ajustes de accesibilidad que afectan a toda la interfaz y vuelve a preparar el tema.
static func accesibilidad(ajustes: Dictionary) -> void:
	alto_contraste = ajustes.get("alto_contraste", false)
	texto_grande = ajustes.get("texto_grande", false)
	usar(id_activo() if not activo.is_empty() else POR_DEFECTO)


## Tamaño de letra con el ajuste de texto grande.
static func tam(n: int) -> int:
	return int(round(n * ESCALA_GRANDE)) if texto_grande else n


static func _activo() -> Dictionary:
	if activo.is_empty():
		usar(POR_DEFECTO)
	return activo


static func id_activo() -> String:
	return _activo()["id"]


static func ui(clave: String) -> Color:
	return _activo()["ui"].get(clave, Color.MAGENTA)


static func tablero(clave: String) -> Color:
	var v = _activo()["tablero"].get(clave, Color.MAGENTA)
	return v if typeof(v) == TYPE_COLOR else Color.MAGENTA


## Número del tema activo (radio_boton, radio_ventana, grosor del borde del tablero…).
static func numero(clave: String, defecto: int) -> int:
	var v = _activo().get(clave, _activo()["tablero"].get(clave, defecto))
	return int(v) if typeof(v) in [TYPE_INT, TYPE_FLOAT] else defecto


static func sombra_solida() -> bool:
	return _activo().get("sombra_solida", true)


## Texto con el tono del tema («¡A tumbar!», «Soltar», «Encender»…).
static func texto(clave: String, defecto: String) -> String:
	var t = _activo().get("textos", {}).get(clave)
	return t if typeof(t) == TYPE_STRING and t != "" else defecto


## Tinta para escribir encima de `fondo`: la del texto de las ventanas o la de la pantalla, la que
## más contraste. Un fondo casi transparente cuenta como la pantalla.
static func tinta_sobre(fondo: Color) -> Color:
	var a := ui("ventana_t")
	var b := ui("texto")
	if fondo.a < 0.5:
		fondo = ui("pantalla")
	if contraste(a, b) < 1.5:
		b = Color.WHITE if _luminancia(a) < 0.5 else Color("#111111")
	return sobre(fondo, a, b)


## Lista de temas tal como vienen en el JSON (colores en texto "#rrggbbaa").
static func todos() -> Array:
	if _todos.is_empty():
		var datos = JSON.parse_string(FileAccess.get_file_as_string(RUTA))
		if typeof(datos) == TYPE_DICTIONARY and typeof(datos.get("temas")) == TYPE_ARRAY:
			_todos = datos["temas"]
	return _todos


static func existe(id) -> bool:
	return typeof(id) == TYPE_STRING and not _crudo(id).is_empty()


## Tema listo para usar: los colores ya convertidos a Color. Si el id no existe, Dominó Pop.
static func de(id) -> Dictionary:
	var t := _crudo(id)
	if t.is_empty():
		t = _crudo(POR_DEFECTO)
	var r := t.duplicate(true)
	for grupo in ["ui", "tablero"]:
		for clave in r[grupo]:
			var v = r[grupo][clave]
			if typeof(v) == TYPE_STRING:
				r[grupo][clave] = Color(v)
			elif v == null:
				r[grupo][clave] = Color(0, 0, 0, 0)
	return r


## Tinta que se lee mejor encima de `fondo`: la más oscura o la más clara de las que da el tema.
static func sobre(fondo: Color, oscura: Color, clara: Color) -> Color:
	return oscura if contraste(fondo, oscura) >= contraste(fondo, clara) else clara


## Contraste WCAG entre dos colores opacos (1 a 21).
static func contraste(a: Color, b: Color) -> float:
	var la := _luminancia(a)
	var lb := _luminancia(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


static func _luminancia(c: Color) -> float:
	var canales := []
	for v in [c.r, c.g, c.b]:
		canales.append(v / 12.92 if v <= 0.03928 else pow((v + 0.055) / 1.055, 2.4))
	return 0.2126 * canales[0] + 0.7152 * canales[1] + 0.0722 * canales[2]


static func _crudo(id) -> Dictionary:
	for t in todos():
		if t.get("id") == id:
			return t
	return {}
