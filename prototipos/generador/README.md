# Generador de niveles

Generador «por construcción» (Fase 4, sección 5.3): primero se crea la solución y después el problema, así que **todo nivel generado tiene solución**. Usa la simulación de referencia (`../simulacion/sim.py`).

```bash
python -X utf8 generador.py --muestra 15                          # 15 niveles de ejemplo, con su dificultad
python -X utf8 generador.py --calendario 365 --desde 2026-11-01   # la Caída del Día de un año
python -X utf8 -m unittest -v test_generador                      # 8 pruebas
```

**Tipos de nivel:** `simple`, `dos` (dos campanas con bifurcador), `numeradas` (el orden engaña: primero la lejana), `doble` (campana doble con ramas de anchos distintos que hay que igualar) y `doble_y_simple`.

**Cómo se evita que un nivel sea trivial:**
- muros que cortan la línea recta hacia cada objetivo, fuera del corredor de la solución y separados entre sí;
- en la campana doble, un muro justo debajo que impide la horquilla simétrica pegada a ella;
- un **solucionador perezoso** prueba lo que haría un jugador con prisa (línea recta, un solo codo, horquilla simétrica desde varios puntos). Si la línea recta funciona, el nivel se descarta; el resto de atajos que funcionan bajan la dificultad prevista.

**Dificultad prevista (0–1):** restricciones (campanas, numeradas, dobles), ramas, muros, margen de fichas y atajos. De cada semilla se generan varios candidatos y se elige el más cercano a la dificultad pedida. Los pesos son una hipótesis: se calibran con datos reales en la Fase 9.

**Tipos con puertas de vaivén:** `puerta` y `dos_puertas`. Filas de muro de lado a lado con un hueco cerrado por una puerta; la solución da un rodeo y el ritmo de cada puerta (periodo, tiempo abierta y fase) se calcula para que esté **abierta cuando llega la solución y cerrada cuando llega la línea recta** por los huecos. El solucionador perezoso prueba esa recta y rodeos por cada lado.

**Barrio 1, La Plaza** (`barrio.py`): los 10 niveles hechos a mano más 10 generados (11–20) con semillas fijas y la regla de ritmo de la Fase 4: subida con picos, un respiro (14), preparación y el Gran Tramo (20). Escribe `godot/datos/barrio_1.json`.

**Barrio 2, El Puerto** (`barrio.py`): presenta la puerta de vaivén. Del 21 al 23, a mano: la puerta (la recta funciona), esperar a que abra (la recta llega con la puerta cerrada) y dos puertas. Del 24 al 40, generados: puertas mezcladas con lo ya aprendido y dos respiros. Escribe `godot/datos/barrio_2.json`.

**Campana dorada** (`poner_dorada`): la tercera estrella. Sale una rama de una ficha de la solución hacia un sitio alejado del camino, de muros y de puertas, sin cambiar cuándo suenan las demás campanas. La marca incluye esa rama, así que las tres estrellas se consiguen con la solución de referencia. Los 40 niveles de los barrios y los 365 días de la Caída del Día la llevan.

**Temas** (`temas.py`): convierte los 11 temas de la maqueta (`docs/fase6/temas/index.html`, copiados en `datos_temas_maqueta.json`) a `godot/datos/temas.json`: colores de la interfaz y del tablero, radios, si los botones llevan sombra sólida y los textos con tono («¡A tumbar!», «Soltar», «Encender»…). Elige la campana normal y la dorada de cada tema y la tinta del tablero (el marco o el texto, el que más contraste). Las pruebas de Godot comprueban contrastes mínimos en los 11.

**Caída del Día:** el calendario se genera aquí y viaja con el juego (`godot/datos/caida_del_dia.json`, unos 570 KB al año). Así el nivel de cada día es idéntico en todos los teléfonos sin servidor y sin depender de que Godot y Python generen igual. El ritmo semanal va de fácil el lunes a más reto el fin de semana (`RITMO`). Hay que regenerarlo antes de que se acabe el año del calendario, en una actualización del juego.
