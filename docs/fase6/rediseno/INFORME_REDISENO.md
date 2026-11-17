# Rediseño de la UI: «Dominó Pop»

**Fecha:** 17/11/2026
**Estado:** pendiente de aprobación del cliente

**Sustituye a:** «La Banda del Pueblo» (rechazada por el cliente). La dirección anterior y su auditoría quedan en el historial de Git, en la rama `main` antes de este cambio.

| Entregable | Contenido |
|---|---|
| **Tablero jugable** | [../tablero/index.html](../tablero/index.html), rehecho por completo |
| **Inspiración** | [INSPIRACION_PINTEREST.md](INSPIRACION_PINTEREST.md): 222 pines recorridos |
| **Sistema visual** | [../../../DESIGN.md](../../../DESIGN.md): tokens, componentes y reglas para Godot |

---

## 1. Qué ha cambiado

| | Antes («La Banda del Pueblo») | Ahora («Dominó Pop») |
|---|---|---|
| Sensación | Sobria, editorial, partitura | **Juego casual jugoso**: botones que se hunden, contornos gruesos, color |
| Fondo | Azul marino con rejilla de tiza | **Azul piscina** en degradado, tablero celeste con puntos |
| Colores | Escarlata, latón, tiza | **Verde** (jugar), **amarillo** (estrellas y lo que cae), **coral** (campanas), **cian** (secundario), **tinta** (contornos) |
| Títulos | Bodoni Moda (serif de partitura) | **Lilita One**: gruesa y redondeada, blanca con contorno y sombra |
| Texto | Atkinson Hyperlegible | **Nunito**: redondeada y legible |
| Fichas | Escarlata con borde de latón | **Fichas de dominó de verdad**: marfil con dos puntos |
| Campanas | Notas musicales | **Campanas** amarillas con badajo coral |
| Pantallas | Repertorio en pentagrama | **Mapa** con nodos y camino de fichas, como en los juegos casuales más populares |
| Botón principal | «¡YA!» | **«¡A TUMBAR!»** |

## 2. Lo que se ha tomado de Pinterest (sin copiar ningún diseño)

- Botón principal enorme y pulsable, con canto inferior.
- Barra superior de recursos (cuerda con temporizador, estrellas).
- Ventana de resultado con 3 estrellas y la central más grande.
- Mapa de niveles con nodos.
- Navegación inferior con la pestaña activa elevada.
- Títulos blancos con contorno.
- Mascota (Pío) con presencia.

**Lo propio de Cadencia:** **la interfaz está hecha de dominós**. El logotipo son fichas que caen, el camino del mapa es una fila de fichas y el contador de fichas es una ficha.

## 3. Pantallas del tablero

1. **Inicio**: mapa del barrio con niveles superados, actual y bloqueados, Pío y «JUGAR · 5».
2. **Partida (jugable)**: arranca sola con el ejemplo de la campana doble. Se puede dibujar.
3. **¡Nivel superado!**: 3 estrellas, fichas usadas frente a la marca y botones Repetir / Siguiente.
4. **¡Sin cuerda!**: cuatro opciones del mismo tamaño, sin cuentas atrás falsas.
5. **Reto del día**: resultado compartible y racha sin castigo.
6. **Club Cadencia**: ventajas, precios mensual y anual, prueba con aviso y «Ahora no» visible.
7. **Sistema**: paleta, letras, botones con sus estados y piezas del tablero.
8. **Cómo hablamos**: tabla de textos antes y después.

## 4. Textos (tono nuevo)

Frases cortas, verbos de acción y alegría de juego, **sin presión de compra ni urgencia falsa**:

| Momento | Texto nuevo |
|---|---|
| Acción principal | «¡A TUMBAR!» |
| Éxito | «¡NIVEL SUPERADO!» · «¡DING DONG! Las dos ramas llegaron a la vez.» |
| Fallo | «¡Casi! Se paró aquí. Prueba otra vez, es gratis.» |
| Sin cuerda | «¡SIN CUERDA! Pío necesita un respiro.» |

## 5. Revisión de calidad

**Revisor automático de impeccable**

Corregido durante el rediseño:
- **El fondo violeta degradado con halo** se marcaba como paleta típica de diseños hechos con IA. **Lo he cambiado a azul**, que también abunda en la muestra de Pinterest.
- Textos claros con poco contraste sobre el halo: eliminado el halo.
- Números de los niveles bloqueados con poco contraste: ahora en tinta.

**Lo que queda marcado es propio del estilo elegido**, y está documentado en DESIGN.md:
- sombras sólidas de tinta;
- canto inferior de los botones;
- paneles dentro de los teléfonos de ejemplo;
- texto blanco sobre verde, amarillo o cian. **Su contraste lo da el contorno de tinta de 5 px**, que el detector no tiene en cuenta.

**Comprobado en el navegador:**
- escritorio (1440 px) y móvil (375 px), sin desbordamiento horizontal;
- la demo llega a «¡DING DONG!» con las dos ramas a la vez.

**No comprobado:**
- rendimiento y gesto de dibujo en móviles reales;
- **auditoría con ai-slop-design-auditor de esta versión** (la anterior se hizo sobre «La Banda del Pueblo» y ya no aplica). Se puede repetir si lo pides.

## 6. Pendiente

- **Tu aprobación** del rediseño. Si algo no convence, se itera sobre este mismo Pull Request.
- Diseño final de Pío, del icono de la app y de las ilustraciones de cada barrio (fase de desarrollo).

---

## 7. Tres alternativas menos "divertidas" (17/11/2026)

El cliente valoró «Dominó Pop» como **mucho mejor**, pero lo ve **demasiado saturado en el mercado** y pidió algo más diferente y menos "divertido". Pidió ver las tres direcciones propuestas: **[../variantes/favoritas/index.html](../variantes/favoritas/index.html)** (guardadas como favoritas el 17/11/2026).

| Dirección | Idea | Fuentes (SIL OFL) | Tono de los textos |
|---|---|---|---|
| **1 · Mesa de juego** | Dominó real sobre tapete de pizarra: fichas de hueso con sombra, latón y lacre | Manrope | «Tumbar», «Bien hecho», «Inténtalo otra vez» |
| **2 · Calma premium** | Degradado de atardecer, fichas blancas mate, mucho espacio, un color por barrio | Jost | «Soltar», «Todo encaja», «Casi. Otra vez, con calma» |
| **3 · Gráfico y limpio** | Pasatiempo de periódico: blanco, fichas negras, mostaza y cobalto, bordes de 2 px | Archivo | «Tumbar», «Resuelto», «No llegó. Reintentar» |

Cada dirección tiene su propia **demo jugable**, el inicio con el mapa, el nivel superado y la ventana sin cuerda (cuatro opciones del mismo tamaño). Todas respetan el marco legal.

**Pendiente:** que el cliente elija una (o una mezcla). Después actualizaré `DESIGN.md` y el tablero principal con la dirección elegida.

## 8. Favoritas guardadas y segunda tanda de 10 (17/11/2026)

**Las tres direcciones anteriores le gustaron al cliente** y quedan guardadas aparte en [../variantes/favoritas/index.html](../variantes/favoritas/index.html).

**El cliente pidió 10 diseños más.** Están en **[../variantes/tanda-2/index.html](../variantes/tanda-2/index.html)**. La página de entrada a todas las variantes es [../variantes/index.html](../variantes/index.html).

| # | Dirección | Fuentes (SIL OFL) | Tono |
|---|---|---|---|
| 1 | Cine negro | Bebas Neue + Barlow | «Acción», «Caso cerrado» |
| 2 | Tinta japonesa | Shippori Mincho + Zen Kaku Gothic New | «Soltar», «Armonía» |
| 3 | Art déco | Marcellus SC + Josefin Sans | «Adelante», «Magnífico» |
| 4 | Bauhaus | League Spartan | «Tumbar», «Forma completa» |
| 5 | Brutalista | Familjen Grotesk | «Hecho.», «Error: no llegó. Reintentar.» |
| 6 | Risografía | Bricolage Grotesque | «¡Allá va!», «¡Impreso!» |
| 7 | Nocturno | Red Hat Display + Red Hat Text | «Encender», «Constelación completa» |
| 8 | Terracota mediterránea | Gloock + Mulish | «¡Venga!», «¡Olé!», «Hora de la siesta» |
| 9 | Nórdico | Figtree | «Tumbar», «Bien hecho», «Pausa» |
| 10 | Cuaderno | Caveat + Patrick Hand | «¡Allá va!», «¡Resuelto!» |

Cada una tiene una partida jugable, el inicio con el mapa, el nivel superado y la ventana sin cuerda con cuatro opciones del mismo tamaño.

**Comprobado** en el navegador: escritorio (1440 px) y móvil (375 px), sin desbordamiento horizontal, y las 10 demos se tumban solas.
