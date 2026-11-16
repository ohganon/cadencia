# FASE 3 — Biblioteca de mecanismos: psicología, retención y monetización

**Fecha:** 16/11/2026
**Estado:** entregado, **pendiente de aprobación**
**Coste:** 0 €

**Base:**
- Fase 1 (Candy Crush y Block Blast) y Fase 2 (50 juegos);
- literatura científica con enlace;
- [marco legal](../legal/MARCO_CUMPLIMIENTO_LEGAL.md).

---

## 0. Resumen ejecutivo

1. **Los mecanismos con mejor base científica** son también los **más éticos y los más compatibles con la ley**:
   - **competencia y dominio**;
   - **autonomía**;
   - **flow** (equilibrio entre reto y habilidad);
   - **progreso visible** (efecto gradiente de meta);
   - **hábito por repetición en un contexto estable**.

   Son el núcleo de los juegos mejor valorados de la Fase 2 (Clash Royale, Balatro, NYT Games, Chess.com).

2. **Los mecanismos con base sólida pero un gran potencial de abuso** deben usarse **solo en su versión gratuita y transparente**:
   - recompensa variable;
   - aversión a la pérdida;
   - efecto de "casi conseguirlo".

   Su versión de pago o su versión punitiva es justo lo que la DFA y la literatura sobre cajas de botín señalan como problemático.

3. **Varios "mecanismos" populares tienen una base más débil de lo que se dice:**
   - la aversión a la pérdida como ley universal;
   - el efecto Zeigarnik;
   - "la dopamina engancha";
   - las insignias y clasificaciones como motivadores garantizados.

   Algunos estudios muestran incluso que **las recompensas extrínsecas mal planteadas reducen la motivación intrínseca**.

4. **Resultado práctico de esta fase:**
   - una **clasificación en verde, ámbar y rojo** de cada mecanismo (sección 2);
   - un **modelo de motivación en tres bucles** que la Fase 4 debe respetar: partida, día y largo plazo (sección 4);
   - **6 nuevos principios de diseño** (sección 5);
   - **métricas de bienestar** para la Fase 9 (sección 6).

---

## 1. Cómo leer esta biblioteca

**Nivel de evidencia científica:**

| Nivel | Significado |
|---|---|
| **Sólida** | Teoría consolidada, varios estudios o metaanálisis, y aplicación demostrada en videojuegos |
| **Moderada** | Estudios sólidos pero en otros contextos (consumo, educación), o pocos estudios en juegos |
| **Débil o controvertida** | Pocos datos, problemas de replicación o un efecto mucho menor del que se le atribuye |

**Semáforo de uso en nuestro proyecto:**

| Color | Significado |
|---|---|
| 🟢 **Verde** | Usar libremente |
| 🟡 **Ámbar** | Usar solo en la versión indicada, con salvaguardas |
| 🔴 **Rojo** | Prohibido. Corresponde a las líneas rojas LR-xx del marco legal |

**Referencias:** las que llevan enlace están verificadas en esta fase. Las marcadas **(ref. clásica)** son obras de referencia ampliamente citadas que no he enlazado.

---

## 2. Fichas de mecanismos

### 2.1 Teoría de la autodeterminación (Self-Determination Theory, SDT)

**1. En qué consiste**
- La motivación de mayor calidad (la intrínseca) aparece cuando se satisfacen tres necesidades psicológicas:
  - **competencia**: sentir que mejoras y dominas;
  - **autonomía**: sentir que eliges;
  - **relación**: sentirte conectado con otros.

**2. Evidencia científica: sólida**
- Ryan, Rigby y Przybylski (2006, *Motivation and Emotion* 30(4)). En 4 estudios, la autonomía y la competencia percibidas en el juego **predicen el disfrute, la preferencia y los cambios en el bienestar** tras jugar. En juegos online, la relación también predice el disfrute y la intención de seguir jugando. [DOI 10.1007/s11031-006-9051-8](https://doi.org/10.1007/s11031-006-9051-8)
- Przybylski, Rigby y Ryan (2010), *A Motivational Model of Video Game Engagement*, *Review of General Psychology* 14(2). [DOI 10.1037/a0019440](https://repository.essex.ac.uk/7228/)

**3. Aplicación a videojuegos**
- **Competencia:** retroalimentación clara y dificultad ajustada.
- **Autonomía:** elegir cómo resolver, qué personalizar, qué camino seguir.
- **Relación:** equipos y compartir.

**4. Ejemplos**
- Clash Royale: competencia (dominar el mazo) + autonomía (construirlo) + relación (clanes).
- Balatro: autonomía extrema en el diseño de la jugada.
- Chess.com.

**5. Cómo incorporarlo**
- **Varias soluciones válidas por nivel** (autonomía).
- **Mejora visible de la habilidad del jugador** (competencia).
- **Lo social ligero y asíncrono** (relación).
- **Es el marco de referencia general de todo el diseño.**

**6. Riesgo si se abusa:** es bajo. El abuso típico es **una autonomía falsa** (decisiones que no importan) y **una relación forzada** (presión del equipo para jugar o pagar).

**Semáforo:** 🟢

---

### 2.2 Flow (equilibrio entre reto y habilidad)

**1. En qué consiste**
- Un estado de concentración total y disfrute que aparece cuando **el reto está ajustado a la habilidad** y hay objetivos claros y retroalimentación inmediata. Es de Csikszentmihalyi (ref. clásica, 1990).

**2. Evidencia científica: sólida**
- Sweetser y Wyeth (2005), *GameFlow*, ACM Computers in Entertainment: un modelo de 8 elementos para el disfrute en los juegos. [PDF](https://ntnu.no/wiki/download/attachments/112986425/GameFlow.pdf?api=v2)
- **Larche y Dixon (2020), *Journal of Behavioral Addictions* 9(3):606–616**, con 60 jugadores de **Candy Crush**:
  - el equilibrio percibido es mayor cuando el nivel se ajusta a su habilidad;
  - **un flow más profundo aumenta las ganas de seguir jugando**.
  - [PMC8943660](https://pmc.ncbi.nlm.nih.gov/articles/PMC8943660)

**3. Aplicación a videojuegos**
- Una curva de dificultad en **"dientes de sierra"**: tensión, alivio, tensión.
- **Objetivos de nivel claros.**
- Una retroalimentación instantánea.

**4. Ejemplos**
- Curva de Candy Crush y Royal Match.
- Clash Royale (emparejamiento por nivel).
- Pixel Flow: dificultad de tipo "presta atención".

**5. Cómo incorporarlo**
- Dificultad **por nivel, con datos agregados** (principio P-03): ajustar el reto a la **habilidad media del tramo**, no al valor económico de cada jugador.
- **Varias rutas de dificultad**: un camino principal accesible más retos opcionales difíciles.

**6. Riesgo si se abusa**
- El mismo estudio de Larche y Dixon advierte de que el flow **también alimenta el juego excesivo**.
- Ajustar la dificultad por jugador para **retener a cualquier precio** (como EA en la Fase 1) o **para monetizar** (como Block Blast) es manipulación.

**Semáforo:** 🟢 en la versión "por nivel y para todos" · 🔴 si depende de datos económicos (LR-01)

---

### 2.3 Efecto gradiente de meta (Goal Gradient)

**1. En qué consiste**
- **El esfuerzo aumenta a medida que la meta se acerca.** Hull lo formuló en 1932 (ref. clásica).

**2. Evidencia científica: sólida en consumo y moderada en juegos**
- Kivetz, Urminsky y Zheng (2006), *Journal of Marketing Research* 43(1):39–58:
  - con tarjetas de fidelidad de cafetería, **la frecuencia de compra se acelera al acercarse a la recompensa**;
  - además, los usuarios **disfrutan de más interacciones** con el programa.
  - [Columbia Business School](https://business.columbia.edu/faculty/research/goal-gradient-hypothesis-resurrected-purchase-acceleration-illusionary-goal) · [PDF](https://business.columbia.edu/sites/default/files-efs/pubfiles/1200/goalgradient.pdf)

**3. Aplicación a videojuegos**
- Barras de progreso, "3 niveles para el siguiente cofre", decoraciones casi terminadas.

**4. Ejemplos**
- Las estrellas y la reforma de Royal Match.
- El pase de temporada (20 de 50 juegos en la Fase 2).
- La imagen pixelada que se va completando en Pixel Flow.

**5. Cómo incorporarlo**
- **Objetivos intermedios cortos y visibles** (capítulos de 10–15 niveles con una recompensa clara al final).
- Mostrar **cuánto falta**.

**6. Riesgo si se abusa**
- Usar el gradiente para **empujar a pagar justo al final** ("¡te falta 1 pieza, cómprala!").
- Hacer metas que **se alejan** a medida que te acercas.

**Semáforo:** 🟢 · 🟡 si la meta final se puede acelerar pagando (solo con valor en euros visible y sin presión, según el Anexo I de la DFA)

---

### 2.4 Efecto del progreso regalado (Endowed Progress)

**1. En qué consiste**
- **Dar un avance inicial** hacia una meta aumenta la probabilidad de completarla.

**2. Evidencia científica: moderada a sólida**
- Nunes y Drèze (2006), *Journal of Consumer Research* 32(4):504–512. En un túnel de lavado, una tarjeta de **10 sellos con 2 ya marcados** se completó más (34 %) que una de **8 sellos sin marcar** (19 %), aunque ambas requerían 8 compras.
- Kivetz et al. (2006) replican el efecto ("progreso ilusorio"). [Columbia](https://business.columbia.edu/insights/chazen-global-insights/goal-gradient-hypothesis-resurrected-purchase-acceleration)
- Nunes y Drèze se citan como **ref. clásica**: no he encontrado un enlace verificado en esta fase. **Los porcentajes del 34 % y el 19 % están citados de memoria** y deben comprobarse con el artículo original.

**3. Aplicación a videojuegos**
- Un primer nivel del pase ya completado, colecciones que empiezan con algunas piezas, una "racha" que empieza en 1 al instalar.

**4. Ejemplos**
- Paquetes de bienvenida y "Starter Pack" (en muchos juegos de la Fase 2).
- Tutoriales que dejan el primer capítulo casi completo.

**5. Cómo incorporarlo**
- **Regalar el primer paso de cada sistema** (colección, capítulo, pase gratuito) para reducir el abandono inicial.

**6. Riesgo si se abusa:** que el progreso regalado sea **un cebo para una compra** ("ya tienes el 80 %, termina por 4,99 €").

**Semáforo:** 🟢 · 🟡 si va asociado a una oferta de pago

---

### 2.5 Recompensas variables (Variable Reward Schedules)

**1. En qué consiste**
- Las recompensas impredecibles, en frecuencia o en cuantía, generan **una respuesta más persistente** que las fijas. Es el programa de refuerzo de razón variable de Ferster y Skinner (ref. clásica, 1957).

**2. Evidencia científica: sólida en laboratorio; en juegos, el riesgo está demostrado sobre todo cuando hay dinero de por medio**
- **Zendle y Cairns (2018), *PLOS ONE*** (n = 7.422): **el gasto en cajas de botín se asocia a la gravedad del juego problemático**. Se replicó en 2019.
  - [DOI 10.1371/journal.pone.0206767](https://eprints.whiterose.ac.uk/139116/1/journal.pone.0206767.pdf)
  - [Nota de prensa de la Universidad de York](https://york.ac.uk/news-and-events/news/2018/research/researchers-find-link-problem-gambling-loot-boxes)
- **No he encontrado evidencia de daño** por la aleatoriedad **gratuita e intrínseca** al juego (cascadas, combos, piezas aleatorias).

**3. Aplicación a videojuegos**
- **Intrínseca:** cascadas, combos y sorpresas jugando.
- **Extrínseca de pago:** cajas de botín, giros, sobres.

**4. Ejemplos**
- Cascadas de Candy Crush y combos de Block Blast (aleatoriedad gratuita).
- Coin Master, sobres de Pokémon TCG Pocket y "rasca y gana" de 8 Ball Pool (aleatoriedad de pago).

**5. Cómo incorporarlo**
- **Solo aleatoriedad gratuita y honesta:**
  - sorpresas jugando (combos o eventos especiales en la partida);
  - recompensas variables que se ganan, nunca que se compran;
  - probabilidades publicadas si hay cofres gratuitos.

**6. Riesgo si se abusa:** **el mayor de toda la biblioteca.** Es la base de las demandas contra Coin Master y del art. 15 de la DFA.

**Semáforo:** 🟢 si es gratuita e intrínseca · 🔴 si es de pago (LR-03)

---

### 2.6 Competencia y dominio (Competence and Mastery)

**1. En qué consiste**
- Es la necesidad de competencia de la SDT aplicada al largo plazo: **sentir que vas dominando un sistema con profundidad**.

**2. Evidencia científica: sólida** (ver SDT). Es el predictor más consistente del disfrute en los estudios de Ryan et al. (2006).

**3. Aplicación a videojuegos**
- **Una profundidad oculta que se descubre jugando**, tipo "fácil de aprender, difícil de dominar".

**4. Ejemplos**
- El *slinging* (encadenar acciones) de Pixel Flow.
- Las sinergias de Balatro.
- El rating de Chess.com.
- Los niveles "demon" de Geometry Dash.

**5. Cómo incorporarlo**
- Introducir **técnicas avanzadas** de forma gradual.
- Hacer **visible la mejora** del jugador ("hoy has resuelto este nivel en 4 movimientos menos").
- Un **modo de maestría opcional**: retos de eficiencia o "resolver con X movimientos".

**6. Riesgo si se abusa:** que el "dominio" se pueda **comprar** (pagar para ganar), lo que destruye la competencia percibida.

**Semáforo:** 🟢 · 🔴 si se puede comprar (LR-05)

---

### 2.7 Aversión a la pérdida (Loss Aversion)

**1. En qué consiste**
- "Las pérdidas pesan más que las ganancias equivalentes". Es de Kahneman y Tversky (ref. clásica, *Econometrica* 1979).

**2. Evidencia científica: controvertida**
- **Gal y Rucker (2018), *Journal of Consumer Psychology* 28(3):497–516**: sostienen que la aversión a la pérdida está **sobregeneralizada** y que la evidencia solo respalda una versión **condicional**.
- Otros autores responden que el efecto tiene moderadores, pero no ha desaparecido.
- [DOI 10.1002/jcpy.1047](https://papers.ssrn.com/abstract=3049660) · [Scientific American](https://www.scientificamerican.com/blog/observations/why-the-most-important-idea-in-behavioral-decision-making-is-a-fallacy/)

**3. Aplicación a videojuegos**
- **Rachas** que se pierden, progreso del nivel que se pierde al salir, ofertas "te vas a perder…".

**4. Ejemplos**
- Las rachas de Duolingo: la propia empresa atribuye su eficacia a la aversión a la pérdida, aunque **sus cifras no están revisadas por pares**. [Blog de Duolingo](https://blog.duolingo.com/how-duolingo-streak-builds-habit)
- La oferta de resurrección en Block Blast.

**5. Cómo incorporarlo** (nuestra versión)
- **Rachas que suman pero nunca restan**: perder la racha no quita nada de lo conseguido. Hay comodines gratis y se pueden desactivar.
- **Protección del progreso**: salir de una partida no castiga.

**6. Riesgo si se abusa**
- Es la técnica clave de los **diseños compulsivos**.
- Es justo lo que señala la **DFA en su art. 17**: incentivar el juego a intervalos fijos **"con penalizaciones o pérdida de beneficios"**.

**Semáforo:** 🟡 solo en versión no punitiva · 🔴 en versión punitiva (LR-09)

---

### 2.8 Mecánicas de colección (Collection Mechanics)

**1. En qué consiste**
- La motivación para **completar un conjunto**. Combina el gradiente de meta, la competencia (completar) y la identidad o el estatus (mostrar).

**2. Evidencia científica: moderada**
- La literatura sobre el coleccionismo en psicología social (por ejemplo, McIntosh y Schmeichel, 2004, *Leisure Sciences*, **ref. pendiente de verificar con enlace**) describe la búsqueda, la adquisición y la exhibición como fuentes de satisfacción.
- **En juegos, la evidencia es sobre todo de la industria:** el gran rendimiento de los álbumes de MONOPOLY GO!, la Pokédex o los álbumes de Royal Match.

**3. Aplicación a videojuegos**
- Álbumes, colecciones de personajes y objetos, con intercambio social.

**4. Ejemplos**
- Pegatinas de MONOPOLY GO! (con intercambio).
- Pokémon GO.
- Disney Solitaire.
- Personajes de Subway Surfers.

**5. Cómo incorporarlo**
- **Colecciones que se completan jugando**, con un **intercambio gratuito** entre amigos.
- **Protección contra duplicados**: nunca se queda uno atascado en la última pieza.
- Las colecciones de eventos **pueden volver más adelante**.

**6. Riesgo si se abusa**
- **La "última pieza" imposible** que obliga a pagar.
- **Colecciones con piezas aleatorias de pago**, que funcionan como cajas de botín.
- **Escasez falsa** ("solo este fin de semana").

**Semáforo:** 🟢 si se completa jugando · 🔴 si las piezas son aleatorias y de pago (LR-03) o la escasez es falsa (LR-06)

---

### 2.9 Comparación social (Social Comparison)

**1. En qué consiste**
- Las personas evalúan su capacidad **comparándose con otras**. Es de Festinger (ref. clásica, 1954, *Human Relations*).

**2. Evidencia científica: moderada y con efectos mixtos**
- Las clasificaciones **pueden mejorar el rendimiento** (Landers et al., 2017, un experimento con 240 participantes), pero:
  - la **comparación con quien está cerca** de tu posición motiva más que la comparación con la cima;
  - **la clasificación también aumenta la presión percibida.**
- [Revisión](https://pmc.ncbi.nlm.nih.gov/articles/PMC8046219) · [Estudio sobre clasificaciones relativas](https://repository.ceibs.edu:443/files/56737897/Influences-of-Leaderboard-Direction-on-Learning-Performance-and-Satisfaction-in-Gamified-E-Learning.pdf)
- **Hanus y Fox (2015), *Computers & Education* 80:152–161**: en un curso, **las insignias y la clasificación redujeron la motivación intrínseca, la satisfacción y las notas** frente al grupo de control. La muestra fue pequeña (71 estudiantes).

**3. Aplicación a videojuegos**
- Clasificaciones, ligas, comparar resultados con amigos.

**4. Ejemplos**
- La conversación diaria de NYT Games.
- Las ligas de Duolingo.
- El rating de Chess.com.
- El King's Cup de Royal Match (50 jugadores).

**5. Cómo incorporarlo**
- **Clasificaciones pequeñas y relativas** (tu grupo de amigos, tu liga de 30 personas), **semanales**, con **reinicio** que da nuevas oportunidades.
- **Comparar contra uno mismo**: tu mejor marca.
- **Compartir el resultado sin desvelar la solución**, al estilo de Wordle.

**6. Riesgo si se abusa**
- **Ansiedad y frustración** en los jugadores que siempre quedan abajo.
- **Competencias de gasto** (las alianzas de Whiteout Survival).
- Comparar con extraños.

**Semáforo:** 🟢 relativa, pequeña y desactivable · 🔴 si se puede ganar pagando

---

### 2.10 Formación de hábitos (Habit Formation)

**1. En qué consiste**
- Un hábito se forma por **repetición de una conducta en un contexto estable**, hasta que se vuelve automática.

**2. Evidencia científica: sólida**
- **Lally, van Jaarsveld, Potts y Wardle (2010), *European Journal of Social Psychology* 40:998–1009**: la automaticidad crece de forma asintótica. La **mediana fue de 66 días** hasta alcanzarla, con una **gran variación entre personas** (de 18 a 254 días). **Saltarse un día de forma puntual no afectó al proceso.**
  - [DOI 10.1002/ejsp.674](https://core.ac.uk/download/70653523.pdf)
- **Este último hallazgo apoya las rachas sin castigo:** no hace falta penalizar un fallo para formar el hábito.

**3. Aplicación a videojuegos**
- El reto diario, una sesión corta asociada a un momento del día (café, transporte), recordatorios **con permiso**.

**4. Ejemplos**
- NYT Games: un Wordle al día.
- El puzle diario de Chess.com.
- La recarga de vidas de Candy Crush, que es un hábito inducido por la espera.

**5. Cómo incorporarlo**
- **Un reto diario igual para todos** de 2–5 minutos.
- Recordatorio opcional **a la hora que el jugador elija**.
- **Un punto de cierre natural**: "hasta mañana".

**6. Riesgo si se abusa**
- Hábitos inducidos por **la ansiedad** (miedo a perder) en lugar del disfrute.
- Notificaciones invasivas.
- **Sesiones sin final**.

**Semáforo:** 🟢 · 🔴 notificaciones no provocadas por la actividad del jugador (LR-10)

---

### 2.11 Sistemas de progresión (Progression Systems)

**1. En qué consiste**
- Estructuras que hacen **visible el avance a largo plazo**: niveles, mapas, capítulos, rangos, desbloqueos.

**2. Evidencia científica: moderada**
- Hamari, Koivisto y Sarsa (2014, HICSS), revisión de 24 estudios: **la gamificación tiene efectos positivos, pero muy dependientes del contexto y de los usuarios**. [PDF](https://www.lescahiersdelinnovation.com/wp-content/uploads/2019/06/2014-hamari_et_al-does_gamification_work.pdf)
- **Deci, Koestner y Ryan (1999), *Psychological Bulletin* 125(6)**, metaanálisis de 128 estudios: las **recompensas tangibles condicionadas pueden reducir la motivación intrínseca** (efecto de sobrejustificación). [PDF](https://depts.washington.edu/techdocs/papers/deciExtrinsicRewardsAndIntrinsicMotivation99.pdf)
- **Conclusión:** la progresión funciona cuando **refleja un avance real** (habilidad, historia, mundo) y falla cuando es **un número que sube porque sí**.

**3. Aplicación a videojuegos**
- El mapa de niveles, la restauración, la narrativa por capítulos, los rangos de habilidad y los desbloqueos que amplían las posibilidades.

**4. Ejemplos** (Fase 2, sección 6.3)
- Restauración en Royal Match.
- Telenovela en Gossip Harbor.
- Rating en Chess.com.
- Comodines en Balatro.

**5. Cómo incorporarlo**
- **Una progresión de doble capa:**
  1. **avance en el mundo** (meta-juego visible);
  2. **avance en la habilidad** (nuevas mecánicas y técnicas).
- Los desbloqueos **amplían las posibilidades**, no solo suben un número.

**6. Riesgo si se abusa**
- **Una progresión artificialmente lenta para vender aceleradores.** La DFA, en su considerando 65, lo describe como una progresión gratuita "ilusoria".
- **La rutina de "grindear"** (repetir sin sentido).

**Semáforo:** 🟢 · 🔴 si se ralentiza para vender (LR-05)

---

## 3. Mecanismos adicionales detectados en las Fases 1 y 2

| Mecanismo | Evidencia | Semáforo y uso |
|---|---|---|
| **Efecto de "casi conseguirlo" (near-miss)** | **Sólida y específica:** Larche, Musielak y Dixon (2017), J. Gambling Studies, con 60 jugadores de Candy Crush. Los casi aciertos producen **la mayor activación, frustración y ganas de seguir**. [PMC5445157](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5445157/) | 🟡 Que surja **de forma natural** del diseño. 🔴 **Fabricarlo** por jugador o **venderlo** en ese momento sin alternativa gratuita (LR-01, LR-02) |
| **Satisfacción sensorial ("juiciness")** | Moderada: mejora la experiencia percibida. Es la base visual de la nueva ola (Fase 2) | 🟢 Un pilar de la experiencia y del marketing |
| **Curiosidad y narrativa por episodios** | Moderada. Lo respalda la industria (Gossip Harbor, n.º 2 en recaudación en ES). El efecto Zeigarnik ("las tareas incompletas se recuerdan más") tiene **una replicación débil** | 🟢 Sin forzar finales "de cliffhanger" vinculados a pagar |
| **Efecto de sobrejustificación** (riesgo) | Sólida (Deci et al., 1999) | ⚠️ Evitar convertir el juego en "trabajo por recompensas". Primero la diversión intrínseca, después las recompensas extrínsecas |

---

## 4. Modelo de motivación del proyecto: tres bucles

Es un marco que **la Fase 4 debe respetar** al diseñar el concepto. **No es todavía el diseño del juego.**

| Bucle | Duración | Necesidad principal (SDT) | Mecanismos 🟢 | Lo que evitamos 🔴 |
|---|---|---|---|---|
| **Bucle de partida** | 1–3 min | Competencia | Flow por nivel, gesto táctil satisfactorio, recompensa variable **gratuita** (combos), efecto de "casi conseguirlo" **natural**, retroalimentación instantánea | Manos o tableros imposibles, ofertas a pantalla completa al fallar sin alternativa |
| **Bucle diario** | 5–15 min al día | Competencia + relación | **Reto diario igual para todos**, resultado compartible, racha **sin castigo**, objetivos diarios cortos y **punto de cierre** | Notificaciones no solicitadas, rachas punitivas, recompensas por iniciar sesión que se pierden |
| **Bucle a largo plazo** | Semanas o meses | Autonomía + competencia + relación | Progresión de doble capa (mundo + habilidad), colecciones que se ganan jugando, técnicas avanzadas, clasificaciones pequeñas semanales, eventos con fecha real | Progresión ralentizada para vender, colecciones de pago, competiciones de gasto |

**Regla de diseño derivada:** cada sesión debe terminar con **una razón positiva para volver** (curiosidad, un reto nuevo mañana, un objetivo a la vista) y **nunca con miedo a perder algo**.

---

## 5. Nuevos principios de diseño (se añaden al documento maestro)

| ID | Principio | Base |
|---|---|---|
| P-10 | **La diversión intrínseca va antes que las recompensas.** El núcleo debe ser divertido sin ninguna recompensa extrínseca; las recompensas lo acompañan, no lo sustituyen | SDT; Deci et al. (1999) |
| P-11 | **Profundidad descubrible:** cada mecánica tiene una técnica avanzada que el jugador puede dominar | Competencia y dominio; Pixel Flow, Balatro |
| P-12 | **Retención positiva:** nos volverán a jugar por curiosidad, reto o progreso, **nunca por miedo a perder** | Gal y Rucker (2018); DFA art. 17 |
| P-13 | **Punto de cierre natural:** el juego ofrece momentos claros para parar (fin del reto diario, fin de capítulo) | Bienestar; Lally et al. (2010) |
| P-14 | **Aleatoriedad gratuita y honesta:** solo en el juego y siempre con solución | Zendle y Cairns (2018); LR-02 y LR-03 |
| P-15 | **Lo social pequeño, relativo y desactivable** | Hanus y Fox (2015); Landers et al. (2017) |

---

## 6. Métricas de bienestar para la Fase 9

Además de las métricas de negocio, mediremos **que el enganche sea sano**:

| Métrica | Objetivo | Por qué |
|---|---|---|
| Duración media de sesión | 5–15 minutos | Juego de "ratos", no compulsivo |
| % de sesiones de más de 60 minutos | Vigilar si sube | Señal de uso excesivo |
| % de sesiones entre las 0:00 y las 5:00 | Vigilar | Afectación del sueño |
| Valoración del jugador tras la sesión ("¿te ha gustado esta partida?"), opcional y anónima | Alta | **Medir el disfrute, no solo el tiempo** |
| Abandono justo después de una oferta | Bajo | Detecta ofertas que molestan |
| % de compras que se reembolsan o se cancelan pronto (suscripción) | Bajo | Detecta compras impulsivas o de las que el jugador se arrepiente |
| Uso del panel de "Juego responsable" | Informativo | Saber qué funciones desactivan los jugadores |

---

## 7. Riesgos y aspectos pendientes

- **Riesgo:** algunas cifras de la industria (Duolingo, por ejemplo) no están revisadas por pares. Las he usado solo como ejemplos, no como evidencia.
- **Pendiente:** verificar con enlace la referencia de McIntosh y Schmeichel (2004) sobre el coleccionismo. Las obras clásicas (Csikszentmihalyi, Kahneman y Tversky, Festinger, Ferster y Skinner, Hull) se citan sin enlace.
- **Contexto clínico:** el trastorno por videojuego está reconocido en la CIE-11 de la OMS. Su prevalencia varía según el método (un metaanálisis de 53 estudios advierte de que las cifras están **infladas por problemas de medición**, Stevens et al., 2021, [PubMed](https://pubmed.ncbi.nlm.nih.gov/33028074/)). **Nuestro diseño no debe empujar hacia ese patrón**, de ahí las métricas de la sección 6.

## 8. Próximos pasos (sujetos a tu aprobación)

**Fase 4: creación del concepto original.**
1. Generar **al menos 10 conceptos** de géneros distintos, guiados por las oportunidades O1–O7 de la Fase 2.
2. Hacer una **matriz de puntuación** de cada concepto: originalidad, dificultad de desarrollo con Godot y 0 €, monetización, retención, viralidad, capacidad de generar cientos de niveles, y **cumplimiento del marco legal y de estos principios**.
3. Comparar los **3 mejores** y **recomendar uno**.
4. Diseñar el concepto ganador en detalle, incluido el sistema escalable de niveles.

---

## Referencias verificadas en esta fase

- Ryan, Rigby y Przybylski (2006) — [DOI 10.1007/s11031-006-9051-8](https://doi.org/10.1007/s11031-006-9051-8)
- Przybylski, Rigby y Ryan (2010) — [Repositorio de la Universidad de Essex](https://repository.essex.ac.uk/7228/)
- Sweetser y Wyeth (2005), *GameFlow* — [PDF](https://ntnu.no/wiki/download/attachments/112986425/GameFlow.pdf?api=v2)
- Larche y Dixon (2020) — [PMC8943660](https://pmc.ncbi.nlm.nih.gov/articles/PMC8943660)
- Larche, Musielak y Dixon (2017) — [PMC5445157](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5445157/)
- Kivetz, Urminsky y Zheng (2006) — [PDF](https://business.columbia.edu/sites/default/files-efs/pubfiles/1200/goalgradient.pdf)
- Zendle y Cairns (2018) — [PDF, *PLOS ONE*](https://eprints.whiterose.ac.uk/139116/1/journal.pone.0206767.pdf)
- Gal y Rucker (2018) — [SSRN](https://papers.ssrn.com/abstract=3049660)
- Lally et al. (2010) — [PDF](https://core.ac.uk/download/70653523.pdf)
- Hamari, Koivisto y Sarsa (2014) — [PDF](https://www.lescahiersdelinnovation.com/wp-content/uploads/2019/06/2014-hamari_et_al-does_gamification_work.pdf)
- Deci, Koestner y Ryan (1999) — [PDF](https://depts.washington.edu/techdocs/papers/deciExtrinsicRewardsAndIntrinsicMotivation99.pdf)
- Clasificaciones y comparación social — [Estudio, PMC8046219](https://pmc.ncbi.nlm.nih.gov/articles/PMC8046219)
- Pendientes de enlace: Nunes y Drèze (2006), McIntosh y Schmeichel (2004), y las obras clásicas
- Stevens et al. (2021), prevalencia del trastorno por videojuego — [PubMed](https://pubmed.ncbi.nlm.nih.gov/33028074/)
