# Proyecto de Godot de Dingfall

Motor: **Godot 4.7.2** (MIT). Arquitectura en [docs/fase8/ARQUITECTURA_BORRADOR.md](../docs/fase8/ARQUITECTURA_BORRADOR.md).

| Carpeta | Contenido |
|---|---|
| `nucleo/` | Código sin nodos visuales: `simulacion.gd` (port exacto de `prototipos/simulacion/sim.py`), `partida.gd` (dibujar tramos, ramas y límite de fichas), `progreso.gd` (estrellas, ajustes y tema guardados en el teléfono), `temas.gd` (los 11 temas y el tema activo, que todas las pantallas leen al construirse) y `registro.gd` (registro local de intentos para las pruebas, sin datos personales) |
| `escenas/comun/` | Piezas de Dominó Pop: botón con borde, sombra y labio (`boton_pop.gd`), pastilla del HUD, fila de estrellas e iconos dibujados con código a partir de los SVG de la maqueta |
| `escenas/mapa/` | Pantalla de inicio: el mapa del barrio con el camino de fichas, la cuerda, «Jugar», la barra de abajo, «Sin cuerda», Ajustes y Apariencia |
| `escenas/taller/` | Taller: editor de niveles (`tablero_editor.gd`) y pantalla con herramientas, «Probar» y «Códigos» |
| `autoload/` | `estado.gd` (autoload «Estado»): el nivel del Taller que se abre al cambiar de pantalla y el borrador. `tema.gd` (autoload «Tema»): elige el tema guardado al arrancar |
| `escenas/partida/` | Pantalla de juego de la entrega 1: tablero, dedo, caída animada, resultado y lista de niveles |
| `iconos/` | Icono provisional (y su versión adaptable de Android), generado por `prototipos/icono/generar_icono.py` |
| `fuentes/` | Las letras de los 11 temas (Lilita One y Nunito para Dominó Pop; 13 familias más para el resto), todas SIL OFL con su licencia. Las japonesas, recortadas a caracteres latinos |
| `sonidos/` | Sonidos propios generados por síntesis (`prototipos/sonido/generar_sonidos.py`). No se editan a mano |
| `datos/` | Niveles, casos compartidos, el calendario de la Caída del Día y los temas. **No se editan a mano**: los generan `prototipos/simulacion/niveles_entrega1.py`, `prototipos/generador/generador.py` y `prototipos/generador/temas.py` |
| `pruebas/` | `ejecutar_pruebas.gd`: todas las pruebas sin pantalla |

## Jugar en el ordenador

Abre Godot, pulsa **Importar**, elige `godot/project.godot` y pulsa **Ejecutar** (F5). Empieza en el mapa de La Plaza. Con el ratón se dibuja igual que con el dedo.

## Pruebas (desde la raíz del repositorio)

```bash
Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://pruebas/ejecutar_pruebas.gd
```

187 pruebas: que todos los scripts compilan, que los sonidos cargan, los 30 casos compartidos con Python, que cada nivel se supera dibujando su solución (también punto a punto, como un dedo), el límite de fichas, el enganche, deshacer, el guardado del progreso y los ajustes, que el registro de pruebas no guarda nada más de lo previsto, que Godot supera los 365 niveles de la Caída del Día con su solución y su marca exacta, y los códigos del Taller: abre los de Python, rechaza 16 códigos rotos o manipulados, ida y vuelta, formato estable y lista de guardados; las reglas de la cuerda (gratis hasta el nivel 15, sin cobrar dos veces, repetir gratis, recarga y reloj hacia atrás) y los 40 niveles de La Plaza y El Puerto (incluido que en el nivel 22 la línea recta encuentra la puerta cerrada y que la solución de referencia de cada nivel da las 3 estrellas). Termina con código 0 si todo pasa.

## Generar el APK de prueba (Android)

```bash
Godot_v4.7.2-stable_win64_console.exe --headless --path godot --export-debug "Android (prueba)" exportaciones/dingfall-prueba.apk
```

Sale en `godot/exportaciones/` (no se sube a git). Es un APK de depuración: `com.dingfall.prueba`, arm64, solo el permiso de vibración, sin internet. Para instalarlo en un móvil conectado por USB con la depuración USB activada:

```bash
adb install -r godot/exportaciones/dingfall-prueba.apk
```

Herramientas instaladas en este equipo (fuera del repositorio): Java 17 (Temurin 17.0.21) en `%LOCALAPPDATA%\Programs\Java`, Android SDK en `%LOCALAPPDATA%\Programs\Android\Sdk` (Platform-Tools, Build-Tools 35.0.1 y Platform 35) y las plantillas de Android de Godot 4.7.2. En otro ordenador hay que poner las dos rutas en *Editor › Configuración del editor › Exportar › Android*. Si `sdkmanager` falla con «PKIX path building failed», hay que lanzarlo con `SDKMANAGER_OPTS=-Djavax.net.ssl.trustStoreType=Windows-ROOT`.

## Versiones para Windows y web (sin Android)

Las plantillas salen del mismo archivo oficial ya descargado para el APK (`Godot_v4.7.2-stable_export_templates.tpz`), así que no hace falta descargar nada más.

```
Godot_v4.7.2-stable_win64_console.exe --headless --path godot --export-release "Windows (prueba)" exportaciones/windows/Dingfall.exe
Godot_v4.7.2-stable_win64_console.exe --headless --path godot --export-release "Web (prueba)" exportaciones/web/index.html
```

- **Windows:** un solo archivo, `godot/exportaciones/windows/Dingfall.exe` (unos 110 MB, con el juego dentro). Se abre con doble clic en una ventana de 450 × 800 y se juega con el ratón como si fuera el dedo. No está firmado, así que Windows puede avisar («Windows protegió su PC»): «Más información» › «Ejecutar de todas formas».
- **Web:** `godot/exportaciones/web/` (unos 43 MB). Funciona en el navegador del ordenador y del móvil (también en un iPhone), pero tiene que servirse desde una web: abrir `index.html` con doble clic no funciona. Sin hilos («nothreads»), así que vale cualquier alojamiento estático. **Publicada con permiso del cliente (20/11/2026) en GitHub Pages: https://ohganon.github.io/cadencia/** (rama `gh-pages`, que solo lleva la exportación; con `noindex` para que no salga en buscadores). Para actualizarla: exportar «Web (prueba)», copiar `godot/exportaciones/web/index.*` a la rama `gh-pages` y subirla.

## Capturas automáticas

```bash
Godot_v4.7.2-stable_win64_console.exe --path godot --resolution 540x960 -- --demo=7 --captura=C:/ruta/prefijo
```

Abre una ventana, dibuja la solución del nivel, la tumba y guarda 4 capturas (vacío, dibujado, cayendo y resultado). Con `--taller --publicar` prueba el nivel como si fuera del Taller y lo publica; con `--codigo=DING1-…` juega un código recibido. El mapa: `-- --demo-mapa --superados=15 [--sin-cuerda | --entrar | --ver-barrio=2]`. Con `--ajustes`, la ventana de Ajustes, con `--apariencia`, la de Apariencia, con `--responsable`, el panel de juego responsable, con `--piezas`, la guía de piezas, con `--creditos`, los créditos, y con `--resumen`, el resumen de la prueba ya copiado (con partidas de ejemplo). Con `--pio-vuela`, la captura del mapa sale con Pío a mitad del vuelo desde el nivel anterior. En la partida, `--aviso=descanso` o `--aviso=limite` enseña ese aviso, `--presentar=espiral` la ventana de pieza nueva y `--guia` el dedo del nivel 1. En las demostraciones no salen las ventanas de pieza nueva (para que no tapen las capturas). En cualquier demostración, `--tema=nocturno` (o el id de otro tema) cambia el tema sin guardar nada, y `--contraste` y `--texto-grande` activan esos ajustes en toda la interfaz. En la partida, `--contraste`, `--sin-movimiento` y `--texto-grande` activan la accesibilidad (en el progreso de la demo). Las demostraciones de partida (`--demo=N`) pasan solas del mapa a la pantalla de juego. El editor tiene su propia demo: `... res://escenas/taller/taller.tscn -- --demo-taller --captura=…`. Con `--diario --fecha=2026-11-18` juega la Caída del Día de esa fecha y con `--lista` añade una captura de la lista de niveles. Con `--incompleto` dibuja solo el primer tramo y con `--recto` una línea recta a la primera campana, para ver los fallos. Usa un progreso aparte y lo borra al terminar, y nunca toca el portapapeles ni el borrador del Taller.
