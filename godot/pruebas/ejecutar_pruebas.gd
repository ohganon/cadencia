## Pruebas del proyecto sin pantalla. Termina con código 0 si todo pasa.
##
## Uso (desde la raíz del repositorio):
##   Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://pruebas/ejecutar_pruebas.gd
##
## 1. Todos los scripts compilan.
## 2. Casos compartidos con Python: la simulación da exactamente los mismos resultados.
## 3. Partida: cada nivel se supera dibujando su solución como lo haría un dedo; límite de fichas,
##    enganche y deshacer.
## 4. Progreso: guardar, cargar y archivo dañado.
##
## Es un ejecutor mínimo sin dependencias. GUT se añadirá cuando haga falta probar escenas.
extends SceneTree

const SCRIPTS := ["res://nucleo/simulacion.gd", "res://nucleo/partida.gd", "res://nucleo/progreso.gd", "res://nucleo/registro.gd", "res://nucleo/reto_diario.gd", "res://nucleo/taller.gd",
	"res://escenas/partida/tablero.gd", "res://escenas/partida/partida.gd",
	"res://escenas/comun/iconos.gd", "res://escenas/comun/boton_pop.gd", "res://escenas/comun/pastilla.gd", "res://escenas/comun/estrellas.gd",
	"res://autoload/estado.gd", "res://escenas/taller/tablero_editor.gd", "res://escenas/taller/taller.gd",
	"res://nucleo/cuerda.gd", "res://escenas/mapa/camino.gd", "res://escenas/mapa/mapa.gd"]

var fallos := 0
var pasadas := 0


func _init() -> void:
	# Se cargan en tiempo de ejecución: si un script no compila, se informa y se sale con error en
	# lugar de quedarse esperando (que es lo que pasa con preload).
	for ruta in SCRIPTS:
		var s: GDScript = load(ruta)
		comprobar(s != null and s.can_instantiate(), "compila " + ruta)
	if fallos > 0:
		terminar()
		return
	var sim: GDScript = load("res://nucleo/simulacion.gd")
	var partida: GDScript = load("res://nucleo/partida.gd")
	var progreso: GDScript = load("res://nucleo/progreso.gd")
	casos_compartidos(sim)
	pruebas_partida(partida)
	pruebas_progreso(progreso)
	pruebas_registro(load("res://nucleo/registro.gd"))
	pruebas_sonidos()
	pruebas_reto(load("res://nucleo/reto_diario.gd"), sim)
	pruebas_taller(load("res://nucleo/taller.gd"), sim)
	pruebas_cuerda(load("res://nucleo/cuerda.gd"), progreso)
	pruebas_barrio(sim)
	terminar()


func pruebas_cuerda(Cuerda: GDScript, Progreso: GDScript) -> void:
	var t0 := 1_800_000_000
	var llena := {"n": 5, "t": 0}
	comprobar(Cuerda.al_dia(llena, t0)["n"] == 5 and Cuerda.falta(llena, t0) == 0, "llena: 5 cuerdas y nada que esperar")
	var c: Dictionary = Cuerda.gastar(llena, t0)
	comprobar(c["n"] == 4 and Cuerda.falta(c, t0) == 1800, "al gastar desde llena empieza la recarga de 30 minutos")
	comprobar(Cuerda.al_dia(c, t0 + 1799)["n"] == 4 and Cuerda.al_dia(c, t0 + 1800)["n"] == 5, "a los 30 minutos vuelve una cuerda")
	var vacia := {"n": 0, "t": t0}
	comprobar(Cuerda.gastar(vacia, t0).is_empty(), "sin cuerda no se puede gastar")
	comprobar(Cuerda.al_dia(vacia, t0 + 3 * 1800 + 60)["n"] == 3 and Cuerda.falta(vacia, t0 + 3 * 1800 + 60) == 1740,
		"tras 1 h 31 min hay 3 cuerdas y faltan 29 min para la cuarta")
	comprobar(Cuerda.al_dia(vacia, t0 + 100 * 1800)["n"] == 5, "nunca pasa del máximo")
	comprobar(Cuerda.al_dia({"n": 2, "t": t0}, t0 - 5000)["n"] == 2, "si el reloj va hacia atrás no se pierde cuerda")
	comprobar(Cuerda.reloj(760) == "12:40", "el contador se ve como 12:40")
	# Reglas de la Fase 5 sobre el progreso
	var ruta := "user://prueba_cuerda.json"
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))
	var p = Progreso.new(ruta)
	comprobar(not p.cobra(1) and not p.cobra(15), "los niveles 1–15 no gastan cuerda")
	comprobar(p.cobra(16), "el nivel 16, nuevo, gasta cuerda")
	comprobar(p.empezar(16, t0) and p.cuerdas(t0) == 4, "empezar el 16 cuesta una cuerda")
	comprobar(p.empezar(16, t0 + 10) and p.cuerdas(t0 + 10) == 4, "salir y volver a entrar sin superarlo no cobra otra vez")
	p.registrar(16, 2)
	comprobar(not p.cobra(16) and p.empezar(16, t0 + 20) and p.cuerdas(t0 + 20) == 4, "repetir un nivel superado es gratis")
	for id in [17, 18, 19, 20]:
		p.registrar(id - 1, 1)
		p.empezar(id, t0 + 30)
	comprobar(p.cuerdas(t0 + 30) == 0, "cinco niveles nuevos gastan las cinco cuerdas")
	p.registrar(20, 1)
	var q = Progreso.new(ruta)
	comprobar(q.cuerdas(t0 + 30) == 0 and q.cuerdas(t0 + 30 + 1800) == 1, "la cuerda se guarda y se recarga al volver a abrir")
	comprobar(q.total() == p.total(), "las estrellas de la Caída del Día no cuentan para el barrio")
	for r in [ruta, "user://prueba_cuerda.anterior.json"]:
		if FileAccess.file_exists(r):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(r))


func pruebas_barrio(sim: GDScript) -> void:
	var Partida: GDScript = load("res://nucleo/partida.gd")
	var primero := 1
	for ruta in ["res://datos/barrio_1.json", "res://datos/barrio_2.json"]:
		var b = leer_json(ruta)
		comprobar(b != null and b["niveles"].size() == 20, "%s tiene 20 niveles" % b["nombre"])
		var mal := []
		var sin_tres := []
		var con_puertas := 0
		for k in b["niveles"].size():
			var n: Dictionary = b["niveles"][k]
			var r: Dictionary = sim.simular(n["nivel"], n["solucion"])
			if int(n["id"]) != primero + k or not r["exito"] or int(r["fichas_usadas"]) != int(n["nivel"]["m"]):
				mal.append(n["id"])
			if not n["nivel"]["p"].is_empty():
				con_puertas += 1
			if r["exito"] and Partida.estrellas(r, int(n["nivel"]["m"]), n["nivel"]) != 3:
				sin_tres.append(n["id"])
		comprobar(mal.is_empty(), "los 20 niveles de %s se superan con su solución y su marca" % b["nombre"], str(mal))
		comprobar(sin_tres.is_empty(), "en %s la solución de referencia da las 3 estrellas (con la campana dorada)" % b["nombre"], str(sin_tres))
		if b["barrio"] == 2:
			comprobar(con_puertas >= 10, "El Puerto tiene puertas de vaivén en la mayoría de niveles (%d)" % con_puertas)
			# El nivel 22 enseña a esperar: en línea recta llega con la puerta cerrada
			var n22: Dictionary = b["niveles"][1]
			var recta: Dictionary = sim.simular(n22["nivel"], [{"puntos": [n22["nivel"]["i"], n22["nivel"]["c"][0][1]], "padre": null, "desde": 0}])
			comprobar(not recta["exito"] and recta["parada"]["motivo"] == "puerta cerrada", "en el nivel 22 la línea recta encuentra la puerta cerrada")
		primero += 20


func terminar() -> void:
	print("%d pruebas correctas, %d fallos" % [pasadas, fallos])
	quit(0 if fallos == 0 else 1)


func comprobar(condicion: bool, nombre: String, detalle := "") -> void:
	if condicion:
		pasadas += 1
		print("ok    ", nombre)
	else:
		fallos += 1
		print("FALLA ", nombre)
		if detalle != "":
			print("      ", detalle)


func leer_json(ruta: String):
	return JSON.parse_string(FileAccess.get_file_as_string(ruta))


# ---------------------------------------------------------------- 2. casos compartidos

func casos_compartidos(sim: GDScript) -> void:
	var datos = leer_json("res://datos/casos_compartidos.json")
	comprobar(datos != null and datos["casos"].size() > 0, "hay casos compartidos")
	if datos == null:
		return
	for caso in datos["casos"]:
		var obtenido: Dictionary = sim.simular(caso["nivel"], caso["tramos"])
		comprobar(iguales(obtenido, caso["esperado"]), "igual que Python: " + caso["nombre"],
			"esperado %s\n      obtenido %s" % [JSON.stringify(caso["esperado"]), JSON.stringify(obtenido)])


# ---------------------------------------------------------------- 3. partida

func dibujar(p, puntos: Array) -> void:
	p.empezar(puntos[0])
	for q in puntos.slice(1):
		p.seguir(q)
	p.terminar()


## Pasa el trazo por puntos cada `cada` unidades, como llegan los eventos del dedo.
func densificar(puntos: Array, cada: float) -> Array:
	var r := [puntos[0]]
	for i in range(1, puntos.size()):
		var a: Array = puntos[i - 1]
		var b: Array = puntos[i]
		var d := Vector2(b[0] - a[0], b[1] - a[1]).length()
		var n := maxi(1, int(ceil(d / cada)))
		for k in range(1, n + 1):
			r.append([a[0] + (b[0] - a[0]) * k / n, a[1] + (b[1] - a[1]) * k / n])
	return r


func pruebas_partida(Partida: GDScript) -> void:
	var niveles: Array = leer_json("res://datos/niveles_entrega1.json")["niveles"]
	comprobar(niveles.size() == 10, "hay 10 niveles")
	for n in niveles:
		for cada in [0.0, 1.3]:     # los puntos tal cual y un dedo que manda un punto cada 1,3 unidades
			var p = Partida.new(n["nivel"])
			for tr in n["solucion"]:
				dibujar(p, tr["puntos"] if cada == 0.0 else densificar(tr["puntos"], cada))
			var r: Dictionary = p.tumbar()["resultado"]
			comprobar(r["exito"] and p.tramos.size() == n["solucion"].size(),
				"nivel %d se supera dibujando la solución%s" % [n["id"], "" if cada == 0.0 else " con el dedo"],
				JSON.stringify(r))
			if cada == 0.0:
				comprobar(Partida.estrellas(r, int(n["nivel"]["m"])) == 2, "nivel %d: la solución da 2 estrellas" % n["id"])

	var corto: Dictionary = niveles[0]["nivel"].duplicate(true)
	corto["f"] = 10                  # nivel 1 con solo 10 fichas, para probar el límite
	var p = Partida.new(corto)
	comprobar(not p.empezar([90.0, 10.0]), "no se puede empezar lejos de la ficha amarilla")
	comprobar(p.empezar([51.0, 149.0]), "se engancha cerca de la ficha amarilla")
	for y in range(148, -10, -1):
		p.seguir([50.0, float(y)])
	p.terminar()
	comprobar(p.usadas() <= p.disponibles(), "el trazo se para al gastar las fichas (%d de %d)" % [p.usadas(), p.disponibles()])
	comprobar(p.usadas() >= p.disponibles() - 1, "y llega hasta casi la última ficha")
	comprobar(p.empezar([50.0, 120.0]) and p.tramos[-1]["padre"] == 0, "una rama engancha con una ficha puesta")
	p.terminar()
	comprobar(p.tramos.size() == 1, "una rama demasiado corta se descarta")
	p.deshacer()
	comprobar(p.tramos.is_empty() and p.usadas() == 0, "deshacer quita el último tramo")


# ---------------------------------------------------------------- 4. progreso

func pruebas_progreso(Progreso: GDScript) -> void:
	var ruta := "user://prueba_progreso.json"
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))
	var a = Progreso.new(ruta)
	comprobar(a.total() == 0 and a.abierto(1) and not a.abierto(2), "sin archivo se empieza de cero")
	a.registrar(1, 2)
	a.registrar(1, 1)
	a.registrar(2, 1)
	var b = Progreso.new(ruta)
	comprobar(b.de(1) == 2 and b.de(2) == 1 and b.abierto(3) and b.total() == 3, "guarda y carga, y nunca baja estrellas")
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	f.store_string("{esto no es json")
	f.close()
	var c = Progreso.new(ruta)
	comprobar(c.total() == 0, "un archivo dañado no rompe el juego")
	c.ajustar("sonido", false)
	var d = Progreso.new(ruta)
	comprobar(d.ajustes["sonido"] == false and d.ajustes["vibracion"] == true, "los ajustes de sonido y vibración se guardan")
	d.ajustar("alto_contraste", true)
	d.ajustar("reducir_movimiento", true)
	var e = Progreso.new(ruta)
	comprobar(e.ajustes["alto_contraste"] and e.ajustes["reducir_movimiento"] and not e.ajustes["texto_grande"],
		"los ajustes de accesibilidad se guardan (y empiezan desactivados)")
	var tablero = load("res://escenas/partida/tablero.gd").new()
	tablero.aplicar_accesibilidad(e.ajustes)
	comprobar(tablero.TINTA == Color("#000000") and tablero.HIELO == Color("#ffffff") and tablero.reducir_movimiento,
		"el tablero pasa a alto contraste y sin movimiento")
	tablero.aplicar_accesibilidad({})
	comprobar(tablero.TINTA == Color("#142554") and not tablero.reducir_movimiento, "y vuelve a Dominó Pop")
	tablero.free()
	for r in [ruta, "user://prueba_progreso.anterior.json"]:
		if FileAccess.file_exists(r):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(r))


func pruebas_registro(Registro: GDScript) -> void:
	var ruta := "user://prueba_registro.jsonl"
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))
	var r = Registro.new(ruta)
	r.anotar("nivel", {"nivel": 3})
	r.anotar("intento", {"nivel": 3, "exito": false, "pistas": 0})
	r.anotar("intento", {"nivel": 3, "exito": false, "pistas": 1})
	r.anotar("intento", {"nivel": 3, "exito": true, "pistas": 1})
	r.anotar("intento", {"nivel": 3, "exito": true, "pistas": 1})
	var lineas: Array = r.leer()
	comprobar(lineas.size() == 5 and lineas[0]["evento"] == "nivel", "el registro guarda una línea por evento")
	var s: Dictionary = r.resumen()
	comprobar(s.has("3") and s["3"]["intentos"] == 4 and s["3"]["intentos_hasta_superar"] == 3 and s["3"]["superado"] and s["3"]["pistas"] == 1,
		"el resumen cuenta intentos hasta superar y pistas", JSON.stringify(s))
	var claves := {}
	for l in lineas:
		for k in l:
			claves[k] = true
	comprobar(claves.keys().all(func(k): return k in ["evento", "t", "nivel", "exito", "pistas"]), "el registro no guarda nada más que lo previsto")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))


func pruebas_reto(RetoDiario: GDScript, sim: GDScript) -> void:
	var r = RetoDiario.new()
	comprobar(r.niveles.size() == 365, "el calendario de la Caída del Día tiene 365 días")
	var fallidos := []
	for e in r.niveles:
		var res: Dictionary = sim.simular(e["nivel"], e["solucion"])
		if not res["exito"] or int(res["fichas_usadas"]) != int(e["nivel"]["m"]):
			fallidos.append(e["fecha"])
	comprobar(fallidos.is_empty(), "Godot supera los 365 niveles diarios con su solución y su marca", str(fallidos.slice(0, 5)))
	comprobar(r.de("2026-11-18")["fecha"] == "2026-11-18", "cada fecha del calendario da su nivel")
	comprobar(r.de("2026-11-01")["fecha"] == r.niveles[0]["fecha"], "el primer día es el primero del calendario")
	comprobar(r.de("2027-11-01")["fecha"] == "2026-11-01", "pasado el año, el calendario se repite igual para todos")
	comprobar(r.de("2026-10-31")["fecha"] == "2027-10-31", "antes del calendario también se repite (sin errores)")
	comprobar(RetoDiario.hoy_utc().length() == 10, "la fecha UTC de hoy tiene el formato AAAA-MM-DD")
	var texto: String = RetoDiario.texto_compartir("2026-11-18", true, 47, 2)
	comprobar(texto.contains("18/11/2026") and texto.contains("47 fichas") and not texto.contains("http"),
		"el texto para compartir lleva fecha y fichas, y ningún enlace", texto)
	comprobar(RetoDiario.texto_compartir("2026-11-18", true, 47, 2, true).contains("con pista"),
		"si se usó la pista, el texto para compartir lo dice")


func pruebas_taller(Taller: GDScript, sim: GDScript) -> void:
	# Python → Godot: abre los códigos válidos de Python y rechaza los malos
	var datos = leer_json("res://datos/codigos_taller.json")
	for v in datos["validos"]:
		var r: Dictionary = Taller.decodificar(v["codigo"])
		comprobar(r["ok"] and iguales(r["nivel"], v["nivel"]) and r["solucion"].size() == int(v["tramos_solucion"]),
			"Godot abre el código de Python del " + v["nombre"], r["error"])
	for m in datos["malos"]:
		var r: Dictionary = Taller.decodificar(m["codigo"])
		comprobar(not r["ok"] and r["error"] != "", "Godot rechaza el código «%s»" % m["nombre"], JSON.stringify(r))
	# Godot → Godot: ida y vuelta, y el codificador no ha cambiado de formato
	var niveles: Array = leer_json("res://datos/niveles_entrega1.json")["niveles"]
	var propios = leer_json("res://datos/codigos_godot.json")
	for k in niveles.size():
		var n: Dictionary = niveles[k]
		var codigo: String = Taller.codificar(n["nivel"], n["solucion"])
		var r: Dictionary = Taller.decodificar(codigo)
		comprobar(r["ok"] and iguales(r["nivel"], n["nivel"]), "ida y vuelta del nivel %d en Godot" % n["id"], r["error"])
		comprobar(propios != null and propios["codigos"][k]["codigo"] == codigo,
			"el código de Godot del nivel %d es el de siempre (mismo formato)" % n["id"])
	# Solución del autor: simplificada sigue superando el nivel y el código queda más corto
	var n7: Dictionary = niveles[6]
	var dedo := []
	for t in n7["solucion"]:
		dedo.append({"puntos": densificar(t["puntos"], 0.8), "padre": t["padre"], "desde": t["desde"]})
	var corta: Array = Taller.solucion_para_codigo(n7["nivel"], dedo)
	comprobar(not corta.is_empty() and sim.simular(n7["nivel"], corta)["exito"], "la solución simplificada del autor sigue superando el nivel")
	comprobar(Taller.codificar(n7["nivel"], corta).length() < Taller.codificar(n7["nivel"], dedo).length(),
		"simplificar el trazo del dedo acorta el código")
	# Lista de niveles guardados
	var ruta := "user://prueba_taller.json"
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))
	Taller.guardar_en_lista({"codigo": "DING1-a", "titulo": "Uno", "propio": true}, ruta)
	Taller.guardar_en_lista({"codigo": "DING1-b", "titulo": "Dos", "propio": false}, ruta)
	Taller.guardar_en_lista({"codigo": "DING1-a", "titulo": "Uno otra vez", "propio": true}, ruta)
	var lista: Array = Taller.cargar_lista(ruta)
	comprobar(lista.size() == 2 and lista[0]["codigo"] == "DING1-b", "la lista guarda cada código una vez, el último arriba")
	Taller.borrar_de_lista("DING1-b", ruta)
	comprobar(Taller.cargar_lista(ruta).size() == 1, "se puede quitar un nivel de la lista")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))


func pruebas_sonidos() -> void:
	for nombre in ["ficha", "campana", "superado", "fallo"]:
		var s = load("res://sonidos/%s.wav" % nombre)
		comprobar(s is AudioStreamWAV and s.get_length() > 0.0, "sonido %s cargado (%.2f s)" % [nombre, s.get_length() if s else 0.0])


## Igualdad profunda. JSON convierte todos los números en float, así que 3 y 3.0 son iguales.
func iguales(a, b) -> bool:
	if a == null or b == null:
		return a == null and b == null
	if (typeof(a) == TYPE_INT or typeof(a) == TYPE_FLOAT) and (typeof(b) == TYPE_INT or typeof(b) == TYPE_FLOAT):
		return float(a) == float(b)
	if typeof(a) != typeof(b):
		return false
	if a is Dictionary:
		if a.size() != b.size():
			return false
		for k in a:
			if not b.has(k) or not iguales(a[k], b[k]):
				return false
		return true
	if a is Array:
		if a.size() != b.size():
			return false
		for i in a.size():
			if not iguales(a[i], b[i]):
				return false
		return true
	return a == b
