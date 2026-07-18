# Indice de flujos de MARROW

Estos documentos son la referencia viva para programadores. Todo cambio de
gameplay debe actualizar el archivo de flujo correspondiente.

## Flujos principales

1. `docs/inventory_flow.md`
   - Inventario, UI, filtros, settings, eventos de inventario.
2. `docs/equipment_flow.md`
   - Slots, rig, equip/unequip, stats, preview.
3. `docs/combat_flow.md`
   - Melee, ranged, stealth, enemy AI, dano, lizard climb.
4. `docs/drops_flow.md`
   - Limb drops, pickups, camp chests, reglas de drops.
5. `docs/camera_flow.md`
   - Orbit camera, aim zoom, raycast, pruebas de camara.
6. `docs/bone_data_structure.md`
   - Estructura de `BoneDefinition`, compatibilidad, calidades, rarezas,
     mutaciones, ataque/combo, stats, peso y pasos para agregar huesos.
7. `docs/tutorial_flow.md`
   - Tutorial de controles, hints del demo y checklist de onboarding.

## Seguimiento y QA

1. `docs/manual_gameplay_qa_checklist.md`
   - Pasada manual repetible para validar gameplay, UI, combate, camara, rig y
     evidencia de PR.
2. `docs/roadmap_progress.md`
   - Tabla operativa de lotes, ramas, evidencia, PRs y pendientes.
3. `docs/p0_runtime_validation_suite.md`
   - Guia especifica para la suite P0 dentro de `scenes/testing_environment.tscn`.
4. `docs/roadmap_1_165.md`
   - Fuente numerada y auditable del roadmap tecnico.
5. `docs/repo_stability_and_graphify.md`
   - Politica de Graphify, line endings, caches y preflight de commits.

## Politica

Leer `docs/change_documentation_policy.md` antes de cerrar cualquier cambio
funcional.

## Escena de prueba recomendada

`scenes/testing_environment.tscn` es la escena unificada para validar:
- camara
- enemigos
- rig
- animaciones
- movimiento
- combate
- drops
- equipamiento
