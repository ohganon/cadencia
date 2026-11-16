# FASE 5 — Modelo de negocio y monetización de Cadencia

**Fecha:** 16/11/2026
**Estado:** entregado, **pendiente de aprobación**
**Coste:** 0 €

**Directriz del cliente:** *"Buscamos monetizar bien el juego"*. El límite de energía debe incentivar el premium.

**Restricciones:** [marco legal](../legal/MARCO_CUMPLIMIENTO_LEGAL.md) (LR-01 a LR-15) y principios P-01 a P-16.

> **Convención de este informe:** **[DATO]** = dato con fuente. **[HIPÓTESIS]** = supuesto nuestro, que habrá que validar con datos reales tras el lanzamiento.

---

## 0. Resumen ejecutivo

1. **Energía "Cuerda"**:
   - **cada nivel nuevo de la campaña cuesta 1 cuerda**; los **reintentos son gratis**;
   - **máximo de 5 cuerdas, 1 cada 30 minutos**.
   - **El jugador comprometido** (sesiones de 20–40 minutos) **se queda sin cuerda en su primera sesión**. Entonces elige entre ver un anuncio (+3), esperar, jugar a los modos gratuitos o hacerse premium.
   - **El jugador casual** (2–3 ratos de 5 minutos) casi no lo nota.
   - **El límite presiona justo al segmento con más probabilidad de pagar**, sin hacer "ilusorio" el camino gratuito.
2. **Club Cadencia (suscripción)** [HIPÓTESIS de precio, justificada con los datos de la Fase 2]:
   - **4,99 €/mes o 29,99 €/año**;
   - prueba de 7 días **solo en el plan anual**, con aviso antes del cobro;
   - incluye: **cuerda ilimitada**, sin anuncios, pistas ilimitadas, archivo de retos diarios, capítulos extra y un estilo de ficha exclusivo cada mes.
3. **Pagos únicos:** **"Sin anuncios" a 7,99 €** y **packs cosméticos a 1,99–3,99 €**. Todos **en euros**, sin moneda virtual.
4. **Publicidad:**
   - **AdMob** para el lanzamiento: hay un plugin gratuito y con licencia MIT para Godot 4 (Poing Studios).
   - **AppLovin MAX** se evaluará al llegar a unos 10.000 jugadores diarios; también tiene **plugin oficial de Godot con licencia MIT**.
   - Formatos: **recompensados** (cuerda y pistas) e **intersticiales con límites estrictos**. **Sin banners.**
5. **Modelo financiero** (beneficio mensual antes de impuestos sobre la renta) [HIPÓTESIS]:

| Jugadores diarios (DAU) | Conservador | Intermedio | Optimista |
|---|---|---|---|
| 1.000 | 387 € | 919 € | 1.649 € |
| 10.000 | 4.900 € | 10.222 € | 17.523 € |
| 50.000 | 25.885 € | 52.498 € | 89.001 € |
| 100.000 | 52.079 € | 105.306 € | 178.311 € |

6. **Conclusión clave:**
   - El **valor de vida estimado a 180 días** es de solo **0,09–0,90 € por jugador**.
   - **Comprar usuarios con publicidad no sale rentable** a esa escala (en la Fase 2 vimos costes de adquisición de 0,50 $ o más en Android).
   - **El crecimiento tiene que ser orgánico** (Fase 7), lo que confirma la estrategia elegida.
   - **El margen es muy alto** porque no hay servidores ni equipo: **la clave es llegar a miles de jugadores diarios**.

---

## 1. Sistema de progresión gratuita: la "Cuerda"

### 1.1 Diseño

**Nombre temático:** en un pueblo de relojeros, la energía es la **cuerda** de los mecanismos.

| Regla | Valor [HIPÓTESIS inicial] | Motivo |
|---|---|---|
| Qué cuesta cuerda | **Empezar un nivel nuevo de la campaña** | Limita el **ritmo de avance**, no la experimentación |
| Qué **no** cuesta cuerda | Reintentos, niveles ya superados (para sacar estrellas), **la Caída del Día**, el Modo Libre, el Taller y los eventos | El camino gratuito **siempre** tiene contenido (DFA art. 16; P-05) |
| Máximo | **5 cuerdas** | Igual que la referencia del género (5 vidas en Candy Crush y Royal Match, Fases 1 y 2) |
| Recarga | **1 cada 30 minutos** (llena en 2,5 horas) | Ídem |
| Anuncio recompensado | **+3 cuerdas** por anuncio voluntario, mostrando la recompensa antes | Ingresos + opción gratuita real |
| Límite de anuncios recompensados | **10 al día** | Protege al jugador del juego excesivo (Fase 3, sección 6) y protege el valor del premium |
| Suscripción | **Cuerda ilimitada** | El principal motivo para pagar |
| Primeros 15 niveles | **Sin consumo de cuerda** | Protección del jugador nuevo (Fase 2, patrón P3; Royal Match) |

### 1.2 Cómo afecta a cada tipo de jugador [HIPÓTESIS, se validará con analítica]

Suponiendo **2–3 minutos por nivel** (diseño de la Fase 4):

| Tipo de jugador | Uso típico | Niveles nuevos al día | ¿Se queda sin cuerda? | Qué hace |
|---|---|---|---|---|
| **Casual** | 2–3 ratos de 5–10 min | 4–8 | Rara vez: la recarga entre ratos cubre casi todo | Juega gratis. Ve intersticiales |
| **Comprometido** | 1–2 sesiones de 20–40 min | 10–20 | **Sí, a los 5 niveles de cada sesión** | Ve 1–4 anuncios recompensados o **se suscribe** |
| **Intensivo** | Más de 1 hora al día | Más de 20 | **Sí, de forma recurrente.** El tope de 10 anuncios le deja unos 35 niveles al día con recargas | **El candidato natural al premium** |

**Por qué responde a tu directriz:** el límite **sí muerde**, pero **solo a quien más juega**, que es quien más valora quitarlo. La investigación del mercado (Chess.com, Fase 2) indica que **solo alrededor del 1 % pagará**, y ese 1 % sale de los jugadores comprometidos e intensivos.

### 1.3 Por qué no endurecerlo más (por ejemplo, 3 cuerdas o recarga de 1 hora)

1. **Riesgo legal:** con la DFA, en un juego "dirigido a menores" (todos los puzles de la Fase 2 tienen clasificación inferior a 18+), una progresión gratuita "ilusoria" es pagar para avanzar (art. 16).
2. **Riesgo de abandono:** el límite actúa cuando el jugador **todavía no está enganchado**. En la Fase 1, King comprobó que **endurecer sube la conversión a corto plazo pero hace perder jugadores a largo plazo**.
3. **Riesgo de ingresos:** **el 70–80 % de los ingresos del modelo viene de los anuncios** (sección 5), y los anuncios necesitan jugadores activos. Expulsar jugadores para forzar suscripciones **reduce el total**.

**Cómo se ajustará:** tras el lanzamiento, **pruebas A/B entre variantes dentro de un rango ético** (máximo de 4–6 cuerdas, recarga de 20–40 minutos). Se medirán los **ingresos totales a 30 días y la retención D30**, no solo la conversión. **La variante elegida se aplicará a todos por igual** (LR-01 y LR-08: nunca un límite distinto según el valor económico del jugador).

---

## 2. Publicidad

### 2.1 Comparativa de redes (verificado el 16/11/2026)

| Red o mediación | Plugin para Godot 4 | Licencia del plugin | Coste | Valoración |
|---|---|---|---|---|
| **Google AdMob** (más su mediación) | ✅ **Poing Studios**, v5.x (julio–septiembre de 2026), Android e iOS, GDScript y C# | MIT | Gratis (Google cobra una parte de cada anuncio) | **Recomendado para el lanzamiento**: el plugin está maduro y bien documentado, e incluye la plataforma de consentimiento de Google (UMP) |
| **AppLovin MAX** | ✅ **Oficial de AppLovin**, Godot 4.x, Android e iOS | MIT | Gratis | **Fase de crecimiento**: es la mediación con mejor rendimiento del sector y la que usa Block Blast (Fase 1) |
| **Unity LevelPlay** | ❌ No he encontrado SDK para Godot | — | — | Descartado |
| **Unity Ads** (directo) | ❌ No oficial | — | — | Descartado, salvo como red dentro de la mediación |

Fuentes:
- [Plugin AdMob de Poing Studios (GitHub)](https://www.Github.com/poingstudios/godot-admob-plugin) · [Godot Asset Store](https://store.godotengine.org/asset/poingstudios/admob/)
- [AppLovin MAX para Godot (GitHub)](https://github.com/AppLovin/AppLovin-MAX-Godot) · [Documentación de integración](https://developers.applovin.com/en/max/godot/overview/integration)
- [Documentación de Unity LevelPlay](https://docs.unity.com/grow/en-us/levelplay/sdk)

**Decisión:** **AdMob en la versión 1.0.** Con unos 10.000 jugadores diarios se hará una **prueba de AppLovin MAX** y se migrará si mejora el ingreso por jugador sin degradar la experiencia.

### 2.2 Estrategia de anuncios

| Formato | Dónde | Reglas |
|---|---|---|
| **Recompensado** | (1) **+3 cuerdas**, cuando el jugador se queda sin cuerda. (2) **Pista** (un tramo en fantasma) | **Siempre voluntario.** La recompensa se muestra antes. Si no se ve el anuncio, no hay castigo. Máximo de 10 al día |
| **Intersticial** | **Entre niveles** de la campaña, nunca durante una partida | **No aparecen en los primeros 15 niveles.** **Como máximo 1 cada 3 niveles completados y con al menos 3 minutos de separación.** **Nunca después de un fallo** (no se castiga la frustración). **Nunca en la Caída del Día ni en el Modo Libre** (que son los que se comparten) |
| **Banner** | **Ninguno** | Afea un juego visual y se gana poco con ellos. Es coherente con la identidad "premium" |
| **Publicidad integrada en el mundo del juego** | No en la versión 1.0 | Más adelante podría valorarse un patrocinio estético bien señalizado (por ejemplo, un barrio patrocinado) |

**Cumplimiento** (marco legal, sección 2):
- **Consentimiento previo** para anuncios personalizados en el Espacio Económico Europeo, con la plataforma de consentimiento de Google (UMP, gratuita, certificada IAB TCF).
- **ATT** en iOS.
- **Configuración de "contenido para menores"** si el cuestionario de clasificación lo exige.
- **Lista de categorías de anunciante bloqueadas**: apuestas, alcohol, citas, contenido para adultos. **Block Blast mantiene una de las listas de bloqueo más amplias del sector** (Fase 1).

---

## 3. Premium

### 3.1 Opciones comparadas

| Opción | Ventaja | Inconveniente | Decisión |
|---|---|---|---|
| A. Solo "sin anuncios" (pago único) | Sencilla y bien aceptada | Ingresos únicos; no cubre el contenido continuo | ✅ **Se incluye** como alternativa barata |
| B. Suscripción "Club" | Ingresos recurrentes, encaja con el contenido infinito (Caída del Día, eventos, capítulos extra) | Exige aportar valor continuo (directriz 3.1.2 de Apple) | ✅ **Producto principal** |
| C. Pase de temporada | Muy extendido (20 de 50 juegos) | Más complejo; riesgo de presión por tiempo | ⏸ **Más adelante**: con camino gratuito y vendido en euros |
| D. Suscripción semanal | Convierte bien (Meowdoku, Magic Tiles) | 3,99 €/semana equivale a unos 207 €/año. Mal visto en cuanto a transparencia y compras de las que el jugador se arrepiente | ❌ No se ofrece |

### 3.2 Club Cadencia: beneficios

| Beneficio | ¿Es pagar para avanzar? |
|---|---|
| **Cuerda ilimitada** | No: el jugador gratuito avanza igual, a otro ritmo, y tiene anuncios y esperas como alternativa |
| **Sin anuncios intersticiales** | No |
| **Pistas ilimitadas** | No: las pistas gratis siguen disponibles (3 al día más las de anuncio) |
| **Archivo completo de la Caída del Día** | No: es contenido extra, no la progresión principal |
| **Capítulos extra "Taller del Maestro"** (fuera de la historia principal) | No: contenido adicional |
| **Un estilo de ficha y un sonido exclusivos cada mes** (cosmético) | No |
| **Herramientas ampliadas del Taller** (tableros más grandes, más piezas) | No |

### 3.3 Precio [HIPÓTESIS justificada con el mercado]

**Referencias del App Store español** (Fase 2, dato oficial a 16/11/2026):

| Juego | Precio |
|---|---|
| NYT Games | 2,99 €/mes |
| Meowdoku | 8,99 €/mes · 39,99 €/año |
| Vita Mahjong | 22,99 €/año |
| Magic Tiles 3 | 9,99–16,99 €/mes · 42,99–49,99 €/año |
| Chess.com | 2,99–13,99 €/mes · 23,99–99,99 €/año |
| Roblox Premium | 5,99–22,99 €/mes |
| Quitar anuncios con pago único | 6,99–9,99 € (14 juegos) |

**Propuesta:**

| Producto | Precio | Justificación |
|---|---|---|
| **Club mensual** | **4,99 €** | Por debajo de la mediana del rango (2,99–9,99 €). En España el precio importa, y por encima de NYT Games hay más valor (cuerda ilimitada) |
| **Club anual** | **29,99 €** (equivale a 2,50 €/mes, un 50 % menos) | Dentro del rango de 22,99–49,99 €. Una buena oferta anual mejora la retención del suscriptor |
| **Prueba** | **7 días, solo en el plan anual** | Según RevenueCat, las pruebas más largas convierten mejor (42,5 % con 17–32 días frente a 25,5 % con 4 días o menos, en todas las categorías). **7 días es un equilibrio** para un juego. **Aviso dentro de la app 24 horas antes del cobro** (DFA: nada de "trampas de suscripción") |
| **Sin anuncios** (pago único) | **7,99 €** | En la media del mercado (6,99–9,99 €). Quita intersticiales, pero **no** da cuerda ilimitada: así protege el valor del Club |
| **Packs cosméticos** | **1,99–3,99 €** | Estilos de ficha y sonidos. Precio en euros, sin aleatoriedad |

Fuente de las pruebas: [RevenueCat, State of Subscription Apps 2026](https://www.revenuecat.com/state-of-subscription-apps-2026/). Sus datos de juegos son de pago; uso la cifra general como referencia.

**Otros mercados:** se usarán las **tablas de precios equivalentes de Apple y Google** (ajustadas por país). En EE. UU.: 4,99 $/mes y 29,99 $/año.

### 3.4 Comisiones y neto [DATO + HIPÓTESIS]

- **Apple Small Business Program**: **15 %** si se factura menos de 1 M$ y **hay que inscribirse**. Las suscripciones bajan al 15 % tras el primer año en cualquier caso.
- **Google Play**: **15 % efectivo** por debajo de 1 M$. La estructura está cambiando en 2026 y hay que confirmarla por región.
- **El IVA está incluido en el precio al consumidor** y lo ingresan las tiendas. En el modelo, el **neto ≈ precio × 0,85 / 1,12**, con un IVA medio mezclado como hipótesis.
- Fuentes: [RevenueCat, Small Business Program](https://www.revenuecat.com/blog/engineering/small-business-program) · [Ayuda de Google Play sobre comisiones](https://support.google.com/googleplay/android-developer/answer/112622?hl=en)

### 3.5 Conversión, retención de suscriptores y coste de adquisición

| Concepto | Valor [HIPÓTESIS] | Base |
|---|---|---|
| Conversión a suscripción (% de jugadores mensuales) | 0,5 % / **1 %** / 2 % (escenarios) | Alrededor del 1 % en Chess.com, sobre miembros registrados (Fase 2). En juegos, la conversión a prueba es más baja que en otras categorías (RevenueCat 2025) |
| Mezcla anual y mensual | 50 / 50 | Prudente |
| Compradores de pagos únicos al mes | 0,3 % / 0,6 % / 1 % de los jugadores mensuales | Prudente |
| Coste de adquisición | **0 € (orgánico)** | Sin presupuesto. La publicidad de pago no es rentable con este valor por jugador (sección 5.3) |

### 3.6 Dónde se ofrece el premium (con la skill **paywalls**, dentro del marco legal)

| Momento | Formato | Reglas |
|---|---|---|
| **Cuando se acaba la cuerda** | Pantalla con **4 opciones del mismo tamaño**: anuncio (+3), esperar (con tiempo visible), jugar gratis a otro modo, Club | **Rechazar no se presenta como un error** (Anexo I de la DFA). Nada de "¡solo hoy!" (LR-06) |
| **Ajustes y tienda** | Página informativa | Precio, renovación y cancelación **muy visibles** |
| **Tras completar un "Gran Tramo"** | Mención discreta del Club, una vez por capítulo | Nunca a pantalla completa ni de forma insistente (Anexo I: "insistir") |
| **Nunca** | Durante una partida, tras un fallo, o con mensajes del tipo "¡Compra ya!" | LR-07, LR-11 |

---

## 4. Analítica para validar el modelo (se prepara en la Fase 9)

Métricas de negocio, **agregadas y con seudónimo**:
- jugadores diarios y mensuales;
- retención D1, D7 y D30;
- impresiones por jugador diario, por formato;
- eCPM real (lo informa la red de anuncios);
- % que se queda sin cuerda y qué elige (anuncio, espera, modo gratis, Club);
- conversión a prueba y de prueba a pago;
- cancelaciones;
- ingreso por jugador diario (ARPDAU) e ingreso por pagador (ARPPU).

Junto con las **métricas de bienestar** de la Fase 3 (sección 6).

---

## 5. Modelo financiero

Script reproducible: [modelo_financiero.py](modelo_financiero.py). Resultados: [resultados.md](resultados.md) y [resultados.csv](resultados.csv).

### 5.1 Hipótesis por escenario

| Variable | Conservador | Intermedio | Optimista | Referencia |
|---|---|---|---|---|
| Jugadores diarios / mensuales (DAU/MAU) | 0,15 | 0,20 | 0,25 | Hipótesis del sector |
| Retención D1 / D7 / D30 | 30 / 8 / 3 % | 38 / 14 / 6 % | 45 / 20 / 10 % | GameAnalytics 2025: D1 mediana 22 % y 40 % en el top 10 %. Puzles: unos 32 / 12 / 5 % (Mistplay). Block Blast: 51 / 32 / 21 % (Fase 1) |
| Intersticiales por jugador diario (no premium) | 2,0 | 3,0 | 4,0 | Con nuestros límites (1 cada 3 niveles y 3 minutos) |
| Recompensados por jugador diario | 1,0 | 1,5 | 2,0 | Diseño de la cuerda y las pistas |
| eCPM intersticial (mezcla de países) | 4 $ | 6 $ | 8 $ | EE. UU.: unos 10 $. Europa y otros países, menos (Appodeal 2025, Playio 2026) |
| eCPM recompensado (mezcla de países) | 6 $ | 9 $ | 12 $ | EE. UU.: 13–20 $. Europa: unos 5–9 $ (Mistplay, Playio) |
| Suscriptores (% de jugadores mensuales) | 0,5 % | 1,0 % | 2,0 % | Sección 3.5 |
| Pagos únicos (% de jugadores mensuales al mes, 4 € de media) | 0,3 % | 0,6 % | 1,0 % | Hipótesis |
| Tipo de cambio | 1 $ = 0,90 € | | | Hipótesis |

**Costes mensuales** [HIPÓTESIS, a confirmar con un gestor]:

| Concepto | Coste |
|---|---|
| Apple (99 $/año) + Google (25 $, pago único), prorrateado | Unos 9 €/mes |
| **Servidores** | **0 €** (sin backend) |
| Herramientas | 0 € (planes gratuitos) |
| Autónomo | 80 €/mes (tarifa plana) por debajo de 10.000 DAU; 300 €/mes por encima, como hipótesis |
| Gestoría | 50 €/mes |
| Servicios de terceros que dejen de ser gratis al crecer | 0–150 €/mes |
| **IRPF** | **No incluido**: el beneficio es antes de impuestos sobre la renta |

### 5.2 Resultados (€ al mes)

| Escenario | DAU | MAU | Suscriptores | Impresiones/mes | Anuncios €/mes | Suscripción €/mes | Compras €/mes | **Ingresos €/mes** | Costes €/mes | **Beneficio €/mes** | ARPDAU € | ARPPU €/mes | LTV 180 d € | % anuncios |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Conservador | 1.000 | 6.667 | 33 | 88.200 | 370 | 95 | 61 | **526** | 139 | **387** | 0,018 | 2,91 | 0,09 | 70,4 |
| Conservador | 10.000 | 66.667 | 333 | 882.000 | 3.704 | 947 | 607 | **5.259** | 359 | **4.900** | 0,018 | 2,91 | 0,09 | 70,4 |
| Conservador | 50.000 | 333.333 | 1.667 | 4.410.000 | 18.522 | 4.736 | 3.036 | **26.294** | 409 | **25.885** | 0,018 | 2,91 | 0,09 | 70,4 |
| Conservador | 100.000 | 666.667 | 3.333 | 8.820.000 | 37.044 | 9.473 | 6.071 | **52.588** | 509 | **52.079** | 0,018 | 2,91 | 0,09 | 70,4 |
| Intermedio | 1.000 | 5.000 | 50 | 130.950 | 825 | 142 | 91 | **1.058** | 139 | **919** | 0,035 | 2,91 | 0,33 | 78,0 |
| Intermedio | 10.000 | 50.000 | 500 | 1.309.500 | 8.250 | 1.421 | 911 | **10.581** | 359 | **10.222** | 0,035 | 2,91 | 0,33 | 78,0 |
| Intermedio | 50.000 | 250.000 | 2.500 | 6.547.500 | 41.249 | 7.105 | 4.554 | **52.907** | 409 | **52.498** | 0,035 | 2,91 | 0,33 | 78,0 |
| Intermedio | 100.000 | 500.000 | 5.000 | 13.095.000 | 82.498 | 14.209 | 9.107 | **105.815** | 509 | **105.306** | 0,035 | 2,91 | 0,33 | 78,0 |
| Optimista | 1.000 | 4.000 | 80 | 171.360 | 1.439 | 227 | 121 | **1.788** | 139 | **1.649** | 0,060 | 2,91 | 0,90 | 80,5 |
| Optimista | 10.000 | 40.000 | 800 | 1.713.600 | 14.394 | 2.273 | 1.214 | **17.882** | 359 | **17.523** | 0,060 | 2,91 | 0,90 | 80,5 |
| Optimista | 50.000 | 200.000 | 4.000 | 8.568.000 | 71.971 | 11.367 | 6.071 | **89.410** | 409 | **89.001** | 0,060 | 2,91 | 0,90 | 80,5 |
| Optimista | 100.000 | 400.000 | 8.000 | 17.136.000 | 143.942 | 22.735 | 12.143 | **178.820** | 509 | **178.311** | 0,060 | 2,91 | 0,90 | 80,5 |

### 5.3 Cómo interpretarlo

1. **Comparación con la realidad:** Block Blast ingresa unos **0,012 $ por jugador diario** solo con anuncios (127 M$ en 5 meses con unos 70 M de jugadores diarios, Fase 1), con mucho tráfico de países con eCPM bajo. **Nuestro escenario intermedio (0,035 €)** supone una mezcla de países más occidental, anuncios recompensados y suscripción.
   - **Si nuestra audiencia se parece a la de Block Blast, estaremos más cerca del escenario conservador.**
2. **La mayoría de los ingresos vienen de los anuncios (70–80 %)**, aunque la suscripción sea el producto premium. **Expulsar jugadores para forzar el pago reduciría los ingresos** (ver la sección 1.3).
3. **El valor de vida a 180 días es de 0,09 a 0,90 € por jugador.** El coste de adquisición en Android del subgénero de ordenar era de unos **0,50 $** en 2025 (Fase 2). **Solo el escenario optimista recuperaría ligeramente lo invertido en comprar jugadores**, así que **el crecimiento orgánico no es una preferencia, es una necesidad**.
4. **El umbral de rentabilidad es muy bajo** (unos 140–360 € al mes de costes): **con unos pocos cientos de jugadores diarios ya hay beneficio.**
5. **Lo que más mueve los resultados**, en este orden: **jugadores diarios** (marketing y viralidad) > **retención** > **eCPM** (mezcla de países) > **conversión a suscripción**.

### 5.4 Advertencias del modelo

- Es un modelo de **estado estable**: no recoge el crecimiento mes a mes ni la estacionalidad (por ejemplo, el eCPM sube en el cuarto trimestre).
- **No incluye el IRPF** ni posibles retenciones fiscales de EE. UU. (que se evitan con el formulario W-8BEN).
- Si el juego se considera dirigido a menores, los anuncios para menores tienen un **eCPM más bajo**.
- **Todas las entradas son hipótesis hasta tener datos reales.** El script permite recalcular en segundos.

---

## 6. Decisiones tomadas

1. **Energía "Cuerda"**: 5 como máximo, 1 cada 30 minutos, solo para niveles nuevos de la campaña, con +3 por anuncio (máximo 10 al día), sin consumo en los primeros 15 niveles. **Se calibrará con pruebas A/B dentro de un rango ético**, igual para todos.
2. **Club Cadencia** a 4,99 €/mes o 29,99 €/año, con prueba de 7 días solo en el anual. **Sin anuncios** a 7,99 €. Cosméticos a 1,99–3,99 €.
3. **AdMob** (plugin MIT de Poing Studios) para la versión 1.0. **AppLovin MAX** (plugin oficial MIT) a partir de unos 10.000 jugadores diarios.
4. **Sin banners, sin suscripción semanal y sin moneda virtual de pago.**
5. **Crecimiento 100 % orgánico** al principio. La publicidad de pago solo si el valor de vida real supera al coste de adquisición.

## 7. Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Retención real inferior a la hipótesis | Alto | Prioridad de diseño en la retención (meta-juego, reto diario, taller). Ajuste continuo |
| La cuerda resulta frustrante | Medio | Pruebas A/B. Métricas de abandono justo al quedarse sin cuerda |
| Conversión al Club inferior al 0,5 % | Medio | El modelo aguanta: los anuncios son el 70–80 % de los ingresos |
| La DFA endurece las reglas sobre la energía | Medio | Diseño ya defendible (camino gratuito real y modos sin límite). Revisión trimestral |
| Integración de plugins (AdMob, compras) con fallos en Godot | Medio | Prototipo técnico temprano (entregas 9–11) |
| **Licencia del plugin de compras godot-iap** (las fuentes indican MIT o AGPLv3) | Medio | **Verificar el archivo LICENSE.** Alternativa en Android: el plugin oficial GodotGooglePlayBilling. Para iOS hay que confirmar la alternativa en la Fase 8 |

## 8. Pendiente

- **Precio real en euros** del Apple Developer Program (aparece en moneda local al inscribirse).
- **Estructura de comisiones de Google 2026** por región.
- **Consulta fiscal** (alta en Hacienda, autónomos, operaciones intracomunitarias), **antes de monetizar**.
- **Precios equivalentes por país** en App Store Connect y Google Play Console.

## 9. Próximos pasos (sujetos a tu aprobación)

**Fase 6: identidad visual y dirección de arte de Cadencia.**
- Paleta, tipografías (con licencia OFL), estilo del juguete de madera, personajes (Tilde, Pío), escenarios (barrios), interfaz, animaciones (sobre todo **la caída**), partículas, sonido (los clics de las fichas y las campanas) y música (con licencias compatibles).
- Usaremos las skills **impeccable** y **ai-slop-design-auditor**, comprobando antes sus instrucciones.
- **Registro de recursos y licencias.**

---

## Fuentes principales de esta fase

**Plugins para Godot**
- [Plugin AdMob de Poing Studios (GitHub)](https://www.Github.com/poingstudios/godot-admob-plugin) · [Godot Asset Store](https://store.godotengine.org/asset/poingstudios/admob/)
- [AppLovin MAX para Godot (GitHub)](https://github.com/AppLovin/AppLovin-MAX-Godot) · [Documentación de integración](https://developers.applovin.com/en/max/godot/overview/integration)
- [godot-iap (compras integradas)](https://hyochan.github.io/godot-iap) · [Documentación de Godot: compras en Android](https://docs.godotengine.org/en/4.4/tutorials/platform/android/android_in_app_purchases.html)

**Comisiones de las tiendas**
- [RevenueCat, Small Business Program](https://www.revenuecat.com/blog/engineering/small-business-program)
- [Ayuda de Google Play sobre comisiones](https://support.google.com/googleplay/android-developer/answer/112622?hl=en)

**eCPM**
- [Appodeal, The Latest eCPM Report 2025](https://appodeal.com/wp-content/uploads/2025/03/Appodeal-The-Latest-eCPM-Report-2025.pdf)
- [Playio, eCPM de juegos móviles 2026](https://blog.playio.co/mobile-game-ecpm-benchmarks-2026)
- [TopOn, informe del primer semestre de 2025](https://mores.toponad.com/reports/TopOn%20Global%20Mobile%20Games%20Monetization%20Report%20_%202025%20H1.pdf)
- [Mistplay, eCPM](https://business.mistplay.com/resources/mobile-ads-ecpm)

**Retención**
- [GameAnalytics, Mobile Gaming Benchmarks 2025](https://investgame.net/wp-content/uploads/2025/02/2025-GameAnalytics-Mobile-Gaming-Benchmarks.pdf)
- [Playio, retención por género](https://blog.playio.co/retention-by-game-genre)

**Suscripciones**
- [RevenueCat, State of Subscription Apps 2026](https://www.revenuecat.com/state-of-subscription-apps-2026/) · [Edición 2025](https://revenuecat.com/state-of-subscription-apps-2025)

**Datos de mercado propios**
- Fases 1 y 2 de este proyecto (compras oficiales del App Store español, 16/11/2026)
