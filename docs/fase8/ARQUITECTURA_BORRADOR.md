# Fase 8: arquitectura (borrador)

**Fecha:** 17/11/2026
**Estado:** **Fase 8 en curso** desde el 17/11/2026, tras aprobarse las fases 6 y 7. Este documento es la arquitectura de trabajo; se ajusta con lo que enseñe la entrega 1.

---

## 0. Lo que ya existe y se puede ejecutar

**[prototipos/simulacion/](../../prototipos/simulacion/)** contiene la **simulación de referencia en Python**, sin dependencias, con **27 pruebas** que pasan. Es la especificación ejecutable de las reglas:

- reparto de fichas por longitud;
- la longitud es el tiempo;
- campana simple, doble y numeradas;
- curvas demasiado cerradas, muros, salida del tablero y puertas de vaivén;
- límite de fichas;
- semilla de la Caída del Día por fecha UTC;
- códigos del Taller, con protección contra códigos manipulados.

**Los 10 niveles de la entrega 1** (17/11/2026) están en `niveles_entrega1.py` y `datos/niveles_entrega1.json`:

| # | Nivel | Enseña | Marca / fichas |
|---|---|---|---|
| 1 | Primer empujón | Dibujar y tumbar | 25 / 40 |
| 2 | La curva | Curvas suaves y muros | 30 / 42 |
| 3 | Fichas justas | El límite de fichas | 30 / 33 |
| 4 | Dos caminos | Bifurcador | 44 / 56 |
| 5 | Eslalon | Respiro | 32 / 52 |
| 6 | Primero la 1 | Campanas numeradas | 47 / 57 |
| 7 | La campana doble | Sincronizar dos ramas | 47 / 57 |
| 8 | El que espera | Alargar el camino corto | 55 / 63 |
| 9 | Una sola salida | Dividir después de un hueco | 52 / 58 |
| 10 | Gran Tramo: la plaza | Todo junto, con pocas fichas de sobra | 56 / 61 |

Cada nivel tiene una **solución de referencia** (prueba que tiene solución, fija la marca y sirve de pista) y, cuando enseña algo, un **intento ingenuo que debe fallar** por el motivo correcto. Es una muestra vertical para la puerta 0, no el capítulo 1 definitivo.

**Casos compartidos con Godot:** `datos/casos_compartidos.json` tiene 30 casos con el resultado esperado: las 10 soluciones, los 8 intentos que fallan, 2 casos de borde de la campana doble (una rama 1 tic tarde suena; 2 tics, no) y 10 de reglas sueltas (puertas, redondeo de medio paso y cada motivo de parada).

**Port a Godot hecho (17/11/2026):** [godot/nucleo/simulacion.gd](../../godot/nucleo/simulacion.gd) da **los mismos resultados en los 30 casos** que Python. Para que sea exacto bit a bit, las dos versiones siguen las mismas reglas de portabilidad: coordenadas en float de 64 bits (sin Vector2), distancias con `sqrt`, redondeo con `floor(x + 0.5)`, curvas comparando cosenos con un literal y módulo siempre positivo en las puertas. Comprobado que el ejecutor detecta errores: con la tolerancia de la campana doble a 0 falla 1 caso, y con el módulo de C en las puertas fallan 2.

Para ejecutarlo (desde la raíz del repositorio):

```bash
Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://pruebas/ejecutar_pruebas.gd
```

**Comprobado que las pruebas detectan errores:** si se rompe a propósito la tolerancia de la campana doble, el reparto por longitud o el límite de curva, fallan 1, 8 y 1 pruebas respectivamente. En los casos compartidos, cambiar la tolerancia a 0 o a 2 hace fallar uno, y cambiar el radio de la campana hace fallar 13.

**Para qué sirve:**
1. **Especificación:** la versión en GDScript debe dar exactamente los mismos resultados. Se pueden exportar casos de prueba a JSON y ejecutarlos en los dos lados.
2. **Generador de niveles y reto diario:** pueden desarrollarse y probarse en Python en cualquier ordenador, sin Godot.
3. **Lecciones ya incorporadas** de los dos fallos encontrados en las demos:
   - **16/11/2026:** el ejemplo recortaba una rama → **reparto por longitud de arco**.
   - **17/11/2026:** a pantalla grande el ejemplo fallaba porque los umbrales estaban en píxeles → **todo en unidades lógicas del tablero**.

---

## 1. Principios de arquitectura

| Principio | Por qué |
|---|---|
| **Simulación separada del dibujo** | La regla (quién cae y cuándo) es código puro y probado. El dibujo solo la representa. Permite repeticiones, reto diario y generador |
| **Unidades lógicas, nunca píxeles** | El resultado no puede depender del teléfono (equidad y reto diario igual para todos) |
| **Temas como datos** | Un tema es un recurso con las claves de DESIGN.md. Cambiar de tema nunca toca la lógica ni la maqueta |
| **Sin servidor (MVP)** | El reto diario sale de una semilla por fecha; el Taller, de códigos de texto; las partidas guardadas, del propio teléfono |
| **Todo lo que cuesta dinero, detrás de una interfaz** | Anuncios, compras y analítica se acceden a través de un singleton propio. Se pueden cambiar de proveedor o simular en las pruebas |

## 2. Estructura del proyecto Godot (propuesta)

```
godot/
  project.godot
  nucleo/            # sin nodos visuales: se prueba con GUT
    simulacion.gd    # port de prototipos/simulacion/sim.py
    reparto.gd       # reparto por longitud de arco
    nivel.gd         # recurso Nivel (campanas, muros, puertas, fichas, marca)
    codigos.gd       # códigos del Taller
    reto_diario.gd   # semilla por fecha UTC + generador
  generador/         # generador "por construcción" (Fase 4, sección 5.3)
  escenas/
    mapa/  partida/  ventanas/  ajustes/  club/  taller/  reto/
  temas/             # 11 recursos .tres (pop por defecto) + texturas
  autoload/          # singletons
    Estado.gd        # progreso, cuerda, estrellas; guardado en user://
    Temas.gd         # tema activo y prueba de temas del Club
    Anuncios.gd      # interfaz → AdMob (Poing Studios, MIT)
    Compras.gd       # interfaz → godot-iap (MIT, verificado)
    Analitica.gd     # interfaz → proveedor por decidir (Fase 9)
  pruebas/           # GUT (MIT) + casos compartidos con la versión Python
```

## 3. Rendimiento con cientos de fichas

- **Dibujo:** un MultiMeshInstance2D por tablero. Cada ficha es una instancia con posición, giro y estado (de pie, cayendo, tumbada) codificados en el color de instancia. **Validar en la entrega 1** en un móvil de gama media.
- **Simulación:** se calcula **entera al pulsar «Tumbar»** (es barata: decenas de operaciones por ficha). La animación solo reproduce los tics, así que la caída nunca se atasca.

## 4. Guardado y privacidad

- Partida en `user://partida.json`, con versión y copia de seguridad del guardado anterior.
- **No se guarda ningún dato personal.** Los ajustes de «Juego responsable» (P-09) se guardan en el mismo archivo.
- El Club se comprueba con el recibo de la tienda a través de godot-iap. **Sin servidor propio, la validación es local**: es suficiente para el MVP y se revisará si aparece fraude.

## 5. Entregas propuestas

| Entrega | Contenido | Puerta (PLAN_LANZAMIENTO.md) |
|---|---|---|
| **1** | Port de la simulación con las mismas pruebas, dibujo con el dedo en el móvil, 10 niveles hechos a mano, tema Dominó Pop | Puerta 0: 10–15 personas lo prueban y piden más |
| 2 | Mapa, progreso, estrellas, cuerda (sin anuncios aún) y guardado | — |
| 3 | Generador y Caída del Día | — |
| 4 | Taller con códigos | — |
| 5 | Los 11 temas y la prueba de temas ✅ (18/11/2026: datos en `godot/datos/temas.json`, tema activo en `nucleo/temas.gd`, letras de cada tema en `escenas/comun/fuentes.gd`) | — |
| 6 | Accesibilidad completa (alto contraste, tamaño de interfaz, reducción de movimiento) ✅ (18/11/2026: también lector de pantalla con AccessKit de Godot; falta probarlo con TalkBack y VoiceOver; el tablero en sí no se puede jugar sin ver) | — |
| 7 | Anuncios recompensados e intersticiales (AdMob) con su consentimiento | — |
| 8 | Club y packs de fichas (godot-iap) | Puerta 1: prueba cerrada |
| 9 | Analítica y panel de juego responsable (panel ✅ 18/11/2026, local; falta la analítica, que necesita cuenta y consentimiento) | Puerta 2: lanzamiento suave |

## 6. Herramientas (licencia comprobada y coste)

| Herramienta | Licencia | Coste | Estado |
|---|---|---|---|
| Godot 4.7.2 (estable, 18/08/2026) | MIT | 0 € | Editor para Windows de 82 MB (`Godot_v4.7.2-stable_win64.exe.zip`, de godotengine.org o GitHub). **Instalado el 17/11/2026** con permiso del cliente, en `%LOCALAPPDATA%\Programs\Godot\4.7.2`, fuera del repositorio. SHA-512 comprobado contra la lista oficial y firma de Windows válida (Prehensile Tales B.V.). Las plantillas de exportación (1,2 GB) solo hacen falta para generar el APK |
| GUT (pruebas en Godot) | MIT, según [la documentación](https://gut.readthedocs.io/) y la Asset Library (repositorio bitwes/Gut, versión 9.6.0 para Godot 4.6) | 0 € | Confirmar el archivo LICENSE y la compatibilidad con Godot 4.7 al instalarlo |
| AdMob (plugin de Poing Studios) | MIT (Fase 5) | 0 € | — |
| godot-iap | MIT (verificado el 17/11/2026) | 0 € | — |
| Temurin 17 (OpenJDK) | GPLv2 con excepción Classpath | 0 € | Instalado el 18/11/2026, solo como herramienta de compilación (no va dentro del juego) |
| Android SDK (Platform-Tools, Build-Tools 35.0.1, Platform 35) | Licencia del Android SDK (aceptada por el cliente el 18/11/2026) | 0 € | Instalado el 18/11/2026 |
| Analítica | Por decidir | **Comprobar el precio, los límites gratuitos y las condiciones antes de elegir** (regla del presupuesto) | Fase 9 |

## 6 bis. Pasada estética (decidido por el cliente el 18/11/2026; primera pasada hecha el 20/11/2026)

**Hecho el 20/11/2026** (`escenas/comun/animar.gd` y `confeti.gd`): botones que se hunden con curva suave (140 ms), ventanas que entran con escala y velo que se funde, fundido al abrir cada pantalla, estrellas que salen una a una con rebote, latido de las pastillas al cambiar la cifra, ficha que vuelca hacia delante al caer (acelerando) con un pequeño rebote al tumbarse, sombra suave y brillo en las fichas de pie, luz en el tablero y en el fondo de las pantallas, campanas que se balancean al sonar con destellos (la doble, una hacia la otra), confeti de fichas al superar un nivel y más grande al terminar un barrio («¡Has terminado …!»), nodo del nivel que toca que respira en el mapa y barra del Taller en dos filas de botones grandes. Todo respeta «reducir movimiento» y el alto contraste. **Pendiente:** Pío (necesita arte), la cámara que sigue la caída en niveles grandes (ahora todos caben en pantalla) y una ilustración de fondo por barrio.

Lista original:

La pantalla de juego ya sigue la maqueta, pero **le falta ser más visual y llamativa**. El cliente prefiere desarrollar primero el juego y dejar esto para después. Lista para esa pasada:

- **Animaciones de la caída:** cada ficha gira al caer en vez de encogerse, con un pequeño rebote al tumbarse; la cámara puede seguir la ficha que cae en los niveles grandes.
- **Campanas:** balanceo al sonar, ondas y partículas (destellos amarillos); la doble, con las dos campanas chocando.
- **Sombreado y profundidad:** sombra suave bajo las fichas de pie, relieve en las caras, luz en el tablero.
- **Interfaz:** botones que se hunden con curva suave (140 ms, `cubic-bezier(.22,1,.36,1)`), ventanas que entran con escala, estrellas que aparecen una a una, contador que baja animado.
- **Celebración** al superar un nivel (confeti de fichas) y al completar un barrio.
- **Pío** animado (vuela, señala, celebra) y el **mapa** con el camino de fichas.
- **Fondo** con algo de textura o ilustración del barrio, sin perder la calma de Dominó Pop v2.
- **Accesibilidad:** todo lo anterior respetará «reducir movimiento».

## 7. Pendiente

- ~~Instalar Godot 4.7.2~~ **Hecho** (17/11/2026).
- ~~Diseñar los 10 niveles de la entrega 1~~ **Hecho** (17/11/2026), con casos compartidos en JSON.
- ~~Port de `sim.py` a GDScript~~ **Hecho**: pasa los 30 casos compartidos. Falta portar el reto diario y los códigos del Taller (entregas 3 y 4).
- ~~Escena de partida de la entrega 1~~ **Hecha** (18/11/2026): dibujar con el dedo, ramas desde cualquier ficha, límite de fichas, aviso de curva cerrada, caída animada, campanas que suenan (visualmente), resultado con estrellas, X donde se para la cadena con su explicación, pista en fantasma, deshacer, lista de niveles y progreso guardado. 77 pruebas sin pantalla y capturas automáticas revisadas.
- ~~Sonido~~ **Hecho** (18/11/2026): sonidos propios por síntesis (sin licencias de terceros), vibración en las campanas, cámara lenta (destacada tras 5 fallos), ajustes de sonido y vibración, registro local de intentos y resumen para quien dirige la prueba. Protocolo de la prueba en [PRUEBA_PUERTA_0.md](PRUEBA_PUERTA_0.md).
- ~~Fuentes y APK~~ **Hecho** (18/11/2026), con permiso del cliente para las descargas: fuentes Lilita One y Nunito (OFL), plantillas de Android de Godot 4.7.2, Java 17 y Android SDK (el cliente aceptó la licencia del SDK). APK de depuración comprobado con aapt2 y apksigner: `com.dingfall.prueba`, arm64, solo el permiso VIBRATE, objetivo Android 16 (API 36), icono provisional propio.
- ~~Pantalla de juego con el diseño acordado~~ **Hecha** (18/11/2026): HUD con volver, «Nivel N» y pastilla de fichas; tarjeta del objetivo; mandos de la maqueta (deshacer, «¡A tumbar!» y bombilla); botones con borde, sombra sólida y labio; fichas, empujador verde y campanas con las medidas de la maqueta; marcas de cuenta cada 4 fichas con el orden de caída; ventana de resultado con estrellas dibujadas y premio; lista de niveles con nodos de mapa. Pendiente para la entrega 2: mapa del barrio, Pío y cuerda.
- ~~Entrega 3: generador y Caída del Día~~ **Hecha** (18/11/2026), adelantada a la entrega 2 por decisión del cliente (primero el juego, luego la estética y el mapa). Generador por construcción en [prototipos/generador/](../../prototipos/generador/) con solucionador perezoso de atajos y dificultad prevista; **la Caída del Día viaja como datos** (un año, 570 KB) en vez de generarse en el teléfono, para que sea idéntica en todos sin servidor. En el juego: botón en la lista de niveles, objetivo según el tipo, estrellas del día y «Copiar resultado» (sin enlaces; si se usó la pista, lo dice).
- ~~Entrega 4: Taller~~ **Hecha** (18/11/2026): editor con inicio, campanas (simple, doble y numerada), muros y goma; «Probar» en la pantalla de partida; **solo se publica lo que el autor ha superado**, y el código lleva su solución simplificada (unos 360 caracteres), así que todo nivel compartido tiene solución y pista. Códigos compatibles Python ↔ Godot (pruebas en los dos sentidos), con los mismos límites y comprobaciones contra códigos manipulados. «Códigos»: pegar el de un amigo y lista de guardados en el teléfono.
- ~~Entrega 2: mapa, progreso y cuerda~~ **Hecha** (18/11/2026): el juego empieza en el mapa de La Plaza (20 niveles: 10 a mano y 10 generados), con el camino de fichas, nodos hechos, actual y cerrados, «Jugar · nivel N» y la barra de abajo (Inicio, Reto, Taller, Ajustes). **Cuerda con las reglas de la Fase 5:** 5 como máximo, 1 cada 30 minutos, solo los niveles nuevos a partir del 16, un solo cobro por nivel, repetir gratis. «Sin cuerda» con tres opciones iguales (esperar con el tiempo real, Caída del Día, Taller); el anuncio (+3) y el Club llegan en las entregas 7 y 8. Pío, pendiente del arte.
- ~~Barrio 7~~ **Hecho** (20/11/2026): El Jardín (niveles 121–140) con el globo: lleva colgado un camino de fichas que no gasta las del jugador; cuando cae una ficha sobre él, revienta en ese tic d y su camino cae como una rama (la ficha j en d + 1 + j), parándose con lo mismo que cualquier tramo. Se resuelven después de los tramos del jugador, en su orden (un globo puede reventar otro). 121 a mano; 122–140 del generador (tipos `globo`: la campana queda lejos de tus fichas; `globo_doble`: dos globos con caminos de largo distinto que hay que reventar cada uno a su tiempo). La campana dorada tiene un segundo intento para soluciones muy cortas. Herramienta «Globo» en el Taller (arrastrar desde el globo hasta donde llega su camino).
- ~~Barrio 6~~ **Hecho** (20/11/2026): La Fábrica (niveles 101–120) con la noria: como el muelle (entrada, salida y un tramo que sale de ella), pero suelta la cadena en su siguiente vuelta: el primer tic posterior al disparo con (s − fase) % periodo = 0. Dos norias iguales sueltan a la vez dos ramas que llegan a destiempo. 101 a mano; 102–120 del generador (tipos `noria` y `noria_doble`). Herramienta «Noria» en el Taller (arrastrar de la entrada a la salida; tocar la entrada cambia la vuelta: 4, 6, 8, 10, 12 o 16 tics).
- ~~Barrio 5~~ **Hecho** (20/11/2026): La Estación (niveles 81–100) con el interruptor: la compuerta para la cadena como un muro hasta que cae una ficha en su placa, y queda abierta desde el tic siguiente. Como abrir una compuerta puede dejar pisar otras placas, la simulación se resuelve por rondas hasta que los tics de las placas no cambian (sin interruptores, una sola ronda: nada cambia en lo anterior). 81 a mano; 82–100 del generador (tipo `interruptor`: una rama pisa la placa y la otra da el rodeo justo). Herramienta «Interruptor» en el Taller (arrastrar dibuja la compuerta; tocar mueve la placa).
- ~~Barrio 4~~ **Hecho** (19/11/2026): La Feria (niveles 61–80) con el muelle: entrada, salida y salto en tics. Un tramo que empieza en la salida cae `salto` tics después de la primera ficha que llega a la entrada y cae de verdad; si no llega ninguna, no cae. La simulación resuelve los tramos en orden (tics y paradas a la vez), con los mismos resultados que antes en todo lo anterior. 61 a mano; 62–80 del generador (tipos `muelle`: un muro de lado a lado; `muelle_doble`: una rama rodea por el hueco y la otra salta, con el salto que las iguala). Herramienta «Muelle» en el Taller (arrastrar de la entrada a la salida; tocar la entrada cambia el salto).
- ~~Barrio 3 con una pieza nueva~~ **Hecho** (18/11/2026): La Relojería (niveles 41–60) con la espiral de retardo: lo que pasa por ella cae R tics más tarde (una vez por tramo; las ramas lo heredan), sin ocupar sitio. Se eligió en lugar del puente porque las ramas ya se pueden cruzar. 41 y 42 a mano; 43–60 del generador (tipos `espiral`: abre la puerta a tiempo; `espiral_doble`: iguala las ramas de una campana doble). En todos, sin la espiral la solución falla. Herramienta «Espiral» en el Taller (tocarla cambia el retraso de 2 en 2).
- ~~Barrio 2 con la puerta de vaivén~~ **Hecho** (18/11/2026): El Puerto (niveles 21–40), 3 de enseñanza a mano y 17 del generador, que ahora crea niveles con puertas cuyo ritmo deja pasar la solución y cierra el paso a la línea recta. En el tablero, la puerta se abre y se cierra a su ritmo mientras se dibuja, muestra cuándo abre en tics y marca dónde la cruza el camino (verde: abierta; coral: cerrada). Mapa con dos barrios (El Puerto se abre al terminar La Plaza) y herramienta de puerta en el Taller.
- ~~Tercera estrella (campana dorada)~~ **Hecha** (18/11/2026): campana opcional en la simulación (Python y Godot, con casos compartidos y en los códigos del Taller, como mucho una), colocada por el generador en los 40 niveles de los barrios; estrellas = superar + no pasar de la marca + campana dorada. Brilla en amarillo, suena más aguda y el objetivo la explica hasta que se consigue la primera tercera estrella. Pendiente: herramienta en el Taller y en la Caída del Día.
- ~~Entrega 6: accesibilidad~~ **Hecha en lo principal** (18/11/2026): en Ajustes, **alto contraste** (tablero blanco, contornos negros y colores saturados), **reducir movimiento** (sin pulsos, brillos ni fichas que se encogen; la puerta sigue abriéndose y cerrándose porque es información) y **texto grande** (objetivo, resultado y ayuda del Taller). **Símbolos además de colores:** ✓/✗ en el cruce de las puertas, «!» en las curvas cerradas y una estrella en la campana dorada. Todo jugable con una mano. Pendiente: escalar toda la interfaz, lector de pantalla y alto contraste en el mapa y las ventanas.
- **Para la puerta 0:** instalar el APK en un Android de gama media y hacer la prueba con 10–15 personas ([PRUEBA_PUERTA_0.md](PRUEBA_PUERTA_0.md)).
- **Para Google Play (más adelante):** AAB con compilación Gradle (requiere el NDK r28b y CMake, unos 1–2 GB más), identificador definitivo de la app y clave de firma de publicación guardada fuera del repositorio.
- **Ajustar en el prototipo** los valores de la simulación (PASO, GIRO_MAXIMO, RADIO_CAMPANA, TOLERANCIA_DOBLE): ahora son una hipótesis razonable, no un dato.
