# Fase 8: arquitectura (borrador)

**Fecha:** 17/11/2026
**Estado:** **borrador adelantado**. La Fase 8 no empieza hasta que apruebes la Fase 7 (regla 10). Lo he preparado mientras no estabas porque no compromete nada y ahorra tiempo.

---

## 0. Lo que ya existe y se puede ejecutar

**[prototipos/simulacion/](../../prototipos/simulacion/)** contiene la **simulación de referencia en Python**, sin dependencias, con **22 pruebas** que pasan. Es la especificación ejecutable de las reglas:

- reparto de fichas por longitud;
- la longitud es el tiempo;
- campana simple, doble y numeradas;
- curvas demasiado cerradas, muros, salida del tablero y puertas de vaivén;
- límite de fichas;
- semilla de la Caída del Día por fecha UTC;
- códigos del Taller, con protección contra códigos manipulados.

**Comprobado que las pruebas detectan errores:** si se rompe a propósito la tolerancia de la campana doble, el reparto por longitud o el límite de curva, fallan 1, 8 y 1 pruebas respectivamente.

**Para qué sirve:**
1. **Especificación:** la versión en GDScript debe dar exactamente los mismos resultados. Se pueden exportar casos de prueba a JSON y ejecutarlos en los dos lados.
2. **Generador de niveles y reto diario:** pueden desarrollarse y probarse en Python en cualquier ordenador, sin Godot.
3. **Lecciones ya incorporadas** de los dos fallos encontrados en las demos:
   - **16/11/2026:** el ejemplo recortaba una rama → **reparto por longitud de arco**.
   - **17/11/2026:** a pantalla grande el ejemplo fallaba porque los umbrales estaban en píxeles → **todo en unidades lógicas del tablero**.

---

## 1. Principios de arquitectura

| Principio | Por qué |
|---|---|
| **Simulación separada del dibujo** | La regla (quién cae y cuándo) es código puro y probado. El dibujo solo la representa. Permite repeticiones, reto diario y generador |
| **Unidades lógicas, nunca píxeles** | El resultado no puede depender del teléfono (equidad y reto diario igual para todos) |
| **Temas como datos** | Un tema es un recurso con las claves de DESIGN.md. Cambiar de tema nunca toca la lógica ni la maqueta |
| **Sin servidor (MVP)** | El reto diario sale de una semilla por fecha; el Taller, de códigos de texto; las partidas guardadas, del propio teléfono |
| **Todo lo que cuesta dinero, detrás de una interfaz** | Anuncios, compras y analítica se acceden a través de un singleton propio. Se pueden cambiar de proveedor o simular en las pruebas |

## 2. Estructura del proyecto Godot (propuesta)

```
godot/
  project.godot
  nucleo/            # sin nodos visuales: se prueba con GUT
    simulacion.gd    # port de prototipos/simulacion/sim.py
    reparto.gd       # reparto por longitud de arco
    nivel.gd         # recurso Nivel (campanas, muros, puertas, fichas, marca)
    codigos.gd       # códigos del Taller
    reto_diario.gd   # semilla por fecha UTC + generador
  generador/         # generador "por construcción" (Fase 4, sección 5.3)
  escenas/
    mapa/  partida/  ventanas/  ajustes/  club/  taller/  reto/
  temas/             # 11 recursos .tres (pop por defecto) + texturas
  autoload/          # singletons
    Estado.gd        # progreso, cuerda, estrellas; guardado en user://
    Temas.gd         # tema activo y prueba de temas del Club
    Anuncios.gd      # interfaz → AdMob (Poing Studios, MIT)
    Compras.gd       # interfaz → godot-iap (MIT, verificado)
    Analitica.gd     # interfaz → proveedor por decidir (Fase 9)
  pruebas/           # GUT (MIT) + casos compartidos con la versión Python
```

## 3. Rendimiento con cientos de fichas

- **Dibujo:** un MultiMeshInstance2D por tablero. Cada ficha es una instancia con posición, giro y estado (de pie, cayendo, tumbada) codificados en el color de instancia. **Validar en la entrega 1** en un móvil de gama media.
- **Simulación:** se calcula **entera al pulsar «Tumbar»** (es barata: decenas de operaciones por ficha). La animación solo reproduce los tics, así que la caída nunca se atasca.

## 4. Guardado y privacidad

- Partida en `user://partida.json`, con versión y copia de seguridad del guardado anterior.
- **No se guarda ningún dato personal.** Los ajustes de «Juego responsable» (P-09) se guardan en el mismo archivo.
- El Club se comprueba con el recibo de la tienda a través de godot-iap. **Sin servidor propio, la validación es local**: es suficiente para el MVP y se revisará si aparece fraude.

## 5. Entregas propuestas

| Entrega | Contenido | Puerta (PLAN_LANZAMIENTO.md) |
|---|---|---|
| **1** | Port de la simulación con las mismas pruebas, dibujo con el dedo en el móvil, 10 niveles hechos a mano, tema Dominó Pop | Puerta 0: 10–15 personas lo prueban y piden más |
| 2 | Mapa, progreso, estrellas, cuerda (sin anuncios aún) y guardado | — |
| 3 | Generador y Caída del Día | — |
| 4 | Taller con códigos | — |
| 5 | Los 11 temas y la prueba de temas | — |
| 6 | Accesibilidad completa (alto contraste, tamaño de interfaz, reducción de movimiento) | — |
| 7 | Anuncios recompensados e intersticiales (AdMob) con su consentimiento | — |
| 8 | Club y packs de fichas (godot-iap) | Puerta 1: prueba cerrada |
| 9 | Analítica y panel de juego responsable | Puerta 2: lanzamiento suave |

## 6. Herramientas (licencia comprobada y coste)

| Herramienta | Licencia | Coste | Estado |
|---|---|---|---|
| Godot 4 | MIT | 0 € | Hay que instalarlo: no está en este equipo |
| GUT (pruebas en Godot) | MIT, según [la documentación](https://gut.readthedocs.io/) y la Asset Library (repositorio bitwes/Gut, versión 9.6.0 para Godot 4.6) | 0 € | Confirmar el archivo LICENSE al instalarlo |
| AdMob (plugin de Poing Studios) | MIT (Fase 5) | 0 € | — |
| godot-iap | MIT (verificado el 17/11/2026) | 0 € | — |
| Analítica | Por decidir | **Comprobar el precio, los límites gratuitos y las condiciones antes de elegir** (regla del presupuesto) | Fase 9 |

## 7. Pendiente

- **Instalar Godot 4** (descargarlo requiere permiso: no lo he hecho).
- Hacer el port de `sim.py` a GDScript y exportar los casos de prueba a JSON para ejecutarlos en los dos lados.
- **Ajustar en el prototipo** los valores de la simulación (PASO, GIRO_MAXIMO, RADIO_CAMPANA, TOLERANCIA_DOBLE): ahora son una hipótesis razonable, no un dato.
