# Proyecto de Godot de Dingfall

Motor: **Godot 4.7.2** (MIT). Arquitectura en [docs/fase8/ARQUITECTURA_BORRADOR.md](../docs/fase8/ARQUITECTURA_BORRADOR.md).

| Carpeta | Contenido |
|---|---|
| `nucleo/` | Código sin nodos visuales: `simulacion.gd` (port exacto de `prototipos/simulacion/sim.py`), `partida.gd` (dibujar tramos, ramas y límite de fichas), `progreso.gd` (estrellas y ajustes guardados en el teléfono) y `registro.gd` (registro local de intentos para las pruebas, sin datos personales) |
| `escenas/comun/` | Piezas de Dominó Pop: botón con borde, sombra y labio (`boton_pop.gd`), pastilla del HUD, fila de estrellas e iconos dibujados con código a partir de los SVG de la maqueta |
| `escenas/partida/` | Pantalla de juego de la entrega 1: tablero, dedo, caída animada, resultado y lista de niveles |
| `iconos/` | Icono provisional (y su versión adaptable de Android), generado por `prototipos/icono/generar_icono.py` |
| `fuentes/` | Lilita One y Nunito con sus licencias SIL OFL |
| `sonidos/` | Sonidos propios generados por síntesis (`prototipos/sonido/generar_sonidos.py`). No se editan a mano |
| `datos/` | Niveles, casos compartidos y el calendario de la Caída del Día. **No se editan a mano**: los generan `prototipos/simulacion/niveles_entrega1.py` y `prototipos/generador/generador.py` |
| `pruebas/` | `ejecutar_pruebas.gd`: todas las pruebas sin pantalla |

## Jugar en el ordenador

Abre Godot, pulsa **Importar**, elige `godot/project.godot` y pulsa **Ejecutar** (F5). Con el ratón se dibuja igual que con el dedo.

## Pruebas (desde la raíz del repositorio)

```bash
Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://pruebas/ejecutar_pruebas.gd
```

100 pruebas: que todos los scripts compilan, que los sonidos cargan, los 30 casos compartidos con Python, que cada nivel se supera dibujando su solución (también punto a punto, como un dedo), el límite de fichas, el enganche, deshacer, el guardado del progreso y los ajustes, que el registro de pruebas no guarda nada más de lo previsto, y que Godot supera los 365 niveles de la Caída del Día con su solución y su marca exacta. Termina con código 0 si todo pasa.

## Generar el APK de prueba (Android)

```bash
Godot_v4.7.2-stable_win64_console.exe --headless --path godot --export-debug "Android (prueba)" exportaciones/dingfall-prueba.apk
```

Sale en `godot/exportaciones/` (no se sube a git). Es un APK de depuración: `com.dingfall.prueba`, arm64, solo el permiso de vibración, sin internet. Para instalarlo en un móvil conectado por USB con la depuración USB activada:

```bash
adb install -r godot/exportaciones/dingfall-prueba.apk
```

Herramientas instaladas en este equipo (fuera del repositorio): Java 17 (Temurin 17.0.21) en `%LOCALAPPDATA%\Programs\Java`, Android SDK en `%LOCALAPPDATA%\Programs\Android\Sdk` (Platform-Tools, Build-Tools 35.0.1 y Platform 35) y las plantillas de Android de Godot 4.7.2. En otro ordenador hay que poner las dos rutas en *Editor › Configuración del editor › Exportar › Android*. Si `sdkmanager` falla con «PKIX path building failed», hay que lanzarlo con `SDKMANAGER_OPTS=-Djavax.net.ssl.trustStoreType=Windows-ROOT`.

## Capturas automáticas

```bash
Godot_v4.7.2-stable_win64_console.exe --path godot --resolution 540x960 -- --demo=7 --captura=C:/ruta/prefijo
```

Abre una ventana, dibuja la solución del nivel, la tumba y guarda 4 capturas (vacío, dibujado, cayendo y resultado). Con `--diario --fecha=2026-11-18` juega la Caída del Día de esa fecha y con `--lista` añade una captura de la lista de niveles. Con `--incompleto` dibuja solo el primer tramo y con `--recto` una línea recta a la primera campana, para ver los fallos. Usa un progreso aparte y lo borra al terminar.
