# Cómo trabajamos en Dingfall

Somos tres personas. Estas reglas sirven para no pisarnos los cambios y para que el proyecto siga siendo coherente.

## Flujo con Git

1. **`main` siempre está estable.** Nadie sube cambios directamente a `main`.
2. Cada tarea va en **su propia rama**, con un nombre descriptivo:
   - `diseno/titulo-logo`
   - `investigacion/marca-nombre`
   - `godot/prototipo-caida`
3. Al terminar, se abre un **Pull Request** hacia `main`. **Otra persona del equipo lo revisa** antes de fusionarlo.
4. Antes de empezar, actualiza tu copia: `git pull origin main`.

```bash
git clone https://github.com/ohganon/cadencia.git
cd cadencia
git checkout -b diseno/mi-cambio
# ...cambios...
git add -A
git commit -m "Explica qué cambia y por qué"
git push -u origin diseno/mi-cambio
# después, abre el Pull Request en GitHub
```

## Reglas del proyecto

- **El documento maestro manda.** Si tomas una decisión, apúntala en [docs/00_DOCUMENTO_MAESTRO.md](docs/00_DOCUMENTO_MAESTRO.md) dentro del mismo Pull Request.
- **Las líneas rojas legales no se discuten en un Pull Request.** Si crees que una debe cambiar, se habla antes entre los tres: [docs/legal/MARCO_CUMPLIMIENTO_LEGAL.md](docs/legal/MARCO_CUMPLIMIENTO_LEGAL.md).
- **Ningún recurso** (imagen, sonido, música, fuente) entra sin estar en [docs/legal/REGISTRO_ASSETS.md](docs/legal/REGISTRO_ASSETS.md), con su licencia y su enlace.
- **Nunca se suben secretos:** claves de AdMob, keystores de Android, certificados de Apple ni archivos `.env`. El `.gitignore` ya los excluye, pero revísalo antes de hacer commit.
- **Datos:** cuando una cifra sea una estimación, indícalo y cita la fuente, como en el resto de los informes.

## Cómo proponer cambios de diseño

La identidad visual está definida en [docs/fase6/INFORME_FASE6_Direccion_Arte.md](docs/fase6/INFORME_FASE6_Direccion_Arte.md) y en el tablero `docs/fase6/tablero/index.html`.

- Los cambios **dentro** del sistema (ajustes, pantallas nuevas con la misma paleta y las mismas tipografías) se proponen con un Pull Request normal.
- Los cambios **del** sistema (otra paleta, otra tipografía, otro mundo visual) se hablan antes entre los tres.
