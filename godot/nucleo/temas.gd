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
	"estrella": "#ffd400", "camino": "#ffffff", "camino_no": "#7a7a7a", "acento": "#ffd400"}
## Texto grande (Ajustes › Accesibilidad): todos los textos de la interfaz, un 15 % más grandes
const ESCALA_GRANDE := 1.15
## Las medidas de la maqueta (bordes, sombras, radios, texturas) están en px de un teléfono dibujado
## pequeño; la pantalla del juego mide 720 px de ancho y sus letras son unas 2,2–2,4 veces las de la
## maqueta. Con este factor, botones, ventanas y nodos guardan las proporciones del catálogo.
const ESCALA := 2.2

static var _todos: Array = []
static var activo: Dictionary = {}     # tema en uso, con los colores ya convertidos
static var alto_contraste := false
static var texto_grande := false
static var reducir_movimiento := false   # sin animaciones decorativas (escenas/comun/animar.gd)


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
	# La estrella no conseguida: el papel de la ventana con un velo de su tinta (no un azul fijo)
	var papel := ui("ventana")
	papel.a = 1.0
	Iconos.apagada = papel.lerp(ui("ventana_t"), 0.12)


## Aplica los ajustes de accesibilidad que afectan a toda la interfaz y vuelve a preparar el tema.
static func accesibilidad(ajustes: Dictionary) -> void:
	alto_contraste = ajustes.get("alto_contraste", false)
	texto_grande = ajustes.get("texto_grande", false)
	reducir_movimiento = ajustes.get("reducir_movimiento", false)
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


## Estilo de una caja de la maqueta (boton_p, boton_s, boton_s_ventana, nodo_h, nodo_a, nodo_c, ventana,
## panel, chip, tablero), ya en px del juego:
## {fondo, borde, borde_color, radio (-1 = círculo o pastilla), sombras: [{pos, desenfoque, extension,
## color, dentro}], texto}. Con alto contraste, un estilo propio: tinta negra, bordes y sombra sólida.
static func caja(nombre: String) -> Dictionary:
	var e: Dictionary = _activo().get("estilo", {}).get(nombre, {})
	var c := {"fondo": _color(e.get("fondo")), "borde": 0.0, "borde_color": Color(0, 0, 0, 0), "radio": 0.0,
		"sombras": [], "texto": _color(e.get("texto"))}
	var b = e.get("borde", [0, null])
	if typeof(b) == TYPE_ARRAY and b.size() == 2 and b[1] != null and float(b[0]) > 0:
		c["borde"] = maxf(1.0, float(b[0]) * ESCALA)
		c["borde_color"] = _color(b[1])
	var r := float(e.get("radio", 0))
	c["radio"] = -1.0 if r < 0 or r >= 999 else r * ESCALA
	for s in e.get("sombras", []):
		c["sombras"].append({"pos": Vector2(float(s["x"]), float(s["y"])) * ESCALA, "desenfoque": float(s["desenfoque"]) * ESCALA,
			"extension": float(s["extension"]) * ESCALA, "color": _color(s["color"]), "dentro": bool(s["dentro"])})
	if alto_contraste:
		_contrastar(nombre, c)
	return c


## Alto contraste: las cajas toman los colores de UI_CONTRASTE con borde negro y sombra sólida.
static func _contrastar(nombre: String, c: Dictionary) -> void:
	var negro := Color.BLACK
	var claves := {"boton_p": ["prim", "prim_t"], "boton_s": ["sec", "sec_t"], "boton_s_ventana": ["sec", "sec_t"],
		"nodo_h": ["nodo_h", "marco"], "nodo_a": ["prim", "prim_t"], "nodo_c": ["nodo_c", "texto"],
		"ventana": ["ventana", "ventana_t"], "panel": ["ventana", "ventana_t"], "chip": ["chip", "chip_t"]}
	if claves.has(nombre):
		c["fondo"] = ui(claves[nombre][0])
		c["texto"] = ui(claves[nombre][1])
	c["borde"] = 2.0 * ESCALA if nombre != "tablero" else 2.0
	c["borde_color"] = negro
	c["sombras"] = []
	if nombre.begins_with("boton"):
		c["sombras"] = [{"pos": Vector2(0, 3) * ESCALA, "desenfoque": 0.0, "extension": 0.0, "color": negro, "dentro": false}]


## Datos del estilo que no son cajas: «brillo», «pulsar», «desactivado», «aviso», «pantalla»…
static func estilo(clave: String, defecto = null):
	return _activo().get("estilo", {}).get(clave, defecto)


## ¿Van en mayúsculas los títulos / los botones de este tema? Y su espaciado entre letras (en em).
static func mayus(uso: String) -> bool:
	return bool(estilo(uso, {}).get("mayus", false))


static func espaciado(uso: String) -> float:
	return float(estilo(uso, {}).get("espaciado", 0.0))


## Caja de la maqueta como StyleBoxFlat (ventanas, tarjetas): fondo, borde, radio y la primera sombra de
## fuera. Las sombras duras (sin desenfoque) salen casi nítidas; las suaves, con su desenfoque.
static func stylebox(nombre: String, margenes := Vector4.ZERO) -> StyleBoxFlat:
	var c := caja(nombre)
	var s := StyleBoxFlat.new()
	s.bg_color = c["fondo"]
	s.set_corner_radius_all(int(c["radio"]) if c["radio"] >= 0 else 999)
	s.set_border_width_all(int(round(c["borde"])))
	s.border_color = c["borde_color"]
	s.anti_aliasing = true
	for sombra in c["sombras"]:
		if sombra["dentro"]:
			continue
		s.shadow_color = sombra["color"]
		s.shadow_offset = sombra["pos"]
		# CSS: desenfoque y extensión (negativa = la sombra asoma menos); Godot solo tiene un tamaño
		s.shadow_size = maxi(1, int(round((sombra["desenfoque"] + minf(sombra["extension"], 0.0)) * 0.5)))
		break
	s.content_margin_left = margenes.x
	s.content_margin_top = margenes.y
	s.content_margin_right = margenes.z
	s.content_margin_bottom = margenes.w
	return s


## Cómo se llama el barrio n en la cinta del mapa: «Barrio 3», «Barrio III» (Mesa) o «Tercer barrio» (Calma).
static func texto_barrio(n: int) -> String:
	match texto("barrio", "numero"):
		"romano":
			var romanos := ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]
			return "Barrio " + (romanos[n - 1] if n >= 1 and n <= romanos.size() else str(n))
		"ordinal":
			var ordinales := ["Primer", "Segundo", "Tercer", "Cuarto", "Quinto", "Sexto", "Séptimo", "Octavo", "Noveno", "Décimo"]
			return (ordinales[n - 1] if n >= 1 and n <= ordinales.size() else str(n) + "º") + " barrio"
	return "Barrio %d" % n


## «Jugar · nivel 16», «Continuar», «Rodar nivel 16», «Nivel 16 →»… según el tono del tema.
static func texto_jugar(nivel: int) -> String:
	var t := texto("jugar", "Jugar · nivel %d")
	return t % nivel if "%d" in t else t


static func _color(v) -> Color:
	if typeof(v) == TYPE_COLOR:
		return v
	return Color(v) if typeof(v) == TYPE_STRING and v != "" else Color(0, 0, 0, 0)


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
