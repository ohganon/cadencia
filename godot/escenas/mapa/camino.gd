## Camino del barrio: los nodos de nivel unidos por una fila de fichas (DESIGN.md › Map).
##
## Las fichas del tramo ya recorrido aparecen tumbadas; las del resto, de pie. Los nodos son botones
## que coloca y conecta la pantalla del mapa.
extends Control

const TINTA := Color("#142554")
const MARFIL := Color("#fffdf6")
const CAIDA := Color("#c9d6f2")
const SEPARACION := 30.0           # píxeles entre fichas del camino

var centros: Array = []            # posición de cada nodo, del primero al último
var recorrido := 0                 # nodos superados (sus tramos se ven tumbados)


func _draw() -> void:
	for k in range(1, centros.size()):
		var a: Vector2 = centros[k - 1]
		var b: Vector2 = centros[k]
		var eje := (b - a).normalized()
		var largo := a.distance_to(b)
		var n := int(largo / SEPARACION)
		for s in range(1, n):
			var p := a + eje * (largo * s / n)
			_ficha(p, eje, k <= recorrido)


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
