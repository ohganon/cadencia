# DOCUMENTO MAESTRO — Proyecto de videojuego móvil · Dingfall

**Última actualización:** 17/11/2026
**Fase actual:** Fases 1–7 **aprobadas** (6 y 7 el 17/11/2026). **Fase 8 (arquitectura y desarrollo) en curso.**

> **Requisito transversal del cliente (16/11/2026):** mantener a los usuarios enganchados **sin asumir riesgos legales ni de otro tipo**. Es de obligado cumplimiento: [legal/MARCO_CUMPLIMIENTO_LEGAL.md](legal/MARCO_CUMPLIMIENTO_LEGAL.md) (líneas rojas LR-01 a LR-15).

---

## 1. Visión y restricciones

- **Objetivo:** un juego móvil original, gratuito, comercializable y con alta retención basada en diversión, satisfacción, progresión y motivación, nunca en manipulación.
- **Presupuesto:** 0 € de desarrollo. Solo se contemplan los gastos de publicación: Apple Developer Program (99 $/año) y Google Play (25 $, pago único). *Pendiente de verificar los precios vigentes en la Fase 8.*
- **Tecnología preferente:** Godot (licencia MIT). Herramientas de código abierto. Recursos gráficos y de audio con licencia comercial compatible. Sin backend propio en el MVP.
- **Adquisición de usuarios:** orgánica (redes sociales). Sin campañas pagadas al inicio.
- **Método de trabajo:** una fase cada vez. No se avanza sin aprobación explícita.

## 2. Principios de diseño (decisiones vigentes)

| ID | Principio | Origen |
|---|---|---|
| P-01 | La dificultad **nunca** dependerá del eCPM, del valor publicitario, del historial de compras ni de ningún dato económico del jugador | Instrucción del cliente y hallazgos de la Fase 1 (Block Blast) |
| P-02 | Aleatoriedad honesta: todo tablero o mano generada tiene al menos una solución | Fase 1 |
| P-03 | El equilibrio de dificultad se hace por nivel y para todos los jugadores, con datos agregados (tasa de superación, tiempo hasta abandonar, tiempo hasta superar). Los niveles con abandono anómalo se rediseñan | Fase 1 (método de King, GDC 2024) |
| P-04 | Los niveles difíciles deben ser cortos. Se evitan los niveles de lógica pura con solución única | Fase 1 (datos de King) |
| P-05 | Las ayudas para la retención (tras varias derrotas seguidas) solo pueden **facilitar**, nunca castigar | Fase 1 |
| P-06 | El modelo económico no puede depender de la adquisición pagada a gran escala | Fase 1 (caso Block Blast) |
| P-07 | Cumplimiento legal desde el diseño, tomando como referencia la norma más estricta previsible (propuesta de DFA de la UE, 11/11/2026) | Petición del cliente |
| P-08 | Sin moneda virtual de pago, sin cajas de botín, sin pagar para avanzar. Se vende en euros con precio claro | Marco legal (LR-03 a LR-05) |
| P-09 | Panel de "Juego responsable" con interruptores para rachas, notificaciones y recordatorios. Las rachas nunca castigan | DFA art. 17 |
| P-10 | La diversión intrínseca va antes que las recompensas | Fase 3: SDT; Deci et al. (1999) |
| P-11 | Profundidad descubrible: cada mecánica tiene una técnica avanzada que se puede dominar | Fase 3 |
| P-12 | Retención positiva (curiosidad, reto, progreso), nunca por miedo a perder | Fase 3; DFA art. 17 |
| P-13 | Punto de cierre natural en cada sesión | Fase 3; Lally et al. (2010) |
| P-14 | Aleatoriedad gratuita y honesta, siempre con solución | Fase 3; Zendle y Cairns (2018) |
| P-15 | Lo social pequeño, relativo y desactivable | Fase 3; Hanus y Fox (2015) |
| P-16 | Modelo de motivación en tres bucles: partida (1–3 min), día (5–15 min) y largo plazo | Fase 3, sección 4 |

## 2b. Repertorio de skills del proyecto

Las 4 skills pedidas por el cliente el 16/11/2026 ya están **activadas en su cuenta**: aparecen como habilitadas al buscarlas. Puede que solo estén disponibles en sesiones nuevas o tras recargar.

| Skill | Para qué la usaremos | Fase | Advertencia |
|---|---|---|---|
| **aso** | Título, subtítulo, palabras clave, capturas y descripción en App Store y Google Play. Comparar fichas con la competencia | 7 (marketing) y preparación del lanzamiento | — |
| **paywalls** | Pantallas de suscripción y de "quitar anuncios", y momentos para ofrecerlas | 5 (monetización) y entrega 11 (Premium) | Toda pantalla debe cumplir el Anexo I de la DFA y las líneas rojas LR-06, LR-07 y LR-12 |
| **offers** | Construcción del valor de las ofertas (packs, bonificaciones) | 5 | Está pensada para servicios y B2B e incluye técnicas de **escasez y urgencia**. Solo se aplicará en su versión **honesta**: nada de falsa escasez (LR-06) ni ofertas personalizadas (LR-08) |
| **attribution** | Saber qué canales orgánicos traen jugadores e ingresos, con medición respetuosa con la privacidad | 7 y 9 | Respetar ATT, el consentimiento y la minimización de datos (marco legal, sección 4) |

**Otras skills disponibles que encajan con el proyecto:** pricing (Fase 5), social y tiktok-growth-strategist (Fase 7), impeccable y ai-slop-design-auditor (Fase 6), game-development (Fase 8) y ads (solo si algún día hay presupuesto).

## 3. Estado de las fases

| Fase | Estado | Entregable |
|---|---|---|
| 1. Candy Crush y Block Blast | ✅ Aprobada (16/11/2026) | [fase1/INFORME_FASE1_Candy_Crush_vs_Block_Blast.md](fase1/INFORME_FASE1_Candy_Crush_vs_Block_Blast.md) |
| Transversal: marco legal | ✅ v1.0 | [legal/MARCO_CUMPLIMIENTO_LEGAL.md](legal/MARCO_CUMPLIMIENTO_LEGAL.md) |
| 2. Top 50 juegos de Apple | ✅ Aprobada (16/11/2026) | [fase2/INFORME_FASE2_Top50.md](fase2/INFORME_FASE2_Top50.md) |
| 3. Psicología, retención y monetización | ✅ Aprobada (16/11/2026) | [fase3/INFORME_FASE3_Biblioteca_Mecanismos.md](fase3/INFORME_FASE3_Biblioteca_Mecanismos.md) |
| 4. Concepto original | ✅ Aprobada (16/11/2026): Cadencia, hoy Dingfall | [fase4/INFORME_FASE4_Concepto.md](fase4/INFORME_FASE4_Concepto.md) |
| 5. Modelo de negocio | ✅ Aprobada; revisada el 17/11/2026 (temas en el Club, sin «Sin anuncios») | [fase5/INFORME_FASE5_Monetizacion.md](fase5/INFORME_FASE5_Monetizacion.md) |
| 6. Dirección de arte | ✅ Aprobada (17/11/2026): 11 temas seleccionables, Dominó Pop v2 por defecto | [fase6/rediseno/INFORME_REDISENO.md](fase6/rediseno/INFORME_REDISENO.md) · [fase6/temas/index.html](fase6/temas/index.html) · [DESIGN.md](../DESIGN.md) |
| 7. Viralidad y marketing | ✅ Aprobada (17/11/2026) | [fase7/INFORME_FASE7_Marketing.md](fase7/INFORME_FASE7_Marketing.md) |
| 8. Arquitectura y desarrollo | 🔄 En curso desde el 17/11/2026 | [fase8/ARQUITECTURA_BORRADOR.md](fase8/ARQUITECTURA_BORRADOR.md) |
| 9. Pruebas y optimización | ⏸ Pendiente | — |

## 4. Hallazgos clave acumulados

- **Fase 1:** Candy Crush basa sus ingresos en compras integradas (unos 0,9–1,1 mil M$ al año) y ajusta los niveles globalmente con datos. Block Blast basa sus ingresos en anuncios (unos 127 M$ entre enero y mayo de 2026) y hay evidencia técnica, aún no replicada, de una mano imposible condicionada al eCPM. Las patentes de "dificultad dinámica" atribuidas a King son en realidad de Zynga y de EA.

- **Fase 2, lote 1:**
  - Las compras de entrada cuestan entre 0,99 € y 2,99 €. Los pases, entre 5,99 € y 9,99 € (6 de 13 juegos tienen pase).
  - La innovación reciente que triunfa está en el **gesto o el formato** (triple match en 3D, destornillar, solitario con palabras), no en añadir complejidad.
  - Dos meta-juegos dominan: decoración y restauración, y narrativa en forma de serie.
  - El riesgo legal se concentra en la energía de pago y en las ofertas dinámicas o "flash".
  - Royal Match lidera el mercado sin anuncios.

- **Fase 2, lote 2:**
  - Los subgéneros de ordenar, tornillos y bloques crecieron un 222 % en 2025, hasta unos 700 M$.
  - Pixel Flow (equipo de unas 10–20 personas, menos de 3 meses de desarrollo) hizo 198 M$ en su primer año. Combina un gesto nuevo con una profundidad oculta.
  - La "oferta al fallar" (5,99–6,99 €) es la palanca principal, pero es una zona gris con la DFA.
  - "Quitar anuncios" cuesta 8,99–14,99 € y los pases 9,99 €. Meowdoku ya vende suscripción (3,99 €/semana, 8,99 €/mes, 39,99 €/año).
  - La retención D30 de estos subgéneros es baja (4–8 %). **Oportunidad: gesto fresco + profundidad y meta-juego.**
  - Las imitaciones ya acaban en demandas (Colony Flow!).

- **Fase 2, lote 3:**
  - Referencia de suscripción en juegos casuales: **mensual unos 8,99–9,99 €, anual unos 23–50 €**. Quitar anuncios con pago único: 6,99–9,99 €.
  - Modelos limpios y compatibles con nuestro marco legal: demo gratis + versión completa (Geometry Dash), pago único + expansiones (BitLife), solo cosmética (Among Us!), prueba sin anuncios a 0,99 € (Paper.io 2).
  - El azar de pago concentra los litigios (Coin Master, 2 demandas colectivas en EE. UU.) y el desgaste (TCG Pocket, –50 %).
  - **Viralidad sin presupuesto:** contenido de usuarios y retos extremos, historias absurdas generadas por el sistema, drama social y un gameplay agradable de mirar.
  - Públicos desatendidos: personas mayores y jugadores españoles de juegos de mesa tradicionales.

- **Fase 2, lote 4:**
  - Suscripción en España: NYT Games a 2,99 €/mes; Chess.com por niveles de 2,99 € a 13,99 €/mes. **Horquilla de suscripción de puzles: 2,99–9,99 €/mes.**
  - Conversión realista a pago: alrededor del 1 % (Chess.com).
  - **"Reto diario igual para todos" + resultado compartible como emojis** (NYT Games): hábito sano y viral, 100 % compatible con nuestro marco legal.
  - Los premium mejor valorados (Balatro 4,96, Mini Metro, Bloons TD 6) combinan profundidad emergente, identidad visual con concepto y cero presión.
  - **Una sola persona puede crear un fenómeno** (Balatro, Geometry Dash).

- **Fase 2, síntesis:**
  - **Oportunidad principal (O1): gesto nuevo + profundidad + meta-juego**, porque la nueva ola no retiene y los veteranos tienen gestos viejos.
  - Complementos: reto diario compartible (O2), contenido infinito con sistemas (O3) y marca "limpia" ante la DFA (O4).
  - 48 de 50 juegos están por debajo de 18+, 41 de 50 venden moneda virtual de pago y solo 9 de 50 tienen riesgo bajo. **Los juegos de riesgo bajo incluyen 4 del top 15** (Balatro, NYT Games, Chess.com, Geometry Dash).

## 5. Concepto del juego (APROBADO el 16/11/2026)

> **Directriz del cliente al aprobar (16/11/2026):** *"Buscamos monetizar bien el juego."*
> - En lugar de pagar por vidas, se usarán anuncios.
> - **El límite de energía debe incentivar de verdad el premium**: no puede ser tan generoso que casi nadie lo note.
> - La Fase 5 calibrará el límite para que **afecte a los jugadores comprometidos** sin hacer "ilusorio" el camino gratuito (DFA art. 16).

**DINGFALL** (antes «Cadencia»): un puzle de dominós en el que **se dibuja el recorrido con el dedo y la longitud es el tiempo**. Detalle en [fase4/INFORME_FASE4_Concepto.md](fase4/INFORME_FASE4_Concepto.md).

- **Núcleo:** dibujar cadenas de fichas, empujar y activar campanas y mecanismos. La profundidad viene de la sincronización (orden, campanas dobles, ventanas de tiempo).
- **Meta-juego:** reconstruir la Gran Cadena del festival de Villa Cadencia, barrio a barrio. Cinemática de la cadena completa al final de cada capítulo.
- **Modos:** Campaña (capítulos de 20 niveles con un "Gran Tramo" de jefe), La Caída del Día (compartible), Taller (editor con verificación y códigos), Modo Libre y eventos.
- **Contenido:** unos 60 niveles a mano, más un generador "por construcción" con validación, más los niveles de la comunidad.
- **Plan B:** Brote (jardín de autómatas), si el dibujo no funciona en el prototipo.
- **Monetización (Fase 5, pendiente de aprobación):**
  - **Cuerda**: cada nivel nuevo cuesta 1, los reintentos son gratis; 5 como máximo, 1 cada 30 minutos; +3 por anuncio recompensado (máximo 10 al día). Afecta sobre todo al jugador comprometido.
  - **Dingclub**: 4,99 €/mes o 29,99 €/año; cuerda ilimitada, sin anuncios, los 10 temas de aspecto y extras. Es la única forma de quitar los anuncios.
  - **Packs de fichas**: 1,99–3,99 €. ~~Sin anuncios a 7,99 €~~, eliminado el 17/11/2026.
  - Intersticiales limitados. Sin banners.

## 6. Arquitectura

**Arquitectura de trabajo (Fase 8 en curso desde el 17/11/2026):** [fase8/ARQUITECTURA_BORRADOR.md](fase8/ARQUITECTURA_BORRADOR.md). La simulación de referencia en Python con 22 pruebas está en [prototipos/simulacion/](../prototipos/simulacion/).

## 7. Tareas

**Completadas:**
- [x] Investigación de la Fase 1 y su informe

**Pendientes:**
- [x] Aprobación de la Fase 1
- [x] Marco de cumplimiento legal v1.0
- [x] Fase 2: muestra de 50 juegos con datos oficiales de Apple (16/11/2026)
- [x] Fase 2, lote 1: 13 juegos de compras integradas → [fase2/LOTE1_monetizacion_IAP.md](fase2/LOTE1_monetizacion_IAP.md)
- [x] Fase 2, lote 2: 12 puzles de la nueva ola → [fase2/LOTE2_nueva_ola_puzles.md](fase2/LOTE2_nueva_ola_puzles.md)
- [x] Fase 2, lote 3: 16 juegos casuales, sociales y de colección → [fase2/LOTE3_casual_social_coleccion.md](fase2/LOTE3_casual_social_coleccion.md)
- [x] Fase 2, lote 4: 9 juegos de suscripción, midcore y premium → [fase2/LOTE4_suscripcion_midcore_premium.md](fase2/LOTE4_suscripcion_midcore_premium.md)
- [x] Fase 2, lote 5: clasificaciones, matriz de 50 juegos, patrones, oportunidades e informe final
- [x] Clasificación por edad real verificada: 48 de 50 están por debajo de 18+
- [x] Aprobación de la Fase 2
- [x] Fase 3: biblioteca de 11 mecanismos más 4 adicionales, con semáforo, modelo de tres bucles y métricas de bienestar
- [x] Aprobación de la Fase 3
- [x] Skills aso, offers, attribution y paywalls añadidas al repertorio (sección 2b)
- [x] Fase 4: 10 conceptos, matriz, 3 finalistas y diseño de Cadencia con su sistema de niveles
- [x] Aprobación de la Fase 4 (Cadencia)
- [x] Fase 5: Cuerda (5 como máximo, 1 cada 30 minutos, +3 por anuncio), Club a 4,99 €/mes o 29,99 €/año, Sin anuncios a 7,99 €, AdMob y luego MAX, modelo financiero
- [x] Aprobación de la Fase 5
- [x] Fase 6: mundo visual «La Banda del Pueblo» (elegido por el cliente), tablero de estilo jugable, auditoría (5/100) y registro de recursos
- [x] Fase 6: «La Banda del Pueblo» rechazada por el cliente (17/11/2026)
- [x] Fase 6: rediseño «Dominó Pop» a partir de 222 pines de Pinterest, tablero jugable rehecho y DESIGN.md
- [x] Fase 6: selección final de 11 temas seleccionables (Dominó Pop v2 por defecto), página de temas y CATALOGO_TEMAS.pdf
- [x] Revisión de la Fase 5 (17/11/2026): los 10 temas pasan al Club y se elimina el pago único «Sin anuncios»; modelo recalculado
- [x] **Aprobación del rediseño y de la Fase 6** (17/11/2026). Falta fusionar el Pull Request #1
- [x] Licencia de godot-iap verificada: MIT (repositorio hyodotdev/openiap; cubre iOS y Android). 17/11/2026
- [x] Búsqueda de marca de «Cadencia» (17/11/2026): conflicto con una solicitud en la OEPM en la clase 41 y con el juego «Cadence» (2026). Se recomienda «Dingfall» (fase7/NOMBRE_Y_MARCA.md)
- [x] **Nombre elegido por el cliente (17/11/2026): Dingfall.** La suscripción se llama **Dingclub**. Villa Cadencia se mantiene como lugar del juego
- [ ] Antes de usar el nombre en público: búsqueda de marcas parecidas, dominio y usuarios en redes
- [x] Fase 7: nombre y marca, fichas ASO en español e inglés, plan de TikTok, plan de lanzamiento y kit de prensa
- [x] **Decidido por el cliente (18/11/2026): nombre del desarrollador.** En App Store, cuenta personal: aparece el nombre del cliente. En Google Play, el nombre de desarrollador es **«Dingfall Games»** (TMview y web sin coincidencias; se descartaron «Zoom Games», con marcas y estudios con ese nombre, y «Ding Games», con marcas parecidas en juegos)
- [ ] Antes de crear las cuentas: datos de contacto que se publicarán como comerciante en la UE (se puede usar un apartado de correos) y consulta con el gestor. Con cuenta personal en Google Play hace falta la prueba cerrada de 12 personas durante 14 días
- [x] Aprobación de la Fase 7 (17/11/2026)
- [x] Fase 8: 10 niveles de la entrega 1 con solución verificada y 30 casos compartidos para el port a Godot (17/11/2026)
- [x] Fase 8: Godot 4.7.2 instalado con permiso del cliente; SHA-512 y firma comprobados (17/11/2026)
- [x] Fase 8: simulación portada a GDScript; da los mismos resultados que Python en los 30 casos (17/11/2026)
- [x] Fase 8: pantalla de partida jugable en el ordenador con los 10 niveles (18/11/2026)
- [x] Fase 8: sonidos propios, vibración, cámara lenta, registro local y protocolo de la prueba de la puerta 0 (18/11/2026)
- [x] Fase 8: fuentes, icono provisional y APK de prueba para Android generado y verificado (18/11/2026)
- [x] Fase 8: pantalla de juego con el diseño Dominó Pop acordado (18/11/2026)
- [ ] Fase 8: instalar el APK en un Android y hacer la prueba de la puerta 0 con 10–15 personas
- [x] Fase 8: generador de niveles por construcción y Caída del Día (calendario de un año dentro del juego) (18/11/2026)
- [ ] Fase 8: regenerar el calendario de la Caída del Día antes del 31/10/2027
- [x] Fase 8: Taller: crear, probar, publicar con código y jugar códigos de otros (18/11/2026)
- [x] Fase 8: mapa del barrio, progreso y cuerda con las reglas de la Fase 5; La Plaza con 20 niveles (18/11/2026)
- [x] Fase 8: Barrio 2, El Puerto, con la puerta de vaivén (generador, tablero, Taller y mapa de dos barrios) (18/11/2026)
- [x] Fase 8: tercera estrella con la campana dorada en los 40 niveles de los barrios (18/11/2026)
- [x] Fase 8: accesibilidad: alto contraste, reducir movimiento, texto grande y símbolos además de colores (18/11/2026)
- [ ] **TODO (decisión del cliente, 18/11/2026): pasada estética** con animaciones, sombreado y efectos. Se hace después de desarrollar el juego. Lista en fase8/ARQUITECTURA_BORRADOR.md, sección 6 bis
- [x] Nunes y Drèze (2006) y McIntosh y Schmeichel (2004) verificadas con DOI (17/11/2026). Quedan sin confirmar los porcentajes 34 %/19 % (texto de pago)
- [ ] Leer íntegro el texto oficial de la propuesta de DFA y ajustar el marco legal
- [ ] Antes de monetizar: consulta fiscal con un gestor (alta, IVA intracomunitario, W-8BEN)
- [ ] Fase 5: resolver el conflicto entre energía o intentos y "pagar para avanzar" (DFA art. 16)
- [ ] Verificar en la tienda española el precio del "Candy Crush Pass" y si Block Blast permite eliminar anuncios
- [ ] (Opcional) Experimento con conexión y sin conexión en Block Blast (protocolo en la sección 9 del informe de la Fase 1)
- [ ] Verificar con enlace las referencias psicológicas citadas de memoria (en la Fase 3)

## 8. Problemas conocidos o riesgos abiertos

- Las conclusiones sobre Block Blast dependen de un único análisis principal (oct. 2026).
- Las cifras de mercado son estimaciones de rastreadores que no coinciden entre sí.
