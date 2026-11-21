## Simulación de la caída de dominós: port de prototipos/simulacion/sim.py.
##
## Tiene que dar EXACTAMENTE los mismos resultados que la versión de Python. Lo comprueban los
## casos de res://datos/casos_compartidos.json (pruebas/ejecutar_pruebas.gd).
##
## Reglas de portabilidad (las mismas en los dos lados):
## - Coordenadas en Array [x, y] de float (64 bits). Nunca Vector2, que es de 32 bits.
## - Distancias con sqrt(dx*dx + dy*dy).
## - Redondeo con floor(x + 0.5).
## - Curvas comparando el coseno con COS_GIRO_MAXIMO, sin acos.
## - Módulo de las puertas con posmod (siempre positivo, como en Python).
##
## Un nivel es el diccionario de nivel_a_dict() de Python:
##   {w, h, i: [x, y], f: fichas, m: marca, c: [[id, [x, y], tipo, numero]...],
##    mu: [[[x1, y1], [x2, y2]]...], p: [[[x1, y1], [x2, y2], periodo, abierta, fase]...],
##    e: [[[x, y], retardo]...] (opcional: espirales de retardo),
##    ml: [[[entrada], [salida], salto]...] (opcional: muelles),
##    in: [[[placa], [a], [b]]...] (opcional: interruptores con su compuerta a-b),
##    nr: [[[entrada], [salida], periodo, fase]...] (opcional: norias),
##    gl: [[[globo], [[x, y]...]]...] (opcional: globos con el camino que sueltan),
##    cr: [[[a], [b]]...] (opcional: cristales)}
## Un tramo es {puntos: [[x, y]...], padre: int o null, desde: int}.
extends RefCounted

const PASO := 5.0
const COS_GIRO_MAXIMO := 0.573576436351046   # cos(55°), el mismo literal que en sim.py
const RADIO_CAMPANA := 6.0
const RADIO_ESPIRAL := 4.5
const RADIO_MUELLE := 4.5
const RADIO_INTERRUPTOR := 4.5
const TOLERANCIA_DOBLE := 1

const PARADAS_SIN_EXITO := ["faltan fichas", "no empieza en el inicio", "bifurcador no válido"]


# ---------------------------------------------------------------- geometría

static func dist(a: Array, b: Array) -> float:
	var dx: float = b[0] - a[0]
	var dy: float = b[1] - a[1]
	return sqrt(dx * dx + dy * dy)


static func longitud(puntos: Array) -> float:
	var total := 0.0
	for i in range(1, puntos.size()):
		total += dist(puntos[i - 1], puntos[i])
	return total


## Reparte un trazo en fichas equidistantes a lo largo del recorrido (longitud de arco).
static func repartir(puntos: Array, paso: float = PASO) -> Array:
	if puntos.size() < 2 or longitud(puntos) == 0.0:
		if puntos.is_empty():
			return []
		return [[float(puntos[0][0]), float(puntos[0][1])]]
	var total := longitud(puntos)
	var n: int = maxi(2, int(floor(total / paso + 0.5)) + 1)
	var fichas := []
	var s := 1
	var acum := 0.0
	for k in n:
		var objetivo: float = total * k / (n - 1)
		while s < puntos.size() - 1 and acum + dist(puntos[s - 1], puntos[s]) < objetivo:
			acum += dist(puntos[s - 1], puntos[s])
			s += 1
		var a: Array = puntos[s - 1]
		var b: Array = puntos[s]
		var d := dist(a, b)
		if d == 0.0:
			d = 1.0
		var t := minf(1.0, maxf(0.0, (objetivo - acum) / d))
		fichas.append([a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t])
	return fichas


static func _orient(a: Array, b: Array, c: Array) -> int:
	var v: float = (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
	if absf(v) < 1e-9:
		return 0
	return 1 if v > 0.0 else -1


static func _sobre(a: Array, b: Array, c: Array) -> bool:
	return minf(a[0], b[0]) - 1e-9 <= c[0] and c[0] <= maxf(a[0], b[0]) + 1e-9 \
		and minf(a[1], b[1]) - 1e-9 <= c[1] and c[1] <= maxf(a[1], b[1]) + 1e-9


## ¿Se cortan los segmentos p1-p2 y q1-q2? (incluye tocarse)
static func cruza(p1: Array, p2: Array, q1: Array, q2: Array) -> bool:
	var o1 := _orient(p1, p2, q1)
	var o2 := _orient(p1, p2, q2)
	var o3 := _orient(q1, q2, p1)
	var o4 := _orient(q1, q2, p2)
	if o1 != o2 and o3 != o4:
		return true
	return (o1 == 0 and _sobre(p1, p2, q1)) or (o2 == 0 and _sobre(p1, p2, q2)) \
		or (o3 == 0 and _sobre(q1, q2, p1)) or (o4 == 0 and _sobre(q1, q2, p2))


static func curva_cerrada(a: Array, b: Array, c: Array) -> bool:
	var v1x: float = b[0] - a[0]
	var v1y: float = b[1] - a[1]
	var v2x: float = c[0] - b[0]
	var v2y: float = c[1] - b[1]
	var n1 := sqrt(v1x * v1x + v1y * v1y)
	var n2 := sqrt(v2x * v2x + v2y * v2y)
	if n1 == 0.0 or n2 == 0.0:
		return false
	return (v1x * v2x + v1y * v2y) / (n1 * n2) < COS_GIRO_MAXIMO


static func puerta_abierta(p: Array, tic: int) -> bool:
	return posmod(tic - int(p[4]), int(p[2])) < int(p[3])


# ---------------------------------------------------------------- simulación

## Resultado de la caída (el mismo diccionario que sim.simular en Python).
static func simular(nivel: Dictionary, tramos: Array) -> Dictionary:
	return simular_detalle(nivel, tramos)["resultado"]


## Como simular(), pero devuelve también lo necesario para animar la caída:
## {resultado, fichas: [[x, y]...] por tramo, tics: tic de cada ficha, caidas: última ficha que cae
## en cada tramo (-1 si no cae ninguna)}. No forma parte de la especificación compartida.
## Tic en que cae cada ficha de un tramo: base + 1 + j, más el retraso de las espirales por las que
## ya ha pasado (cada espiral, una vez por tramo; la primera ficha del tramo no cuenta).
static func tics_tramo(nivel: Dictionary, fichas: Array, base: int) -> Array:
	var tics := []
	var extra := 0
	var usadas := {}
	var espirales: Array = nivel.get("e", [])
	for j in fichas.size():
		tics.append(base + 1 + j + extra)
		if j == 0:
			continue
		for k in espirales.size():
			if not usadas.has(k) and dist(fichas[j], espirales[k][0]) <= RADIO_ESPIRAL:
				usadas[k] = true
				extra += int(espirales[k][1])
	return tics


## Muelle del que sale un tramo sin padre que no empieza en el inicio (-1 si ninguno).
static func salida_de(nivel: Dictionary, primera: Array) -> int:
	var lista := lanzadores(nivel)
	for k in lista.size():
		if dist(primera, lista[k][1]) <= PASO:
			return k
	return -1


## Piezas con entrada y salida de las que puede salir un tramo: primero los muelles
## [entrada, salida, salto] y luego las norias [entrada, salida, periodo, fase].
static func lanzadores(nivel: Dictionary) -> Array:
	return nivel.get("ml", []) + nivel.get("nr", [])


## Tic en que cae la primera ficha del tramo que sale de un muelle (salto fijo) o de una noria
## (en su siguiente vuelta: el primer tic posterior al disparo con (s - fase) % periodo == 0).
static func primera_salida(m: Array, disparo: int) -> int:
	if m.size() == 4:
		var s := disparo + 1
		return s + posmod(int(m[3]) - s, int(m[2]))
	return disparo + int(m[2])


## Tic de la primera ficha que llega a la entrada del muelle y cae de verdad, entre los tramos ya
## resueltos (`caidas` tiene uno por tramo); -1 si no llega ninguna.
static func disparo_muelle(m: Array, fichas: Array, tics: Array, caidas: Array) -> int:
	var mejor := -1
	for t in caidas.size():
		for j in range(1, int(caidas[t]) + 1):
			if dist(fichas[t][j], m[0]) <= RADIO_MUELLE and (mejor == -1 or tics[t][j] < mejor):
				mejor = tics[t][j]
	return mejor


static func simular_detalle(nivel: Dictionary, tramos: Array) -> Dictionary:
	var fichas_por_tramo := []
	var salidas := []      # muelle del que sale cada tramo, o -1
	for idx in tramos.size():
		var tr: Dictionary = tramos[idx]
		var f := repartir(tr["puntos"])
		var salida := -1
		if tr["padre"] == null:
			if dist(f[0], nivel["i"]) > PASO:
				salida = salida_de(nivel, f[0])
				if salida < 0:
					return _detalle(_resultado(nivel, [], {}, {"tramo": idx, "ficha": 0, "motivo": "no empieza en el inicio"}), [], [], [])
		else:
			var padre := int(tr["padre"])
			var desde := int(tr["desde"])
			if padre >= idx or desde >= fichas_por_tramo[padre].size():
				return _detalle(_resultado(nivel, [], {}, {"tramo": idx, "ficha": 0, "motivo": "bifurcador no válido"}), [], [], [])
		fichas_por_tramo.append(f)
		salidas.append(salida)

	var usadas := 0
	for f in fichas_por_tramo:
		usadas += f.size()
	if usadas > int(nivel["f"]):
		return _detalle(_resultado(nivel, fichas_por_tramo, {}, {"tramo": null, "ficha": null, "motivo": "faltan fichas"}, usadas),
			fichas_por_tramo, [], [])

	# Por rondas, para los interruptores y los cristales (sin ellos, una sola). `disparos`: primero
	# el tic de cada placa pisada y luego el de cada cristal roto (-1: todavía no)
	var interruptores: Array = nivel.get("in", [])
	var cristales: Array = nivel.get("cr", [])
	var disparos := []
	for k in interruptores.size() + cristales.size():
		disparos.append(-1)
	var r := {}
	var convergio := false
	for _ronda in disparos.size() + 4:
		r = _resolver(nivel, tramos, fichas_por_tramo, salidas, disparos)
		var nuevos := []
		for it in interruptores:
			nuevos.append(disparo_placa(it[0], r["todas"], r["tics"], r["caidas"]))
		for k in cristales.size():
			nuevos.append(int(r["golpes"].get(k, -1)))
		if nuevos == disparos:
			convergio = true
			break
		disparos = nuevos
	if not convergio:
		r = _resolver(nivel, tramos, fichas_por_tramo, salidas, disparos)
	var tics: Array = r["tics"]
	var caidas: Array = r["caidas"]
	var parada = r["parada"]
	var todas: Array = r["todas"]        # los tramos del jugador y, detrás, los caminos de los globos

	# Campanas: el primer tic en que una ficha caída de cada tramo llega a su radio
	var llegadas := {}
	for c in nivel["c"]:
		var lista := []
		for idx in todas.size():
			var f: Array = todas[idx]
			for j in range(0, caidas[idx] + 1):
				if dist(f[j], c[1]) <= RADIO_CAMPANA:
					lista.append([tics[idx][j], idx])
					break
		llegadas[c[0]] = lista
	var d := _detalle(_resultado(nivel, fichas_por_tramo, llegadas, parada, usadas), todas, tics, caidas)
	d["interruptores"] = disparos
	return d


## Tic de la primera ficha que cae de verdad sobre la placa (-1 si ninguna).
static func disparo_placa(pos: Array, fichas: Array, tics: Array, caidas: Array) -> int:
	var mejor := -1
	for t in caidas.size():
		for j in range(1, int(caidas[t]) + 1):
			if dist(fichas[t][j], pos) <= RADIO_INTERRUPTOR and (mejor == -1 or tics[t][j] < mejor):
				mejor = tics[t][j]
	return mejor


## Tramo a tramo, en el orden en que se dibujaron: cuándo cae cada ficha y dónde se para. `disparos[k]`
## es el tic en que se pisó el interruptor k (-1: ninguno): su compuerta se abre después de ese tic.
static func _resolver(nivel: Dictionary, tramos: Array, fichas_por_tramo: Array, salidas: Array, disparos: Array) -> Dictionary:
	# Tramo a tramo, en el orden en que se dibujaron: cuándo cae cada ficha y dónde se para (si se
	# para). Un tramo solo depende de los anteriores (su bifurcador o la entrada de su muelle).
	var tics := []
	var caidas := []
	var parada = null
	var golpes := {}         # cristal -> tic del primer choque con él
	# Después de los tramos del jugador, los caminos de los globos (en su orden)
	var globos: Array = nivel.get("gl", [])
	var todas := fichas_por_tramo.duplicate()
	for g in globos:
		todas.append(repartir(g[1]))
	for idx in todas.size():
		var f: Array = todas[idx]
		var cae := true
		var base := -1
		if idx >= tramos.size():
			var reventon := disparo_placa(globos[idx - tramos.size()][0], todas, tics, caidas)
			cae = reventon >= 0
			if cae:
				base = reventon
		elif salidas[idx] >= 0:
			var m: Array = lanzadores(nivel)[salidas[idx]]
			var disparo := disparo_muelle(m, fichas_por_tramo, tics, caidas)
			cae = disparo >= 0          # si nada llegó a la entrada, no sale nada
			if cae:
				base = primera_salida(m, disparo) - 1
		elif tramos[idx]["padre"] != null:
			var tr: Dictionary = tramos[idx]
			base = tics[int(tr["padre"])][int(tr["desde"])]
			cae = caidas[int(tr["padre"])] >= int(tr["desde"])   # su bifurcador tiene que haber caído
		tics.append(tics_tramo(nivel, f, base))
		if not cae:
			caidas.append(-1)
			continue
		var ultima := f.size() - 1
		for j in range(1, f.size()):
			var motivo := ""
			var x: float = f[j][0]
			var y: float = f[j][1]
			if not (0.0 <= x and x <= float(nivel["w"]) and 0.0 <= y and y <= float(nivel["h"])):
				motivo = "sale del tablero"
			elif j >= 2 and curva_cerrada(f[j - 2], f[j - 1], f[j]):
				motivo = "curva demasiado cerrada"
			else:
				for m in nivel["mu"]:
					if cruza(f[j - 1], f[j], m[0], m[1]):
						motivo = "choca con un muro"
						break
				if motivo == "":
					for p in nivel["p"]:
						if cruza(f[j - 1], f[j], p[0], p[1]) and not puerta_abierta(p, tics[idx][j]):
							motivo = "puerta cerrada"
							break
				if motivo == "":
					var interruptores: Array = nivel.get("in", [])
					for k in interruptores.size():
						var it: Array = interruptores[k]
						if cruza(f[j - 1], f[j], it[1], it[2]) and (disparos[k] < 0 or tics[idx][j] <= disparos[k]):
							motivo = "compuerta cerrada"
							break
			if motivo == "":
				var cristales: Array = nivel.get("cr", [])
				var n_in: int = nivel.get("in", []).size()
				for k in cristales.size():
					var rotura: int = disparos[n_in + k]
					if cruza(f[j - 1], f[j], cristales[k][0], cristales[k][1]) and (rotura < 0 or tics[idx][j] <= rotura):
						motivo = "rompe el cristal"
						golpes[k] = tics[idx][j] if not golpes.has(k) else mini(golpes[k], tics[idx][j])
						break
			if motivo != "":
				ultima = j - 1
				if parada == null or tics[idx][j] < parada["tic"]:
					parada = {"tramo": idx, "ficha": j, "tic": tics[idx][j], "motivo": motivo}
				break
		caidas.append(ultima)
	return {"tics": tics, "caidas": caidas, "parada": parada, "todas": todas, "golpes": golpes}


static func _detalle(resultado: Dictionary, fichas: Array, tics: Array, caidas: Array) -> Dictionary:
	return {"resultado": resultado, "fichas": fichas, "tics": tics, "caidas": caidas}


static func _resultado(nivel: Dictionary, fichas: Array, llegadas: Dictionary, parada, usadas := -1) -> Dictionary:
	if usadas < 0:
		usadas = 0
		for f in fichas:
			usadas += f.size()
	var estado := {}
	var motivos := {}
	for c in nivel["c"]:
		var id: String = c[0]
		var ll: Array = llegadas.get(id, []).duplicate()
		ll.sort_custom(func(a, b): return a[0] < b[0] or (a[0] == b[0] and a[1] < b[1]))
		if c[2] == "doble":
			var ok = null
			for i in ll.size():
				for k in range(i + 1, ll.size()):
					if ll[i][1] != ll[k][1] and absi(ll[i][0] - ll[k][0]) <= TOLERANCIA_DOBLE:
						ok = maxi(ll[i][0], ll[k][0])
						break
				if ok != null:
					break
			estado[id] = ok
			if ok == null:
				var ramas := {}
				for e in ll:
					ramas[e[1]] = true
				if ramas.size() == 1:
					motivos[id] = "solo llegó una rama"
				elif not ll.is_empty():
					motivos[id] = "no llegaron a la vez"
				else:
					motivos[id] = "no llegó ninguna rama"
		else:
			estado[id] = ll[0][0] if not ll.is_empty() else null
			if ll.is_empty() and c[2] != "dorada":      # la dorada es opcional: no es un fallo
				motivos[id] = "no llegó"
	var numeradas := []
	for c in nivel["c"]:
		if c[2] == "numerada":
			numeradas.append(c)
	numeradas.sort_custom(func(a, b): return a[3] < b[3])
	var orden_ok := true
	if not numeradas.is_empty():
		var tics_num := []
		var todas := true
		for c in numeradas:
			tics_num.append(estado[c[0]])
			if estado[c[0]] == null:
				todas = false
		if todas:
			for i in range(tics_num.size() - 1):
				if not (tics_num[i] < tics_num[i + 1]):
					orden_ok = false
			if not orden_ok:
				motivos["orden"] = "las campanas numeradas sonaron en otro orden"
	# Hacen falta todas las campanas menos la dorada, que es opcional (da la tercera estrella)
	var obligatorias := 0
	var todas_suenan := true
	for c in nivel["c"]:
		if c[2] != "dorada":
			obligatorias += 1
			if estado[c[0]] == null:
				todas_suenan = false
	todas_suenan = todas_suenan and obligatorias > 0
	var exito: bool = todas_suenan and orden_ok and usadas <= int(nivel["f"]) \
		and not (parada != null and parada["motivo"] in PARADAS_SIN_EXITO)
	return {"exito": exito, "fichas_usadas": usadas, "sobran": int(nivel["f"]) - usadas,
		"campanas": estado, "parada": parada, "motivos": motivos}
