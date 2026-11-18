## Estado compartido entre pantallas (autoload «Estado»).
##
## De momento solo lleva el nivel del Taller que se va a jugar al cambiar de escena y el borrador
## del editor. El progreso del jugador vive en nucleo/progreso.gd.
extends Node

## Nivel que la pantalla de partida tiene que abrir al cargarse, o vacío:
## {modo: "prueba" | "codigo", nivel, solucion, titulo, codigo}
var pendiente: Dictionary = {}

## Nivel que se está editando en el Taller (formato de nivel_a_dict)
var borrador: Dictionary = {}
