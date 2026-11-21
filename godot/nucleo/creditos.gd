## Créditos, licencias y privacidad (Ajustes › Créditos y avisos legales).
##
## Lo que piden las licencias de lo que usa el juego (docs/legal/REGISTRO_ASSETS.md):
## - Godot Engine (MIT): su aviso de copyright y su licencia, y los de los componentes de terceros
##   que lleva dentro. Se sacan del propio motor (Engine), así siempre coinciden con la versión usada.
## - Las fuentes (SIL OFL 1.1): el aviso de copyright de cada familia y el texto de la licencia,
##   leídos de los archivos res://fuentes/OFL-*.txt que van dentro del juego.
## El texto sale en BBCode para un RichTextLabel; todo lo que viene de fuera se escapa.
extends RefCounted

const FUENTES := [["Lilita One", "LilitaOne"], ["Nunito", "Nunito"], ["Manrope", "Manrope"], ["Jost", "Jost"],
	["Archivo", "Archivo"], ["Bebas Neue", "BebasNeue"], ["Barlow", "Barlow"], ["Shippori Mincho", "ShipporiMincho"],
	["Zen Kaku Gothic New", "ZenKakuGothicNew"], ["League Spartan", "LeagueSpartan"], ["Familjen Grotesk", "FamiljenGrotesk"],
	["Bricolage Grotesque", "BricolageGrotesque"], ["Red Hat Display", "RedHatDisplay"], ["Red Hat Text", "RedHatText"],
	["Figtree", "Figtree"]]

const PRIVACIDAD := "Dingfall no recoge ni envía datos personales. Tu progreso, tus ajustes y el tiempo de juego se guardan solo en este aparato y no salen de él. Esta versión de prueba no tiene anuncios, compras, cuentas ni analítica."


static func escapar(s: String) -> String:
	return s.replace("[", "[lb]")


## Los textos de licencia vienen cortados a 80 columnas: se juntan las líneas de cada párrafo para que
## se lean bien en la pantalla del móvil (los párrafos, separados por una línea en blanco, se respetan).
static func fluir(s: String) -> String:
	var parrafos := []
	for p in s.replace("\r", "").split("\n\n"):
		var lineas := []
		for l in p.split("\n"):
			if l.strip_edges() != "":
				lineas.append(l.strip_edges())
		if not lineas.is_empty():
			parrafos.append(" ".join(lineas))
	return "\n\n".join(parrafos)


static func _titulo(s: String) -> String:
	return "\n[b]%s[/b]\n" % escapar(s)


## Aviso de copyright de una fuente: las primeras líneas de su OFL, hasta la frase de la licencia.
static func copyright_fuente(archivo: String) -> String:
	var texto := FileAccess.get_file_as_string("res://fuentes/OFL-%s.txt" % archivo)
	var lineas := []
	for l in texto.split("\n"):
		if l.strip_edges().begins_with("This Font Software is licensed"):
			break
		if l.strip_edges() != "":
			lineas.append(l.strip_edges())
	return " ".join(lineas)


static func texto() -> String:
	var t := "[b]Dingfall[/b]\nVersión de prueba del prototipo. © 2026 Dingfall Games.\n"
	t += "Diseño, programación, niveles, sonidos e icono: obra propia del equipo de Dingfall.\n"
	t += _titulo("Privacidad")
	t += escapar(PRIVACIDAD) + "\n"
	t += _titulo("Hecho con Godot Engine")
	t += escapar("Godot Engine se distribuye bajo la licencia MIT. Este es su aviso de copyright y su licencia:") + "\n\n"
	t += escapar(fluir(Engine.get_license_text())) + "\n"
	t += _titulo("Componentes de terceros incluidos en Godot")
	var licencias := {}
	for parte in Engine.get_copyright_info():
		var linea := "• " + str(parte.get("name", ""))
		for pieza in parte.get("parts", []):
			for c in pieza.get("copyright", []):
				linea += "\n   © " + str(c)
			linea += "\n   Licencia: " + str(pieza.get("license", ""))
			licencias[str(pieza.get("license", ""))] = true
		t += escapar(linea) + "\n"
	var textos: Dictionary = Engine.get_license_info()
	for nombre in textos:
		t += _titulo("Licencia " + str(nombre))
		t += escapar(fluir(str(textos[nombre]))) + "\n"
	t += _titulo("Fuentes tipográficas")
	t += escapar("Todas se usan bajo la SIL Open Font License, versión 1.1. Las japonesas van recortadas a los caracteres latinos.") + "\n\n"
	for f in FUENTES:
		t += escapar("• %s: %s" % [f[0], copyright_fuente(f[1])]) + "\n"
	var ofl := FileAccess.get_file_as_string("res://fuentes/OFL-Nunito.txt")
	var inicio := ofl.find("SIL OPEN FONT LICENSE")
	t += _titulo("SIL Open Font License 1.1")
	t += escapar(fluir(ofl.substr(maxi(inicio, 0)))) + "\n"
	return t
