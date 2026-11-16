# FASE 1 — Informe técnico, psicológico y comercial
## Candy Crush Saga (King) y Block Blast! (Hungry Studio)

**Fecha del informe:** 16 de noviembre de 2026
**Estado:** Entregado, a la espera de aprobación
**Coste incurrido:** 0 € (solo fuentes públicas; no se ha usado ninguna herramienta de pago)

---

## 0. Resumen ejecutivo

1. **Son dos modelos de negocio opuestos.** Candy Crush Saga es un juego de **niveles diseñados a mano y monetización por compras integradas** (más o menos 0,9–1,1 mil millones de dólares al año en compras dentro de la tienda, con un 14.º año de vida). Block Blast! es un **puzle sin fin con monetización casi exclusivamente publicitaria** (unos 127 M$ en anuncios entre enero y mayo de 2026 según Sensor Tower, e ingresos por compras prácticamente nulos).
2. **La afirmación más grave que circula ("el juego te hace perder cuando un anuncio vale más") tiene evidencia técnica seria en Block Blast, pero no en Candy Crush.**
   - En **Block Blast**, un análisis público de octubre de 2026 muestra código descompilado con una regla (`RewardHighValueAdHarvestTrait`) que, si se cumplen ciertas condiciones, entrega una mano de piezas imposible de colocar (`ZHI_SI_TI`, 致死题, "pregunta letal") **cuando el anuncio recompensado cargado vale ≥3,5 veces el eCPM del anterior**. Un tercero ha revisado los fotogramas del código y lo considera "muy probablemente auténtico". **No hay confirmación ni desmentido de Hungry Studio y nadie lo ha replicado de forma independiente descifrando el paquete.** Grado de evidencia: **D (experimento de terceros con código mostrado, sin replicar)**.
   - En **Candy Crush**, **no existe evidencia pública** de que la dificultad se ajuste por jugador según su valor publicitario o sus compras. Lo que sí está documentado por King es que **ajusta la dificultad de los niveles para todos los jugadores** (no individualmente) usando datos agregados de abandono y conversión, y que su nivel más rentable fue también el que más jugadores perdió.
3. **Corrección importante de un mito:** las patentes que suelen citarse como "patentes de King sobre dificultad dinámica" (US10363487B2, US10561944B2) son en realidad de **Zynga**. La patente de "Dynamic difficulty adjustment" que menciona el gasto del jugador como posible dato de entrada es de **Electronic Arts** (US9919217B2). No he encontrado ninguna patente de King que cubra ajustar la dificultad por el valor comercial del jugador.
4. **Lección estratégica para nuestro proyecto (con presupuesto 0 €):** el crecimiento de Block Blast **dependió en gran parte de la adquisición pagada de usuarios**, como admitió su propio VP. Su modelo (mucho volumen y anuncios baratos) no se puede replicar sin presupuesto de marketing. El modelo de Candy Crush (pocos pagadores, mucho valor por pagador, años de contenido) es más compatible con un crecimiento orgánico lento, pero exige profundidad de diseño y una producción de niveles escalable.

---

## 1. Metodología y criterios de evidencia

### 1.1 Clasificación de la evidencia (tal como pediste)

| Código | Tipo | Cómo lo uso |
|---|---|---|
| **A** | Código, documentación o evidencia técnica verificable (patentes, papers con datos, comportamiento del juego que cualquiera puede reproducir) | Lo trato como hecho |
| **B** | Declaraciones de la empresa o de sus desarrolladores (charlas GDC, notas de prensa, entrevistas) | Hecho *declarado*; puede ser parcial o interesado |
| **C** | Investigación independiente y análisis técnico (académico o periodístico) | Fuerte si hay metodología |
| **D** | Experimentos y análisis de terceros (descompilaciones, pruebas) | Creíble si muestra el método; provisional hasta que alguien lo replique |
| **E** | Hipótesis y especulación de comunidades | No lo considero probado |

### 1.2 Qué he hecho y qué no

**He hecho:**
- Búsqueda y lectura de fuentes primarias: patentes en Google Patents, papers académicos (IEEE CIG, WWW, Journal of Gambling Studies), crónicas de charlas GDC de King, notas de prensa de Hungry Studio y el análisis original de descompilación de Block Blast.
- Contraste de cifras entre varios rastreadores (Sensor Tower, AppMagic) y datos que publica la propia empresa.
- Verificación cruzada de las afirmaciones virales con fuentes primarias. Por ejemplo, abrí las patentes para comprobar quién las había registrado.

**No he hecho (y por qué):**
- **No he descompilado ningún APK yo mismo.** Las condiciones de uso de ambos juegos lo prohíben, y la excepción legal europea a la descompilación (Directiva 2009/24/CE, art. 6) solo cubre la interoperabilidad, no el análisis competitivo. Además, el análisis publicado sobre Block Blast indica que la lógica relevante se descarga cifrada desde servidores. Descifrarla supondría saltarse una protección, cosa que excluiste expresamente.
- **No he usado Sensor Tower, AppMagic ni data.ai de pago.** Las cifras de estos servicios proceden de sus blogs públicos o de medios que los citan, y siempre indico la fuente intermedia.
- **No he hecho experimentos propios con el juego.** En la sección 9 propongo un protocolo reproducible y gratuito por si quieres validar las afirmaciones antes de la Fase 2.

### 1.3 Advertencia temporal

El análisis de descompilación de Block Blast es del **15 de octubre de 2026**, es decir, de hace un mes. Ha tenido mucha difusión, pero todavía no hay réplicas independientes completas ni respuesta pública de Hungry Studio. Las conclusiones sobre Block Blast deben revisarse si aparece información nueva.

---

## 2. Fichas de identidad

| | **Candy Crush Saga** | **Block Blast!** |
|---|---|---|
| Desarrolladora | King (Activision Blizzard → **Microsoft** desde oct. 2023) | **Hungry Studio** (se atribuye su sede a Pekín; no lo he verificado con una fuente primaria) |
| Lanzamiento | Facebook abr. 2012; móvil nov. 2012 | Las fuentes discrepan: 2021, 2022 o 2023. Hungry Studio dice que se fundó en 2021 |
| Género | Match-3 por niveles ("saga") | Puzle de bloques en tablero 8×8, sin fin, con modo aventura |
| Motor | Propio de King (no documentado públicamente en detalle) | **Cocos** (JavaScript y nativo), según dos análisis independientes [D/C] |
| Niveles | Más o menos 16.000–17.000 en 2026, con unos 45–60 nuevos por semana (fuentes secundarias; no hay cifra oficial) [E/C] | Modo **Clásico** sin fin y modo **Aventura** con niveles temáticos y de rompecabezas |
| Usuarios | MAU de la saga: las estimaciones van de ~80 M (Bank of America/Business of Apps, 2025) a ~180 M en toda la franquicia (2024). King no publica MAU por juego | **70 M DAU / 300 M MAU** (empresa, ene. 2026) [B]; 40 M / 160 M en dic. 2024 [B] |
| Descargas | Miles de millones acumuladas | **284 M en 2025** (Sensor Tower), 2.º juego más descargado del mundo [C]; ~216 M en 2024 [B] |
| Ingresos | ~1,09 mil M$ (2024) y ~0,88–1,0 mil M$ (2025) en compras dentro de la tienda (AppMagic/Business of Apps) [C]. Franquicia: **20.000 M$ acumulados** (King, sep. 2023) [B] | **~127 M$ por anuncios en ene.–may. 2026** (Sensor Tower), el juego n.º 1 del mundo en ingresos publicitarios [C]. Compras: insignificantes (<10 k$ en 2025, estimación de terceros) |
| Público | Muy amplio, con mayoría adulta y mucho jugador de más de 35 años (perfil típico del match-3) | Amplísimo; fuerte en EE. UU., Filipinas, Alemania, Rusia, Indonesia, Reino Unido, Brasil y México [C] |

---

## 3. Ingeniería inversa e investigación técnica

### 3.1 Candy Crush Saga

#### Arquitectura general (lo que se puede afirmar)
- **Cliente con lógica de juego local y contenido y configuración servidos de forma remota**: eventos, ofertas, ajustes de nivel y pruebas A/B. El reajuste de niveles sin actualizar la app lo describe la propia King [B] y lo confirma la observación de la comunidad [E].
- **Generación de caramelos:** dentro de cada nivel diseñado (tablero, objetivos, movimientos, colores disponibles y obstáculos), los caramelos nuevos caen de forma aleatoria. Al reintentar un nivel, el tablero inicial cambia, cosa que cualquiera puede comprobar [A, comportamiento observable]. **King no ha publicado su algoritmo de generación.** La afirmación de que "es aleatorio dentro de las restricciones del nivel y no depende del gasto" circula atribuida a King, pero **no he encontrado ningún documento primario de King que lo diga** [E].

#### Sistema de diseño y ajuste de niveles (lo mejor documentado)
- **Pruebas de juego con IA (2018):** King publicó *Human-Like Playtesting with Deep Learning* (Gudmundsson et al., IEEE CIG 2018). Entrenaron una red convolucional con jugadas reales de jugadores de Candy Crush Saga y Soda Saga para **predecir la tasa de superación de un nivel nuevo antes de lanzarlo**. Según crónicas posteriores, pasaron de unos 7 días de pruebas humanas por episodio de 15 niveles a menos de un minuto por nivel [A/B].
  Fuente: [IEEE DOI 10.1109/CIG.2018.8490442](https://api.crossref.org/works/10.1109%2FCIG.2018.8490442) · [PDF en gwern.net](https://www.Gwern.net/doc/reinforcement-learning/imitation-learning/2018-gudmundsson.pdf)
- **Métricas de "nivel bueno" (GDC 2024, Jan Wedekind y Xavier Guardiola, de King) [B]:**
  - La "diversión" de un nivel se mide combinando **tiempo hasta abandonar** y **tiempo hasta superarlo**.
  - "Cuanto más largo es el nivel, menos probable es que sea divertido". Los niveles difíciles deben ser cortos.
  - Los niveles muy "puzzly" (de solución única y basados en lógica pura) resultaron los **menos atractivos**.
  - King identificó los **100 niveles menos divertidos y los corrigió**, con una "mejora muy significativa" del engagement. Es un proceso continuo en todo su catálogo.
  - **Nivel 65:** era el nivel más rentable de la historia del juego y también **el que más abandono provocaba**. Una de las primeras pruebas A/B demostró que **hacerlo más difícil subía la conversión a corto plazo y hacerlo más fácil retenía más a largo plazo**.
  - Sus conclusiones: "los niveles extremadamente difíciles nunca compensan a largo plazo", "diseñar para la media no es buena idea" y "la retención siempre gana".
  Fuente: [mobilegamer.biz, 27/03/2024](https://mobilegamer.biz/how-king-defines-a-good-candy-crush-saga-level-and-why-it-constantly-prunes-the-bad-ones/)
- **Etiquetas de dificultad visibles** ("Hard", "Super Hard"…): el jugador puede verlas en el cliente [A, observable]. Según hilos del foro oficial, la etiqueta se recalcula automáticamente tras unas semanas de datos reales [E: foro, no documento oficial].
  Fuente: [King Community](https://community.king.com/en/candy-crush-saga/discussion/426167/level-difficulty-changing)
- **Producción con IA (2025):** en julio de 2025 King despidió a unas 200 personas, entre ellas buena parte del equipo de diseño de niveles. Según fuentes anónimas, sus funciones pasaron a herramientas de IA que esos mismos empleados habían construido [C: periodismo con fuentes anónimas; King no lo ha confirmado].
  Fuente: [mobilegamer.biz](https://mobilegamer.biz/laid-off-king-staff-set-to-be-replaced-by-the-ai-tools-they-helped-build/)

#### ¿Dificultad dinámica por jugador?
- **No hay evidencia pública** de que Candy Crush ajuste la dificultad por jugador.
- **Sobre las patentes que se suelen citar:**
  - **US10363487B2**, *"determining game level attributes based on player skill level"*: titular **Zynga Inc.**, no King. Ajusta la frecuencia de aparición de objetos según la **habilidad** del jugador. La **oportunidad de compra** aparece como *resultado* de ese cálculo, no como dato de entrada [A]. [Google Patents](https://patents.google.com/patent/US10363487B2/en)
  - **US10561944B2**, ajuste de dificultad mediante ficheros de definición de nivel: titular **Zynga Inc.** [A]. [Google Patents](https://patents.google.com/patent/US10561944B2/en)
  - **US9919217B2**, *"Dynamic difficulty adjustment"*: titular **Electronic Arts**. Ajusta "palancas" del juego según la **probabilidad de abandono prevista**. En la descripción (no en las reivindicaciones) se incluye **"cuánto dinero gastó el usuario"** entre los posibles datos de entrada [A]. [Google Patents](https://patents.google.com/patent/US9919217B2/en)
  - Patentes de King que sí he encontrado: *"Controlling a user interface of a computer device"* (US9776093, US10086296), que tratan de mecánicas de interfaz y match-3. **No he encontrado reivindicaciones sobre dificultad ligada al gasto.** [A]
- **Análisis viral de Candy Crush (Ayoships, oct. 2026):** afirma que King calcula un indicador de "pass proximity" (lo cerca que estás de superar el nivel) para decidir qué compras y anuncios ofrecerte. **En el material publicado no se muestra código, nombre de variable ni captura que lo respalde.** [E, por falta de pruebas.] Fuente: [mobilegamer.biz, 27/10/2026](https://mobilegamer.biz/this-creator-says-he-decompiled-block-blast-candy-crush-and-subway-surfers-to-reveal-their-monetisation-secrets/)
- **Contexto del sector:** EA publicó y desplegó un sistema de dificultad dinámica en varios juegos móviles. Obtuvo **hasta un 9 % más de engagement con un impacto "neutro" en la monetización** (Xue et al., WWW 2017) [A/C]. Esto prueba que la dificultad dinámica orientada a retención existe en la industria, **no** que King la use. [Paper](https://archives.iw3c2.org/www2017/proceedings/companion/p465.pdf)

### 3.2 Block Blast!

#### Lo que declara la empresa [B]
- Hacen pruebas A/B de forma intensiva: **más de 10.000 experimentos en 2025** y más de 300 en paralelo cada día (nota de prensa del 08/01/2026). En 2024 hablaban de más de 50 por semana, con un **97 % de pruebas fallidas**.
- Tienen **"Block AI"**, una plataforma propia que simula el comportamiento de usuarios para probar versiones antes de lanzarlas.
- Hay una **versión minimalista** para regiones con mala conexión o móviles poco potentes.
- Jason Wang, VP: *"el crecimiento de Block Blast se ha apoyado mucho en la adquisición de usuarios"* (adquisición pagada).
Fuentes: [BusinessWire 08/01/2026](https://www.businesswire.com/news/home/20260108572322/en/Block-Blast-Scales-to-70M-DAU-as-Hungry-Studio-Runs-Over-10000-Experiments-in-a-Single-Year) · [mobilegamer.biz 14/01/2025](https://mobilegamer.biz/block-blast-maker-hungry-studio-a-b-tested-its-way-to-the-top-of-the-charts/)

#### La descompilación de Ayoships (15/10/2026) [D]
Ayo Omolewa ("Ayoships") publicó un análisis detallado. Fuente original: [ayoships.com/breakdowns/block-blast](https://ayoships.com/breakdowns/block-blast)

**Método que declara:** APK de Android v10.8.2 (APKPure, coincide con la de APKMirror) e IPA de iOS v7.4.9, con firmas verificadas. Usó jadx para la parte Java y Ghidra para la librería nativa de Cocos. Lo ejecutó en un emulador limpio de Android 14 y en el simulador de iOS. Las reglas ("traits") se descargan **cifradas (XXTEA) y comprimidas (Brotli) desde servidores** de Hungry Studio, y el servidor asigna a cada jugador una variante de experimento. El autor declara haber descifrado esas reglas y no publica la clave.

**Elementos con código mostrado en el análisis:**

| Regla o nombre en el código | Qué hace según el código mostrado |
|---|---|
| `RewardHighValueAdHarvestTrait` | Constantes `HIGH_PRICE_MULTIPLIER = 3.5` y `MIN_HISTORY_AD_WATCH_COUNT = 3`. Se activa si: (1) has visto al menos 3 anuncios recompensados en total, (2) completaste tus 3 últimos anuncios recompensados, (3) tu puntuación supera tu récord más un umbral (1.000 en la variante del autor; otras variantes usan 500 o 750) y (4) **el anuncio recompensado cargado ahora vale ≥3,5 veces el eCPM del último que viste**. Entonces sustituye el siguiente reparto de piezas por `deathAlgorithm` |
| `ZHI_SI_TI` (致死题, "pregunta letal") → `algo_must_death` | Tipo de reparto de piezas diseñado para no poder colocarse. El autor probó un ejemplo: 171 colocaciones, ninguna válida |
| `PersonalMarginBreakTrait` | Al superar el récord en cierto porcentaje, cambia el algoritmo de reparto con cierta probabilidad. En la configuración real del autor: prob. 20 %, umbral 10 %, algoritmo 9 = letal |
| `ClientDieModelLoadTrait` | Modelo **XGBoost** (500 árboles, 52 variables) en el cliente que elige la dificultad del modo aventura |
| `EcpmFeatureBaseInfo.runModel` | Modelo XGBoost que **predice el eCPM del jugador** según país, dispositivo, historial de anuncios, etc. |
| `NewNextDayLowActivityTrait` | Modelo **LightGBM** que predice si mañana jugarás poco. Si la probabilidad es ≥0,69, te regala una resurrección sin anuncio, una vez al día |

**Elementos que el autor describe pero sin código mostrado (solo su lectura):** `FailStreakStrategyTrait` (piezas más fáciles tras dos partidas por debajo del récord), `FastHandPunishTrait` (piezas difíciles si juegas muy rápido cerca del récord), `MultiClearBoostThenKillTrait`, `MABXiBaiTrait` (experimento tipo *bandit* sobre **a qué minuto** de la partida conviene introducir la mano letal) y `AdPlusMinusStrategyTrait` (bonificación aleatoria de hasta el 10 % del récord tras ciertas resurrecciones).

**Verificación por terceros [C/D]:** *Acid Alchamy* (14/10/2026) revisó fotograma a fotograma el vídeo viral. Concluye que el código mostrado es **"muy probablemente JavaScript auténtico de Block Blast descompilado"** y que la narración es "en general una lectura justa". Señala cuatro puntos que el vídeo **insinúa pero no prueba**:
- que la dificultad varíe según el valor del jugador en general;
- la lógica concreta de selección de piezas de la mano letal (solo se ven los nombres);
- el "Boost Then Kill";
- que la bonificación del 10 % sea secreta.

Considera que 11 de los 13 mecanismos son **habituales en juegos financiados por anuncios**. Solo dos le parecen **distintos en naturaleza**: provocar una derrota encubierta para forzar un anuncio y escribir una puntuación inflada. [Acid Alchamy](https://acidalchamy.com/blog/block-blast-ad-harvest-fact-check)

**Respuesta de Hungry Studio:** ninguna sobre el fondo de la acusación. No respondió a mobilegamer.biz ni a Inc./The Star. Su postura pública se limita a enmarcarlo todo como pruebas A/B.

**Mi valoración profesional:**
- La existencia del código es **creíble**: lo muestran dos análisis distintos y concuerda con nombres internos en chino que difícilmente se habrían inventado.
- Lo que **no** está demostrado: **a cuántos jugadores se aplica** (es una variante de experimento entre otras y la mitad de las versiones de la regla tienen la comprobación desactivada, según el autor), **con qué frecuencia** se activa en el uso real y si **sigue activo hoy**.
- Una predicción que se puede comprobar: si la regla depende de que haya un anuncio cargado (`isTargetAdReady()`), **jugando sin conexión no debería activarse**. El protocolo de la sección 9 lo comprueba.

#### Generación de piezas: lo que se sabe en general
- El algoritmo base **no está documentado públicamente** por Hungry Studio.
- Según el análisis anterior, hay **varios algoritmos de reparto** intercambiables con prioridades: unos generan manos favorables (que permiten limpiar líneas), otros normales y otros letales, y los "traits" eligen cuál usar en cada momento [D].
- Los clones de código abierto suelen usar muestreo con rechazo que **garantiza al menos una colocación válida** ([Kirill009943/block_blast_ML](https://github.com/Kirill009943/block_blast_ML), [dffge552/block-blast](https://github.com/dffge552/block-blast)) [A, pero solo para los clones; no demuestra qué hace el juego oficial].

---

## 4. Verificación de las afirmaciones que circulan

| # | Afirmación | Candy Crush | Block Blast | Evidencia |
|---|---|---|---|---|
| 1 | **Ajustar la dificultad según el valor publicitario o comercial del jugador** | **No demostrado.** No hay ninguna evidencia técnica. King sí ajusta los niveles *globalmente* teniendo en cuenta la conversión (caso del nivel 65) | **Probable en al menos algunas variantes de experimento.** Hay código mostrado que condiciona una mano imposible al eCPM del anuncio cargado | CC: B (GDC) · BB: D + C (verificación de fotogramas) |
| 2 | **Modificar la probabilidad de superar un nivel** | **Sí, pero para todos por igual:** reajuste continuo de niveles con datos agregados ("poda" de los 100 peores). No hay evidencia de ajuste individual | **Sí, por jugador:** distintos algoritmos de reparto y modelos de aprendizaje automático eligen la dificultad, tanto para facilitar (racha de derrotas, riesgo de abandono) como para endurecer (rapidez, récord) | CC: B · BB: D |
| 3 | **Provocar situaciones en las que te quedas a punto de conseguirlo** | Los "casi aciertos" surgen de forma natural en un diseño con movimientos limitados, y el juego ofrece "+5 movimientos" justo al fallar [A, observable]. **Está probado que los casi aciertos aumentan las ganas de seguir jugando** (Larche et al. 2017). **No** hay pruebas de que se fabriquen artificialmente para cada jugador | La mano letal aparece **justo después de batir el récord** y se ofrece resucitar viendo un anuncio. Es una situación de "casi" provocada | CC: A/C · BB: D |
| 4 | **Adaptar la dificultad según el historial de compras** | **No demostrado** | **No demostrado** para compras, porque Block Blast apenas vende nada. Sí usa el **historial de anuncios** (ver punto 1) | Solo la patente de EA lo menciona como posibilidad [A, otra empresa] |
| 5 | **Sistemas de recompensa variable** | **Sí:** ruleta diaria de potenciadores, cofres de eventos, combinaciones especiales con resultado incierto | **Sí:** combos y limpiezas múltiples con recompensa variable. Según el análisis, bonificación aleatoria de hasta el 10 % del récord | A (observable) |
| 6 | **Incentivar anuncios mediante escasez** | **Sí, moderado:** vidas limitadas (5, con recarga por tiempo) y anuncios recompensados opcionales a cambio de potenciadores. Si no ves el anuncio, no hay penalización | **Sí, intenso:** la resurrección por anuncio es el momento clave de la monetización y además hay intersticiales entre partidas | A (observable) + B |
| 7 | **Patrones de progresión que fomentan sesiones recurrentes** | **Sí:** recarga de vidas, eventos semanales y temporales, rachas y pases de temporada | **Sí, más sencillos:** batir el récord, modo aventura, y un regalo para quien el modelo prevé que mañana jugará poco | A + D |

**Conclusión de la verificación:** la expresión "Candy Crush está trucado" mezcla dos cosas distintas.
1. **Diseño de niveles optimizado con datos agregados**, igual para todos y documentado por King. Es una práctica estándar y legítima.
2. **Manipulación individual oculta según tu valor económico.** No hay evidencia para Candy Crush. Para Block Blast hay evidencia técnica seria, aunque todavía sin replicar.

---

## 5. Análisis psicológico y de comportamiento

### 5.1 Mecanismos y solidez de su base científica

| Mecanismo | Cómo aparece en CC | Cómo aparece en BB | Solidez científica |
|---|---|---|---|
| **Efecto de casi conseguirlo (near-miss)** | Quedarse a 1–2 objetivos de superar el nivel con "+5 movimientos" disponibles | Romper el récord y recibir justo después una mano imposible | **Alta y específica.** Larche, Musielak y Dixon (2017) midieron a 60 jugadores de Candy Crush: los casi aciertos producen **más frustración, más activación fisiológica y las mayores ganas de seguir jugando** de todos los resultados. [PMC5445157](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5445157/) |
| **Flow (equilibrio entre reto y habilidad)** | Curva de dificultad en dientes de sierra: nivel difícil seguido de niveles de "descanso" | Partidas fluidas hasta acercarse al récord | **Alta** (Csikszentmihalyi; Larche y Dixon 2020 lo relacionan con las ganas de seguir en juegos móviles) |
| **Competencia y dominio (Self-Determination Theory)** | Aprender combinaciones especiales y nuevos obstáculos cada ~15 niveles | Dominar la gestión del espacio en el tablero | **Alta** (Ryan, Rigby y Przybylski 2006: la competencia y la autonomía predicen el disfrute y las ganas de volver a jugar) |
| **Gradiente de meta y progreso visible** | Mapa de la saga, estrellas, episodios | Récord personal siempre visible | **Media-alta** (Kivetz et al. 2006: el esfuerzo aumenta al acercarse a la meta) |
| **Refuerzo variable** | Caída aleatoria de caramelos, cascadas, ruleta diaria | Combos, piezas aleatorias | **Alta en laboratorio** (Skinner). En videojuegos la relación con el juego problemático está **demostrada para las cajas de botín pagadas** (Zendle y Cairns 2018), **no** para la aleatoriedad del juego en sí |
| **Satisfacción visual y sonora ("juiciness")** | Explosiones, voces ("Sweet!", "Divine!"), cascadas | Destellos al limpiar líneas, vibración, combos | **Media.** Hay estudios que muestran que mejora la experiencia percibida, con resultados mixtos según el tipo de jugador |
| **Aversión a la pérdida** | Perder una vida y "perder" el progreso del nivel al salir; ofertas al fallar | Perder el récord en curso si no se resucita | **Media.** El efecto clásico (Kahneman y Tversky) está aceptado, pero su magnitud se discute (Gal y Rucker 2018) |
| **Curiosidad** | Episodio nuevo, mecánica nueva, nuevo mundo | Nuevos temas del modo aventura | **Media** |
| **Coleccionismo** | Álbumes y coleccionables en eventos recientes | Prácticamente inexistente | **Media** (apoyado sobre todo por la experiencia de la industria) |
| **Comparación social y competición** | Ver amigos en el mapa (era Facebook), torneos y eventos por equipos | Mínima (el récord personal es la comparación principal) | **Media-alta** (Festinger). En móvil funciona mejor la competición asíncrona y suave |
| **Retos diarios y eventos limitados** | Muy intensivos (live ops; el evento "All Stars" llevó al juego a ingresos casi récord) | Modo diario y aventura | **Alta como formación de hábitos** (Lally et al. 2010: el hábito se forma por repetición en un contexto estable) |
| **Personalización** | Limitada (avatar) | Temas | **Baja-media** como motor de retención en puzles |

### 5.2 Qué tiene base sólida y qué es interpretación comercial

- **Base sólida:** flow, competencia y dominio, efecto de casi conseguirlo (con evidencia específica en Candy Crush), formación de hábitos por repetición en contexto estable, y gradiente de meta.
- **Interpretación comercial exagerada:**
  - "La dopamina engancha": simplificación de la neurociencia del aprendizaje por recompensa.
  - "El efecto Zeigarnik obliga a volver": las réplicas de ese efecto son débiles.
  - "Los colores brillantes generan adicción": no tiene respaldo experimental serio.
- **La línea roja ética que aparece en el análisis:** usar los mismos mecanismos (casi conseguirlo, aversión a la pérdida) **dirigidos de forma individual y oculta para maximizar el valor de un anuncio** convierte una buena práctica de diseño en manipulación. En la UE esto puede chocar con la normativa de consumo: la Directiva 2005/29/CE sobre prácticas desleales y los *Key principles on in-game virtual currencies* que la Comisión y la red CPC publicaron en 2024. **Este riesgo regulatorio es real y va en aumento.**

### 5.3 Por qué funcionan (mi síntesis)

- **Candy Crush:** una mecánica que se entiende en 3 segundos, una **novedad constante** (una mecánica nueva cada pocos episodios y miles de niveles), **picos de dificultad que crean tensión** y una **economía de "esperar o pagar"** que convierte esa tensión en ingresos. Detrás hay un aparato de análisis de datos maduro y prudente: "la retención siempre gana".
- **Block Blast:** **cero fricción** (sin tutorial, sin vidas, sin esperas), **partidas que se encadenan sin pausa**, una **meta única y personal** (el récord) y una **satisfacción táctil** muy alta al limpiar líneas. Encima se monta un sistema de aprendizaje automático que optimiza el **momento** de cada anuncio. La retención publicada es excelente: D1 51 %, D7 32 % y D30 21 % (Sensor Tower vía Gamigion, ~ene. 2025) [C].

---

## 6. Modelo de negocio

### 6.1 Candy Crush Saga

| Palanca | Detalle |
|---|---|
| **Compras integradas (motor principal)** | **Lingotes de oro** como moneda premium, con precios distintos por país y descuentos por volumen. Se gastan en **movimientos extra** (+5 por ~10 lingotes en el momento de fallar), **vidas** y **potenciadores** |
| **Vidas** | 5 vidas que se recargan con el tiempo: la clásica economía de "esperar o pagar" |
| **Anuncios recompensados** | King quitó todos los anuncios en 2013 y **volvió a introducir los recompensados en 2018**. Son opcionales y dan potenciadores. Más del 90 % de los anuncios empezados se ven hasta el final, según King [B]. No he encontrado evidencia de intersticiales obligatorios |
| **Pases** | En Soda Saga hay pases de temporada de 7, 14 o 21 etapas por 4,99–12,99 $ (Gamigion 2024) [C]. Se mencionan un "Spooky Season Pass" y un posible "Candy Crush Pass" por suscripción, **sin precio verificado** |
| **Ofertas personalizadas** | Habituales en el sector. **No he encontrado documentación primaria** de cómo King las segmenta |
| **Eventos (live ops)** | Torneos, competiciones por equipos y temporadas temáticas. El evento "All Stars" se asocia a ingresos casi récord |
| **Dato clave** | King prefiere de forma explícita la retención a largo plazo frente a la conversión inmediata (GDC 2024) [B] |

### 6.2 Block Blast!

| Palanca | Detalle |
|---|---|
| **Publicidad (prácticamente el 100 %)** | **Intersticiales entre partidas** y **un único punto de anuncio recompensado (resucitar)** (Gamigion) [C]. Mediación con **AppLovin MAX**, con AdMob entre las redes que pujan (Ayoships) [D] |
| **Optimización** | Modelos que predicen el eCPM de cada jugador y deciden cuándo mostrar intersticiales y recompensados (`FullScreenAdAddByEcpmTrait`, `IsOpenEcpmTooLowNoInterTrait`) [D]. Una de las **listas de anunciantes bloqueados más grandes** del sector, según gestores de redes publicitarias [C, fuente anónima] |
| **Compras integradas** | Prácticamente nulas. Según terceros, **no hay compra para quitar anuncios** en la versión gratuita [C, por verificar en la tienda] |
| **Crecimiento** | Mucha adquisición pagada (admitido por la empresa), con picos estimados de 30–40 M de instalaciones compradas al mes [E/C, fuente secundaria] |
| **Escala** | Black Friday 2025: ~55 M DAU y ~1,8 M$ de ingresos publicitarios en un solo día (estimación de un consultor, no de un rastreador) [C, estimación] |

### 6.3 Tabla comparativa final

| Dimensión | Candy Crush Saga | Block Blast! |
|---|---|---|
| Estructura | Niveles diseñados, saga lineal | Sin fin, con récord, más modo aventura |
| Sesión típica | Unos pocos niveles, limitados por las vidas | Partidas encadenadas sin límite |
| Fricción de entrada | Baja | **Mínima** |
| Profundidad a largo plazo | **Muy alta** (miles de niveles, decenas de mecánicas) | Baja-media (la misma mecánica siempre) |
| Producción de contenido | Muy costosa (equipo de niveles, ahora con IA) | **Mínima** (procedural) |
| Monetización principal | Compras integradas (lingotes, movimientos, vidas, pases) | Anuncios (intersticiales y recompensados) |
| Ingresos anuales aprox. | ~0,9–1,1 mil M$ en compras (2024–2025) | ~300 M$+ en anuncios al año (extrapolación de 127 M$ en 5 meses; **hipótesis mía**) |
| Ingresos por usuario | Alto por pagador, bajo por usuario | Muy bajo por usuario, compensado con una escala enorme |
| Dependencia de la adquisición pagada | Media (marca consolidada) | **Alta** (admitido) |
| Retención | Larga cola de años | D1 51 % / D7 32 % / D30 21 % (ene. 2025) |
| Dificultad | Ajuste global por nivel con datos agregados | Ajuste individual con aprendizaje automático, incluido condicionado al eCPM [D] |
| Pruebas A/B | Maduras y prudentes ("prepárate para pruebas largas") | Masivas (más de 10.000 al año) |
| Riesgo de reputación o regulación | Medio (presión clásica de "esperar o pagar") | **Alto** si se confirma la mano letal ligada al eCPM |
| Replicable con 0 € de marketing | Parcialmente: el núcleo de diseño sí, el volumen de contenido requiere un sistema procedural | **No**: el modelo exige escala comprada |

---

## 7. Decisiones tomadas en esta fase

1. **Se descarta replicar el modelo económico de Block Blast** (anuncios a gran escala financiados con adquisición pagada) porque es incompatible con el presupuesto de 0 €.
2. **Principio ético y comercial que propongo fijar ya en el documento maestro:** la dificultad **nunca** dependerá del valor publicitario, del eCPM, del historial de compras ni de ningún dato económico del jugador. La aleatoriedad será **honesta**: toda mano o tablero inicial tendrá solución. El ajuste se hará **por nivel y para todos**, con datos agregados, como hace King y como pediste.
3. **Lo que sí merece estudiarse en la Fase 2** a partir de esta investigación:
   - La **fricción mínima** de Block Blast: sin tutorial y con partidas encadenadas.
   - La **disciplina de King con los niveles**: medir el tiempo hasta abandonar y hasta superar, eliminar los niveles malos y hacer cortos los difíciles.
   - **Ayudas dirigidas a la retención** que no penalizan nunca: por ejemplo, una ayuda tras varias derrotas seguidas, como hace también Block Blast.

---

## 8. Riesgos detectados

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Las conclusiones sobre Block Blast se apoyan en un solo análisis principal de hace un mes | Medio | Reflejarlo como D. Vigilar réplicas y la respuesta de Hungry Studio. Protocolo de la sección 9 |
| Las cifras de ingresos y usuarios proceden de estimaciones de rastreadores, que discrepan entre sí (Sensor Tower da ingresos brutos y AppMagic netos) | Medio | Dar siempre rangos y fuente |
| Falta documentación primaria de King sobre la generación de caramelos y la segmentación de ofertas | Bajo para nuestro objetivo | No hace falta para diseñar; no lo trato como hecho |
| Regulación de la UE más estricta sobre monedas virtuales y personalización comercial | **Alto para nuestro producto** | Diseñar con transparencia desde el principio (Fase 5) |
| Saturación de puzles casuales en el mercado | Alto | Lo analizará la Fase 2 (50 juegos) |

---

## 9. Pendiente y propuesta de experimento opcional (coste 0 €)

**Pendiente de esta fase:**
- Precio actual y existencia del "Candy Crush Pass": comprobarlo en la tienda española desde un dispositivo.
- Confirmar si Block Blast vende la eliminación de anuncios en España.
- Fecha exacta de lanzamiento de Block Blast (las fuentes discrepan).

**Experimento reproducible opcional:** *¿la mano letal depende de tener conexión?* Es una prueba legal, que no requiere descompilar nada y que puedes hacer con tu propio móvil.
1. Juega 30 partidas con conexión y 30 en modo avión, todas en el modo clásico.
2. Anota en cada una: récord previo, puntuación final, si la derrota llegó justo tras superar el récord y si la última mano tenía alguna colocación posible (haz una captura).
3. **Hipótesis:** si la regla ligada al eCPM existe y está activa en tu variante, las derrotas con mano imposible justo tras el récord serán **significativamente más frecuentes con conexión**.
4. **Limitación:** tu cuenta puede estar en una variante sin la regla, así que un resultado negativo no lo descarta.

Puedo preparar la hoja de registro y el análisis estadístico (prueba exacta de Fisher) si quieres hacerlo.

---

## 10. Próximos pasos (sujetos a tu aprobación)

**Fase 2:** análisis de los 50 juegos móviles más populares de Apple, con España y EE. UU. como referencia, fecha de corte fija y metodología consistente. Antes de empezar te propondré:
- la composición de la muestra (por descargas, por ingresos y por modelo de monetización);
- las fuentes gratuitas que usaré para cada dato;
- la plantilla de ficha individual.

---

## 11. Fuentes principales (con fecha)

**Primarias o técnicas (A):**
- Gudmundsson et al., *Human-Like Playtesting with Deep Learning*, IEEE CIG 2018 — [DOI](https://api.crossref.org/works/10.1109%2FCIG.2018.8490442)
- Xue et al., *Dynamic Difficulty Adjustment for Maximized Engagement in Digital Games*, WWW 2017 (EA) — [PDF](https://archives.iw3c2.org/www2017/proceedings/companion/p465.pdf)
- Chen et al., *EOMM: An Engagement Optimized Matchmaking Framework*, WWW 2017 (EA) — [arXiv](https://arxiv.org/pdf/1702.06820)
- Patente US10363487B2 (Zynga, 2019) — [Google Patents](https://patents.google.com/patent/US10363487B2/en)
- Patente US10561944B2 (Zynga, 2020) — [Google Patents](https://patents.google.com/patent/US10561944B2/en)
- Patente US9919217B2 (Electronic Arts, 2018) — [Google Patents](https://patents.google.com/patent/US9919217B2/en)
- Patentes de King US9776093 y US10086296 — [USPTO 9776093](https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/9776093) · [USPTO 10086296](https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/10086296)

**Investigación independiente (C):**
- Larche, Musielak y Dixon (2017), *The Candy Crush Sweet Tooth*, J. Gambling Studies 33(2) — [PMC](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5445157/)
- Columbia Business School, *Easier games, more revenue* — [enlace](https://business.columbia.edu/research-brief/digital-future/easier-games-more-revenue)
- Acid Alchamy, verificación del análisis de Block Blast (14/10/2026) — [enlace](https://acidalchamy.com/blog/block-blast-ad-harvest-fact-check)
- mobilegamer.biz, despidos en King e IA (jul. 2025) — [enlace](https://mobilegamer.biz/laid-off-king-staff-set-to-be-replaced-by-the-ai-tools-they-helped-build/)
- Gamigion (Felix Braberg), Block Blast y anuncios (ene. 2025 y ene. 2026) — [1](https://www.gamigion.com/block-blast-the-largest-iaa-revenue-game-in-the-world/) · [2](https://www.gamigion.com/the-biggest-ad-monetized-game-on-black-friday-2025/)
- Inc./The Star, *Is Block Blast rigged?* (28/10/2026) — [enlace](https://www.thestar.com.my/tech/tech-news/2026/10/28/is-block-blast-rigged-a-developer-decompiled-the-viral-game-to-find-out)
- Digiday, monetización de Candy Crush — [enlace](https://digiday.com/marketing/how-the-designers-of-candy-crush-maintain-the-balance-between-monetization-and-fun)
- Business of Apps, estadísticas de Candy Crush — [enlace](https://businessofapps.com/data/candy-crush-statistics) · Levvvel — [enlace](https://levvvel.com/candy-crush-saga-statistics/)

**Declaraciones de las empresas (B):**
- King en GDC 2024 vía mobilegamer.biz (27/03/2024) — [enlace](https://mobilegamer.biz/how-king-defines-a-good-candy-crush-saga-level-and-why-it-constantly-prunes-the-bad-ones/)
- King, franquicia de 20.000 M$ (27/09/2023) — [Game World Observer](https://gameworldobserver.com/2023/09/27/candy-crush-saga-revenue-20-billion-king)
- Hungry Studio, nota de prensa de 70 M DAU (08/01/2026) — [BusinessWire](https://www.businesswire.com/news/home/20260108572322/en/Block-Blast-Scales-to-70M-DAU-as-Hungry-Studio-Runs-Over-10000-Experiments-in-a-Single-Year)
- Hungry Studio, entrevista sobre pruebas A/B (14/01/2025) — [mobilegamer.biz](https://mobilegamer.biz/block-blast-maker-hungry-studio-a-b-tested-its-way-to-the-top-of-the-charts/)
- mobilegamer.biz, *data digest* (14/01/2026) — [enlace](https://mobilegamer.biz/data-digest-2025s-top-earning-genres-appsflyer-for-sale-block-blast-hits-70m-dau-app-store-earnings-more/)

**Análisis de terceros (D):**
- Ayo Omolewa (Ayoships), *How Block Blast harvests its players for ad money* (15/10/2026) — [enlace](https://ayoships.com/breakdowns/block-blast)
- mobilegamer.biz sobre Ayoships, incluido lo que afirma sobre Candy Crush (27/10/2026) — [enlace](https://mobilegamer.biz/this-creator-says-he-decompiled-block-blast-candy-crush-and-subway-surfers-to-reveal-their-monetisation-secrets/)

**Comunidad (E):**
- Foro oficial de King sobre cambios de dificultad — [enlace](https://community.king.com/en/candy-crush-saga/discussion/426167/level-difficulty-changing)

> Nota sobre las fuentes psicológicas citadas sin enlace (Ryan et al. 2006, Kivetz et al. 2006, Zendle y Cairns 2018, Lally et al. 2010, Gal y Rucker 2018): son referencias académicas conocidas que cito de memoria. Las verificaré con enlace en la Fase 3, que trata específicamente esta biblioteca de mecanismos.
