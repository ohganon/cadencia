# Fase 8: arquitectura (borrador)

**Fecha:** 17/11/2026
**Estado:** **Fase 8 en curso** desde el 17/11/2026, tras aprobarse las fases 6 y 7. Este documento es la arquitectura de trabajo; se ajusta con lo que enseñe la entrega 1.

---

## 0. Lo que ya existe y se puede ejecutar

**[prototipos/simulacion/](../../prototipos/simulacion/)** contiene la **simulación de referencia en Python**, sin dependencias, con **27 pruebas** que pasan. Es la especificación ejecutable de las reglas:

- reparto de fichas por longitud;
- la longitud es el tiempo;
- campana simple, doble y numeradas;
- curvas demasiado cerradas, muros, salida del tablero y puertas de vaivén;
- límite de fichas;
- semilla de la Caída del Día por fecha UTC;
- códigos del Taller, con protección contra códigos manipulados.

**Los 10 niveles de la entrega 1** (17/11/2026) están en `niveles_entrega1.py` y `datos/niveles_entrega1.json`:

| # | Nivel | Enseña | Marca / fichas |
|---|---|---|---|
| 1 | Primer empujón | Dibujar y tumbar | 25 / 40 |
| 2 | La curva | Curvas suaves y muros | 30 / 42 |
| 3 | Fichas justas | El límite de fichas | 30 / 33 |
| 4 | Dos caminos | Bifurcador | 44 / 56 |
| 5 | Eslalon | Respiro | 32 / 52 |
| 6 | Primero la 1 | Campanas numeradas | 47 / 57 |
| 7 | La campana doble | Sincronizar dos ramas | 47 / 57 |
| 8 | El que espera | Alargar el camino corto | 55 / 63 |
| 9 | Una sola salida | Dividir después de un hueco | 52 / 58 |
| 10 | Gran Tramo: la plaza | Todo junto, con pocas fichas de sobra | 56 / 61 |

Cada nivel tiene una **solución de referencia** (prueba que tiene solución, fija la marca y sirve de pista) y, cuando enseña algo, un **intento ingenuo que debe fallar** por el motivo correcto. Es una muestra vertical para la puerta 0, no el capítulo 1 definitivo.

**Casos compartidos con Godot:** `datos/casos_compartidos.json` tiene 30 casos con el resultado esperado: las 10 soluciones, los 8 intentos que fallan, 2 casos de borde de la campana doble (una rama 1 tic tarde suena; 2 tics, no) y 10 de reglas sueltas (puertas, redondeo de medio paso y cada motivo de parada).

**Port a Godot hecho (17/11/2026):** [godot/nucleo/simulacion.gd](../../godot/nucleo/simulacion.gd) da **los mismos resultados en los 30 casos** que Python. Para que sea exacto bit a bit, las dos versiones siguen las mismas reglas de portabilidad: coordenadas en float de 64 bits (sin Vector2), distancias con `sqrt`, redondeo con `floor(x + 0.5)`, curvas comparando cosenos con un literal y módulo siempre positivo en las puertas. Comprobado que el ejecutor detecta errores: con la tolerancia de la campana doble a 0 falla 1 caso, y con el módulo de C en las puertas fallan 2.

Para ejecutarlo (desde la raíz del repositorio):

```bash
Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://pruebas/ejecutar_pruebas.gd
```

**Comprobado que las pruebas detectan errores:** si se rompe a propósito la tolerancia de la campana doble, el reparto por longitud o el límite de curva, fallan 1, 8 y 1 pruebas respectivamente. En los casos compartidos, cambiar la tolerancia a 0 o a 2 hace fallar uno, y cambiar el radio de la campana hace fallar 13.

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
| Godot 4.7.2 (estable, 18/08/2026) | MIT | 0 € | Editor para Windows de 82 MB (`Godot_v4.7.2-stable_win64.exe.zip`, de godotengine.org o GitHub). **Instalado el 17/11/2026** con permiso del cliente, en `%LOCALAPPDATA%\Programs\Godot\4.7.2`, fuera del repositorio. SHA-512 comprobado contra la lista oficial y firma de Windows válida (Prehensile Tales B.V.). Las plantillas de exportación (1,2 GB) solo hacen falta para generar el APK |
| GUT (pruebas en Godot) | MIT, según [la documentación](https://gut.readthedocs.io/) y la Asset Library (repositorio bitwes/Gut, versión 9.6.0 para Godot 4.6) | 0 € | Confirmar el archivo LICENSE y la compatibilidad con Godot 4.7 al instalarlo |
| AdMob (plugin de Poing Studios) | MIT (Fase 5) | 0 € | — |
| godot-iap | MIT (verificado el 17/11/2026) | 0 € | — |
| Temurin 17 (OpenJDK) | GPLv2 con excepción Classpath | 0 € | Instalado el 18/11/2026, solo como herramienta de compilación (no va dentro del juego) |
| Android SDK (Platform-Tools, Build-Tools 35.0.1, Platform 35) | Licencia del Android SDK (aceptada por el cliente el 18/11/2026) | 0 € | Instalado el 18/11/2026 |
| Analítica | Por decidir | **Comprobar el precio, los límites gratuitos y las condiciones antes de elegir** (regla del presupuesto) | Fase 9 |

## 7. Pendiente

- ~~Instalar Godot 4.7.2~~ **Hecho** (17/11/2026).
- ~~Diseñar los 10 niveles de la entrega 1~~ **Hecho** (17/11/2026), con casos compartidos en JSON.
- ~~Port de `sim.py` a GDScript~~ **Hecho**: pasa los 30 casos compartidos. Falta portar el reto diario y los códigos del Taller (entregas 3 y 4).
- ~~Escena de partida de la entrega 1~~ **Hecha** (18/11/2026): dibujar con el dedo, ramas desde cualquier ficha, límite de fichas, aviso de curva cerrada, caída animada, campanas que suenan (visualmente), resultado con estrellas, X donde se para la cadena con su explicación, pista en fantasma, deshacer, lista de niveles y progreso guardado. 77 pruebas sin pantalla y capturas automáticas revisadas.
- ~~Sonido~~ **Hecho** (18/11/2026): sonidos propios por síntesis (sin licencias de terceros), vibración en las campanas, cámara lenta (destacada tras 5 fallos), ajustes de sonido y vibración, registro local de intentos y resumen para quien dirige la prueba. Protocolo de la prueba en [PRUEBA_PUERTA_0.md](PRUEBA_PUERTA_0.md).
- ~~Fuentes y APK~~ **Hecho** (18/11/2026), con permiso del cliente para las descargas: fuentes Lilita One y Nunito (OFL), plantillas de Android de Godot 4.7.2, Java 17 y Android SDK (el cliente aceptó la licencia del SDK). APK de depuración comprobado con aapt2 y apksigner: `com.dingfall.prueba`, arm64, solo el permiso VIBRATE, objetivo Android 16 (API 36), icono provisional propio.
- **Para la puerta 0:** instalar el APK en un Android de gama media y hacer la prueba con 10–15 personas ([PRUEBA_PUERTA_0.md](PRUEBA_PUERTA_0.md)).
- **Para Google Play (más adelante):** AAB con compilación Gradle (requiere el NDK r28b y CMake, unos 1–2 GB más), identificador definitivo de la app y clave de firma de publicación guardada fuera del repositorio.
- **Ajustar en el prototipo** los valores de la simulación (PASO, GIRO_MAXIMO, RADIO_CAMPANA, TOLERANCIA_DOBLE): ahora son una hipótesis razonable, no un dato.
