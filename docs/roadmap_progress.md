# Roadmap Progress

Fecha base: 2026-07-15. Ultima actualizacion: 2026-07-16.

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
| 2026-07-15 | `chore/repo-stability-and-graphify` | Repo / CI / Docs | Definir politica de Graphify, line endings y fuente auditable del roadmap 1-165. | Integrado en `develop`; validado estaticamente. | `.gitattributes`, `docs/repo_stability_and_graphify.md`, `docs/roadmap_1_165.md`; merge a `develop`. | Abrir PR `develop` hacia `main` solo despues de validar la cascada completa. |
| 2026-07-16 | `chore/repo-stability-and-graphify` | Repo / CI | Cerrar el pendiente de `.gitignore` para el output anidado accidental de Graphify. | Integrado en `develop`. | `.gitignore` actualizado; verificado que 0 archivos requerian renormalizacion (`git ls-files --eol`). | Ninguno. |
| 2026-07-16 | `test/p0-runtime-validation-suite` | Tools / QA | Convertir la guia P0 en un flujo de registro PASS/FAIL/observado/evidencia. | Integrado en `develop`. | Teclas O/P/F en `testing_environment.gd`; log en `user://p0_validation_log.txt`; verificado headless (Godot 4.7, escena real corre 60 frames sin error tras warmup de cache de clases). | Ejecucion manual interactiva de las teclas O/P/F (headless no simula input). |
| 2026-07-16 | `feat/bone-stats-quality-and-weight` | Datos / Stats | Corregir orden de redondeo, exponer claves sin consumidor, documentar unidades. | Integrado en `develop`. | Fix de `aggregate_player_bonuses` (sumar floats, redondear una vez); `get_inventory_stats_snapshot` expone weight/quality; verificado headless con datos reales de hueso. | Ninguno. |
| 2026-07-16 | `fix/inventory-preview-stability` | Inventario / Preview | Corregir orden del snapshot y eliminar resize manual redundante. | Integrado en `develop`. | `sync_preview` cachea solo tras aplicar con exito; `_sync_preview_viewport_size` eliminado (redundante bajo `stretch=true`); verificado headless, escena corre sin error. | Pruebas manuales de render (equipar/desequipar, reapertura, resoluciones). |
| 2026-07-16 | `fix/player-camera-movement-stability` | Camara | Documentar comportamiento sobre 60 FPS y examinar escrituras directas de `global_position`. | Integrado en `develop`. | Documentacion agregada; asimetria encontrada entre detach (compensado) y reattach (sin compensar) de torso/cabeza, registrada sin corregir. | Confirmar/descartar jitter con un humano jugando; QA runtime del reattach. |
| 2026-07-16 | `feat/inventory-equipment-ux-core` | Inventario / Equipamiento | Corregir bug de piernas, limpiar aliases, agregar comparador/deltas/feedback de drag. | Integrado en `develop`. | Bug real de equip-next (siempre `right_leg`) corregido; bug de tipado de GDScript encontrado y corregido de paso; verificado headless: `{"left_leg": "leg_bone", "right_leg": "leg_bone"}`. | Ninguno de lo especificado; UI en ingles ya consistente. |
| 2026-07-16 | `feat/inventory-build-presets` | Inventario / Builds | Implementar aplicacion transaccional real con rollback. | Integrado en `develop`. | Snapshot previo + reaplicacion si falla la verificacion post-apply; bug preexistente de compilacion (`display_name` inexistente) encontrado y corregido; verificado headless en 5 escenarios (valido, vacio, pieza ausente, slot incompatible, rollback forzado). | Ninguno. |
| 2026-07-16 | `feat/bone-durability-mutations-and-synergies` | Datos | Elegir Ruta A (esquema de datos puro) y documentar honestamente el alcance. | Integrado en `develop`. | Cero llamadores externos confirmado por grep; validador y docs corregidos para no sugerir funcionalidad runtime. | Ruta B (runtime real) queda para una rama futura si se decide implementarla. |
| 2026-07-16 | `fix/combat-backstab-stability` | Combate | Corregir freeze, animacion faltante, sincronizacion de impacto. | Integrado en `develop`. | 2 bugs de freeze corregidos (muerte/pausa a mitad de ejecucion; objetivo liberado a mitad de ejecucion); pose de finisher forzada; senal de impacto del animador; verificado headless con jugador y enemigo reales. | Pausa real en editor (mismo codigo que muerte, no ejercido); confirmacion visual de pose/reaccion/camara. |

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
