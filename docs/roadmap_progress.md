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
| 2026-07-15 | `codex/qa-validation-baseline` | Docs / QA | Crear checklist manual y tablero de seguimiento para futuros lotes. | En progreso | `git status`, `git diff --check`, revision documental. | Commit, push y PR draft. |

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
