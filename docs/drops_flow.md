# Flujo de drops y pickups

Este documento describe como aparecen huesos, limbs desprendidos, pickups de
limb y recompensas de camp chests.

## Objetivo del sistema

Los drops deben sentirse fisicos y legibles: los enemigos sueltan limbs, solo
uno de esos limbs puede volverse pickup por enemigo, torso/cabeza caen al final,
y el jugador recoge manteniendo interact.

## Scripts y escenas principales

- `scripts/enemy.gd`: desprende limbs, crea rigid bodies, decide cuando soltar
  bone pickup o standard pickup.
- `scripts/drop_pickup_rules_service.gd`: reglas de que limbs pueden caer,
  cuales pueden ser pickups, prioridad, prompt y hold-to-pickup.
- `scripts/equipment_rules_service.gd`: genera ids de huesos por limb/source.
- `scripts/bone_rules_service.gd`: nombres, colores y descripcion visible.
- `scripts/bone_definition.gd`, `scripts/bone_database.gd` y
  `scripts/bone_data_catalog.gd`: datos de huesos hechos a mano y conversion al
  formato compatible.
- `scenes/bone.tscn` + `scripts/bone.gd`: pickup standard.
- `scripts/limb_bone_pickup.gd`: pickup que vive sobre un limb desprendido.
- `scripts/demo_enemy_camp.gd`: camp chest que da reward al limpiar enemigos.
- `scripts/player_inventory_component.gd`: recibe `collect_bone`.

## Eventos usados

- `GameEvents.drop_spawned(bone_id, pickup, source)`.
- `GameEvents.pickup_focus_changed(pickup, bone_id, player, in_range)`.
- `GameEvents.pickup_collected(bone_id, pickup, collector)`.
- `GameEvents.bone_collected(bone_id, collector)`.
- `GameEvents.camp_chest_opened(camp, reward_bone_id, player)`.
- `GameEvents.camp_state_changed(camp, unlocked, opened, remaining_enemies)`.

## Flujo de limb detach

1. `Enemy.take_hit` calcula dano recibido.
2. `_detach_limbs_for_damage` decide cuantos limbs caeran.
3. `_preferred_detach_keys` pregunta a `DropPickupRulesService`.
4. `_detach_limb_group` oculta el limb del rig y crea una pieza fisica.
5. `_spawn_detached_limb_piece` crea `RigidBody3D` con mesh duplicada.
6. El limb cae con impulso.
7. Si pasa la regla de pickup, se adjunta `LimbBonePickup`.
8. Se emite `drop_spawned`.

## Reglas de drops

Dueño principal: `DropPickupRulesService`.

Reglas actuales:
- Limbs detachables: right arm, left arm, right leg, left leg, body, head.
- Pickups elegibles: todos esos limbs.
- Core fall order: body, head.
- Torso y cabeza caen al final.
- Solo un limb pickup por enemigo.
- El source profile puede ser `normal`, `gorilla` o `lizard`.

Los drops hechos a mano siguen usando ids como `arm_bone` o `heavy_bone`.
Esos ids deben poder resolverse como `BoneDefinition` mediante
`BoneDataCatalog`, preferiblemente desde `data/bones/*.tres`. `BoneDatabase`
los convierte al formato plano que leen pickups, labels, camp chests e
inventario.

Rareza:
- Los campos `rarity`, `rarity_rank`, `rarity_color` y `rarity_drop_weight`
  viven en `BoneDefinition` y pasan por `BoneDatabase`.
- `rarity_drop_weight` y `quality_drop_percent` **si** tienen consumidor desde
  2026-08-04: las tablas de loot de cofres los usan para elegir pieza y para
  sesgar la calidad. Ver `docs/chest_and_loot_flow.md`.
- Los drops de ENEMIGOS siguen sin ponderar: `Enemy` elige el limb por las
  reglas de `DropPickupRulesService`, no por peso de rareza. Unificar ambos
  caminos es trabajo pendiente, no algo que ya ocurra.
- Rarezas canonicas para drops: `comun`, `corrupto`, `maldito`, `especial`,
  `legendario`. No usar labels legacy como `Common`, `Uncommon` o `Rare`.
- Rareza no debe mezclarse con calidad. Calidad describe condicion/valor de la
  pieza; rareza describe probabilidad o categoria de obtencion.

## Flujo de muerte

1. `Enemy.die` emite `enemy_defeated`.
2. `_drop_bone` evita duplicar si ya hubo limb pickup.
3. `_drop_remaining_limbs_on_death` desprende lo restante.
4. Si no se creo pickup de limb, `_drop_standard_bone_pickup` instancia
   `scenes/bone.tscn`.
5. Se emite `drop_spawned`.

## Flujo de pickup

1. Player entra al area del pickup.
2. Pickup llama `enter_bone_pickup_range` en player.
3. Se emite `pickup_focus_changed(..., true)`.
4. Si interact YA estaba apretado al tomar foco, el pickup queda a la espera de
   una pulsacion fresca (`DropPickupRulesService.next_fresh_press_latch`) y no
   acumula nada hasta que el jugador suelte. Sin esto, un pickup que nace bajo
   un dedo ya apretado -- loot de un cofre recien abierto, o un enemigo muerto
   con interact mantenido -- se auto-recoge antes de ser visible.
5. Mientras se mantiene interact, `DropPickupRulesService` calcula progreso.
6. Cuando el hold completa, pickup llama `player.collect_bone`.
7. Se emite `pickup_collected`.
8. Se emite `pickup_focus_changed(..., false)`.
9. El pickup se elimina.

`Player.nearby_bone_pickups` se incrementa y decrementa pero **nadie lo lee**.
No es una exclusion entre interactuables; no construir sobre el.

## Camp chest

Desde 2026-08-04 el camp ya no dibuja ni maneja su cofre: compone un
`LootChest` (`scenes/chest.tscn`). El flujo completo esta en
`docs/chest_and_loot_flow.md`; el resumen es:

1. `DemoEnemyCamp` registra enemigos.
2. Escucha `GameEvents.enemy_defeated`.
3. Cuando todos estan muertos, llama `chest.unlock()`.
4. Emite `camp_state_changed`.
5. El cofre maneja su propio hold y entrega la recompensa.
6. El camp escucha `chest_opened` y reemite `camp_chest_opened`.

## Puntos delicados

- `Enemy` ejecuta el drop, pero las reglas viven en
  `DropPickupRulesService`.
- No duplicar reglas de hold prompt en `bone.gd`, `limb_bone_pickup.gd` o
  `demo_enemy_camp.gd`; usar el servicio.
- No leer `BoneDefinition` ni `BoneDataCatalog` directamente desde pickups. Usar
  `BoneRulesService` o `DropPickupRulesService`, para que los drops generados y
  los huesos hechos a mano sigan una sola ruta.
- Si se agrega un nuevo enemy profile, actualizar:
  - `EquipmentRulesService`
  - `DropPickupRulesService` si cambia elegibilidad
  - `ModularSkeletonRig` si cambia visual
  - este documento
- Si un drop afecta equipamiento, actualizar tambien `equipment_flow.md`.

## Como probar

En `TESTING ENVIRONMENT`:

1. Spawn enemy normal, gorilla, lizard y ranged.
2. Atacar hasta que caigan limbs.
3. Confirmar que torso/cabeza caen al final.
4. Confirmar que solo un limb pickup por enemigo se puede recoger.
5. Recoger el pickup manteniendo interact.
6. Confirmar que aparece en inventario.
7. Confirmar que el limb recogido cambia el cuerpo al equiparlo.

## Historial de cambios

- 2026-07-14: Se documento el flujo actual. Drops/pickups usan
  `DropPickupRulesService` y eventos globales de pickup/drop.
- 2026-07-14: Se preparo `BoneDataCatalog` como datos limpios para drops hechos
  a mano, manteniendo `BoneDatabase` como compatibilidad para pickups actuales.
- 2026-07-14: Se agrego `BoneDefinition` como tipo Resource para que los drops
  hechos a mano puedan migrar a assets editables.
- 2026-07-14: Los drops hechos a mano iniciales (`arm_bone`, `leg_bone`,
  `heavy_bone`, `dummy_bone`, `rib_bone`) ya tienen Resources en `data/bones/`.
- 2026-07-14: Se agregaron campos de rareza y peso de drop por rareza sin
  activar todavia reglas ponderadas de loot.
- 2026-08-04: `rarity_drop_weight` y `quality_drop_percent` pasaron a tener
  consumidor real a traves de las tablas de loot de cofres. Los drops de
  enemigos siguen sin ponderar. `DemoEnemyCamp` ahora compone un `LootChest`
  reutilizable en vez de dibujar el suyo.
- 2026-08-04 (correccion): todos los pickups exigen una pulsacion fresca. Un
  pickup que aparecia mientras interact estaba apretado se recogia solo. Afecta
  a `bone.gd` y `limb_bone_pickup.gd`; la regla vive en
  `DropPickupRulesService.next_fresh_press_latch`.
