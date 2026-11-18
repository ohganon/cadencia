# Registro de recursos y licencias

**Obligatorio** (marco legal, LR-14). Cada recurso que entre en el juego se anota aquí **antes** de usarlo: origen, autor, licencia, enlace, si exige atribución y dónde se usa.

**Licencias aceptadas:** CC0, SIL OFL 1.1 (fuentes), MIT, y CC-BY **con atribución registrada**.

**Licencias no aceptadas:**
- "solo uso personal";
- "no comercial" (NC);
- "sin obras derivadas" (ND);
- recursos sin licencia clara;
- recursos de pago.

## Recursos en uso

| Recurso | Tipo | Autor u origen | Licencia | Atribución | Enlace | Uso |
|---|---|---|---|---|---|---|
| Lilita One | Fuente | Juan Montoreano* | SIL OFL 1.1 | No obligatoria (incluir el texto de la licencia con la app) | [Google Fonts](https://fonts.google.com/specimen/Lilita+One) | Títulos, botones y cifras grandes (dirección «Dominó Pop»). **Descargada el 18/11/2026** del repositorio oficial google/fonts; licencia en `godot/fuentes/OFL-LilitaOne.txt` (nombre reservado «Lilita»: no se modifica la fuente) |
| Nunito | Fuente | Vernon Adams y colaboradores* | SIL OFL 1.1 | No obligatoria (incluir la licencia) | [Google Fonts](https://fonts.google.com/specimen/Nunito) | Textos de servicio, ayudas y precios. **Descargada el 18/11/2026** (fuente variable); licencia en `godot/fuentes/OFL-Nunito.txt` |
| Manrope, Jost, Archivo, Bebas Neue, Barlow, Shippori Mincho, Zen Kaku Gothic New, League Spartan, Familjen Grotesk, Bricolage Grotesque, Red Hat Display, Red Hat Text, Figtree | Fuentes | Sus autores (copyright en el OFL de cada familia: Manrope, Jost, Archivo, Bebas Neue/Dharma Type, Barlow, Shippori Mincho, Zen Kaku Gothic, League Spartan, Familjen Grotesk, Bricolage Grotesque, Red Hat, Figtree Project Authors) | SIL OFL 1.1 (comprobado el 18/11/2026 en el METADATA.pb y el OFL.txt de cada familia; **ninguna declara nombre reservado**) | No obligatoria (incluir el texto de la licencia de cada familia con la app) | [google/fonts](https://github.com/google/fonts/tree/main/ofl) | Temas seleccionables (Ajustes › Apariencia). **Descargadas el 18/11/2026 con permiso del cliente** del repositorio oficial google/fonts; licencias en `godot/fuentes/OFL-<Familia>.txt`. Shippori Mincho Bold y Zen Kaku Gothic New Medium y Bold van **recortadas a caracteres latinos** con fontTools (versión modificada que permite la OFL; sin nombre reservado, conservan el nombre). Las variables se renombraron sin corchetes (p. ej. `Manrope[wght].ttf` → `Manrope-wght.ttf`), sin tocar su contenido. No se venden ni se distribuyen sueltas |
| ~~Bodoni Moda / Atkinson Hyperlegible~~ | Fuentes | — | SIL OFL 1.1 | — | — | **Retiradas** con la dirección «La Banda del Pueblo» (17/11/2026) |
| Sonidos del prototipo (`ficha`, `campana`, `superado`, `fallo`) | Efectos de sonido | **Obra propia del equipo**: síntesis por código, sin muestras de terceros ([prototipos/sonido/generar_sonidos.py](../../prototipos/sonido/generar_sonidos.py)) | Propia | No aplica | — | Prototipo de la entrega 1 (18/11/2026). Se pueden sustituir más adelante por sonidos grabados con licencia |
| Icono provisional del prototipo | Imagen | **Obra propia del equipo**: dibujado por código ([prototipos/icono/generar_icono.py](../../prototipos/icono/generar_icono.py)) | Propia | No aplica | — | APK de prueba (18/11/2026). El icono final con Pío llegará con el arte definitivo |
| Godot Engine | Motor | Godot Foundation y colaboradores | MIT | **Sí**: el aviso de licencia en los créditos o la pantalla legal | [godotengine.org/license](https://godotengine.org/license/) | Motor del juego |
| godot-iap (OpenIAP) | Plugin de compras (iOS y Android) | hyo.dev | MIT (verificado el 17/11/2026) | **Sí**: el aviso de licencia en los créditos | [LICENSE](https://raw.githubusercontent.com/hyodotdev/openiap/main/libraries/godot-iap/LICENSE) | Dingclub y packs de fichas (previsto, Fase 8) |
| SwiftGodot (dependencia de godot-iap en iOS) | Biblioteca | Miguel de Icaza | Tipo MIT | **Sí**: el aviso de licencia en los créditos | [LICENSE](https://raw.githubusercontent.com/hyodotdev/openiap/main/libraries/godot-iap/third-party/SwiftGodot-LICENSE) | Previsto, Fase 8 |
| Gráficos del tablero de estilo | Vectores | Hechos en código para este proyecto | Propios | — | docs/fase6/tablero/index.html | Referencia de diseño |

## Fuentes candidatas (todavía no incorporadas)

| Fuente | Contenido | Licencia | Comprobación pendiente |
|---|---|---|---|
| [Kenney](https://kenney.nl/assets/music-jingles) (audio, interfaz) | Efectos, jingles e iconos | CC0 1.0 ([página de licencia del pack](https://www.kenney.nl/assets/rpg-audio)) | Descargar del sitio oficial; guardar la página de licencia de cada pack |
| Sonniss GDC Game Audio Bundle | Efectos de sonido profesionales | Libre de regalías, uso comercial permitido; **prohibido usarlo para entrenar IA** | **Leer el archivo de licencia incluido** en el bundle del año que se descargue |
| Freesound (filtro CC0) | Clics de madera y campanas | CC0 (solo los marcados así) | Filtrar por CC0 y guardar el enlace de cada sonido |
| Música de banda propia | Metales y caja | Propia | Componerla con herramientas gratuitas (por ejemplo, LMMS o MuseScore) e instrumentos de bancos CC0 |

\* *Autoría de cada fuente: confirmarla en su ficha de Google Fonts al descargarla e incluir el archivo OFL.txt en el juego.*

## Reglas

1. Sin entrada en este registro, el recurso no entra en el juego.
2. Se guarda una copia (captura o PDF) de la página de licencia **en la fecha de descarga**.
3. Los recursos generados con IA no se usan como material final mientras no se decida lo contrario (marco legal, sección 5).
