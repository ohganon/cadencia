## Taller: códigos de texto para compartir niveles sin servidor, y la lista de niveles propios.
##
## Formato (el mismo que prototipos/simulacion/sim.py): "DING1-" + base64url sin relleno de los
## datos JSON del nivel comprimidos con zlib. El JSON lleva el nivel (nivel_a_dict) y, en «s», la
## solución del autor redondeada a décimas: quien recibe el código sabe que tiene solución y puede
## usarla de pista.
##
## Un código es texto que llega de cualquiera, así que se comprueba todo antes de jugarlo: tamaño
## (máximo 64 KB descomprimido, contra las «bombas» de compresión), estructura, límites y que la
## solución que trae supere de verdad el nivel. Las reglas son las de sim.validar_nivel_taller.
extends RefCounted

const Sim = preload("res://nucleo/simulacion.gd")

const PREFIJO := "DING1-"
const MAXIMO_DESCOMPRIMIDO := 65536
const MAXIMO_CODIGO := 20000
const LIMITES := {"campanas": 6, "numeradas": 4, "muros": 12, "puertas": 6, "fichas": 400,
	"tramos": 8, "puntos": 600, "id": 8, "periodo": 200}
const TIPOS_CAMPANA := ["simple", "doble", "numerada", "dorada"]
const RUTA := "user://taller.json"


# ---------------------------------------------------------------- códigos

## Código para compartir el nivel con la solución de su autor.
static func codificar(nivel: Dictionary, solucion: Array) -> String:
	var d := nivel.duplicate(true)
	var s := []
	for t in solucion:
		var puntos := []
		for p in t["puntos"]:
			puntos.append([snappedf(p[0], 0.1), snappedf(p[1], 0.1)])
		s.append([puntos, t["padre"], int(t["desde"])])
	d["s"] = s
	var bytes := JSON.stringify(d, "", true).to_utf8_buffer()
	var comprimido := bytes.compress(FileAccess.COMPRESSION_DEFLATE)
	var b64 := Marshalls.raw_to_base64(comprimido)
	return PREFIJO + b64.replace("+", "-").replace("/", "_").rstrip("=")


## Abre un código. Devuelve {ok: bool, error: String, nivel: Dictionary, solucion: Array}.
static func decodificar(codigo: String) -> Dictionary:
	var malo := func(motivo: String) -> Dictionary: return {"ok": false, "error": motivo, "nivel": {}, "solucion": []}
	codigo = codigo.strip_edges()
	if not codigo.begins_with(PREFIJO) or codigo.length() > MAXIMO_CODIGO:
		return malo.call("Eso no parece un código de Dingfall.")
	var cuerpo := codigo.substr(PREFIJO.length())
	var regex := RegEx.create_from_string("^[A-Za-z0-9_-]+$")
	if cuerpo.is_empty() or regex.search(cuerpo) == null:
		return malo.call("El código está incompleto o tiene caracteres raros.")
	cuerpo = cuerpo.replace("-", "+").replace("_", "/")
	while cuerpo.length() % 4 != 0:
		cuerpo += "="
	var comprimido := Marshalls.base64_to_raw(cuerpo)
	if comprimido.is_empty():
		return malo.call("El código está incompleto.")
	var bytes := comprimido.decompress_dynamic(MAXIMO_DESCOMPRIMIDO, FileAccess.COMPRESSION_DEFLATE)
	if bytes.is_empty() or bytes.size() >= MAXIMO_DESCOMPRIMIDO:
		return malo.call("El código está dañado.")
	var json := JSON.new()
	if json.parse(bytes.get_string_from_utf8()) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return malo.call("El código está dañado.")
	var d: Dictionary = json.data
	var motivo := validar_nivel(d)
	if motivo != "":
		return malo.call(motivo)
	var solucion := []
	if d.has("s"):
		motivo = _validar_solucion(d["s"], d)
		if motivo != "":
			return malo.call(motivo)
		for t in d["s"]:
			solucion.append({"puntos": t[0], "padre": t[1], "desde": int(t[2])})
		if not Sim.simular(d, solucion)["exito"]:
			return malo.call("La solución que trae el código no supera el nivel.")
	d.erase("s")
	return {"ok": true, "error": "", "nivel": d, "solucion": solucion}


static func _numero(x, minimo: float, maximo: float) -> bool:
	if typeof(x) != TYPE_INT and typeof(x) != TYPE_FLOAT:
		return false
	var f := float(x)
	return is_finite(f) and f >= minimo and f <= maximo


static func _punto(p, d: Dictionary) -> bool:
	return typeof(p) == TYPE_ARRAY and p.size() == 2 and _numero(p[0], 0, d["w"]) and _numero(p[1], 0, d["h"])


## "" si el nivel es válido; si no, el motivo (mismas reglas que sim.validar_nivel_taller).
static func validar_nivel(d: Dictionary) -> String:
	for clave in ["v", "w", "h", "i", "f", "m", "c", "mu", "p"]:
		if not d.has(clave):
			return "Faltan datos del nivel."
	if not (_numero(d["v"], 1, 1) and _numero(d["w"], 100, 100) and _numero(d["h"], 160, 160)):
		return "El código es de otra versión del juego."
	if not _punto(d["i"], d):
		return "El inicio está fuera del tablero."
	if not (_numero(d["f"], 2, LIMITES["fichas"]) and _numero(d["m"], 0, float(d["f"]) if _numero(d["f"], 2, LIMITES["fichas"]) else 0)):
		return "El número de fichas no es válido."
	var c = d["c"]
	if typeof(c) != TYPE_ARRAY or c.size() < 1 or c.size() > LIMITES["campanas"]:
		return "Un nivel lleva entre 1 y 6 campanas."
	var ids := {}
	var numeros := []
	for x in c:
		if typeof(x) != TYPE_ARRAY or x.size() != 4 or typeof(x[0]) != TYPE_STRING or x[0].length() == 0 \
				or x[0].length() > LIMITES["id"] or not _punto(x[1], d) or not (x[2] in TIPOS_CAMPANA) \
				or not _numero(x[3], 0, LIMITES["numeradas"]):
			return "Hay una campana que no es válida."
		ids[x[0]] = true
		if x[2] == "numerada":
			numeros.append(int(x[3]))
	if ids.size() != c.size():
		return "Hay campanas repetidas."
	var doradas := 0
	for x in c:
		if x[2] == "dorada":
			doradas += 1
	if doradas > 1 or doradas == c.size():
		return "Como mucho una campana dorada, y no puede ser la única."
	numeros.sort()
	for k in numeros.size():
		if numeros[k] != k + 1:
			return "Las campanas numeradas tienen que ir 1, 2, 3…"
	if typeof(d["mu"]) != TYPE_ARRAY or d["mu"].size() > LIMITES["muros"]:
		return "Hay demasiados muros."
	for m in d["mu"]:
		if typeof(m) != TYPE_ARRAY or m.size() != 2 or not _punto(m[0], d) or not _punto(m[1], d):
			return "Hay un muro que no es válido."
	if typeof(d["p"]) != TYPE_ARRAY or d["p"].size() > LIMITES["puertas"]:
		return "Hay demasiadas puertas."
	for p in d["p"]:
		if typeof(p) != TYPE_ARRAY or p.size() != 5 or not _punto(p[0], d) or not _punto(p[1], d) \
				or not _numero(p[2], 2, LIMITES["periodo"]) or not _numero(p[3], 1, float(p[2]) if _numero(p[2], 2, LIMITES["periodo"]) else 1) \
				or not _numero(p[4], 0, LIMITES["periodo"]):
			return "Hay una puerta que no es válida."
	return ""


static func _validar_solucion(s, d: Dictionary) -> String:
	if typeof(s) != TYPE_ARRAY or s.size() < 1 or s.size() > LIMITES["tramos"]:
		return "La solución del código no es válida."
	for k in s.size():
		var t = s[k]
		if typeof(t) != TYPE_ARRAY or t.size() != 3 or typeof(t[0]) != TYPE_ARRAY or t[0].size() < 2 \
				or t[0].size() > LIMITES["puntos"]:
			return "La solución del código no es válida."
		for p in t[0]:
			if not _punto(p, d):
				return "La solución del código no es válida."
		if k == 0 and t[1] != null:
			return "La solución del código no es válida."
		if k > 0 and not (_numero(t[1], 0, k - 1) and _numero(t[2], 0, LIMITES["puntos"])):
			return "La solución del código no es válida."
	return ""


## Quita puntos casi alineados del trazo del dedo (Ramer-Douglas-Peucker) para que el código sea
## corto. Hay que volver a simular después: si deja de superar el nivel, se usa el trazo original.
static func simplificar(puntos: Array, tolerancia := 0.25) -> Array:
	if puntos.size() < 3:
		return puntos.duplicate()
	var a: Array = puntos[0]
	var b: Array = puntos[-1]
	var peor := 0.0
	var indice := 0
	for i in range(1, puntos.size() - 1):
		var d := _distancia(puntos[i], a, b)
		if d > peor:
			peor = d
			indice = i
	if peor <= tolerancia:
		return [a, b]
	var izq := simplificar(puntos.slice(0, indice + 1), tolerancia)
	var der := simplificar(puntos.slice(indice), tolerancia)
	return izq.slice(0, izq.size() - 1) + der


static func _distancia(p: Array, a: Array, b: Array) -> float:
	var ax: float = a[0]
	var ay: float = a[1]
	var dx: float = b[0] - ax
	var dy: float = b[1] - ay
	var l2 := dx * dx + dy * dy
	var t := 0.0 if l2 == 0.0 else clampf(((p[0] - ax) * dx + (p[1] - ay) * dy) / l2, 0.0, 1.0)
	return Vector2(p[0] - (ax + t * dx), p[1] - (ay + t * dy)).length()


## Prepara la solución del autor para el código: simplifica cada trazo y comprueba que, redondeada
## como irá en el código, sigue superando el nivel. Si no, la devuelve sin simplificar.
static func solucion_para_codigo(nivel: Dictionary, tramos: Array) -> Array:
	var corta := []
	for t in tramos:
		corta.append({"puntos": simplificar(t["puntos"]), "padre": t["padre"], "desde": int(t["desde"])})
	for candidata in [corta, tramos]:
		var abierto := decodificar(codificar(nivel, candidata))
		if abierto["ok"]:
			return candidata
	return []


# ---------------------------------------------------------------- borrador del editor

const RUTA_BORRADOR := "user://taller_borrador.json"


## Nivel vacío para empezar: el inicio abajo en el centro y nada más.
static func nivel_vacio() -> Dictionary:
	return {"v": 1, "w": 100, "h": 160, "i": [50.0, 148.0], "f": 400, "m": 0, "c": [], "mu": [], "p": []}


static func cargar_borrador(ruta := RUTA_BORRADOR) -> Dictionary:
	if FileAccess.file_exists(ruta):
		var json := JSON.new()
		if json.parse(FileAccess.get_file_as_string(ruta)) == OK and typeof(json.data) == TYPE_DICTIONARY:
			var d: Dictionary = json.data
			d["f"] = 400
			d["m"] = 0
			# Un borrador puede no tener campanas todavía: se valida con una de prueba
			var prueba := d.duplicate(true)
			if typeof(prueba.get("c")) == TYPE_ARRAY and prueba["c"].is_empty():
				prueba["c"] = [["x", [50.0, 20.0], "simple", 0]]
			if validar_nivel(prueba) == "":
				return d
	return nivel_vacio()


static func guardar_borrador(nivel: Dictionary, ruta := RUTA_BORRADOR) -> void:
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(nivel))


## Texto del objetivo de un nivel del Taller según sus campanas.
static func objetivo(nivel: Dictionary) -> String:
	var simples := 0
	var dobles := 0
	var numeradas := 0
	var dorada := false
	for c in nivel["c"]:
		match c[2]:
			"doble": dobles += 1
			"numerada": numeradas += 1
			"dorada": dorada = true
			_: simples += 1
	var partes := []
	if numeradas > 0:
		partes.append("las numeradas [b]en orden[/b]")
	if dobles > 0:
		partes.append("la [b]campana doble[/b] con dos ramas a la vez" if dobles == 1 else "las [b]campanas dobles[/b]")
	if simples > 0:
		partes.append("[b]la campana[/b]" if simples == 1 else "[b]las %d campanas[/b]" % simples)
	var texto := "Haz sonar " + ", ".join(partes) + "."
	if dorada:
		texto += " [b]Extra:[/b] la campana dorada da la tercera estrella."
	return texto


# ---------------------------------------------------------------- mis niveles

## Lista de niveles guardados en el teléfono: {codigo, titulo, fecha, propio}.
static func cargar_lista(ruta := RUTA) -> Array:
	if not FileAccess.file_exists(ruta):
		return []
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(ruta)) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return []
	var lista = json.data.get("niveles", [])
	return lista if typeof(lista) == TYPE_ARRAY else []


static func guardar_en_lista(entrada: Dictionary, ruta := RUTA) -> void:
	var lista := cargar_lista(ruta)
	for e in lista:
		if e.get("codigo") == entrada["codigo"]:
			return          # ya estaba
	lista.push_front(entrada)
	lista = lista.slice(0, 50)          # como mucho 50 niveles guardados
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({"version": 1, "niveles": lista}, " "))


static func borrar_de_lista(codigo: String, ruta := RUTA) -> void:
	var lista := cargar_lista(ruta).filter(func(e): return e.get("codigo") != codigo)
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({"version": 1, "niveles": lista}, " "))
