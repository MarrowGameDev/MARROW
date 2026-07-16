# Repo Stability And Graphify Policy

Fecha base: 2026-07-15

Este documento define como mantener estable el repositorio mientras el roadmap
avanza por ramas de hito. No cambia gameplay.

## Estado Actual

- `graphify-out/` y `graphify-corpus/` siguen versionados como artefactos
  revisables del mapa de arquitectura.
- `graphify-out/cache/` y `graphify-corpus/graphify-out/cache/` son caches y no
  deben entrar al control de versiones.
- El workflow de Graphify solo debe ejecutarse en `main` y `develop`.
- Las ramas feature, fix y test no deben incluir regeneraciones de Graphify.
- Los cambios de line endings deben controlarse mediante `.gitattributes`, no
  por normalizaciones masivas accidentales.

## Politica De Ramas

- Las ramas de gameplay no deben modificar `graphify-out/` ni
  `graphify-corpus/` salvo que el hito sea explicitamente de arquitectura o
  estabilidad del repositorio.
- Si Graphify aparece modificado en una rama de gameplay, tratarlo como salida
  generada accidental y no incluirlo en el commit.
- No usar `Accept Both Changes` en JSON generado.
- No configurar `merge=ours` como solucion silenciosa permanente.
- Si un conflicto de Graphify bloquea un PR, resolverlo en una rama de
  estabilidad o regenerarlo desde la rama oficial, no mezclarlo con la feature.

## Regeneracion

Graphify se regenera con el workflow `.github/workflows/update-graphify.yml`.
El flujo esperado es:

1. Cambios funcionales entran primero por PR normal.
2. El workflow corre en `main` o `develop`.
3. El bot crea un commit `chore: actualiza grafo de arquitectura` solo si la
   salida cambia.
4. Las ramas siguientes parten de la punta actualizada de `origin/main`.

No regenerar Graphify manualmente en ramas de inventario, combate, camara,
preview, jitter, enemigos, stats, animaciones o progresion.

## Line Endings

`.gitattributes` define LF para scripts, escenas, resources, documentacion,
workflows, JSON y archivos `.import`.

Esta politica no normaliza archivos ya existentes por si sola. Si un archivo
aparece modificado solo por CRLF/LF, no debe incluirse automaticamente. Crear
una rama exclusiva de normalizacion solo si hay evidencia de que el ruido de
line endings bloquea el trabajo.

## Preflight De Commit

Antes de cada commit:

```powershell
git status --short --branch
git diff --check
git diff --stat
git diff --name-status
git diff
```

Comprobar especificamente:

- Sin conflictos.
- Sin caches.
- Sin Graphify accidental.
- Sin archivos `.import` accidentales.
- Sin normalizacion masiva de line endings.
- Sin cambios fuera del hito.

## Fuente Del Roadmap

El roadmap numerado vive en `docs/roadmap_1_165.md`. Ese archivo es la fuente
auditable para clasificar objetivos como no iniciados, preparados, parciales,
integrados o validados.
