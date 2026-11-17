# Simulación de referencia

Reglas de la caída de dominós en Python puro (sin dependencias). Es la especificación ejecutable que debe replicar la versión de Godot. Ver [docs/fase8/ARQUITECTURA_BORRADOR.md](../../docs/fase8/ARQUITECTURA_BORRADOR.md).

Ejecutar las pruebas desde esta carpeta:

```bash
python -X utf8 -m unittest -v test_sim
```

Archivos:
- `sim.py`: simulación, reparto de fichas, reto diario y códigos del Taller (prefijo `DING1-`).
- `niveles_entrega1.py`: los 10 niveles hechos a mano de la entrega 1, con su solución de referencia y los intentos que deben fallar. Genera los archivos de `datos/`.
- `datos/niveles_entrega1.json`: los niveles que cargará el prototipo de Godot. La solución sirve de pista.
- `datos/casos_compartidos.json`: 30 casos (niveles, trazos y resultado esperado) que la versión de Godot debe reproducir exactamente. Se generan también en `godot/datos/`.
- `test_sim.py`: 27 pruebas.

Si se cambia un nivel o una regla, hay que regenerar los datos:

```bash
python -X utf8 niveles_entrega1.py
```

Las pruebas fallan si los JSON no están al día.
