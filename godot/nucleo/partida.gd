## Estado de una partida mientras el jugador dibuja: tramos, bifurcaciones y límite de fichas.
##
## No dibuja nada ni depende de nodos: se prueba sin pantalla (pruebas/ejecutar_pruebas.gd).
## Todas las coordenadas están en unidades lógicas del tablero, nunca en píxeles.
extends RefCounted

const Sim = preload("res://nucleo/simulacion.gd")

## Distancia máxima (unidades) a la que hay que empezar a dibujar para enganchar con el inicio o
## con una ficha ya puesta. Un dedo ocupa unas 5–6 unidades en un teléfono.
const RADIO_ENGANCHE := 7.0
## Separación mínima entre dos puntos del dedo que se guardan.
const PASO_MINIMO := 0.75

var nivel: Dictionary
var tramos: Array = []          # [{puntos, padre, desde}] en el formato de la simulación
var _actual = null              # tramo que se está dibujando (o null)


func _init(datos_nivel: Dictionary) -> void:
	nivel = datos_nivel


## Fichas disponibles en el nivel.
func disponibles() -> int:
	return int(nivel["f"])


## Fichas que ocupa todo lo dibujado, incluido el tramo en curso.
func usadas() -> int:
	var total := 0
	for t in tramos:
		total += Sim.repartir(t["puntos"]).size()
	return total


func dibujando() -> bool:
	return _actual != null


## Intenta empezar un tramo en el punto p. Devuelve true si engancha con el inicio (el primer
## tramo) o con una ficha ya puesta (una rama nueva).
func empezar(p: Array) -> bool:
	if _actual != null:
		return false
	if tramos.is_empty():
		if Sim.dist(p, nivel["i"]) > RADIO_ENGANCHE:
			return false
		_actual = {"puntos": [_copia(nivel["i"])], "padre": null, "desde": 0}
	else:
		var mejor := _ficha_cercana(p)
		if mejor.is_empty():
			return false
		_actual = {"puntos": [mejor["pos"]], "padre": mejor["tramo"], "desde": mejor["ficha"]}
	tramos.append(_actual)
	return true


## Añade un punto al tramo en curso. Si con él se pasaría de las fichas disponibles, el trazo se
## detiene ahí: las fichas son la «tinta» del nivel. Devuelve false si no se ha añadido.
func seguir(p: Array) -> bool:
	if _actual == null:
		return false
	var ultimo: Array = _actual["puntos"][-1]
	if Sim.dist(ultimo, p) < PASO_MINIMO:
		return false
	_actual["puntos"].append(_copia(p))
	if usadas() > disponibles():
		_actual["puntos"].pop_back()
		return false
	return true


## Termina el tramo en curso. Si es tan corto que no llega a poner dos fichas, se descarta.
func terminar() -> void:
	if _actual == null:
		return
	if Sim.repartir(_actual["puntos"]).size() < 2:
		tramos.erase(_actual)
	_actual = null


## Quita el último tramo dibujado. Las ramas siempre van después de su padre, así que quitar el
## último nunca deja una rama huérfana.
func deshacer() -> void:
	_actual = null
	if not tramos.is_empty():
		tramos.pop_back()


func borrar_todo() -> void:
	_actual = null
	tramos.clear()


## Fichas de cada tramo, para dibujarlas mientras se dibuja.
func fichas() -> Array:
	var r := []
	for t in tramos:
		r.append(Sim.repartir(t["puntos"]))
	return r


## Posiciones de las fichas donde la curva ya es demasiado cerrada (aviso mientras se dibuja).
func curvas_cerradas() -> Array:
	var r := []
	for f in fichas():
		for j in range(2, f.size()):
			if Sim.curva_cerrada(f[j - 2], f[j - 1], f[j]):
				r.append(f[j])
	return r


func tumbar() -> Dictionary:
	_actual = null
	return Sim.simular_detalle(nivel, tramos)


## 0 si no se supera. Si se supera: 1, más 1 si no se pasa de la marca de fichas, más 1 si suena la
## campana dorada (solo en los niveles que la tienen). Con la solución de referencia salen todas.
static func estrellas(resultado: Dictionary, marca: int, nivel := {}) -> int:
	if not resultado["exito"]:
		return 0
	var e := 1
	if int(resultado["fichas_usadas"]) <= marca:
		e += 1
	for c in nivel.get("c", []):
		if c[2] == "dorada" and resultado["campanas"].get(c[0]) != null:
			e += 1
	return e


## Estrellas posibles en un nivel: 3 si tiene campana dorada, 2 si no.
static func maximo_estrellas(nivel: Dictionary) -> int:
	for c in nivel.get("c", []):
		if c[2] == "dorada":
			return 3
	return 2


static func dorada_sono(resultado: Dictionary, nivel: Dictionary) -> bool:
	for c in nivel.get("c", []):
		if c[2] == "dorada" and resultado.get("campanas", {}).get(c[0]) != null:
			return true
	return false


func _ficha_cercana(p: Array) -> Dictionary:
	var mejor := {}
	var mejor_d := RADIO_ENGANCHE
	var todas := fichas()
	for i in todas.size():
		for j in todas[i].size():
			var d := Sim.dist(p, todas[i][j])
			if d <= mejor_d:
				mejor_d = d
				mejor = {"tramo": i, "ficha": j, "pos": _copia(todas[i][j])}
	return mejor


static func _copia(p: Array) -> Array:
	return [float(p[0]), float(p[1])]
