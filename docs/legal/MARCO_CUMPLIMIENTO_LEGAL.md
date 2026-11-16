# Marco de cumplimiento legal y ético del proyecto

**Versión:** 1.0, 16/11/2026
**Aplicación:** obligatoria en todas las fases, con prioridad sobre cualquier decisión de diseño o monetización.

> **Aviso:** este documento es un análisis de riesgos hecho con fuentes públicas. **No es asesoramiento jurídico ni fiscal.** Antes de activar la monetización (Fase 5 y entregas 9–11) conviene una revisión puntual por un profesional (abogado o gestor). Ver la sección 7.

---

## 1. Filosofía: diseñar ya para la norma más estricta previsible

El juego estará en el mercado varios años. La regulación europea se está endureciendo justo en lo que nos afecta: monedas virtuales, menores, *dark patterns*, diseño adictivo y suscripciones. Si cumplimos **desde ahora** con la propuesta más exigente, evitamos rehacer sistemas más adelante y convertimos el cumplimiento en un argumento de marca ("un juego que te respeta").

**Regla de oro:** el jugador debe engancharse porque el juego es **divertido, satisfactorio y le hace progresar**. Nunca por miedo a perder algo, presión de tiempo artificial, engaño o manipulación individualizada.

---

## 2. Normas aplicables (estado a 16/11/2026)

### 2.1 Vigentes

| Norma | Qué nos exige en la práctica |
|---|---|
| **RGPD** y **LOPDGDD** (España) | Recoger los mínimos datos posibles, con una base legal para cada uso y una política de privacidad clara. **En España, un menor de 14 años no puede consentir por sí mismo** el tratamiento de sus datos (LOPDGDD, art. 7) |
| **LSSI, art. 22.2**, y directiva ePrivacy | **Consentimiento previo** para identificadores publicitarios y seguimiento. Para servir anuncios de Google en el Espacio Económico Europeo y Reino Unido hace falta una **plataforma de consentimiento certificada por Google (IAB TCF)**. *Verificar en la Fase 5* |
| **Apple ATT** | Pedir permiso antes de usar el identificador publicitario de iOS (IDFA). Si el jugador lo rechaza, seguimos con anuncios no personalizados |
| **Directiva 2005/29/CE de prácticas comerciales desleales** (traspuesta en España en la Ley 3/1991 y en la ley de consumidores) | Prohíbe las prácticas engañosas y agresivas. Su **Anexo I, punto 28, prohíbe incitar directamente a los niños a comprar**. Ningún mensaje del tipo "¡Compra ya!" en un juego que puedan usar menores |
| **Ley de consumidores española (TRLGDCU)** | Precio total claro. **Derecho de desistimiento** en contenido digital: solo se pierde si el usuario lo acepta expresamente al comprar (las tiendas gestionan este flujo) |
| **Principios clave de la red CPC sobre monedas virtuales** (21/03/2025) | Son orientativos, pero las autoridades los usan para actuar contra empresas (King, Supercell y otras ya han sido objeto de acciones coordinadas). Exigen **mostrar el precio en euros**, no mezclar monedas para ocultar el coste y no presionar |
| **Directrices de Apple** (3.1.1 compras integradas, 3.1.2 suscripciones, 4.1 imitaciones, 5.1 privacidad) | Bienes digitales solo mediante compras integradas. La suscripción debe aportar **valor continuo**. **Prohibido clonar** otros juegos. Etiquetas de privacidad veraces |
| **Políticas de Google Play** (Families, Data Safety, anuncios) | Formulario de seguridad de datos veraz. Si el juego atrae a niños, se aplica la política Families (solo redes de anuncios certificadas). Los anuncios recompensados deben ser opcionales |
| **Políticas de AdMob y AppLovin** | Nada de clics incentivados, anuncios que imiten la interfaz ni anuncios a pantalla completa inesperados |
| **DSA, condición de comerciante en la UE** | Apple exige declararla. Si te registras **como particular, tu dirección, teléfono y correo se publican en la tienda europea**. Se puede usar un apartado de correos |
| **Google Play, cuenta personal nueva** | **12 probadores** inscritos durante **14 días seguidos** en una prueba cerrada antes de poder publicar |
| **COPPA** (EE. UU.) | Si el juego se dirige a menores de 13 años o tiene "conocimiento real" de que los hay, se aplican normas estrictas sobre datos y publicidad |
| **Acta Europea de Accesibilidad** (jun. 2025) | Las microempresas están exentas en servicios, pero aplicaremos buenas prácticas de accesibilidad igualmente |

### 2.2 En tramitación, para las que diseñamos desde ya

**Propuesta de Digital Fairness Act (DFA), presentada por la Comisión Europea el 11/11/2026.** Todavía tiene que aprobarla el Parlamento y el Consejo, y puede cambiar. Lo que más nos afecta (según el análisis de Lewis Silkin del 12/11/2026):

| Artículo | Contenido | Impacto en nuestro juego |
|---|---|---|
| Art. 10 y Anexo I | Prohibición general de *dark patterns* y lista negra: falsa escasez, opciones preseleccionadas, presentar como "error" la opción de rechazar, volver a preguntar algo ya decidido, que darse de baja sea más difícil que darse de alta, precio o renovación poco visibles, notificaciones falsas de "algo requiere tu atención"… | Ninguna de esas técnicas en la interfaz |
| Art. 14 y considerando 62 | Hay que mostrar el **valor en dinero** de todo lo que se compre con moneda virtual de pago. **En juegos dirigidos a menores, la moneda virtual de pago debe estar desactivada por defecto** y solo se activa con permiso de un padre o tutor. Un juego se considera "dirigido a menores" si su calificación **PEGI es inferior a 18** | Un puzle será PEGI 3, **así que estaremos dentro** |
| Art. 15 | **Cajas de botín y recompensas variables de pago prohibidas en juegos dirigidos a menores** | No las tendremos |
| Art. 16 y considerando 65 | **Mecánicas de pagar para ganar o pagar para avanzar prohibidas** en juegos dirigidos a menores. Pone como ejemplos las **"barreras de dificultad artificiales"** y una progresión gratuita tan lenta que resulta "ilusoria" | **Afecta directamente al diseño de energía, vidas y suscripción (Fase 5)** |
| Art. 17 | **Derecho a desactivar** las funciones que fomentan un uso compulsivo: notificaciones no provocadas por la actividad del usuario, incentivos para jugar a horas fijas **con penalización o pérdida si no se juega** (rachas que se pierden, por ejemplo), y otras | Necesitamos un **panel de "Juego responsable"** con interruptores |
| Varios | Restricciones a la publicidad y los precios personalizados dirigidos a menores. Cancelación sencilla y fin de las "trampas" de pruebas gratuitas | Sin ofertas personalizadas por perfil. Suscripción transparente |
| Sanciones | Hasta el **6 % de la facturación mundial** en casos transfronterizos de gran escala | — |

**España, cajas de botín:** no hay ley vigente. Los anteproyectos de 2022 y 2024 decayeron y la reforma de la Ley del Juego sigue en tramitación. No nos afecta porque **no tendremos mecánicas aleatorias de pago**.

---

## 3. Decisiones vinculantes para el proyecto

### 3.1 Líneas rojas: nunca se implementarán

| # | Práctica prohibida en el proyecto | Motivo |
|---|---|---|
| LR-01 | Ajustar la dificultad, las piezas o la probabilidad de ganar según el eCPM, el valor publicitario, el historial de compras o cualquier dato económico del jugador | Riesgo de práctica desleal o engañosa; ética |
| LR-02 | Repartos imposibles, tableros sin solución o derrotas provocadas | Engaño al jugador |
| LR-03 | Cajas de botín o recompensas aleatorias **de pago** | DFA art. 15 |
| LR-04 | Moneda virtual **de pago**. Se vende en euros, con precio claro y directo | DFA art. 14 y principios CPC; simplifica el cumplimiento |
| LR-05 | Barreras de dificultad artificiales para empujar al pago (pagar para avanzar) | DFA art. 16 |
| LR-06 | Falsa escasez, cuentas atrás falsas u ofertas de "solo ahora" que se repiten | Anexo I de la DFA y Directiva 2005/29/CE |
| LR-07 | Incitar directamente a comprar ("¡Compra ya!") | Directiva 2005/29/CE, Anexo I, punto 28 |
| LR-08 | Ofertas y precios personalizados según el perfil del jugador | DFA y riesgo con menores |
| LR-09 | Rachas o eventos que **castiguen** dejar de jugar (perder lo acumulado) | DFA art. 17 |
| LR-10 | Notificaciones que no responden a algo real del jugador ("¡te echamos de menos!", falsas alertas) | DFA art. 17 y Anexo I |
| LR-11 | Anuncios a pantalla completa en mitad de una partida, anuncios disfrazados de botones del juego o anuncios que no se pueden cerrar | Políticas de AdMob y Apple; experiencia |
| LR-12 | Prueba gratuita de suscripción que se convierte en pago sin aviso claro, o baja difícil | DFA, consumidores y tiendas |
| LR-13 | Copiar el nombre, el arte, los personajes, los niveles o la marca de otro juego | Propiedad intelectual y directriz 4.1 de Apple |
| LR-14 | Usar recursos (gráficos, música, sonidos, fuentes) sin licencia comercial verificada y registrada | Propiedad intelectual |
| LR-15 | Recoger datos personales que no hagan falta, o usar analítica sin base legal o consentimiento | RGPD |

### 3.2 Técnicas de enganche permitidas (en versión segura)

| Técnica | Versión que usaremos |
|---|---|
| Progresión y niveles | Siempre se puede superar gratis. La dificultad se ajusta **por nivel y para todos** con datos agregados |
| Rachas diarias | **Sin castigo**: recompensan la constancia, pero perder la racha no quita nada de lo conseguido. Incluyen comodines gratis y se pueden desactivar |
| Eventos temporales | Con fechas reales y avisadas. Los cosméticos de eventos pasados pueden volver más adelante, para no crear miedo a perdérselos |
| Recompensa variable | Solo **gratuita** y dentro del juego (combos, sorpresas al jugar). Nunca a cambio de dinero |
| Energía o intentos | Generosos. **No bloquean la progresión de forma "ilusoria"**. Ver la nota de la Fase 5 más abajo |
| Anuncios recompensados | 100 % opcionales. Lo que se obtiene se indica antes del anuncio. Si no se ve, no hay castigo |
| Suscripción | De comodidad: sin anuncios, extras cosméticos y más margen. Precio y renovación muy visibles. Baja gestionada por la propia tienda |
| Notificaciones | Desactivadas por defecto o pedidas con permiso explícito. Solo avisan de algo real ("tus intentos se han recargado"). Se pueden apagar desde el juego |
| Récords y retos entre amigos | Comparación positiva y asíncrona. Sin presión para gastar |
| **Panel de "Juego responsable"** | Interruptores por función (rachas, notificaciones, recordatorios), avisos opcionales de tiempo jugado y resumen de gasto |

### 3.3 Nota para la Fase 5: conflicto entre el encargo original y la DFA

El encargo original pide **un sistema de energía o intentos que limite el ritmo, con anuncios recompensados o suscripción para saltárselo**. Si la DFA se aprueba como está redactada y el juego tiene PEGI 3, **un límite que solo se supera pagando podría considerarse "pagar para avanzar"**.

Propuesta preliminar, que se decidirá en la Fase 5:
- El límite **frena, pero no bloquea**: recarga rápida, siempre hay un modo de juego gratuito sin límite y el anuncio recompensado es una opción gratuita.
- La suscripción vende **comodidad y cosmética, no avance**.
- Así el modelo queda en un terreno defendible tanto con la ley actual como con la futura.

---

## 4. Privacidad y datos (MVP sin servidor propio)

- **Sin cuentas de usuario en el MVP.** Así evitamos la obligación de borrado de cuenta y reducimos datos.
- La partida se guarda en el dispositivo. La nube nativa (iCloud o Google Play Games) es opcional.
- Analítica **mínima y con seudónimo**. La herramienta concreta se elegirá en la Fase 8, comprobando antes su precio y sus condiciones.
- Política de privacidad propia y clara, en español e inglés.
- Etiquetas de privacidad de Apple y formulario de seguridad de datos de Google **coherentes con lo que hagan realmente los SDK**, incluidos los de anuncios.
- **Clasificación por edad** con el cuestionario IARC, que es gratuito. Público general, **sin diseño ni marketing dirigido a niños**. Los SDK de anuncios se configuran para tratar como menores a quien corresponda.

---

## 5. Propiedad intelectual

- Concepto, nombre, personajes y arte **originales**. Antes de fijar el nombre:
  - búsqueda de marcas en **EUIPO TMview** y **OEPM** (gratis);
  - búsqueda en las tiendas de apps.
- Godot es MIT: hay que **incluir su aviso de licencia** en los créditos o la sección legal del juego.
- **Registro de recursos** (`docs/legal/REGISTRO_ASSETS.md`, se creará en la Fase 6): por cada recurso, su origen, autor, licencia y enlace, y si exige atribución. Se priorizan CC0, OFL (fuentes) y licencias que permitan uso comercial.
- **Recursos generados con IA:** se usarán con cuidado. Hay que revisar las condiciones de la herramienta y tener en cuenta que en muchos países **no se pueden registrar con derechos de autor**. Se decidirá en la Fase 6.

---

## 6. Temas fiscales y administrativos en España ("líos de otro tipo")

> Esto sí exige confirmación con un gestor antes de cobrar el primer euro.

- **Cobrar de Apple, Google o redes de anuncios es una actividad económica.** Normalmente implica:
  - **darse de alta en Hacienda** (modelo 036/037, epígrafe del IAE);
  - y, si hay **habitualidad**, en el régimen de autónomos (RETA). La habitualidad es un criterio discutible que debe valorar un profesional.
- **IVA:** en las ventas a consumidores, las tiendas actúan como vendedor a efectos de IVA. Pero tus cobros de **Apple Distribution International** y **Google Ireland** suelen ser operaciones entre empresas de la UE. Eso implica normalmente el **alta en el Registro de Operadores Intracomunitarios (ROI)** y declaraciones informativas (modelo 349).
- **Formulario W-8BEN** en las tiendas o redes estadounidenses, para aplicar el convenio entre España y EE. UU. y evitar retenciones de más.
- **Recomendación:** hacer la consulta antes de publicar con monetización. Hay orientación gratuita en los Puntos de Atención al Emprendedor (PAE) y algunas Cámaras de Comercio. Un gestor cobra por la consulta: es un coste a presupuestar que no he cuantificado.

---

## 7. Puntos de control legal en el calendario del proyecto

| Momento | Comprobación |
|---|---|
| Fase 4 (concepto) | Originalidad frente a la directriz 4.1. Búsqueda de marca del nombre provisional |
| Fase 5 (monetización) | Comprobar cada mecanismo contra las líneas rojas y la DFA. Diseño del panel de "Juego responsable" |
| Fase 6 (arte) | Registro de recursos y licencias |
| Fase 8 (técnica) | Selección de SDK: privacidad, plataforma de consentimiento, menores, coste |
| Antes de publicar | Política de privacidad, términos, etiquetas de privacidad, IARC, condición de comerciante, prueba de 14 días en Google Play, **consulta fiscal** |
| Después de publicar | Seguir la tramitación de la DFA y de la ley española del juego. Revisión trimestral de este documento |

---

## Fuentes

- Lewis Silkin, *What the Digital Fairness Act means for video games* (12/11/2026) — [enlace](https://www.lewissilkin.com/insights/2026/11/12/come-on-now-play-fair-what-the-digital-fairness-act-means-for-video-games-102o9e6)
- Comisión Europea, texto de la propuesta de DFA — [PDF](https://commission.europa.eu/document/download/0575d59f-554f-4a9e-b54b-e6b717175809_en?filename=Proposal+for+a+Digital+Fairness+Act.pdf) *(pendiente de leer íntegro; los detalles proceden de análisis secundarios)*
- Principios clave de la red CPC sobre monedas virtuales (21/03/2025) — [Linklaters](https://techinsights.linklaters.com/post/102k6t4/game-changer-eu-introduces-consumer-protection-guidance-for-in-game-virtual-curr) · [Bird & Bird](https://twobirds.com/en/insights/2025/european-move-towards-protecting-users-from-harmful-practices-in-video-games-eu-consumer-protection) · [Comisión Europea](https://commission.europa.eu/topics/consumers/consumer-rights-and-complaints/enforcement-consumer-protection/coordinated-actions/social-media-online-games-and-search-engines%5Fen)
- Ministerio de Consumo, campaña sobre cajas de botín (oct. 2025) — [enlace](https://www.dsca.gob.es/es/comunicacion/notas-prensa/consumo-lanza-campana-advertir-peligros-cajas-botin-videojuegos)
- Apple, cumplimiento de la DSA (condición de comerciante) — [App Store Connect Help](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-compliance-information)
- Google Play, requisito de pruebas para cuentas personales — [Ayuda de Google](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)
