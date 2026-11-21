## Camino del barrio: los nodos de nivel unidos por una fila de fichas (DESIGN.md › Map).
##
## Las fichas del tramo ya recorrido aparecen tumbadas; las del resto, de pie. Los nodos son botones
## que coloca y conecta la pantalla del mapa.
extends Control

const Temas = preload("res://nucleo/temas.gd")

# Colores del tema activo (nucleo/temas.gd)
var TINTA: Color = Temas.ui("marco")
var MARFIL: Color = Temas.ui("camino")
var CAIDA: Color = Temas.ui("camino_no")
const SEPARACION := 30.0           # píxeles entre fichas del camino

var centros: Array = []            # posición de cada nodo, del primero al último
var radios: Array = []             # radio de cada nodo: las fichas van de borde a borde, nunca dentro
var recorrido := 0                 # nodos superados (sus tramos se ven tumbados)
const AIRE := 14.0                 # espacio libre entre el borde del nodo y la primera ficha


func _draw() -> void:
	for k in range(1, centros.size()):
		var a: Vector2 = centros[k - 1]
		var b: Vector2 = centros[k]
		var eje := (b - a).normalized()
		# El tramo empieza y acaba fuera de los nodos (algunos temas los tienen translúcidos)
		var desde := a + eje * (_radio(k - 1) + AIRE)
		var hasta := b - eje * (_radio(k) + AIRE)
		var largo := desde.distance_to(hasta)
		if largo <= 0.0 or eje.dot(hasta - desde) <= 0.0:
			continue
		var n := maxi(int(round(largo / SEPARACION)), 1)
		for s in range(0, n + 1):
			_ficha(desde + eje * (largo * s / n), eje, k <= recorrido)


func _radio(k: int) -> float:
	return float(radios[k]) if k < radios.size() else 48.0


func _ficha(c: Vector2, eje: Vector2, tumbada: bool) -> void:
	var normal := Vector2(-eje.y, eje.x)
	var largo := 26.0 if tumbada else 9.0       # a lo largo del camino
	var ancho := 12.0 if tumbada else 22.0      # de lado a lado
	var a := eje * largo / 2
	var b := normal * ancho / 2
	var forma := PackedVector2Array([c - a - b, c + a - b, c + a + b, c - a + b])
	draw_colored_polygon(forma, CAIDA if tumbada else MARFIL)
	var borde := forma.duplicate()
	borde.append(forma[0])
	draw_polyline(borde, TINTA, 2.0, true)
