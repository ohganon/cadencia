# Prueba de la puerta 0: ¿engancha el prototipo?

**Fecha:** 18/11/2026
**Estado:** listo para usar en cuanto el prototipo funcione en un móvil (entrega 1).
**Coste:** 0 €

La puerta 0 del [plan de lanzamiento](../fase7/PLAN_LANZAMIENTO.md) decide si merece la pena construir el resto del juego. Es la prueba más barata y la más importante: **si la mecánica no engancha con 10 niveles, no la arreglarán 500.**

---

## 1. Qué queremos saber

| Pregunta | Cómo se mide | Umbral para pasar [HIPÓTESIS] |
|---|---|---|
| ¿Engancha? | Al terminar los 10 niveles, ¿pide la persona más niveles **sin que se lo preguntemos**? | **Al menos la mitad** |
| ¿Se entiende sin explicaciones? | Niveles 1–3 superados sin pista | 8 de cada 10 personas |
| ¿Se entiende la idea estrella? | Niveles 7–9 (campana doble) superados sin pista | 6 de cada 10 |
| ¿Dibujar frustra? | Observación: trazos repetidos por imprecisión del dedo, quejas, gestos de fastidio | Nadie abandona por el control |
| ¿Hay un nivel roto? | Intentos hasta superarlo (registro del juego) | Ningún nivel con más del doble de intentos que sus vecinos |

Si **no** se pasa el primer umbral, no se avanza a la entrega 2: se revisan los primeros niveles, el tutorial o la propia mecánica, y se repite la prueba con otras personas.

## 2. Participantes

- **10–15 personas ajenas al equipo.** Amigos de amigos sirve; el equipo y sus parejas no (ya saben de qué va).
- Mezcla de edades dentro del público (15–55) y de costumbre de jugar: la mitad que juegue a puzles en el móvil y la mitad que no.
- **Solo mayores de 18 años en esta prueba.** Con menores haría falta el permiso de sus padres; no compensa para un prototipo.
- Cada sesión, de 15 a 25 minutos, con una persona cada vez.

## 3. Privacidad (marco legal)

- **No se graba ni la cara ni la voz.** Solo notas escritas en la hoja de observación.
- **No se apunta el nombre** en la hoja: cada sesión es «P1», «P2»…
- El registro del juego (`registro_pruebas.jsonl`) **solo guarda nivel, resultado, fichas, tiempo y pistas**, se queda en el teléfono y no lleva ningún dato personal. Hay una prueba automática que comprueba que no guarda nada más.
- Al empezar se dice en voz alta: «Es un juego en desarrollo. No se graba nada; solo apunto qué tal va. Puedes parar cuando quieras.»

## 4. Cómo se hace la sesión

1. **Preparar:** el móvil cargado, el juego instalado y el progreso a cero (desinstalar y volver a instalar). Sonido activado.
2. **Lo único que se dice:** «Es un juego de dominó en desarrollo. Juega como quieras. Si te apetece, piensa en voz alta.» **No se explica cómo se juega.** Si preguntan, se responde «¿qué crees tú?».
3. **Mientras juega, el observador apunta** (hoja de la sección 5) sin ayudar. Solo se interviene si lleva más de 3 minutos atascado y frustrado; se anota como «ayuda del observador».
4. **La sesión cubre los niveles 1–10**, los hechos a mano. Desde el 18/11/2026 el mapa tiene 20 niveles (11–20 del generador), así que el juego no se para solo en el 10: **al terminar el nivel 10, el observador dice únicamente «Hasta aquí la prueba»** y no añade nada. **Aquí está la medida clave:** se queda callado 10 segundos. ¿Pide más? ¿Pregunta si hay más niveles? ¿Sigue jugando el 11 por su cuenta o vuelve a alguno para sacar la segunda estrella? Se anota tal cual. (Si alguien sigue jugando sin preguntar, cuenta como «pide más».)
5. **Cinco preguntas finales** (en este orden, sin sugerir respuestas):
   1. ¿De qué va el juego, con tus palabras?
   2. ¿Qué momento te ha gustado más?
   3. ¿Qué te ha frustrado?
   4. Si estuviera en la tienda, ¿lo instalarías? ¿Por qué?
   5. ¿Cuánto rato crees que jugarías a la semana?
6. **Antes de devolver el móvil**, en «Niveles › Resumen de la prueba» aparecen los intentos por nivel. Se hace una foto de esa pantalla y se adjunta a la hoja.

## 5. Hoja de observación (una por persona)

| Campo | Anotación |
|---|---|
| Sesión | P__ · fecha · edad aproximada (18–25, 26–40, 41–55) · ¿juega a puzles en el móvil? |
| Primer contacto | ¿Encuentra solo cómo empezar a dibujar? ¿Cuánto tarda? |
| Ramas (nivel 4) | ¿Descubre solo que se puede abrir una rama desde una ficha? |
| Campana doble (niveles 7–9) | ¿Entiende que las ramas tienen que medir lo mismo? ¿Usa «Lento»? |
| Frustraciones | Momento y motivo (control, nivel, texto, otra cosa) |
| Momentos buenos | Risas, «¡ahí va!», repeticiones por gusto |
| Ayuda del observador | Nivel y qué se dijo |
| **Al acabar el nivel 10** | ¿Pide más sin que se le pregunte? (sí / no) y frase literal |
| Respuestas 1–5 | Literales, sin resumir |
| Foto del resumen | Adjunta |

## 6. Cómo se decide

- Se juntan las hojas en una tabla (la misma hoja compartida del plan de TikTok sirve).
- **Pasa** si se cumplen los umbrales de la sección 1. Sobre todo el primero.
- **No pasa:** se buscan patrones (un nivel concreto, el control, la campana doble) antes de cambiar nada, y se cambia **una cosa cada vez**.
- Los umbrales son [HIPÓTESIS] razonables, no datos. Si el equipo decide otros, se fijan **antes** de hacer las pruebas, nunca después de ver los resultados.

## 7. Qué hace falta antes de empezar

- [x] Los 10 niveles, con sus soluciones comprobadas.
- [x] Pantalla de juego, sonido, cámara lenta y registro local.
- [x] APK instalable en Android (`godot/exportaciones/dingfall-prueba.apk`, 18/11/2026).
- [ ] Un móvil Android de gama media para las pruebas.
- [ ] Imprimir o copiar 15 hojas de observación.
