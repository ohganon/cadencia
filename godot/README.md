# Proyecto de Godot de Dingfall

Motor: **Godot 4.7.2** (MIT). Arquitectura en [docs/fase8/ARQUITECTURA_BORRADOR.md](../docs/fase8/ARQUITECTURA_BORRADOR.md).

| Carpeta | Contenido |
|---|---|
| `nucleo/` | Código sin nodos visuales: `simulacion.gd` (port exacto de `prototipos/simulacion/sim.py`), `partida.gd` (dibujar tramos, ramas y límite de fichas) y `progreso.gd` (estrellas guardadas en el teléfono) |
| `escenas/partida/` | Pantalla de juego de la entrega 1: tablero, dedo, caída animada, resultado y lista de niveles |
| `datos/` | Niveles y casos compartidos. **No se editan a mano**: los genera `prototipos/simulacion/niveles_entrega1.py` |
| `pruebas/` | `ejecutar_pruebas.gd`: todas las pruebas sin pantalla |

## Jugar en el ordenador

Abre Godot, pulsa **Importar**, elige `godot/project.godot` y pulsa **Ejecutar** (F5). Con el ratón se dibuja igual que con el dedo.

## Pruebas (desde la raíz del repositorio)

```bash
Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://pruebas/ejecutar_pruebas.gd
```

77 pruebas: que todos los scripts compilan, los 30 casos compartidos con Python, que cada nivel se supera dibujando su solución (también punto a punto, como un dedo), el límite de fichas, el enganche, deshacer y el guardado del progreso. Termina con código 0 si todo pasa.

## Capturas automáticas

```bash
Godot_v4.7.2-stable_win64_console.exe --path godot --resolution 540x960 -- --demo=7 --captura=C:/ruta/prefijo
```

Abre una ventana, dibuja la solución del nivel, la tumba y guarda 4 capturas (vacío, dibujado, cayendo y resultado). Con `--incompleto` dibuja solo el primer tramo y con `--recto` una línea recta a la primera campana, para ver los fallos. Usa un progreso aparte y lo borra al terminar.
