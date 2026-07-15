# Roadmap Progress

Fecha base: 2026-07-15

Este archivo mantiene una tabla operativa de lotes pequenos para MARROW. Su
objetivo es que cada cambio tenga rama, evidencia y estado verificable sin
tocar `main` directamente.

## Reglas De Seguimiento

- Cada lote debe vivir en una rama dedicada desde `origin/main`.
- Evitar mezclar runtime, UI, datos y documentacion salvo que el cambio lo
  requiera.
- Preferir lotes de bajo conflicto antes de tocar hotspots como
  `scripts/player.gd`, `scripts/enemy.gd`, `scripts/player_inventory_ui.gd`,
  `scripts/rig/procedural_player_animator.gd`, `scripts/rig/modular_skeleton_rig.gd`,
  `scenes/main.tscn` o `project.godot`.
- Registrar validacion real. Si algo no se ejecuto, dejarlo como pendiente.
- Abrir PR en borrador cuando el lote este listo para revision.

## Estado De Lotes

| Fecha | Rama | Tipo | Objetivo | Estado | Evidencia | Pendiente |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-07-15 | `docs/qa-validation-baseline` | Docs / QA | Crear checklist manual y tablero de seguimiento para futuros lotes. | Integrado en `main`; validado estaticamente. | Incluido por la cascada de integracion; `git diff --check`; revision documental. | Ejecutar checklist manual dentro de Godot. |
| 2026-07-15 | `chore/data-bone-validator` | Tools / Datos | Validar integridad de definiciones de huesos y compatibilidad del catalogo. | Integrado en `main`; validado estaticamente. | PR #1; `python -B tools\validate_bone_data.py` OK. | Ejecutar flujo manual de pickups/equipamiento con datos reales. |
| 2026-07-15 | `test/p0-backstab-validation` | Tools / Combate | Cubrir casos de backstab frente, detras, laterales y enemigos rotados sin tocar IA general. | Integrado en `main`; validado estaticamente. | PR #2; `python -B tools\validate_backstab_geometry.py` OK. | Confirmar manualmente en `scenes/testing_environment.tscn` o escena equivalente. |
| 2026-07-15 | `test/p0-preview-validation` | Tools / Preview | Registrar contrato estatico del preview de inventario sin reconstruir `SubViewport` ni `World3D`. | Integrado en `main`; validado estaticamente. | PR #3; `python -B tools\validate_inventory_preview_contract.py` OK. | Validar render, equip/unequip y lifecycle dentro de Godot. |
| 2026-07-15 | `test/p0-jitter-diagnostics` | Tools / Camara / Rig | Diagnosticar contrato de actualizacion de movimiento, camara y rig sin aplicar correccion especulativa. | Integrado en `main`; validado estaticamente con advertencias. | PR #3; `python -B tools\validate_jitter_update_contract.py` OK; advierte hipotesis runtime no demostradas. | Reproducir jitter en runtime antes de cualquier fix. |
| 2026-07-15 | `test/inventory-stack-contract` | Tools / Inventario | Validar que el inventario oculte solo las copias equipadas y conserve duplicados visibles. | Integrado en `main`; validado estaticamente. | PR #3; `python -B tools\validate_inventory_stack_contract.py` OK. | Probar abrir inventario, recoger duplicados y equipar/desequipar en juego. |
| 2026-07-15 | `feature/inventory-stack-count` | UI / Inventario | Mostrar cantidades `xN` agrupando duplicados visibles sin cambiar payload de drag and drop. | Integrado en `main`; validado estaticamente. | PR #3; `python -B tools\validate_inventory_stack_count.py` OK. | Confirmar layout responsive y comportamiento drag/drop en runtime. |
| 2026-07-15 | `integration/marrow-validation-cascade` | Integracion | Juntar lotes de validacion en cascada y limitar Graphify Actions a `main` y `develop`. | Integrado en `main`; remoto de ramas de trabajo ya podado. | PR #3; `45be471` incluido en `origin/main`; Graphify limitado por workflow. | Monitorear checks de GitHub y ejecutar QA manual post-merge. |
| 2026-07-15 | `chore/repo-stability-and-graphify` | Repo / CI / Docs | Definir politica de Graphify, line endings y fuente auditable del roadmap 1-165. | En desarrollo. | `.gitattributes`, `docs/repo_stability_and_graphify.md`, `docs/roadmap_1_165.md`. | Validar, commitear, subir y abrir PR draft o entregar enlace manual. |

## Backlog Tecnico Inmediato

| Prioridad | Sistema | Lote sugerido | Riesgo | Validacion minima |
| --- | --- | --- | --- | --- |
| P0 | Git / proceso | Mantener trabajo de Codex fuera de `main` con ramas por lote. | Bajo | `git status --short --branch` antes y despues. |
| P0 | QA | Ejecutar este checklist en `scenes/testing_environment.tscn` antes de PRs funcionales. | Bajo | Evidencia manual por escena y resolucion. |
| P1 | Combate | Revisar backstab con casos frente/lateral/detras antes de cambiar reglas. | Medio | Dummy/enemigo activo, posiciones controladas, sin cambios especulativos. |
| P1 | Movimiento / camara | Reproducir jitter o head movement antes de parchear. | Medio | Video o pasos exactos, escena y estado del jugador. |
| P1 | Rig / preview | Verificar sincronizacion entre jugador y preview antes de tocar sockets. | Medio | Equip/unequip torso, brazos y piernas en inventario. |
| P2 | Datos de huesos | Migrar mas definiciones a `.tres` sin romper `BoneDatabase`. | Medio | Cache reload, inventario, drops y equipamiento. |
| P2 | Docs | Actualizar flujo afectado con cada cambio funcional. | Bajo | `docs/flow_index.md` apunta al flujo correcto. |

## Plantilla De Lote

```text
Fecha:
Rama:
Tipo:
Objetivo:
Archivos previstos:
Riesgo:
Validacion:
Resultado:
PR:
Pendientes:
```
