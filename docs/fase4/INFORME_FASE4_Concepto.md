# FASE 4 — Creación del concepto original

**Fecha:** 16/11/2026
**Estado:** entregado, **pendiente de aprobación**
**Coste:** 0 €

**Base:**
- oportunidades O1–O7 de la Fase 2;
- principios P-01 a P-16 y modelo de tres bucles de la Fase 3;
- [marco legal](../legal/MARCO_CUMPLIMIENTO_LEGAL.md).

> **Nota (17/11/2026):** el nombre comercial es ahora **Dingfall** y la suscripción, **Dingclub**. «Cadencia» se descartó por un conflicto de marca ([fase7/NOMBRE_Y_MARCA.md](../fase7/NOMBRE_Y_MARCA.md)). Este informe se deja como se aprobó.

---

## 0. Resumen ejecutivo

**Recomendación: CADENCIA** (nombre provisional).

> **Un puzle de dominós en el que dibujas el recorrido con el dedo y la longitud del recorrido es el tiempo.**
> Dibujas cadenas de fichas para hacer sonar campanas y activar mecanismos. Como cada ficha tarda lo mismo en caer, **cuanto más largo es el camino, más tarda en llegar**. Al principio es solo "llega a la campana". Después hay que **sincronizar ramas, llegar antes de que se cierre una puerta y ordenar los golpes**.
> Cada capítulo añade un tramo a **la Gran Cadena del festival del pueblo**. Al final la ves caer entera de principio a fin, y es un vídeo hecho para compartir.

**Por qué este concepto:**

| Criterio | Por qué Cadencia lo cumple |
|---|---|
| **Se entiende en 3 segundos** | "Dibuja fichas hasta la campana y empuja" |
| **Profundidad durante meses** | **La regla oculta "longitud = tiempo"** convierte un juguete en un puzle de sincronización. Es la "profundidad descubrible" de Pixel Flow y Balatro (P-11) |
| **Viralidad nativa** | Las cadenas de dominó que caen son **contenido viral probado**: el canal de la artista de dominós Hevesh5 tiene unos 4,5 M de suscriptores y más de 2.000 M de visualizaciones. **Cada partida es un vídeo** |
| **Miles de niveles sin producción manual** | Generación **por construcción** (primero se crea la solución), simulación determinista y verificación automática. Más un **taller de niveles** de la comunidad con verificación de que se pueden superar |
| **Viable con 0 € y Godot** | Simulación discreta (sin motor de física), 2,5D con piezas sencillas y una estética de "juguete de madera" alcanzable sin ilustrador |
| **Legal y ético** | Sin moneda de pago, sin azar de pago, sin dificultad manipulada. Cumple **todas** las líneas rojas |

**Finalistas:**

| Puesto | Concepto | Puntuación /100 |
|---|---|---|
| 1 | **Cadencia** | **90** |
| 2 | Brote (jardín de autómatas) | 83 |
| 3 | Baraja (roguelike de cartas españolas) | 82 |

---

## 1. Brainstorming: 10 conceptos

**Nota sobre originalidad:** he buscado competidores reales de cada uno (sección 1.2). Ningún concepto copia un juego concreto. Los que se parecen demasiado a algo existente tienen una puntuación baja en originalidad.

### 1.1 Los 10 conceptos

| # | Concepto | Género | Idea central en una frase | Oportunidad (Fase 2) |
|---|---|---|---|---|
| 1 | **Cadencia** | Puzle de dominós, de sincronización | Dibujas cadenas de fichas y **la longitud es el tiempo**: sincroniza ramas para activar mecanismos | O1, O2, O3, O7 |
| 2 | **Telar** | Puzle lógico textil | Subes y bajas hilos de la urdimbre y pasas la lanzadera para **tejer el dibujo objetivo** fila a fila | O1, O5 (personas mayores), O7 |
| 3 | **Brote** | Puzle de autómata celular | Plantas semillas que **crecen con reglas** (en línea, en cruz, trepando) hasta cubrir el jardín con el patrón pedido | O1, O3, O5 |
| 4 | **Baraja** | Roguelike de cartas | Un "Balatro" con **baraja española** (escoba, chinchón) y comodines que rompen las reglas | O5 (mercado español), O3 |
| 5 | **Azulejo** | Colocación de piezas | Encajar azulejos por sus bordes para completar mosaicos de inspiración andaluza | O7 |
| 6 | **Cartero** | Puzle de rutas | Trazar una ruta de reparto por un pueblo que cumpla un orden y unas restricciones | O2 |
| 7 | **Faro** | Óptica | Girar espejos y filtros para que la luz de colores llegue a los barcos | O1 |
| 8 | **Pliegue** | Espacial | Doblar una hoja cuadriculada para superponer los colores en las posiciones objetivo | O1 |
| 9 | **Marea** | Fluidos | Verter agua sobre un terreno y abrir canales para llenar los estanques | O1, O7 |
| 10 | **Constelación** | Dibujo y narrativa | Unir estrellas con pocas líneas para formar figuras que cuentan mitos | O6 |

### 1.2 Comprobación de competencia (búsqueda del 16/11/2026)

| Concepto | Lo más parecido que existe | Valoración |
|---|---|---|
| Cadencia | **Dominos Draw!** (Entity3): dibujar el camino de fichas y verlo caer, en clave de juego casual de anuncios. **Draw Domino** (RedLine): revelar una imagen. Brain It On! y Pocket Marble Runs (reacciones en cadena con física) | **El gesto de dibujar dominós ya existe** en juegos casuales simples. **La sincronización por longitud, la composición de mecanismos y el meta-juego de la Gran Cadena no los he encontrado.** Nuestra diferencia está en la profundidad, no en el gesto |
| Telar | Pattern Weave Logic Lab (nonograma "tejido"), Weave Craft (simulador de telar), Thread Rush, Color Weave Puzzle | Competencia pequeña pero en aumento |
| Brote | Leafus (Juego de la Vida), Plant with Care, Regrowth y prototipos de *game jam* | Nicho indie, sin un referente fuerte en móvil |
| Baraja | Nada publicado. Escobita (itch.io) **planea** un modo roguelike | **Hueco real**, aunque el género "a lo Balatro" está saturado en PC |
| Resto | Flow Free y otros (Cartero), muchos puzles de láser (Faro), varios de plegado (Pliegue) | Muy explotados |

Fuentes: [Dominos Draw!](https://apps.apple.com/au/app/dominos-draw/id1472739353) · [Draw Domino](https://apps.apple.com/us/app/draw-domino/id1519433885?l=ko) · [Pocket Marble Runs](https://www.taptap.io/app/43186) · [Pattern Weave Logic Lab](https://apps.apple.com/se/app/pattern-weave-logic-lab/id6758345549) · [Weave Craft](https://apps.apple.com/us/app/-/id6760608757) · [Leafus](https://rawg.io/games/leafus) · [Plant with Care](https://apps.apple.com/app/id1589410147) · [Escobita](https://itch.io/post/17590702)

---

## 2. Matriz de puntuación

**Criterios del encargo**, más simplicidad, profundidad y encaje legal, con sus pesos:

| Criterio | Peso |
|---|---|
| Originalidad | 15 % |
| Simplicidad (se entiende en 3 segundos) | 10 % |
| Profundidad a largo plazo | 10 % |
| **Facilidad de desarrollo** con Godot, un solo desarrollador y 0 € | 15 % |
| Monetización **limpia** | 10 % |
| Retención | 10 % |
| **Viralidad orgánica** | 15 % |
| Escalabilidad de niveles | 10 % |
| Encaje legal | 5 % |

**Puntuaciones (1–5):**

| Concepto | Orig. | Simpl. | Prof. | Desarr. | Monet. | Ret. | Viral | Escal. | Legal | **Total /100** |
|---|---|---|---|---|---|---|---|---|---|---|
| **Cadencia** | 4 | 5 | 5 | 4 | 4 | 4 | 5 | 5 | 5 | **90** |
| Brote | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 5 | 5 | **83** |
| Baraja | 4 | 3 | 5 | 4 | 3 | 5 | 4 | 5 | 4 | **82** |
| Telar | 4 | 3 | 4 | 4 | 4 | 4 | 4 | 5 | 5 | **81** |
| Constelación | 3 | 4 | 3 | 5 | 3 | 3 | 3 | 4 | 5 | **72** |
| Cartero | 2 | 5 | 3 | 5 | 3 | 3 | 2 | 5 | 5 | **70** |
| Azulejo | 3 | 4 | 3 | 4 | 3 | 3 | 3 | 4 | 5 | **69** |
| Marea | 4 | 5 | 3 | 1 | 3 | 3 | 5 | 3 | 5 | **69** |
| Faro | 2 | 4 | 4 | 4 | 3 | 3 | 3 | 4 | 5 | **68** |
| Pliegue | 3 | 3 | 4 | 2 | 3 | 3 | 3 | 3 | 5 | **61** |

**Notas:**
- **Marea** sería muy viral, pero **simular fluidos en móvil está fuera de nuestro alcance** (facilidad 1).
- **Baraja** pierde puntos porque las cartas españolas limitan su atractivo fuera de España e Hispanoamérica, porque la monetización del género es sobre todo premium, y por el **riesgo de que la baraja se asocie al juego de azar** (clasificación por edad).
- **Telar** pierde en simplicidad porque la lógica de urdimbre y trama **no se entiende en 3 segundos**.

---

## 3. Comparativa de los 3 finalistas

| | **Cadencia** | **Brote** | **Baraja** |
|---|---|---|---|
| Gesto principal | **Dibujar** el camino y **empujar** | Tocar para plantar y ver crecer | Elegir cartas |
| Momento "wow" | **La cadena cae y todo suena a la vez** | El jardín florece | Una combinación absurda de puntos |
| Profundidad oculta | **Longitud = tiempo**: sincronización y orden | Interacción entre reglas de crecimiento | Sinergias de comodines |
| Meta-juego | **La Gran Cadena del festival**, vista entera al acabar cada capítulo | Restaurar un jardín (como el tema de Gardenscapes) | Una gira de torneos |
| Reto diario compartible | ✅ Mismo tablero para todos, comparando fichas usadas y precisión | ✅ | ✅ (semilla diaria) |
| Contenido infinito | ✅ Generación por construcción + taller | ✅ Generación | ✅ Roguelike |
| Viralidad | **Máxima**: es vídeo puro | Alta (timelapse) | Alta (capturas) |
| Público | **Universal**, sin idioma | Universal y tranquilo, mayores | **España e Hispanoamérica** |
| Riesgo técnico | Medio: dibujo preciso y rendimiento con muchas fichas | Bajo | Bajo |
| Riesgo de mercado | Gesto parecido a Dominos Draw! | Poca intensidad emocional | Género "a lo Balatro" muy saturado |

**Recomiendo Cadencia** por tres razones decisivas:
1. **Es el único finalista cuyo gameplay es en sí mismo contenido para redes.** Para un proyecto sin presupuesto de adquisición, esto pesa más que cualquier otro criterio (Fase 2, sección 7.4).
2. **Su regla de profundidad ("longitud = tiempo") es original, elegante y genera variedad combinatoria**, igual que la de Balatro.
3. **Es universal**: no necesita idioma, cultura ni licencias.

**Brote queda como plan B.** Si en el prototipo (entrega 1) el dibujo de fichas no resulta preciso o divertido en pantallas pequeñas, Brote reutiliza buena parte de la arquitectura (rejilla, simulación determinista, generador con verificación).

---

## 4. Diseño del concepto ganador: CADENCIA

### 4.1 Nombre provisional e identidad

- **Nombre provisional:** **Cadencia**. Une "cadena" y "cadencia" (ritmo, tiempo). Funciona en español e inglés ("Cadence").
- **Pendiente:** búsqueda de marca en EUIPO, OEPM y las tiendas antes de fijarlo (Fase 7).
- **Alternativas** si el nombre no está libre: *Tumbo*, *Fichas al Viento*, *Dominó Grande*.
- **Lema provisional:** *"Dibuja. Empuja. Que suene."*
- **Identidad:** un **juguete de madera artesanal** que cobra vida. Es cálido, táctil, sonoro y preciso como un reloj.
  - Puntos de partida para la dirección de arte (Fase 6): las fichas, las campanas y los mecanismos de latón como en un **taller de relojería y juguetería**; una paleta de maderas claras con acentos de color por tipo de pieza.
  - **Es lo opuesto a la estética brillante genérica** de la nueva ola de puzles (O7).

### 4.2 Historia y universo

- **Villa Cadencia** es un pueblo de relojeros y jugueteros. Cada año celebra **el Festival de la Gran Cadena**: una cadena de dominós que recorre el pueblo entero y, al caer, hace sonar todas las campanas a la vez.
- **Este año el gran reloj de la torre se ha parado** y el festival peligra.
- **La protagonista es Tilde**, una aprendiz de relojera. Junto a **Pío**, un pájaro de hojalata de cuerda que señala con su vuelo dónde hay que llegar (es también la guía del tutorial), tiene que **reconstruir la Gran Cadena tramo a tramo**: la plaza, el mercado, el puerto, el viaducto, la fábrica de juguetes y, por último, la torre del reloj.
- **El tono es amable y con humor ligero.** No hay villanos. El "conflicto" es el reto de la ingeniería y el reloj que no anda.
- **La narrativa es por episodios cortos** (al final de cada capítulo), en la línea de lo que funciona en Gossip Harbor (O6), pero **sin texto largo**: viñetas animadas y sin diálogos, para no tener que traducir.

### 4.3 Mecánica principal

| Elemento | Regla |
|---|---|
| **Dibujar** | Arrastras el dedo desde un punto de inicio y aparecen fichas a distancia fija a lo largo del trazo. **Ajuste magnético suave** para que el dibujo sea preciso en móvil |
| **Fichas disponibles** | Cada nivel da un número de fichas. La **"marca"** del nivel (como el par en golf) es el número de fichas de la solución de referencia |
| **Empujar** | Tocas el empujador y la cadena cae |
| **Longitud = tiempo** | Cada ficha tarda el mismo tiempo en caer. **El tiempo de llegada a un punto es proporcional a la longitud del recorrido** |
| **Curvas** | Un giro demasiado cerrado rompe la cadena. Hay un radio mínimo y el juego lo muestra al dibujar |
| **Éxito** | Todos los objetivos obligatorios se activan durante una sola caída |
| **Fallo** | La cadena se para o un objetivo no se activa. **Se ve exactamente dónde y por qué**, y se reintenta gratis al instante |

**La simulación es discreta y determinista**: los mismos trazos dan siempre el mismo resultado. Es fundamental para la equidad, para el reto diario y para el generador de niveles.

### 4.4 Objetivo del jugador

- **En cada nivel:** activar todos los objetivos con una sola caída.
- **Objetivos opcionales, con estrellas:**
  - ★ completar el nivel;
  - ★★ completarlo sin pasar de la marca de fichas;
  - ★★★ activar el objetivo de bonificación (una campana dorada en un sitio difícil).
- **A largo plazo:** reconstruir la Gran Cadena y la torre del reloj, completar el álbum de piezas y dominar los retos de maestría.

### 4.5 Controles

| Acción | Gesto |
|---|---|
| Dibujar | Arrastrar con el dedo |
| Borrar un tramo | Arrastrar el dedo hacia atrás sobre el trazo, o pulsar la goma |
| Deshacer y rehacer | Botones |
| Empujar | Tocar el empujador |
| Cámara rápida o lenta | Botones; la cámara lenta es un recurso clave para entender la sincronización |
| Zoom y desplazamiento | Pellizcar y arrastrar con dos dedos, solo en niveles grandes |

**Accesibilidad**, diseñada desde el principio:
- modo de **alto contraste**;
- **símbolos además de colores** (para el daltonismo);
- **tamaño de interfaz ajustable**;
- **todo se puede jugar con una mano**.

### 4.6 Piezas y mecanismos (el vocabulario del juego)

Se introducen **de forma progresiva**. El calendario está en la sección 5.2.

| # | Pieza | Qué hace | Profundidad que aporta |
|---|---|---|---|
| 1 | **Campana** | Objetivo básico: se activa al recibir el golpe | — |
| 2 | **Muro** | Obstáculo | Recorrido |
| 3 | **Bifurcador** | Divide la cadena en 2 ramas | Ramas paralelas |
| 4 | **Campanas numeradas** | Hay que golpearlas **en orden** | **Tiempo relativo** |
| 5 | **Puente** | Permite cruzar por encima de otra rama | Topología |
| 6 | **Campana doble** | Necesita **2 golpes casi a la vez** (dentro de una ventana) | **Sincronización** (la regla estrella) |
| 7 | **Bote de pintura** | Cambia el color de la cadena | Rutas por color |
| 8 | **Campanas de color** | Solo cuentan si las golpea su color | Combinación de colores y rutas |
| 9 | **Puerta de vaivén** | Se abre y se cierra a un ritmo fijo | **Ventanas de tiempo** |
| 10 | **Escalera** | Sube o baja de nivel (2,5D) | Capas |
| 11 | **Muelle** | Lanza la cadena por encima de un hueco (consume tiempo fijo) | Atajos con coste |
| 12 | **Espiral de retardo** | Una pieza que retrasa sin ocupar espacio | Ajuste fino del tiempo |
| 13 | **Interruptor** | Al caer, activa o desactiva otra pieza | Mecanismos condicionales |
| 14 | **Noria** | Recoge un golpe y lo devuelve más tarde | Bucles de tiempo |
| 15 | **Globo** | Al explotar libera algo, por ejemplo un camino nuevo | Secuencias en varias etapas |
| 16 | **Cinta transportadora** | Desplaza fichas ya colocadas | Movimiento |
| 17 | **Fichas pesadas** | Más lentas, pero derriban obstáculos frágiles | Compensación entre tiempo y fuerza |
| 18 | **Espejo** | Duplica tu trazo en simetría | Planificación espacial |
| 19 | **Reloj** | Algo debe pasar en un instante exacto | Precisión |
| 20 | **Campanario** (en los niveles de jefe) | Combinación de todo lo anterior | Maestría |

**Con 20 piezas y sus combinaciones** sale un espacio de diseño de miles de niveles, igual que los comodines de Balatro.

### 4.7 Sistema de niveles y progresión (resumen; el detalle está en la sección 5)

- **Campaña** en **capítulos de 20 niveles**. Cada capítulo es un **barrio** del pueblo y presenta **una pieza nueva**.
- **El nivel 20 de cada capítulo es el "Gran Tramo"** (equivale al jefe). Al superarlo se añade ese tramo a la Gran Cadena y **se ve caer la cadena entera** del pueblo hasta ese punto.
- **Progresión de doble capa** (Fase 3, sección 2.11):
  1. **el mundo**: el pueblo se reconstruye y el festival crece;
  2. **la habilidad**: piezas nuevas y técnicas avanzadas.

### 4.8 Personajes

| Personaje | Papel |
|---|---|
| **Tilde** | La aprendiz de relojera, protagonista. Se expresa con gestos, sin texto |
| **Pío** | Pájaro de hojalata. Guía del tutorial e indicador de pistas, y mascota de la marca |
| **Los vecinos** (panadera, farero, maquinista…) | Cada barrio tiene uno que "encarga" su tramo y celebra al terminarlo |
| **El Gran Reloj** | El "personaje" final: su campanada es el clímax de la campaña |

### 4.9 Elementos desbloqueables

| Desbloqueable | Contenido |
|---|---|
| **Estilos de ficha** (cosméticos) | Madera de haya, nogal, cristal, cerámica, papel, chocolate, neón… cada uno con su **propio sonido al caer** |
| **Sonidos de campana** | Escalas musicales: hacer sonar una melodía con la cadena es un reto opcional |
| **Decoraciones del pueblo** | Banderines, farolillos, fuegos artificiales del festival |
| **Álbum de piezas** | Fichas de cada mecanismo con curiosidades. Una colección que **se completa jugando** |
| **Piezas del taller** | Desbloquean el uso de cada mecanismo en el editor |

### 4.10 Recompensas

- **Estrellas**: progreso del capítulo y desbloqueos de decoración.
- **Fichas de colección**: al completar retos.
- **Sin moneda de pago** (LR-04). Si hace falta una moneda para cosméticos, **solo se gana jugando** y no se vende.
- **Recompensa variable gratuita** (P-14): cadenas "perfectas" (sin fichas sobrantes, todo sincronizado) con una celebración especial, y **Pío encuentra a veces un adorno escondido** al completar niveles.

### 4.11 Retos

| Reto | Descripción |
|---|---|
| **Maestría del nivel** | Las 3 estrellas |
| **Retos de capítulo** | Por ejemplo, "completa 5 niveles usando un solo bifurcador" |
| **Reto melódico** | Hacer sonar las campanas en el orden de una melodía conocida (de dominio público) |
| **Retos de taller** | Superar niveles creados por la comunidad |

### 4.12 Modos de juego

| Modo | Descripción | Bucle (Fase 3) |
|---|---|---|
| **Campaña** | Capítulos y Gran Cadena | Largo plazo |
| **La Caída del Día** | **El mismo nivel para todo el mundo cada día.** Puntuación = fichas usadas + precisión de sincronización. **Resultado compartible como texto o emojis sin desvelar la solución** (estilo Wordle) | Diario |
| **Taller** | Editor de niveles. Para publicar un nivel **hay que superarlo antes** (verificación). Se comparte con un **código de texto** (sin servidor) | Largo plazo y social |
| **Modo Libre (zen)** | Un lienzo sin objetivos para dibujar y derribar. ASMR puro y **una herramienta de creación de vídeos** | Relajación y viralidad |
| **Eventos temporales** | Barrios temáticos con fecha real (Navidad, verano…), con cosméticos que **vuelven en años siguientes** (P-12) | Medio plazo |

### 4.13 Sistema de dificultad

- **Dificultad por nivel e igual para todos** (P-03), definida por métricas objetivas del generador:
  - número de objetivos;
  - restricciones de tiempo (orden, campanas dobles, ventanas);
  - **margen de fichas** (fichas disponibles frente a la marca);
  - número de ramas;
  - piezas presentes.
- **Calibración con datos agregados** (Fase 9): tasa de superación, intentos medios, tiempo hasta superar y tiempo hasta abandonar.
- **Curva en dientes de sierra**: después de un nivel difícil vienen 2–3 de "respiro" (Fase 1, King).
- **Ayudas que solo facilitan** (P-05):
  - una **pista** que dibuja en fantasma un tramo de la solución (gratis con límite diario, ilimitada para premium y con anuncio voluntario);
  - tras 5 intentos fallidos, **la cámara lenta se muestra destacada**, sin cambiar el nivel.
- **Nunca** se altera un nivel según el jugador ni su valor económico (LR-01). **Todos los niveles tienen solución** (LR-02, P-14).

### 4.14 Elementos sociales (pequeños, relativos y desactivables, P-15)

- **Compartir el resultado diario** (texto o emojis).
- **Compartir la repetición**: un clip corto de la caída (viabilidad técnica pendiente de comprobar en la Fase 8).
- **Clasificación de amigos** de la Caída del Día mediante Game Center o Google Play Games (gratis).
- **Ligas semanales pequeñas**, opcionales.
- **Códigos de niveles del taller**: el intercambio de creaciones entre amigos y en redes.

### 4.15 Diferenciación frente a la competencia

| Frente a | Cadencia aporta |
|---|---|
| Dominos Draw! y Draw Domino | **Profundidad** (sincronización, mecanismos, orden), meta-juego, reto diario, taller y monetización limpia |
| Brain It On! y juegos de física | **Determinismo**: lo que planeas es lo que pasa, sin frustración por la física. Ritmo más relajado |
| Flow Free y otros puzles de trazos | **La dimensión del tiempo** y el espectáculo de la caída |
| La nueva ola de puzles (Pixel Flow…) | **Retención**: meta-juego, taller, reto diario. Monetización sin trucos |
| Royal Match y los veteranos | **Un gesto nuevo, muy visual y sin idioma** |
| Todos | **Marca "limpia"**: sin moneda de pago, sin azar de pago, panel de "Juego responsable" (O4) |

### 4.16 Encaje con el modelo de tres bucles (Fase 3)

| Bucle | En Cadencia |
|---|---|
| **Partida (1–3 min)** | Dibujar, empujar, ver caer y celebrar. Si fallas, ves por qué y reintentas al instante. "Casi conseguirlo" surge de forma natural (una campana que falla por poco), **nunca fabricado** |
| **Día (5–15 min)** | La Caída del Día, algún nivel de la campaña y compartir el resultado. **Cierre natural**: "mañana, otra caída" |
| **Largo plazo** | La Gran Cadena, el álbum, el taller, los eventos y la maestría de 3 estrellas |

---

## 5. Diseño escalable de niveles

### 5.1 Arquitectura del contenido

**Los niveles tienen tres orígenes:**
1. **Diseñados a mano**: los **primeros unos 60 niveles** (tutorial y presentación de piezas) y **todos los "Gran Tramo"**, para cuidar la calidad donde más importa.
2. **Generados y curados**: el generador produce miles de candidatos. Un **filtro automático** descarta los malos y se seleccionan los mejores para la campaña.
3. **De la comunidad**: los niveles del taller, verificados porque su autor tuvo que superarlos.

**Formato:** cada nivel es un **archivo de datos pequeño** (JSON o recurso de Godot) con tamaño, piezas, objetivos, fichas disponibles, marca y semilla. **Miles de niveles caben en unos pocos MB.**

### 5.2 Introducción progresiva de mecánicas

| Capítulo (20 niveles) | Barrio | Pieza nueva | Combinaciones que se introducen |
|---|---|---|---|
| 1 | La Plaza | Campana, muro | Tutorial: dibujar, curvas y fichas limitadas |
| 2 | El Mercado | Bifurcador | Varias campanas |
| 3 | La Fuente | Campanas numeradas | **Primer contacto con el tiempo**: el orden |
| 4 | El Puente Viejo | Puente | Ramas que se cruzan |
| 5 | El Campanario Pequeño | **Campana doble** | **Sincronización**: la regla estrella |
| 6 | El Taller de Pintura | Bote de pintura y campanas de color | Color + orden |
| 7 | El Puerto | Puerta de vaivén | Ventanas de tiempo |
| 8 | Las Escaleras | Escalera (capas) | 2,5D |
| 9 | La Feria | Muelle | Atajos con coste de tiempo |
| 10 | La Relojería | Espiral de retardo | Ajuste fino |
| 11–20 | Viaducto, Fábrica, Faro, Estación, Jardín… | Interruptor, noria, globo, cinta, fichas pesadas, espejo, reloj… | Combinaciones de 2 y 3 piezas |
| 21+ | Barrios "remix" | Sin piezas nuevas, combinaciones profundas | Maestría |

**Regla de ritmo dentro de cada capítulo:**

| Niveles | Función |
|---|---|
| 1–3 | Enseñar la pieza nueva sola |
| 4–8 | Combinarla con lo ya conocido |
| 9–10 | Respiro |
| 11–16 | Dificultad creciente con picos cortos |
| 17–19 | Preparación |
| 20 | **Gran Tramo** |

### 5.3 Generador procedural "por construcción"

Sigue el principio que ya usan los clones abiertos de Block Blast (Fase 1, sección 3.2), pero llevado más lejos: **primero se crea la solución y después el problema.**

1. **Topología:** generar el árbol de la solución (inicio → tramos → bifurcadores → ramas) dentro del tablero.
2. **Trazado:** dibujar recorridos válidos (radio de curva mínimo, sin colisiones salvo en los puentes).
3. **Tiempos:** simular la caída de la solución y registrar el instante en que llega a cada punto.
4. **Objetivos:** colocar campanas en puntos del recorrido y **derivar sus restricciones** de esos tiempos:
   - numeradas según el orden real de llegada;
   - campanas dobles donde dos ramas llegan dentro de la ventana;
   - puertas con una fase que encaje con la llegada.
5. **Obstáculos:** añadir muros y elementos **fuera del corredor de la solución**, para desviar los atajos obvios.
6. **Fichas:** fichas disponibles = marca de la solución + margen según la dificultad objetivo.
7. **Validación automática** con un **solucionador heurístico** de búsqueda sobre una rejilla gruesa:
   - descartar los niveles con **soluciones triviales** (demasiado fáciles);
   - estimar **cuántas soluciones distintas** hay (queremos más de una, por autonomía, P-01 y SDT);
   - **la solubilidad está garantizada por construcción.**
8. **Puntuación de dificultad** prevista (número de restricciones, margen, ramas, piezas). Se calibra después con datos reales.
9. **Curación:** se seleccionan los mejores por variedad y por la "elegancia" de la solución.

**Con el mismo generador se crean:** la Caída del Día (una semilla por fecha, igual para todos), los eventos y los barrios "remix".

### 5.4 Niveles especiales

| Tipo | Descripción |
|---|---|
| **Gran Tramo** (jefe, nivel 20) | Nivel grande con todas las piezas del capítulo y varias fases (un globo libera la segunda parte). Al superarlo, **cinemática de la Gran Cadena** |
| **Un solo trazo** | Sin levantar el dedo |
| **Contrarreloj musical** | Las campanas deben sonar al ritmo de una melodía |
| **Niebla** | Parte del tablero oculta hasta que la cadena pasa |
| **Espejo** | Tu trazo se duplica |
| **Mínimo absoluto** | Fichas = marca exacta |

### 5.5 Eventos temporales

- **Un barrio temático de duración limitada**, con 10–15 niveles generados y curados y un Gran Tramo propio.
- **Fechas reales y anunciadas**; los cosméticos del evento **vuelven en años siguientes** (P-12, LR-06).
- **Sin pase de pago obligatorio** para completar el evento.

### 5.6 Rejugabilidad

- 3 estrellas por nivel y una marca de fichas que hay que batir.
- La Caída del Día (infinita).
- El taller (infinito).
- El Modo Libre.
- **Varias soluciones por nivel**: compartir soluciones distintas también es contenido.

### 5.7 Equilibrado con datos y tratamiento de niveles problemáticos

**Métricas por nivel** (analítica de la Fase 9, agregada y con seudónimo):
- tasa de superación;
- intentos medios;
- **tiempo hasta superar** y **tiempo hasta abandonar** (las métricas de King, Fase 1);
- % que usa pista;
- % que abandona la app en ese nivel.

**Reglas de alerta y rediseño**, aplicadas **a todos los jugadores por igual y mediante una actualización del nivel**:

| Señal | Umbral inicial (se ajustará con datos) | Acción |
|---|---|---|
| Tasa de superación anormalmente baja | Menos del 40 % tras 3 intentos de media, o 2 desviaciones por debajo de la media del capítulo | Más margen de fichas, ventana más amplia o retirar un obstáculo |
| Abandono de la app en el nivel | El doble que la media del capítulo | Revisar la claridad: ¿se entiende por qué falla? Mejorar la retroalimentación |
| Nivel largo y difícil | Tiempo hasta superar por encima del percentil 90 | **Acortar** (regla de King: los niveles difíciles deben ser cortos) |
| Demasiado fácil | Más del 95 % lo supera al primer intento, salvo en los niveles de respiro | Subir la dificultad o recolocarlo como respiro |
| "Nivel poco divertido" | Abandono alto **y** pocos reintentos | Sustituirlo por otro candidato del generador ("poda", como hizo King con sus 100 peores niveles) |

**Explícitamente prohibido:** ajustar la dificultad o el reparto a cada jugador según sus compras, su valor publicitario o cualquier dato económico (LR-01).

---

## 6. Riesgos y aspectos pendientes

| Riesgo | Impacto | Mitigación |
|---|---|---|
| **Precisión del dibujo en pantallas pequeñas** | Alto | Ajuste magnético, zoom y deshacer. **Es lo primero que validará el prototipo** (entrega 1). Plan B: Brote |
| **Parecido percibido con Dominos Draw!** | Medio | Diferenciación clara por la profundidad, la identidad visual y el meta-juego. Comunicar "el puzle de dominós con tiempo" |
| **Rendimiento con cientos de fichas animadas** | Medio | Instancias múltiples en Godot (MultiMesh) y animación por vértices. Se validará en la entrega 1 |
| **Exportar la repetición como vídeo en el móvil** | Medio | Se estudiará en la Fase 8. La alternativa es compartir el código del nivel más una captura o la grabación de pantalla nativa del sistema |
| **Curva de aprendizaje de la sincronización** | Medio | Introducción en el capítulo 5, no antes, con cámara lenta y Pío indicando "¡a la vez!" |
| **Nombre "Cadencia" ocupado** | Bajo | Búsqueda de marca en la Fase 7. Hay alternativas |

**Pendiente para las fases siguientes:**
- **Fase 5:** modelo de negocio concreto (ver la nota de abajo).
- **Fase 6:** dirección de arte.
- **Fase 7:** marca y nombre definitivos.
- **Fase 8:** prototipo de la mecánica (entrega 1).

**Nota sobre el sistema de energía del encargo original:** con este concepto propongo **no limitar la campaña con vidas**. El ritmo de consumo lo marcan de forma natural la Caída del Día, los capítulos y los eventos. **La monetización irá a la comodidad, la cosmética y el contenido extra**, no al acceso a la progresión, para evitar el "pagar para avanzar" de la DFA (art. 16). Se decide en la Fase 5.

## 7. Próximos pasos (sujetos a tu aprobación)

**Fase 5: modelo de negocio y monetización de Cadencia.**
- Modelo freemium sin barreras de progresión.
- Suscripción y "quitar anuncios" con los precios de referencia de la Fase 2.
- Estrategia de anuncios (AdMob, LevelPlay, AppLovin MAX…, con precios y condiciones verificados).
- Modelo financiero con 1.000, 10.000, 50.000 y 100.000 jugadores diarios en tres escenarios.
- **Usaremos las skills pricing, paywalls y offers** dentro del marco legal.
