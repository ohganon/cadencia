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

**Barrio 3, La Relojería** (`barrio.py`): presenta la espiral de retardo. El 41 y el 42, a mano (la recta pasa por la espiral; luego hay que desviarse para pasar por ella). Del 43 al 60, del generador con dos tipos nuevos: `espiral` (una fila con puerta que la recta cruza cerrada; pasando por la espiral se llega con la puerta abierta) y `espiral_doble` (campana doble con ramas de largo distinto; una espiral en la corta las iguala). Sin su espiral, la solución de cada nivel falla. Escribe `godot/datos/barrio_3.json`.

**Barrio 4, La Feria** (`barrio.py`): presenta el muelle. El 61, a mano (un muro de lado a lado: se llega al muelle y se sigue desde su salida). Del 62 al 80, del generador con dos tipos nuevos: `muelle` (fila de muro sin hueco) y `muelle_doble` (campana doble: una rama rodea por el hueco y la otra salta; el salto se calcula para que lleguen a la vez). Sin su muelle, la solución de cada nivel falla. Escribe `godot/datos/barrio_4.json`.

**Barrio 5, La Estación** (`barrio.py`): presenta el interruptor. El 81, a mano (la cadena pisa la placa y luego cruza la compuerta). Del 82 al 100, del generador con el tipo `interruptor`: una fila con compuerta y la placa a un lado; una rama pisa la placa y la otra da el rodeo justo para cruzar después. Con la placa donde nadie la pisa, la solución falla. Escribe `godot/datos/barrio_5.json`.

**Barrio 6, La Fábrica** (`barrio.py`): presenta la noria. El 101, a mano (un muro de lado a lado). Del 102 al 120, del generador con los tipos `noria` (muro sin hueco) y `noria_doble` (dos ramas de largo distinto entran en dos norias del mismo ritmo y salen a la vez, a la misma distancia de una campana doble). Sin sus norias, la solución falla. Escribe `godot/datos/barrio_6.json`.

**Campana dorada** (`poner_dorada`): la tercera estrella. Sale una rama de una ficha de la solución hacia un sitio alejado del camino, de muros y de puertas, sin cambiar cuándo suenan las demás campanas. La marca incluye esa rama, así que las tres estrellas se consiguen con la solución de referencia. Los 40 niveles de los barrios y los 365 días de la Caída del Día la llevan.

**Temas** (`temas.py`): convierte los 11 temas de la maqueta (`docs/fase6/temas/index.html`, copiados en `datos_temas_maqueta.json`) a `godot/datos/temas.json`: colores de la interfaz y del tablero, radios, si los botones llevan sombra sólida y los textos con tono («¡A tumbar!», «Soltar», «Encender»…). Elige la campana normal y la dorada de cada tema y la tinta del tablero (el marco o el texto, el que más contraste). Las pruebas de Godot comprueban contrastes mínimos en los 11.

**Caída del Día:** el calendario se genera aquí y viaja con el juego (`godot/datos/caida_del_dia.json`, unos 570 KB al año). Así el nivel de cada día es idéntico en todos los teléfonos sin servidor y sin depender de que Godot y Python generen igual. El ritmo semanal va de fácil el lunes a más reto el fin de semana (`RITMO`). Hay que regenerarlo antes de que se acabe el año del calendario, en una actualización del juego.
