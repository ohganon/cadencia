# FASE 6 — Identidad visual y dirección de arte

> **⚠️ DIRECCIÓN SUSTITUIDA (17/11/2026).** El cliente rechazó «La Banda del Pueblo». La dirección vigente es **«Dominó Pop»**: ver [rediseno/INFORME_REDISENO.md](rediseno/INFORME_REDISENO.md) y [DESIGN.md](../../DESIGN.md). Este documento se conserva como histórico; sus secciones de método (skills, sonido, animación y registro de recursos) siguen siendo válidas.

## Histórico: «La Banda del Pueblo»

**Fecha:** 16/11/2026
**Estado:** entregada a falta de tus decisiones sobre la auditoría (sección 9)
**Coste:** 0 €

**Entregables**

| Entregable | Contenido |
|---|---|
| [tablero/index.html](tablero/index.html) | **Tablero de estilo interactivo**, con un nivel de demostración jugable |
| [auditoria/auditoria_ai_slop_tablero.pdf](auditoria/auditoria_ai_slop_tablero.pdf) | Auditoría contra el aspecto "hecho con IA": **5/100, "diseño muy cuidado"** |
| [../legal/REGISTRO_ASSETS.md](../legal/REGISTRO_ASSETS.md) | Registro de recursos y licencias |
| [../../PRODUCT.md](../../PRODUCT.md) | Ficha del producto para la skill impeccable |

**Para ver el tablero:** ábrelo en un navegador. Pulsa la bombilla («Ejemplo») y después «¡YA!»: las dos ramas caen a compás y la campana doble suena. También puedes dibujar arrastrando desde el empujador.

---

## 1. Cómo se ha trabajado (skills)

| Skill | ¿Existe? | Uso |
|---|---|---|
| **impeccable** | ✅ | La he usado siguiendo sus instrucciones: ficha de producto (PRODUCT.md), **sorteo de dirección** para evitar la estética por defecto, página de decisión (elegiste **La Banda del Pueblo**), contrato de dirección y detector automático de errores de diseño |
| **ai-slop-design-auditor** | ✅ | Auditoría completa del tablero con su informe PDF de 4 páginas. **El flujo queda detenido hasta tu decisión**, como exige la skill |
| **dbs-ai-check** | ✅, pero no aplica | Detecta rasgos de escritura con IA en textos en chino. No sirve para revisar elementos visuales |
| "Anti AI-Slop" | No como skill independiente | Su función la cumple ai-slop-design-auditor |

**Detector automático de impeccable:**
- Encontró **contrastes insuficientes** (texto escarlata sobre azul a 2,8:1, texto claro sobre escarlata a 4,0:1), letras demasiado espaciadas y una sombra de "pestaña" en la batuta. **Todo corregido.**
- Quedan como **decisiones deliberadas**: la rejilla del fondo (es el campo de ensayo) y el galón a rayas (es el uniforme).

---

## 2. La idea

**Cada nivel es la partitura de desfile de la banda del pueblo.**
- La cadena es una formación que avanza **un tiempo de compás por ficha**.
- Las **campanas son notas**.
- "Cadencia" es también un término musical, así que nombre, mundo y mecánica dicen lo mismo: **el largo del camino es el tiempo**.

**Lo que rechazamos:** el estándar del género (plástico brillante, marcos dorados, botones de caramelo, al estilo Royal Match) y la estética luminosa genérica.

**Mejoras incorporadas** a partir de las alternativas descartadas en el sorteo:
1. **Jerarquía solo por escala:** la caída ocupa la pantalla y la interfaz queda en pequeño.
2. **Una única rejilla de tiempos:** cada ficha es un tiempo y se puede leer en las cifras de compás.
3. **Estados inequívocos de la cadena:** dibujada, armada, cayendo, sincronizada y rota.
4. **Un solo brillo:** la ficha que cae ahora es lo único que brilla.
5. **Primero la promesa, después las reglas:** cada nivel enseña la caída terminada y, al girarlo, sus restricciones.

---

## 3. Paleta: el uniforme de gala

| Color | Hex | Papel |
|---|---|---|
| **Azul de lana** | #16213F · #0E1630 (profundo) · #24315A (claro) | Suelo de todas las pantallas y del campo. **Nunca fondo blanco** |
| **Escarlata de paño** | #B51C2A | Superficies con texto encima: batuta, Club, nivel en curso. Texto claro a **5,9:1** |
| **Escarlata vivo** | #EF4655 | Fichas y texto grande sobre azul (**4,3:1**). Cumple el contraste mínimo de 3:1 para gráficos |
| **Latón** | #D9A93B · #F1CF7A (claro) | Campanas, cifras de compás y **el único brillo** (la ficha que cae) |
| **Tiza** | #F4F1EA | Rejilla (con transparencia) y texto principal (**14:1** sobre azul) |
| **Tinta** | #1D1D1B | Fichas rotas y bordes |

**Estrategia de color:** el azul **cubre la superficie** y el escarlata y el latón son los papeles activos.

**Decisión de accesibilidad:** dos escarlatas en lugar de uno, porque un solo tono no daba contraste suficiente ni sobre azul ni con texto claro encima. **El modo daltónico** usa forma además de color, y **el modo de alto contraste** sube la rejilla y los bordes.

---

## 4. Tipografía: el programa de mano

| Voz | Fuente | Uso | Licencia |
|---|---|---|---|
| **La banda** | **Bodoni Moda** (900 y 700), mayúsculas | Títulos, barrios, cifras de compás. La estética de la partitura grabada | SIL OFL 1.1 |
| **El servicio** | **Atkinson Hyperlegible** (400 y 700) | Botones, ayudas, ajustes. **Diseñada para leerse bien con poca vista**, pensando en el público de hasta 55 años | SIL OFL 1.1 |

**Reglas:**
- Bodoni nunca por debajo de 20 px: **sus trazos finos desaparecen** (ver la auditoría, hallazgo 2).
- Atkinson con un mínimo de 15 px en juego.
- La interfaz es escalable (opción de texto grande).

---

## 5. Estilo de ilustración y piezas

- **Vector plano con volumen mínimo**: formas limpias como las de un gráfico de desfile impreso, con sombras suaves solo para separar capas.
- **Sin texturas fotográficas ni 3D brillante.**
- **Vista cenital 2D**: más barata en Godot, más legible y fiel al gráfico de desfile. Corrige la idea de 2,5D de la Fase 4. Las escaleras y los puentes se resuelven con capas y sombra.
- **Fichas:** rectángulos escarlata con un borde de latón (el galón).
- **Campanas:** cabezas de nota con plica; la doble es una corchea unida.
- **Mecanismos:** dibujados como instrumentos y atrezo de banda:
  - el bifurcador, como la horquilla de un atril;
  - la puerta de vaivén, como dos postes de latón con barrera;
  - el muelle, como un platillo;
  - la espiral de retardo, como un caracol de trompa.

## 6. Personajes

| Personaje | Diseño |
|---|---|
| **Tilde** | Aprendiz de relojera y **tambor de la banda**. Uniforme escarlata con galón, gorra de plato azul y un reloj de bolsillo al cinto. Silueta reconocible en 32 px. Solo gestos, sin texto |
| **Pío** | Pájaro de hojalata de cuerda, en latón con una llave de cuerda en la espalda. **Es el guía y el puntero**: vuela hasta el objetivo. Mascota de la marca e icono de la app |
| **Vecinos** | Cada barrio tiene un músico (panadera con bombardino, farero con trompeta…). Celebran al completar su tramo |

**Producción a coste 0:** se dibujan en vector (Inkscape, licencia GPL; lo que se crea con él es nuestro) a partir de formas simples, coherentes con las piezas. **No se usarán imágenes generadas con IA como material final** (registro de recursos, regla 3).

## 7. Escenarios

- Cada barrio es **un campo de ensayo superpuesto al plano del pueblo**: la rejilla de tiza sobre el azul, con los edificios del barrio dibujados en el borde, en línea de tiza.
- **El final de capítulo (la Gran Cadena)** cambia a una vista del pueblo entero, con las tiras de fichas cruzando calles y plazas.

## 8. Iconografía e interfaz

- **Iconos:** trazo de 2,2 px, puntas redondeadas y un único estilo (ver deshacer y pista en el tablero).
- **Interfaz:**
  - **una sola acción principal por pantalla** (la batuta escarlata);
  - acciones secundarias en círculos azules;
  - **paneles sin marcos dorados**;
  - **pantallas de decisión con opciones del mismo tamaño** (pantalla sin cuerda, conforme a la DFA).
- **Repertorio** (selección de niveles): pentagramas en los que cada nivel es una nota. Superado = latón; en curso = escarlata.
- **Caída del Día:** tarjeta de resultado en tiza sobre azul, compartible como texto.

## 9. Animación, efectos y partículas

| Momento | Animación | Rendimiento |
|---|---|---|
| **La caída** (el momento escénico) | Tempo fijo por ficha. La ficha activa se ilumina en latón claro y se tumba con una curva de salida rápida; las caídas quedan en escarlata oscuro | Instancias múltiples en Godot (MultiMesh), sin física: **cientos de fichas a 60 fps** |
| **Campana** | Anillo de latón que se expande una vez y una sacudida de 2 px | Shader barato |
| **Sincronización perfecta** | **Polvo de tiza** (unas 20 partículas) y acorde de las campanas | Partículas en GPU, limitadas |
| **Cadena rota** | La ficha rota se pone en tinta con una X; la cámara se acerca 1 s | Sin partículas |
| **Victoria** | **Desfile**: las fichas caídas se levantan en fila y saludan (se pliegan como un abanico), y Pío vuela | Una sola vez por nivel |
| **Transiciones** | Cortinilla horizontal, como pasar una página de partitura | 250 ms |
| **Final de capítulo** | Plano secuencia de la Gran Cadena con música completa | Es el vídeo para compartir |
| **Reducir movimiento** | Las fichas se tumban sin rotación, sin sacudidas ni cámara | Obligatorio |

## 10. Sonido y música

- **Clic de madera por ficha**, afinado por material de ficha (cosméticos: haya, nogal, cristal…).
- **Campanas afinadas en una escala.** Una sincronización perfecta suena como un acorde (lo demuestra el tablero con un acorde sintetizado).
- **Música:** banda de pueblo (metales y caja), compuesta con herramientas gratuitas o de bancos CC0. Fuentes candidatas en el [registro de recursos](../legal/REGISTRO_ASSETS.md).
- **Todo el juego se puede jugar sin sonido:** el ritmo también se ve en las cifras de compás.

---

## 10b. Auditoría contra el aspecto "hecho con IA": tus decisiones

**Puntuación:** 5/100, "diseño muy cuidado" ([PDF](auditoria/auditoria_ai_slop_tablero.pdf)).

| # | Problema | Prioridad | Propuesta |
|---|---|---|---|
| 1 | **El campo de juego aparece vacío** al abrir la página: el mecanismo no se ve hasta pulsar «Ejemplo» | Alta | Cargar la cadena de ejemplo ya armada y dejarla caer una vez, sin sonido |
| 2 | **El título partido en dos colores se lee «CIA»** y los trazos finos de Bodoni casi desaparecen | Media | Nombre entero en tiza y una fila de fichas escarlata debajo, como una cadena |

**Lo que respeta la auditoría:**
- la rejilla de fondo (es el campo de ensayo);
- el galón del uniforme;
- los dos escarlatas (una decisión de contraste);
- el muestrario de piezas en celdas iguales.

**No compruebo:** el rendimiento en móviles reales ni el gesto de dibujar con el dedo en pantallas táctiles. Se validarán en el prototipo de Godot.

**Opciones:** aceptar las dos, aceptar alguna, rechazar, pedir otra solución o profundizar. **No modificaré nada hasta que decidas.**

## 11. Riesgos y pendientes

| Pendiente | Detalle |
|---|---|
| Correcciones de la auditoría | Según tu decisión |
| Revisión final y DESIGN.md | El documento técnico del sistema visual para Godot. **Se cierra después de las correcciones**, para que documente el diseño definitivo |
| Diseño final de Tilde, Pío e icono de la app | Se hará en la fase de desarrollo (entrega 6), con este tablero como referencia |
| Riesgo: la estética de banda puede resultar "antigua" para adolescentes | La energía viene del escarlata, el ritmo y la caída. **Se probará con jugadores reales** en el lanzamiento suave |

## 12. Próximos pasos (sujetos a tu aprobación)

**Fase 7: viralidad y marketing**, con las skills **aso**, **social** y **tiktok-growth-strategist**:
- formatos de TikTok, Reels, Shorts y Reddit;
- lanzamiento;
- ficha de tienda;
- capturas y vídeo;
- calendario;
- adquisición orgánica;
- búsqueda de marca del nombre.
