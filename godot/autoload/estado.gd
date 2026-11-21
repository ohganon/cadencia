## Estado compartido entre pantallas (autoload «Estado»).
##
## Lleva el nivel del Taller que se va a jugar al cambiar de escena, el borrador del editor y el
## tiempo jugado para el panel de juego responsable (nucleo/juego_responsable.gd). El progreso del
## jugador vive en nucleo/progreso.gd.
extends Node

const JuegoResponsable = preload("res://nucleo/juego_responsable.gd")
## Si el juego pasa más de esto en segundo plano, al volver empieza una sesión nueva
const PAUSA_NUEVA_SESION := 300
const GUARDAR_CADA := 30.0

## Nivel que la pantalla de partida tiene que abrir al cargarse, o vacío:
## {modo: "prueba" | "codigo", nivel, solucion, titulo, codigo}
var pendiente: Dictionary = {}
## Nivel (índice en la campaña) junto al que estaba Pío la última vez que se vio el mapa: si al volver
## toca otro, Pío vuela hasta él. -1 al empezar (aparece en su sitio).
var pio_nivel := -1

## Nivel que se está editando en el Taller (formato de nivel_a_dict)
var borrador: Dictionary = {}

## Tiempo jugado y avisos que ha elegido el jugador
var responsable: JuegoResponsable
var sesion := 0.0                 # segundos de juego seguido
var avisos_descanso := 0          # avisos de descanso ya dados en esta sesión
var limite_avisado := ""          # fecha en que ya se avisó del límite diario
var _activo := true
var _fuera_desde := -1
var _sin_guardar := 0.0
var _demo := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for a in OS.get_cmdline_user_args():
		_demo = _demo or a.begins_with("--demo")
	# En la demostración no se cuenta ni se guarda nada del jugador
	responsable = JuegoResponsable.new("user://demo_juego_responsable.json" if _demo else JuegoResponsable.RUTA)


func _process(delta: float) -> void:
	if not _activo or _demo:
		return
	sesion += delta
	_sin_guardar += delta
	if _sin_guardar >= GUARDAR_CADA:
		_guardar()


func _notification(que: int) -> void:
	match que:
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			_guardar()
			_activo = false
			_fuera_desde = int(Time.get_unix_time_from_system())
		NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED:
			if _fuera_desde >= 0 and int(Time.get_unix_time_from_system()) - _fuera_desde >= PAUSA_NUEVA_SESION:
				sesion = 0.0
				avisos_descanso = 0
			_fuera_desde = -1
			_activo = true
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_PREDELETE:
			_guardar()


func _guardar() -> void:
	if responsable == null or _demo or _sin_guardar <= 0.0:
		return
	responsable.sumar(JuegoResponsable.fecha_local(), _sin_guardar)
	responsable.guardar()
	_sin_guardar = 0.0


## Segundos jugados hoy, contando lo que aún no se ha guardado.
func hoy() -> int:
	return responsable.hoy(JuegoResponsable.fecha_local()) + int(_sin_guardar)


func semana() -> int:
	return responsable.semana(JuegoResponsable.fecha_local()) + int(_sin_guardar)


## Qué aviso toca al empezar un nivel: "limite", "descanso" o "". Cada aviso se da una vez (el del
## límite, una vez al día; el de descanso, una vez por intervalo).
func aviso_pendiente() -> String:
	if responsable == null:
		return ""
	var fecha := JuegoResponsable.fecha_local()
	if responsable.limite > 0 and hoy() >= responsable.limite * 60 and limite_avisado != fecha:
		limite_avisado = fecha
		return "limite"
	if JuegoResponsable.toca_descanso(sesion, responsable.descanso, avisos_descanso):
		avisos_descanso = int(sesion / (responsable.descanso * 60))
		return "descanso"
	return ""
