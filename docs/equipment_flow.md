# Flujo de equipamiento

Este documento describe como un hueso pasa del inventario al cuerpo del jugador
y como cambia stats/rig visual.

## Objetivo del sistema

Equipar huesos debe modificar el slot correcto del cuerpo, refrescar stats,
actualizar el rig visual y avisar a UI/sistemas externos sin que esos sistemas
dependan directamente del componente.

## Scripts y escenas principales

- `scripts/player_equipment_component.gd`: estado real de equipo por slot.
- `scripts/player_stats_component.gd`: calculo de stats finales del jugador.
- `scripts/equipment_rules_service.gd`: reglas de slots, sockets, ids generados
  por limbs y escalas visuales.
- `scripts/bone_rules_service.gd`: definiciones, bonuses y textos visibles.
- `scripts/bone_database.gd`: API compatible para definiciones planas.
- `scripts/bone_definition.gd`: `Resource` editable que representa un hueso
  hecho a mano.
- `scripts/bone_data_catalog.gd`: fuente limpia de datos para huesos hechos a
  mano.
- `scripts/rig/modular_skeleton_rig.gd`: sockets y piezas visuales del cuerpo.
- `scripts/rig/procedural_player_animator.gd`: anima los sockets ya equipados.
- `scripts/player_inventory_ui.gd`: paper doll, slots, preview y drag/drop.
- `scripts/ui_bone_slot.gd`: valida drop visual hacia un slot.

## Eventos usados

- `GameEvents.bone_equipped(bone_id, slot, player)`.
- `GameEvents.bone_unequipped(bone_id, slot, player)`.
- `GameEvents.inventory_changed(player, items, stats)`.

## Flujo de equipar

1. La UI o el input de equip next llama `player.equip_bone(bone_id)`.
2. `Player` delega a `PlayerEquipmentComponent.equip_bone`.
3. El componente pregunta el slot con `EquipmentRulesService.slot_for_bone`.
4. Si el hueso ya esta equipado en ese slot, no hace nada.
5. Si hay `ModularSkeletonRig`, el componente llama `rig.equip_bone`.
6. Se incrementa `equip_swaps`.
7. Se recalculan stats con `player.recalculate_player_stats`.
8. Se emite `inventory_changed`.
9. Se emite `bone_equipped`.
10. La UI escucha los eventos y refresca grid, paper doll y preview.

## Flujo de desequipar

1. La UI llama `player.unequip_slot(slot)`.
2. `PlayerEquipmentComponent` borra el slot de `equipped`.
3. Si hay rig, llama `rig.unequip_slot(slot)`.
4. Limpia visuales legacy si existen.
5. Recalcula stats.
6. Emite `inventory_changed`.
7. Emite `bone_unequipped`.

## Reglas de slots

El punto central es `EquipmentRulesService`.

Slots principales:
- `right_arm`
- `left_arm`
- `legs`
- `body`
- `head`

Los huesos generados por limbs usan ids como:
- `normal_right_arm_bone`
- `gorilla_left_leg_bone`
- `lizard_body_bone`

Cada id generado contiene:
- slot
- source profile
- limb key
- escala visual
- bonuses de jugador

Los huesos hechos a mano (`arm_bone`, `leg_bone`, `heavy_bone`, etc.) se pueden
representar como `BoneDefinition` Resources con identidad, stats de jugador,
stats de enemigo y datos visuales. Durante esta etapa, `BoneDataCatalog` crea
esos Resources desde sus datos internos y `BoneDatabase` los transforma al
formato plano que todavia consumen `BoneRulesService`, `EquipmentRulesService`,
stats, rig e inventario.

## Responsabilidades

`PlayerEquipmentComponent`:
- Posee `equipped`.
- No construye UI.
- Emite eventos de cambio.
- Pide al rig que aplique visuales.

`ModularSkeletonRig`:
- Solo visual/estructura corporal.
- No decide reglas de inventario.
- Aplica proporciones especiales como gorilla/lizard.

`PlayerStatsComponent`:
- Calcula stats a partir de base stats + equipo.
- No conoce UI ni pickups.

## Puntos delicados

- `Player` debe seguir como orquestador. No mover input o UI directo al
  componente sin actualizar este documento.
- Si se agregan nuevos slots, actualizar:
  - `EquipmentRulesService`
  - `PlayerInventoryUI`
  - `ModularSkeletonRig`
  - este documento
- Si un hueso cambia visualmente el cuerpo, la preview del inventario debe
  mostrarlo tambien.
- Al editar datos de huesos hechos a mano ahora se debe respetar la forma de
  `BoneDefinition`. Solo tocar `BoneDatabase` si se necesita cambiar la
  conversion o compatibilidad.

## Como probar

En `TESTING ENVIRONMENT`:

1. Abrir inventario con `Tab`.
2. Equipar huesos de brazo, piernas, torso y cabeza.
3. Confirmar que el cuerpo del jugador cambia.
4. Confirmar que el preview cambia igual que el jugador.
5. Desequipar con right click o drag hacia zona vacia si aplica.
6. Confirmar que stats en UI cambian.

## Historial de cambios

- 2026-07-14: Se documento el flujo actual. El equipamiento usa
  `GameEvents.bone_equipped`, `bone_unequipped` e `inventory_changed`.
- 2026-07-14: Se preparo la migracion de `BoneDatabase` a datos limpios con
  `BoneDataCatalog`, manteniendo intactos los consumidores actuales.
- 2026-07-14: Se agrego `BoneDefinition` como `Resource` de Godot y
  `BoneDataCatalog` ahora puede convertir cada definicion a ese tipo.
