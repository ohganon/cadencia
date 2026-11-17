# Cadencia (nombre provisional)

Juego móvil de puzles de dominós para iOS y Android, hecho con **Godot 4**.

> **Dibuja. Empuja. Que suene.**
> Dibujas con el dedo el recorrido de las fichas, empujas la primera y la cadena cae haciendo sonar campanas y mecanismos. Cada ficha tarda lo mismo en caer, así que **el largo del camino es el tiempo**: al principio basta con llegar a la campana; después hay que sincronizar ramas, respetar un orden y entrar en ventanas de tiempo.

**Estado (16/11/2026):** fase de diseño. **Todavía no hay código del juego.** Están hechas la investigación, el concepto, el modelo de negocio y la dirección de arte (falta cerrar la Fase 6).

---

## Probarlo ya: el tablero de estilo jugable

Abre `docs/fase6/tablero/index.html` en el navegador (doble clic en el archivo).

1. Al abrirlo, la pantalla central ya tumba un ejemplo: dos ramas con el mismo número de fichas llegan a la vez y suena la campana doble.
2. Pulsa la **bombilla** para cargar otra vez el ejemplo y **«¡A TUMBAR!»** para repetirlo.
3. Pulsa la flecha azul para borrar y **arrastra desde el botón verde** para dibujar tu propia cadena.

Si las fuentes no cargan con doble clic, sírvelo en local:

```bash
python -m http.server 8765 --directory docs/fase6/tablero
```

Y abre http://127.0.0.1:8765

---

## Por dónde empezar a leer

1. **[docs/00_DOCUMENTO_MAESTRO.md](docs/00_DOCUMENTO_MAESTRO.md)**: el estado del proyecto, las decisiones y las tareas. **Es la fuente de verdad.**
2. **[docs/fase4/INFORME_FASE4_Concepto.md](docs/fase4/INFORME_FASE4_Concepto.md)**: qué juego es y por qué.
3. **[docs/legal/MARCO_CUMPLIMIENTO_LEGAL.md](docs/legal/MARCO_CUMPLIMIENTO_LEGAL.md)**: **las líneas rojas que no se cruzan**. Léelo antes de proponer mecánicas o monetización.

## Estructura

```
PRODUCT.md                      Ficha del producto (la usa la skill de diseño impeccable)
DESIGN.md                       Sistema visual: colores, tipografías, componentes y reglas
docs/
  00_DOCUMENTO_MAESTRO.md       Estado, decisiones, tareas
  fase1/                        Candy Crush y Block Blast: técnica, psicología, negocio
  fase2/                        Análisis de 50 juegos del App Store (ES/US), datos y scripts
  fase3/                        Biblioteca de mecanismos psicológicos (con semáforo ético)
  fase4/                        Concepto: Cadencia, niveles y generador procedural
  fase5/                        Monetización: Cuerda, Club, anuncios, modelo financiero
  fase6/                        Dirección de arte «Dominó Pop», tablero jugable e inspiración de Pinterest
  legal/                        Marco legal y registro de recursos y licencias
.impeccable/surfaces/           Contrato de dirección visual (skill impeccable)
```

## Fases del proyecto

| Fase | Estado |
|---|---|
| 1. Investigación de Candy Crush y Block Blast | ✅ |
| 2. Análisis de 50 juegos del App Store | ✅ |
| 3. Psicología, retención y monetización | ✅ |
| 4. Concepto original (Cadencia) | ✅ |
| 5. Modelo de negocio | ✅ |
| 6. Dirección de arte | 🔄 Rediseño «Dominó Pop» pendiente de aprobación (DESIGN.md incluido) |
| 7. Viralidad y marketing | ⏸ |
| 8. Arquitectura y desarrollo en Godot | ⏸ |
| 9. Pruebas y optimización | ⏸ |

## Herramientas reproducibles

```bash
# Modelo financiero (escenarios conservador, intermedio y optimista)
python docs/fase5/modelo_financiero.py docs/fase5

# Matriz y clasificaciones de los 50 juegos
python docs/fase2/scripts/matriz.py docs/fase2/datos
```

Solo necesitan Python 3.10 o superior, sin dependencias externas.

## Restricciones del proyecto

- **Presupuesto de desarrollo: 0 €.** Solo se pagan las cuentas de desarrollador de Apple (99 $/año) y Google (25 $, pago único).
- **Herramientas y recursos gratuitos con licencia comercial compatible.** Todo recurso se anota en [docs/legal/REGISTRO_ASSETS.md](docs/legal/REGISTRO_ASSETS.md) **antes** de usarlo.
- **Monetización limpia.** Sin moneda virtual de pago, sin cajas de botín, sin dificultad manipulada y sin falsa escasez. Detalle en el marco legal.

¿Vas a colaborar? Lee **[CONTRIBUTING.md](CONTRIBUTING.md)**.
