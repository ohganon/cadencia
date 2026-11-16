# FASE 2 — Informe final: análisis de 50 juegos móviles del App Store

**Fecha de referencia:** rankings de juegos de iPhone de España y EE. UU. del 16/11/2026
**Estado:** entregado, **pendiente de aprobación**
**Coste incurrido:** 0 € (solo fuentes públicas y datos oficiales gratuitos de Apple)

**Documentos de esta fase**

| Documento | Contenido |
|---|---|
| [00_METODOLOGIA_Y_MUESTRA.md](00_METODOLOGIA_Y_MUESTRA.md) | Metodología y muestra |
| [LOTE1_monetizacion_IAP.md](LOTE1_monetizacion_IAP.md) | Fichas de los juegos #1–#13 |
| [LOTE2_nueva_ola_puzles.md](LOTE2_nueva_ola_puzles.md) | Fichas de los juegos #14–#25 |
| [LOTE3_casual_social_coleccion.md](LOTE3_casual_social_coleccion.md) | Fichas de los juegos #26–#41 |
| [LOTE4_suscripcion_midcore_premium.md](LOTE4_suscripcion_midcore_premium.md) | Fichas de los juegos #42–#50 |
| [datos/](datos/) | Datos brutos auditables: rankings, metadatos, compras integradas, edades y matriz en CSV |
| [scripts/matriz.py](scripts/matriz.py) | Script que reproduce la matriz y las clasificaciones |

---

## 0. Resumen ejecutivo

1. **El mercado está dominado por dos fórmulas.**
   - **Puzle + meta-juego + monetización por compras** (Royal Match, Playrix, Gossip Harbor): gran retención y grandes ingresos.
   - **Gesto nuevo + niveles cortos + monetización híbrida** (la ola de 2024–2026: Pixel Flow, Magic Sort, Block Out!): grandes descargas, **retención débil** (D30 entre el 4 % y el 8 %).
2. **Casi nadie combina las dos.** Un juego con **el gesto fresco y táctil de la nueva ola** y **la profundidad, el meta-juego y la retención de los veteranos** es **la oportunidad más clara** que he detectado.
3. **El mercado entero está expuesto a la propuesta de DFA europea.** Con la clasificación por edad real del App Store español:
   - **48 de los 50 juegos tienen una clasificación inferior a 18+**;
   - **41 de 50 venden moneda virtual de pago**;
   - **solo 9 de 50 tienen un riesgo bajo** según los criterios de la propuesta.

   Si la DFA se aprueba tal como está redactada, **la mayor parte del mercado tendrá que rediseñar su monetización**. Nosotros partimos ya cumpliendo.
4. **"Limpio" no significa "peor".** Los 9 juegos de riesgo bajo incluyen **4 de los 15 mejor valorados** de toda la muestra: Balatro (37/40), NYT Games (36), Chess.com (35) y Geometry Dash (34).
5. **La viralidad orgánica tiene patrones replicables con 0 €.** Lo que funciona:
   - el resultado compartible sin desvelar la solución (Wordle);
   - los retos extremos y el contenido creado por los usuarios (Geometry Dash);
   - las combinaciones "rotas" que dan resultados absurdos (Balatro, BitLife);
   - lo que es agradable de mirar (Subway Surfers, Sand Blocks, Pixel Flow).
6. **Referencias de precio para la Fase 5**, sacadas de las compras oficiales del App Store español:

| Producto | Rango de precio |
|---|---|
| Quitar anuncios (pago único) | 6,99–9,99 € |
| Suscripción mensual | 2,99–9,99 € |
| Suscripción anual | 22,99–49,99 € |
| Pase | 5,99–9,99 € |
| Juego premium de pago | 3,99–9,99 € |

---

## 1. Objetivos cumplidos

| Objetivo del encargo | Estado |
|---|---|
| 50 juegos con país (ES y US), fecha fija y metodología consistente | ✅ Datos oficiales de Apple del 16/11/2026 |
| Muestra representativa (gratis, compras, anuncios, distintos modelos) | ✅ 6 estratos, incluidos suscripción y premium |
| Análisis individual: identidad, jugabilidad, retención, monetización, visual y marketing | ✅ 50 fichas en 4 lotes |
| Clasificación en 8 dimensiones | ✅ Sección 3 |
| Patrones y decisiones de diseño detrás del éxito | ✅ Sección 4 |
| Matriz comparativa de los 50 juegos | ✅ Sección 5 y `datos/matriz50.csv` |
| Benchmarking: los 7 puntos pedidos | ✅ Sección 6 |
| No inventar datos de herramientas de pago | ✅ "Sin dato público" cuando no lo hay |

---

## 2. Metodología (resumen)

- **Datos oficiales (A):**
  - rankings RSS de Apple (top 100 de juegos gratis, recaudación y de pago, ES y US);
  - API pública de Apple (fecha de lanzamiento, valoraciones, precio);
  - fichas del App Store español (las 10 compras integradas principales y la **clasificación por edad real**).
- **Estimaciones (C):** blogs públicos de Sensor Tower y AppMagic y prensa especializada (Naavik, Deconstructor of Fun, mobilegamer.biz, PocketGamer.biz, Gamigion).
- **Puntuaciones del 1 al 5:** **juicio profesional**, justificado en cada ficha. **No son datos medidos.**
- **Indicador de "riesgo DFA":**

| Nivel | Criterio |
|---|---|
| **Alto** | Azar de pago, **u** oferta al fallar combinada con moneda de pago |
| **Medio** | Moneda de pago **u** oferta al fallar |
| **Bajo** | Ninguna de las anteriores |

  **Limitación:** este indicador **no recoge el "pagar para ganar" competitivo**. Por ejemplo, Whiteout Survival sale como "Medio", pero su riesgo real es mayor.
- **No he jugado a los juegos.** El análisis del gameplay se basa en fuentes publicadas.

---

## 3. Clasificaciones por dimensión (top 10)

Entre paréntesis, la puntuación total sobre 40. Los empates se ordenan por la puntuación total.

| Dimensión | Top 10 |
|---|---|
| **Mejor gameplay** | Clash Royale (39), Royal Match (38), Balatro (37), Royal Kingdom (37), Brawl Stars (36), NYT Games (36), Bloons TD 6 (35), Chess.com (35), Pixel Flow! (35), Geometry Dash Lite (34) |
| **Mejor retención** | Clash Royale, Royal Match, Balatro, NYT Games, Pokémon GO, Bloons TD 6, Chess.com, Roblox, MONOPOLY GO!, Toon Blast |
| **Mejor monetización** | Clash Royale, Royal Match, Royal Kingdom, Pokémon GO, Pixel Flow!, Roblox, Disney Solitaire, Pokémon TCG Pocket, Gardenscapes, MONOPOLY GO! |
| **Mejor experiencia visual** | Clash Royale, Royal Match, Balatro, Royal Kingdom, Brawl Stars, Disney Solitaire, Pokémon TCG Pocket, Gardenscapes, Mini Metro, NYT Games |
| **Mejor progresión** | Clash Royale, Royal Match, Royal Kingdom, Brawl Stars, Pokémon GO, Bloons TD 6, Chess.com, Township, Whiteout Survival, Balatro |
| **Mayor potencial viral** | Balatro, NYT Games, Pokémon GO, Pixel Flow!, Geometry Dash Lite, Roblox, Subway Surfers, Meowdoku!, BitLife, Sand Blocks |
| **Mejor equilibrio entre anuncios y experiencia** | Clash Royale, Royal Match, Balatro, Royal Kingdom, Brawl Stars, NYT Games, Bloons TD 6, Mini Metro, Pokémon GO, Chess.com |
| **Mejor relación entre simplicidad y profundidad** | Clash Royale, Royal Match, Balatro, Royal Kingdom, NYT Games, Chess.com, Pixel Flow!, Geometry Dash Lite, Meowdoku!, Mini Metro |

**Media de la puntuación total por estrato:**

| Estrato | Media /40 |
|---|---|
| 1. Puzles con monetización por compras | 30,8 |
| 2. Nueva ola de puzles | 27,2 |
| 3. Casuales y de anuncios | 27,1 |
| 4. Meta-juego y sociales | 29,9 |
| 5. Suscripción y midcore | 35,0 |
| 6. Premium de pago | 34,3 |

**Cómo leer estas clasificaciones:**
- **Los juegos de solo anuncios no aparecen en ninguna lista de equilibrio ni de retención.** Con los anuncios intersticiales como modelo principal, es muy difícil una experiencia de primer nivel.
- **El potencial viral está muy repartido**: hay juegos con presupuesto (Pokémon GO) y juegos sin él (Balatro, Geometry Dash, BitLife, NYT Games). **Es la dimensión más "democrática"**, la que menos depende del dinero.
- **Balatro aparece en 6 de las 8 listas** con un solo desarrollador y un modelo de pago único. Es la referencia de "calidad por diseño, no por presupuesto".

---

## 4. Patrones de los juegos que mejor funcionan y decisiones de diseño detrás de su éxito

### P1. "Se entiende en 3 segundos y se domina en meses"
**Dónde aparece:** Clash Royale (partidas de 3 minutos), Royal Match, Pixel Flow (técnica avanzada escondida), Balatro (póker más comodines), Chess.com, Meowdoku.

**Decisión de diseño:**
- **Reglas que ya conoces o que caben en una frase**;
- **más una capa de dominio que se descubre jugando**: el encadenado de acciones (*slinging*) de Pixel Flow, las sinergias de Balatro, la composición del mazo en Clash Royale.

### P2. Un meta-juego que da sentido al puzle
**Dónde aparece:** la decoración de Royal Match y Gardenscapes, la telenovela de Gossip Harbor, la imagen pixelada de Pixel Flow, las ciudades de Mini Metro, el World Tour de Subway Surfers.

**Decisión de diseño:** el puzle es un **medio para avanzar en algo más grande y visible**.

**Lo que dicen los datos:** los juegos **sin meta-juego** (la mayoría de la nueva ola) **retienen la mitad o menos** que los que lo tienen.

### P3. Niveles cortos y protección del jugador nuevo
**Dónde aparece:**
- en Royal Match, los niveles duran entre 1 y 3 minutos y **los eventos no aparecen hasta el nivel 22–25**;
- en Candy Crush (Fase 1), King concluyó que "los niveles difíciles deben ser cortos".

**Decisión de diseño:** cuidar los primeros minutos (el *onboarding*) por encima de todo.

### P4. Satisfacción táctil y visual intrínseca
**Dónde aparece:** la arena de Sand Blocks, la lana de Yarn Loop, los tornillos de Screwdom, la imagen que se pinta en Pixel Flow, los sobres de Pokémon, la vibración háptica.

**Decisión de diseño:** **el gesto en sí es la recompensa.** Esto también es lo que hace que un juego **se vea bien en un vídeo de 15 segundos**.

### P5. Renovar el contenido decide el ciclo de vida
**Los que crecieron:** Township (récord a los 13 años), Clash Royale (mejor año en 2025), Toon Blast (crece a los 8 años).
**Los que cayeron:** Brawl Stars (–57 %), TCG Pocket (–50 %), Gardenscapes (–13 %).

**Decisión de diseño:** una capacidad continua de generar contenido nuevo.
- Los grandes lo hacen **con equipos enormes**.
- Los pequeños lo hacen **con sistemas**: contenido de los usuarios (Geometry Dash, Roblox, Bloons), combinatoria emergente (Balatro) o un reto diario (NYT Games).

### P6. Lo social, lo más asíncrono y ligero posible
**Dónde aparece:** los equipos de Royal Match y Toon Blast, el intercambio de pegatinas de MONOPOLY GO!, la conversación diaria sobre el mismo Wordle, los clanes de Clash Royale, el Parchís con la familia en España.

**Decisión de diseño:** lo social **multiplica la retención sin exigir que todos jueguen a la vez**.

### P7. La monetización acompaña al momento emocional
**Dónde aparece:**
- **la oferta al fallar** (7 de 50; es la palanca principal de la nueva ola);
- **el pase** (20 de 50);
- **la "hucha"** (Township, Solitaire Associations Journey);
- **la suscripción** (7 de 50, en crecimiento).

**Lectura ética:**
- Las ofertas en el momento de la frustración son **eficaces y legales hoy**, pero son **el punto más expuesto a la DFA**.
- La **hucha, el pase con camino gratuito y la suscripción transparente** consiguen lo mismo **sin explotar el momento de frustración**.

---

## 5. Matriz comparativa de los 50 juegos

Fuente: `datos/matriz50.csv`. "Edad ES" = clasificación real en el App Store español a 16/11/2026 [A]. Las compras y precios proceden de las fichas oficiales [A]. El resto son atributos analizados en las fichas.

| # | Juego | Subgénero | Modelo | Meta-juego | Social | Pase | Quitar anuncios € | Oferta al fallar | Suscr. | Azar de pago | Moneda de pago | Edad ES | Riesgo DFA | Total /40 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Royal Match | Match-3 | Compras | Decoración | Equipos | Sí | - | No | No | No | Sí | 13+ | Medio | 38 |
| 2 | Royal Kingdom | Match-3 | Compras | Decoración | Equipos | Sí | - | No | No | No | Sí | 13+ | Medio | 37 |
| 3 | Toon Blast | Tap-blast | Compras | Episodios | Equipos | No | - | No | No | No | Sí | 4+ | Medio | 32 |
| 4 | Match Factory! | Triple match 3D | Compras | Episodios | Equipos | Sí | - | No | No | No | Sí | 4+ | Medio | 32 |
| 5 | Gardenscapes | Match-3 | Compras | Decoración+narrativa | Equipos | Sí | - | No | No | No | Sí | 13+ | Medio | 32 |
| 6 | Township | Granja/ciudad | Compras | Construcción | Cooperativas | Sí | - | No | No | No | Sí | 13+ | Medio | 32 |
| 7 | Gossip Harbor | Merge-2 | Compras | Narrativa | Mínimo | Sí | - | No | No | No | Sí | 13+ | Medio | 30 |
| 8 | Travel Town | Merge-2 | Compras | Restauración | Amigos | No | - | No | No | No | Sí | 16+ | Medio | 26 |
| 9 | Tasty Travels | Merge-2 | Compras | Viajes/cocina | Mínimo | No | - | No | No | No | Sí | 9+ | Medio | 28 |
| 10 | Disney Solitaire | Solitario TriPeaks | Compras | Colección (licencia) | Mínimo | No | - | No | No | No | Sí | 13+ | Medio | 33 |
| 11 | Jelly Busters | Ordenar/romper | Híbrido | Mínimo | Mínimo | No | - | No | No | No | Sí | 16+ | Medio | 28 |
| 12 | Screwdom | Tornillos 3D | Híbrido | Mínimo | Mínimo | No | - | No | No | No | Sí | 9+ | Medio | 27 |
| 13 | Solitaire Associations Journey | Solitario+palabras | Híbrido | Mínimo | Mínimo | No | 9,99 | Sí | No | No | Sí | 4+ | Alto | 26 |
| 14 | Block Out! | Bloques de color | Híbrido | Mínimo | Mínimo | Sí | - | No | No | No | Sí | 4+ | Medio | 29 |
| 15 | Magic Sort! | Ordenar líquidos | Híbrido | Mínimo | Mínimo | No | - | Sí | No | No | Sí | 13+ | Alto | 30 |
| 16 | Meowdoku! | Lógica (Star Battle) | Anuncios+suscripción | Ninguno | Ninguno | No | - | No | Sí | No | No | 13+ | Bajo | 31 |
| 17 | Amaze GO! | Flechas | Anuncios | Ninguno | Ninguno | No | - | No | No | No | No | 13+ | Bajo | 21 |
| 18 | Bus Traffic Fever! | Tráfico/colores | Híbrido | Mínimo | Mínimo | Sí | 14,99 | Sí | No | No | Sí | 13+ | Alto | 27 |
| 19 | CubeAway | Desmontar 3D | Híbrido | Mínimo | Mínimo | No | 8,99 | No | No | No | Sí | 13+ | Medio | 27 |
| 20 | Pixel Flow! | Shooter de colores | Híbrido | Imagen a completar | Mínimo | Sí | 8,99 | Sí | No | No | Sí | 13+ | Alto | 35 |
| 21 | Colony Flow! | Shooter de colores | Híbrido | Mínimo | Mínimo | Sí | 8,99 | Sí | No | No | Sí | 13+ | Alto | 26 |
| 22 | Sand Blocks | Bloques de arena | Híbrido | Mínimo | Mínimo | Sí | 8,99 | Sí | No | No | Sí | 4+ | Alto | 29 |
| 23 | Yarn Loop | Ordenar lana | Híbrido | Mínimo | Mínimo | No | - | No | No | No | Sí | 4+ | Medio | 29 |
| 24 | Parking Loop | Tráfico | Híbrido | Mínimo | Mínimo | No | 0,99 | Sí | No | No | Sí | 13+ | Alto | 21 |
| 25 | Cube Smash | Romper cubos | Híbrido | Mínimo | Mínimo | No | - | No | No | No | Sí | 4+ | Medio | 22 |
| 26 | Vita Mahjong | Mahjong | Híbrido+suscripción | Mínimo | Mínimo | No | 6,99 | No | Sí | No | Sí | 13+ | Medio | 26 |
| 27 | Word Tiles | Palabras | Híbrido | Mínimo | Mínimo | No | 9,99 | No | No | No | Sí | 4+ | Medio | 23 |
| 28 | Brain Puzzle 3 | Acertijos | Anuncios | Ninguno | Ninguno | No | 6,99 | No | No | No | No | 13+ | Bajo | 20 |
| 29 | Magic Tiles 3 | Ritmo | Híbrido+suscripción | Canciones | Mínimo | No | 9,99 | No | Sí | No | Sí | 4+ | Medio | 28 |
| 30 | Paper.io 2 | IO territorial | Anuncios+cosmética | Skins | PvP con bots | No | 9,99 | No | No | No | Sí | 9+ | Medio | 25 |
| 31 | Mob Control | Casual híbrido | Híbrido | Cartas/mejoras | PvP | Sí | - | No | No | Sí | Sí | 13+ | Alto | 29 |
| 32 | Subway Surfers | Endless runner | Híbrido | Colección+World Tour | Mínimo | Sí | - | No | No | No | Sí | 9+ | Medio | 32 |
| 33 | Geometry Dash Lite | Plataformas rítmico | Demo+premium | Iconos | Contenido de usuarios | No | - | No | No | No | No | 13+ | Bajo | 34 |
| 34 | MONOPOLY GO! | Tablero de dados | Compras | Construcción+álbum | Intercambio | No | - | No | No | Sí | Sí | 9+ | Alto | 32 |
| 35 | Coin Master | Tragaperras+aldea | Compras | Construcción+cartas | Ataques/amigos | No | - | No | No | Sí | Sí | 18+ | Alto | 26 |
| 36 | Pokémon GO | Geolocalización | Compras | Colección | Presencial | Sí | - | No | No | No | Sí | 9+ | Medio | 36 |
| 37 | Pokémon TCG Pocket | Cartas | Compras | Colección | Intercambio/PvP | Sí | - | No | No | Sí | Sí | 9+ | Alto | 33 |
| 38 | BitLife | Simulador de vida | Pago único+expansiones | Vidas | Compartir historias | No | 8,99 | No | No | No | No | 18+ | Bajo | 29 |
| 39 | Parchisi STAR | Parchís online | Compras | Cosmética | PvP con amigos | Sí | - | No | No | Sí* | Sí | 4+ | Alto* | 26 |
| 40 | 8 Ball Pool | Billar | Compras | Tacos/ligas | PvP | Sí | - | No | Sí | Sí | Sí | 13+ | Alto | 29 |
| 41 | Among Us! | Deducción social | Cosmética | Cosmética | Multijugador | No | 1,99 | No | No | No | Sí | 9+ | Medio | 28 |
| 42 | NYT Games | Pasatiempos diarios | Suscripción | Rachas/archivo | Conversación diaria | No | - | No | Sí | No | No | 13+ | Bajo | 36 |
| 43 | Chess.com | Ajedrez | Suscripción por niveles | Rating/lecciones | PvP | No | - | No | Sí | No | No | 4+ | Bajo | 35 |
| 44 | Clash Royale | Estrategia con cartas | Compras | Mazo/trofeos | PvP+clanes | Sí | - | No | No | No | Sí | 9+ | Medio | 39 |
| 45 | Brawl Stars | Acción por equipos | Compras | Personajes | PvP+clubes | Sí | - | No | No | No | Sí | 13+ | Medio | 36 |
| 46 | Whiteout Survival | 4X | Compras | Ciudad/héroes | Alianzas | Sí | - | No | No | No | Sí | 9+ | Medio** | 30 |
| 47 | Roblox | Plataforma de contenido de usuarios | Suscripción+moneda | Plataforma | Contenido de usuarios | No | - | No | Sí | No | Sí | 13+ | Medio | 34 |
| 48 | Balatro | Roguelike de póker | Premium | Desbloqueos | Ninguno | No | - | No | No | No | No | 13+ | Bajo | 37 |
| 49 | Mini Metro | Diseño de redes | Premium | Ciudades | Ninguno | No | - | No | No | No | No | 4+ | Bajo | 31 |
| 50 | Bloons TD 6 | Tower defense | Premium+compras | Héroes/mapas | Cooperativo+contenido de usuarios | No | - | No | No | No | Sí | 9+ | Medio | 35 |

\* "Pick a Golden Card": que sea aleatorio **está sin verificar**.
\*\* Pagar para ganar competitivo explícito, que el indicador no recoge. Su riesgo real es alto.

**Recuento** (cálculo del script `scripts/matriz.py`):

| Atributo | Juegos de 50 |
|---|---|
| Moneda virtual de pago | 41 |
| Pase | 20 |
| Venden "quitar anuncios" | 14 |
| Oferta al fallar | 7 |
| Suscripción | 7 |
| Azar de pago | 6 |
| Clasificación inferior a 18+ en ES | **48** |

**Riesgo DFA:** alto 13, medio 28, bajo 9.

**La clasificación por edad real confirma un punto del marco legal.** Ninguno de los puzles casuales está en 18+. Solo lo están **Coin Master** (tragaperras) y **BitLife**. Travel Town y Jelly Busters están en **16+**. Por tanto, un juego como el nuestro **estará casi seguro en el grupo "dirigido a menores"** de la DFA.

---

## 6. Benchmarking (los 7 puntos del encargo)

### 6.1 Elementos comunes entre los juegos más exitosos

| Elemento | En el top 10 por total | En el resto |
|---|---|---|
| Reglas en una frase con profundidad oculta | 10 de 10 | Frecuente |
| Meta-juego visible (decoración, colección, mazo, ranking) | 9 de 10 (todos salvo NYT Games, que usa el reto diario) | Escaso en la nueva ola |
| Capa social (equipos, PvP, conversación) | 8 de 10 | Escaso |
| Sin anuncios intersticiales como modelo principal | 10 de 10 | No |
| Contenido que se renueva de forma continua (eventos, temporadas, contenido de la comunidad o combinatoria) | 10 de 10 | Variable |

### 6.2 Mecánicas que aparecen en distintos géneros

| Mecánica | Juegos |
|---|---|
| **Huecos o recursos limitados como condición de derrota** | Barra de 7 en Match Factory, frascos en Magic Sort, cajas de tornillos en Screwdom, bandeja en Pixel Flow, movimientos en el match-3, la Bitizenship de BitLife |
| **Ordenar el caos por colores** | Magic Sort, Block Out, Bus Traffic Fever, Yarn Loop, Jelly Busters, Pixel Flow, Screwdom |
| **Colección con progreso visible** | Álbumes de MONOPOLY GO!, Pokédex, Disney Solitaire, personajes de Subway Surfers, Brawl Stars |
| **Pase de temporada con camino gratuito** | 20 juegos de casi todos los géneros |
| **Reto diario o temporal** | NYT Games, Chess.com (puzle diario), eventos de Royal Match y Township, Pokémon GO |

### 6.3 Sistemas de progresión especialmente eficaces

1. **Mapa o meta-juego de restauración** (Royal Match, Gardenscapes, Township): la progresión es visible y física.
2. **Narrativa por episodios con gancho** (Gossip Harbor): el motor de curiosidad más fuerte de la muestra.
3. **Ranking o rating de habilidad** (Chess.com, Clash Royale): la progresión mide **el dominio real** del jugador.
4. **Desbloqueos que amplían las posibilidades** (comodines de Balatro, torres de Bloons TD 6): la progresión aumenta **la profundidad**, no solo el número del nivel.
5. **Imagen o colección que se completa** (pixel art de Pixel Flow, ciudades de Mini Metro): una recompensa estética intrínseca.

### 6.4 Estrategias de monetización (de más a menos compatibles con nuestro marco)

| Estrategia | Ejemplos | Compatibilidad con nuestro marco legal |
|---|---|---|
| Suscripción transparente | NYT Games (2,99 €/mes), Chess.com por niveles, Meowdoku | ✅ Alta |
| Pago único, demo o expansiones | Geometry Dash, BitLife, Balatro, Mini Metro | ✅ Alta |
| Quitar anuncios con pago único | 14 juegos, 6,99–9,99 € (más la prueba a 0,99 € de Paper.io 2) | ✅ Alta |
| Solo cosmética | Among Us!, skins de Paper.io 2 | ✅ Alta (pocos ingresos) |
| Pase con camino gratuito | 20 juegos, 5,99–9,99 € | ✅ Si se vende en euros y sin moneda virtual |
| Hucha | Township, Solitaire Associations Journey | ✅ Si el precio es claro |
| Anuncios recompensados voluntarios | Generalizado | ✅ |
| Intersticiales | Nueva ola y juegos de anuncios | ⚠️ Con moderación |
| Moneda virtual de pago | 41 juegos | ❌ LR-04 |
| Oferta al fallar | 7 juegos | ⚠️ Zona gris DFA (art. 16) |
| Energía de pago como palanca principal | Merge-2, MONOPOLY GO! | ❌ Riesgo de pagar para avanzar |
| Azar de pago (sobres, giros, rasca y gana) | 6 juegos | ❌ LR-03 |
| Ofertas personalizadas | Mob Control, Travel Town | ❌ LR-08 |

### 6.5 Elementos que generan frustración

**Lo que he podido observar** (reseñas y análisis; evidencia C/E, no he hecho un estudio sistemático de reseñas):

| Fuente de frustración | Ejemplo |
|---|---|
| Barrera de energía o vidas cuando el jugador quiere seguir | Merge-2 |
| Exceso de intersticiales | Meowdoku, con tiempos de espera de 90–120 s; reseña de Android Central: "tiene un gran problema" |
| Presión de eventos superpuestos | Hasta 23 eventos activos a la vez en Royal Match |
| Picos de dificultad diseñados para vender | Nivel 65 de Candy Crush (Fase 1); límites de tiempo estrictos en los juegos de bloques |
| Anuncios engañosos | Playrix y el precedente de la ASA |
| Ofertas constantes con nombres de "rebaja eterna" | "Endless Sale" de Screwdom, "Endless Treasure" de Parking Loop |
| Desgaste de la aleatoriedad de pago | TCG Pocket (–50 %) |

### 6.6 Oportunidades que todavía no están suficientemente explotadas

| # | Oportunidad | Evidencia |
|---|---|---|
| O1 | **Un puzle de "gesto nuevo" con meta-juego y profundidad real.** La nueva ola tiene descargas pero no retención; los veteranos tienen retención pero gestos viejos | D30 del 4–8 % en la ola frente a la retención de Royal Match y Township |
| O2 | **El reto diario igual para todos con resultado compartible, dentro de un juego de puzle con progresión.** NYT Games lo hace con pasatiempos clásicos, pero casi ningún puzle casual lo integra como pieza central | NYT Games 36/40; ausente en la nueva ola |
| O3 | **Contenido infinito sin producción manual:** generación procedural verificada, combinatoria emergente o un editor de niveles para la comunidad | Balatro, Geometry Dash, Roblox |
| O4 | **Un juego "limpio" como posicionamiento de marca**: sin moneda de pago, sin trucos y con un panel de "Juego responsable". **Si la DFA se aprueba, la competencia tendrá que adaptarse y nosotros ya estaremos ahí** | 41/50 con moneda de pago, 48/50 con clasificación inferior a 18+ |
| O5 | **Públicos desatendidos:** personas mayores (accesibilidad real) y el mercado español de juegos de mesa y familiares | Vita Mahjong (media 4,9); Parchís STAR (top 20 en recaudación solo en ES) |
| O6 | **Narrativa por episodios en un puzle "de gesto"**, no en merge-2 | Gossip Harbor domina el merge, pero no existe equivalente en la nueva ola |
| O7 | **Una estética con concepto en lugar de estética "brillante y genérica"** | Mini Metro y Balatro destacan visualmente con poco presupuesto; la nueva ola es visualmente intercambiable |

### 6.7 Mecánicas que podrían combinarse de formas originales

Son **direcciones** que se exploran en la Fase 4. **No son conceptos cerrados.**

| Combinación | Por qué podría funcionar |
|---|---|
| **Gesto táctil nuevo + combinatoria emergente tipo Balatro** (modificadores que cambian las reglas) | Profundidad infinita sin miles de niveles hechos a mano |
| **Puzle diario igual para todos + progresión personal + resultado compartible** | El hábito sano de Wordle con la retención de un juego de progresión |
| **Física satisfactoria (arena, líquidos, telas) + lógica de deducción** (Meowdoku) | Satisfacción visual con profundidad mental, poco visto |
| **Reto extremo opcional ("modo pesadilla") + clasificación semanal** | El motor viral de Geometry Dash dentro de un puzle casual |
| **Meta-juego de colección intercambiable gratis** (pegatinas o piezas que se ganan jugando) | El motor social de MONOPOLY GO! sin azar de pago |
| **Editor de niveles + sistema de verificación de que el nivel tiene solución** | El contenido de la comunidad de Geometry Dash y Bloons aplicado a un puzle |

---

## 7. Decisiones tomadas en esta fase

1. **Se descarta como modelo principal** la monetización basada en moneda virtual de pago, energía de pago, oferta al fallar sin alternativa gratuita, azar de pago y ofertas personalizadas. Coherente con el marco legal (LR-03 a LR-08).
2. **Se fijan los rangos de precio** de referencia para la Fase 5 (sección 0, punto 6).
3. **Se prioriza la oportunidad O1** como hipótesis principal para la Fase 4: **gesto nuevo + profundidad + meta-juego**. **O2, O3 y O4 son complementos** probablemente necesarios.
4. **La viralidad se diseñará en el propio juego** (resultado compartible, retos extremos, momentos visualmente satisfactorios), porque **no podemos competir en adquisición pagada** (Meowdoku gasta unos 500 k$ al día).

---

## 8. Riesgos detectados

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Las puntuaciones son juicio profesional, no medición | Medio | Están justificadas en las fichas. Las conclusiones se apoyan sobre todo en datos A y C |
| Las cifras de ingresos discrepan entre rastreadores (bruto o neto, con o sin tienda web) | Medio | Siempre se dan rangos y la fuente |
| No he jugado a los 50 juegos | Medio | Propuesta opcional: que juegues tú a 5 de referencia (Pixel Flow, Royal Match, Balatro, NYT Games y Geometry Dash Lite), unos 20 minutos cada uno, con una plantilla de observación |
| Saturación de la nueva ola de puzles (nuevos títulos cada semana) | Alto | Diferenciación por profundidad, meta-juego y marca "limpia" |
| Nuestra mayor desventaja estructural es la falta de presupuesto de adquisición | **Alto** | Viralidad incorporada al diseño (Fase 7). Una estrategia de nicho y comunidad en lugar de volumen |
| La DFA puede cambiar durante su tramitación | Medio | Revisión trimestral del marco legal |

## 9. Aspectos pendientes

- Estudio sistemático de reseñas de una página o dos estrellas para cuantificar las frustraciones (opcional; se puede hacer en la Fase 3).
- Leer íntegro el texto oficial de la DFA (sigue pendiente del marco legal).

## 10. Próximos pasos (sujetos a tu aprobación)

**Fase 3: biblioteca de mecanismos de psicología, retención y monetización.**

Cubrirá:
- Self-Determination Theory, Flow, Goal Gradient, Endowed Progress, recompensas variables, competencia y dominio, aversión a la pérdida, colección, comparación social, formación de hábitos y sistemas de progresión;
- para cada uno: su evidencia científica (con enlace), ejemplos de las Fases 1–2, cómo aplicarlo a nuestro proyecto y sus riesgos si se usa de forma abusiva;
- **filtrado por nuestro marco legal**.
