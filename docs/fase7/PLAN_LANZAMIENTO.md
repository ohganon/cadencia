# Plan de lanzamiento (0 €)

**Fecha:** 17/11/2026
**Estado:** propuesta. Las fechas dependen del desarrollo (Fase 8).

> **[OFICIAL]** = documentado por Apple o Google, con enlace. **[HIPÓTESIS]** = propuesta nuestra que hay que validar con datos.

---

## 1. Etapas y puertas de paso

Cada etapa tiene una **puerta**: no se pasa a la siguiente sin cumplirla. Las cifras de retención son las del modelo financiero (Fase 5): el escenario **conservador es el mínimo para seguir** y el **intermedio, la meta**.

| Etapa | Qué es | Puerta para pasar a la siguiente |
|---|---|---|
| **0. Prototipo** (entrega 1 de la Fase 8) | Mecánica jugable en móvil: dibujar, tumbar y la campana doble | 10–15 personas ajenas al equipo lo prueban. **Al menos la mitad pide «otro nivel» sin que se lo digamos** [HIPÓTESIS]. Dibujar no frustra en pantallas pequeñas |
| **1. Prueba cerrada** | Unos 50 niveles, sin monetización. TestFlight en iOS y prueba cerrada en Google Play | **[OFICIAL]** Las cuentas personales nuevas de Google Play necesitan **al menos 12 probadores durante 14 días seguidos** antes de publicar en producción (ver marco legal). Puerta propia: ningún fallo bloqueante y la cadena siempre se comporta igual |
| **2. Lanzamiento suave** | Versión completa con anuncios y Club, **solo en unos pocos países** durante 4–6 semanas | Retención igual o mejor que el escenario conservador: **D1 ≥ 30 %, D7 ≥ 8 %, D30 ≥ 3 %**. En Android, cierres por fallo **por debajo del 1,09 %** y bloqueos (ANR) **por debajo del 0,47 %**, los umbrales a partir de los cuales Google reduce la visibilidad |
| **3. Lanzamiento global** | España y EE. UU. a la vez, más el resto de países | — |

**Países del lanzamiento suave [HIPÓTESIS]:**
- **Canadá, Australia y Nueva Zelanda**: su comportamiento se parece al de EE. UU. y lanzar allí no gasta la novedad en los mercados principales.
- **Un país hispanohablante pequeño** (por ejemplo, Uruguay o Costa Rica) para probar los textos en español.

**Si la puerta 2 no se cumple:** se itera (primeros niveles, cuerda, tutorial) y se repite la medición. **No se lanza en global para «ver si cambia».** El lanzamiento global solo ocurre una vez, y la novedad no vuelve.

---

## 2. Herramientas gratuitas de las tiendas

| Herramienta | Qué hace | Cuándo | Fuente |
|---|---|---|---|
| **Prerregistro en Google Play** | La gente se apunta desde la ficha. El día del lanzamiento recibe un aviso y, en dispositivos compatibles, el juego se instala solo. **Máximo 90 días** antes del lanzamiento en producción | Abrirlo con el inicio del pilar 4 de TikTok | **[OFICIAL]** [Ayuda de Play Console](https://support.google.com/googleplay/android-developer/answer/9859047?hl=en) |
| **Recompensa de prerregistro** | Un regalo para quien se apuntó. Debe ser un producto creado solo para eso y **no se puede editar ni borrar después**. Si no se entrega, Google puede suspender la app | **Recomendación:** un estilo de ficha exclusivo, nunca moneda ni ventajas de juego | **[OFICIAL]** misma ayuda |
| **Reserva anticipada en App Store** | Las apps gratuitas también pueden reservarse; el día del lanzamiento se descargan solas. Las compras integradas no se reservan, pero se pueden configurar antes | En paralelo al prerregistro. **El plazo máximo se consulta en la ayuda en ese momento** | **[OFICIAL]** [Ayuda de App Store Connect](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/publish-for-pre-order/) |
| **Nominación a destacados de Apple** | Se propone el juego a los editores desde App Store Connect. Apple pide **al menos 3 semanas** de antelación y sugiere **hasta 3 meses** para tener más opciones | **3 meses antes** del lanzamiento global | **[OFICIAL]** [Nominar tu app](https://developer.apple.com/help/app-store-connect/manage-featuring-nominations/nominate-your-app-for-featuring/), [Cómo destacar](https://developer.apple.com/app-store/getting-featured/) |
| **Contenido promocional de Google Play** | Eventos y ofertas que aparecen en la tienda. Se envía con unos 14 días de antelación para optar a destacados | Eventos de temporada | Guía ASO del proyecto (references de la skill **aso**) |
| **Festivales de Google Play** | En ediciones anteriores, para estudios pequeños con el juego ya lanzado | **No he encontrado convocatoria europea en 2026**; revisarlo tras el lanzamiento | Búsqueda del 17/11/2026 |

**Por qué tenemos opciones con los editores de Apple [HIPÓTESIS]:**
- su curación premia la calidad y el diseño;
- un juego limpio (sin moneda de pago, sin trucos y accesible) y con identidad propia encaja con lo que suelen destacar;
- en la Fase 2, 4 de los 15 juegos mejor valorados eran de monetización limpia.

---

## 3. Prensa y comunidades

**Kit de prensa:** [KIT_DE_PRENSA.md](KIT_DE_PRENSA.md). Se publica como página sencilla cuando haya capturas reales.

**A quién escribir** (siempre con un correo corto, personal, con un GIF y el enlace al kit; nunca envíos masivos):

| Tipo | Ejemplos | Cuándo |
|---|---|---|
| Prensa de juegos móviles en inglés | Pocket Gamer, TouchArcade, Gamezebo | 2–3 semanas antes del lanzamiento global, con código de TestFlight si lo piden |
| Prensa en español | Medios de videojuegos con sección de móviles | Igual. **Hay que confirmar que cada medio sigue cubriendo juegos móviles** antes de escribirle |
| Comunidades | r/godot (contar el desarrollo), r/indiegaming, r/puzzles, foros de puzles | **Siempre leer las normas de autopromoción de cada comunidad.** Aportar antes de pedir: el diario de desarrollo encaja mejor que un anuncio |
| Creadores de TikTok y YouTube de puzles | Cuentas pequeñas y medianas de juegos móviles | Tras el lanzamiento suave. **Si hay cualquier contraprestación** (un código del Club, por ejemplo), **deben marcarlo como colaboración** |

---

## 4. Calendario orientativo

Toma como referencia el día L del lanzamiento global.

| Cuándo | Qué |
|---|---|
| Desde ya | Reservar el nombre en redes (cuando se decida el nombre). Empezar el plan de TikTok con el prototipo HTML rotulado como prototipo |
| L − 6 meses | Prueba cerrada (12 probadores × 14 días en Google Play) |
| L − 4 meses | Lanzamiento suave en los países elegidos |
| L − 3 meses | Nominación a destacados de Apple. Prerregistro de Google Play (máximo 90 días) y reserva en App Store |
| L − 3 semanas | Kit de prensa y correos a medios. Vídeo de tienda final |
| L | Lanzamiento global en España y EE. UU. Vídeo de lanzamiento en las tres redes |
| L + 1 semana | Revisar las métricas, las opiniones en tiendas y responder a todas las negativas con calma y soluciones |
| L + 1 mes | Primer evento dentro de la app (ASO_FICHAS.md, sección 2.4) |

---

## 5. Valoraciones en tiendas

- Se pide la valoración **solo tras un momento bueno**: superar un nivel difícil o completar un capítulo. Nunca tras un fallo ni al abrir el juego.
- **iOS:** con el sistema oficial de Apple, que limita las peticiones a **3 al año**.
- **Android:** con la API oficial de valoraciones dentro de la app.
- **Nunca se regalan recompensas a cambio de valorar**: lo prohíben las dos tiendas y es una práctica engañosa.
