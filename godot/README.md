# Proyecto de Godot de Dingfall

Motor: **Godot 4.7.2** (MIT). Arquitectura en [docs/fase8/ARQUITECTURA_BORRADOR.md](../docs/fase8/ARQUITECTURA_BORRADOR.md).

| Carpeta | Contenido |
|---|---|
| `nucleo/` | Código sin nodos visuales. `simulacion.gd` es el port exacto de `prototipos/simulacion/sim.py` |
| `datos/` | Niveles y casos compartidos. **No se editan a mano**: los genera `prototipos/simulacion/niveles_entrega1.py` |
| `pruebas/` | `ejecutar_pruebas.gd` comprueba que Godot da los mismos resultados que Python |

Pruebas (desde la raíz del repositorio):

```bash
Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://pruebas/ejecutar_pruebas.gd
```

Termina con código 0 si los 30 casos coinciden con Python.
