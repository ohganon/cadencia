## Fuentes de un tema: títulos, botones, texto y negrita (datos/temas.json › letras).
##
## Todas son SIL OFL y están en res://fuentes/ con su licencia. Las variables se ajustan con sus
## ejes (peso «wght» y, en Gráfico, ancho «wdth»); en las fijas el peso no cambia nada. Si a una le
## falta un signo, se toma de Nunito.
extends RefCounted

const Temas = preload("res://nucleo/temas.gd")
const CARPETA := "res://fuentes/"
const POR_DEFECTO := {"titulos": {"archivo": "LilitaOne-Regular.ttf", "peso": 400},
	"botones": {"archivo": "LilitaOne-Regular.ttf", "peso": 400},
	"texto": {"archivo": "Nunito-wght.ttf", "peso": 700},
	"negrita": {"archivo": "Nunito-wght.ttf", "peso": 900}}

static var _archivos := {}       # nombre de archivo -> FontFile (se cargan una vez)


## Fuentes del tema activo.
static func del_tema() -> Dictionary:
	var r := de(Temas.activo.get("letras", POR_DEFECTO) if not Temas.activo.is_empty() else POR_DEFECTO)
	# Espaciado entre letras de la maqueta (letter-spacing en em), en px para el tamaño habitual de
	# cada uso: títulos unos 44 px y botones unos 34 px
	for par in [["titulos", 44.0], ["botones", 34.0]]:
		var em := Temas.espaciado(par[0])
		if em != 0.0:
			(r[par[0]] as FontVariation).spacing_glyph = int(round(em * par[1]))
	return r


## Fuentes de unas letras concretas: {"titulos", "botones", "texto", "negrita"} -> Font.
static func de(letras: Dictionary) -> Dictionary:
	var reserva := _variacion(POR_DEFECTO["texto"], [])
	var texto := _variacion(letras.get("texto", POR_DEFECTO["texto"]), [reserva])
	var r := {"texto": texto}
	for uso in ["titulos", "botones", "negrita"]:
		r[uso] = _variacion(letras.get(uso, POR_DEFECTO[uso]), [texto, reserva])
	return r


static func _variacion(uso: Dictionary, reservas: Array) -> FontVariation:
	var ts := TextServerManager.get_primary_interface()
	var v := FontVariation.new()
	v.base_font = _archivo(str(uso.get("archivo", "Nunito-wght.ttf")))
	var ejes := {ts.name_to_tag("wght"): int(uso.get("peso", 400))}
	var otros = uso.get("ejes", {})
	if typeof(otros) == TYPE_DICTIONARY:
		for eje in otros:
			ejes[ts.name_to_tag(eje)] = float(otros[eje])
	v.variation_opentype = ejes
	v.fallbacks = reservas
	return v


static func _archivo(nombre: String) -> Font:
	if not _archivos.has(nombre):
		var f = load(CARPETA + nombre) if ResourceLoader.exists(CARPETA + nombre) else null
		_archivos[nombre] = f if f != null else load(CARPETA + "Nunito-wght.ttf")
	return _archivos[nombre]
