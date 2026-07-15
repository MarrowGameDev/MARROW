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

Los huesos hechos a mano (`arm_bone`, `leg_bone`, `heavy_bone`, etc.) viven
como `BoneDefinition` Resources en `data/bones/`. `BoneDataCatalog` carga esos
assets primero y solo usa sus diccionarios internos como fallback temporal.
`BoneDatabase` transforma cada Resource al formato plano que todavia consumen
`BoneRulesService`, `EquipmentRulesService`, stats, rig e inventario.

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

- Inicio/progresion corporal:
  - El jugador inicia con `head_bone` equipado como nucleo fijo.
  - La cabeza no se puede reemplazar ni desequipar; si se rompe, el jugador
    muere.
  - El torso (`body`) debe equiparse antes de brazos o piernas.
  - Si el torso se quita, las extremidades se desacoplan primero.
  - Brazos y piernas no tienen orden obligatorio entre si una vez equipado el
    torso.
- `Player` debe seguir como orquestador. No mover input o UI directo al
  componente sin actualizar este documento.
- Si se agregan nuevos slots, actualizar:
  - `EquipmentRulesService`
  - `PlayerInventoryUI`
  - `ModularSkeletonRig`
  - este documento
- Si un hueso cambia visualmente el cuerpo, la preview del inventario debe
  mostrarlo tambien.
- Al editar datos de huesos hechos a mano, cambiar el `.tres` correspondiente
  en `data/bones/`. Solo tocar `BoneDataCatalog` si se agrega un id nuevo o se
  necesita fallback; solo tocar `BoneDatabase` si cambia la compatibilidad.
- No cambiar consumidores existentes para leer `BoneDefinition` directo.
  `BoneDatabase.get_def` y `BoneRulesService.definition_for` siguen entregando
  el diccionario plano que el rig, stats y slots ya esperan.
- Los campos de calidad (`quality_rank`, `quality_score`,
  `quality_multiplier`, `quality_color`) viajan por el mismo diccionario plano.
  `BoneRulesService.player_stats_with_equipment()` aplica `quality_multiplier`
  sobre los bonuses directos del jugador antes de agregarlos al resultado final.
- Los modificadores porcentuales por calidad (`quality_damage_percent`,
  `quality_speed_percent`, `quality_health_percent`, `quality_drop_percent`,
  `quality_weight_percent`) son metadata granular. Damage, speed, health y
  weight ya alimentan la formula determinista de stats; drop sigue pasivo hasta
  que una regla de drops lo consuma.
- Las calidades canonicas son ids en minuscula y sin acentos para datos:
  `chatarra`, `fragil`, `comun`, `fuerte`, `legendario`. Si UI necesita
  acentos o traduccion, debe mapearlos al presentar texto, no cambiar el id.
- Las rarezas canonicas son `comun`, `corrupto`, `maldito`, `especial` y
  `legendario`. Las familias de mutacion canonicas actuales son vacio,
  `corrupto`, `maldito`, `especial` e `hibrido`.
- Rareza y mutacion siguen siendo metadata pasiva hasta que una regla de drops,
  rig o combate las consuma explicitamente.
- Los campos de mutacion (`mutation_id`, `mutation_family`, `mutation_stage`,
  `mutation_intensity`, `mutation_tags`) describen transformaciones potenciales
  de una pieza. No deben cambiar rig/stats automaticamente hasta que exista una
  regla de equipamiento que los consuma.
- Los campos de ataque/combo (`attack_type`, `attack_tags`, `combo_family`,
  `combo_step`, `combo_window`, `combo_tags`, `combo_finisher`) describen como
  una pieza podria participar en cadenas de combate. Actualmente solo alimentan
  una cadena visual simple; equipar una pieza no debe cambiar dano, cooldown ni
  hitboxes sin una regla dedicada.
- Los campos de peso (`weight`, `weight_class`, `physical_weight`,
  `equipment_weight`, `inventory_weight`) separan respuesta fisica, carga al
  equipar e impacto de inventario. `weight` queda como campo legacy para la
  animacion procedural actual. `equipment_weight` contribuye a una penalizacion
  suave de velocidad cuando la carga equipada supera el umbral libre.
- Los campos de set/sinergia (`set_id`, `set_name`, `set_piece_key`,
  `set_tags`, `synergy_ids`, `synergy_tags`, `synergy_score`) permiten detectar
  combinaciones de piezas. No aplican bonuses automaticamente todavia.
- `head_bone` y `torso_bone` son piezas de progresion inicial. `head_bone` no
  entra al inventario normal; `torso_bone` aparece como pickup starter en el
  demo.
- Las piezas pueden definir `hitbox_size`, `hitbox_offset`, `hitbox_scale` y
  `hitbox_rotation`. `ModularSkeletonRig` consume esos campos al equipar para
  ajustar el hurtbox de cada socket individual. Si no hay `hitbox_size`, el rig
  deriva el tamano desde la geometria base y `visual_scale`.
- Los torsos pueden definir `head_socket_offset`. `ProceduralPlayerAnimator`
  lee ese valor desde el hueso equipado en `body` para colocar el origen de la
  cabeza segun la forma del torso. Esto permite que un torso pesado, largo o
  lizard-like cambie la altura/profundidad de la cabeza sin tocar el player.
- Cuando la cabeza se separa por fallar un ataque torso-solo, el slot `body`
  queda bloqueado para nuevos equips. `PlayerEquipmentComponent` solo permite
  restaurar el torso abandonado mediante `restore_detached_body()` cuando el
  player vuelve al marcador y mantiene `Interact`.
- El marcador del torso abandonado se coloca desde el `VisualRoot` actual del
  player mas el origen del rig antes de mover la capsula hacia la cabeza. No
  debe depender primero de un transform global cacheado por el animator, porque
  ese cache puede quedarse viejo y mandar el torso siempre al mismo sitio.
- Despues de elegir ese X/Z, `Player` hace un raycast hacia abajo y sube el
  marcador por media altura del mesh del torso. Asi el torso abandonado queda
  apoyado en el piso o plataforma, no flotando a la altura de la capsula. El
  transform final se calcula antes y se aplica despues de agregar el marker a la
  escena, para no leer `global_position` desde un nodo temporal sin parent.
- Mientras se mantiene `Interact`, el progreso del hold controla
  `ProceduralPlayerAnimator.set_detached_head_reattach_tornado_progress()`.
  La cabeza sube en espiral diagonal alrededor del marcador del torso hasta el
  socket de cabeza. Si se suelta `Interact` antes de completar el hold,
  `cancel_detached_head_reattach_tornado_to_ground()` cancela la espiral y deja
  caer la cabeza al modo head-only. Solo al llegar al 100% se llama
  `restore_detached_body()` para volver a equipar el torso abandonado.
- El punto final de la espiral usa la rotacion del marcador del torso mas
  `head_socket_offset` / `head_origin_offset` del torso que se esta restaurando.
  Al completarse el hold, `Player` captura la posicion global actual de la
  cabeza, alinea la pose estable del cuerpo y el yaw del rig al marcador del
  torso, y luego vuelve a aplicar esa posicion capturada a la cabeza antes de
  restaurar el torso. Asi la animacion normal vuelve desde el marcador y el
  cuerpo no se mueve ni rota despues de que la cabeza ya se acoplo.
  Despues de `restore_detached_body()`,
  `play_detached_head_reattach_finish_blend()` solo mezcla la cabeza hacia la
  pose normal del rig. No fija el socket del torso al marcador abandonado,
  porque eso puede crear un teleport visible cuando la animacion normal vuelve a
  controlar el cuerpo.
- Reattach solo alinea el root del jugador al completarse, despues de que la
  cabeza llega al marcador del torso. Esa alineacion usa el marcador actual, no
  datos cacheados del ataque, para que el cuerpo restaurado se quede quieto
  despues de terminar el acople.
- El bow depende de brazos equipados. `Player._can_use_bow()` revisa el estado
  de equipamiento y exige `right_arm` y `left_arm`; si falta cualquiera de los
  dos brazos, el bow se oculta, se cancela aim y no puede disparar flechas.
  Finger bones siguen siendo el fallback sin bow.
- El mismo contrato de `hitbox_*` aplica para jugador y enemigos. La diferencia
  vive en el grupo de dano (`player_body_hurtboxes` o `enemy_body_hurtboxes`),
  no en datos duplicados. Los enemigos aplican un recorte adicional de precision
  mediante `ENEMY_HITBOX_ACCURACY_SCALE` despues de registrar su owner.

## Como probar

En `TESTING ENVIRONMENT`:

1. Abrir inventario con `Tab`.
2. Confirmar que la cabeza inicial ya esta equipada y no se puede reemplazar.
3. Equipar torso.
4. Equipar huesos de brazo y piernas.
5. Confirmar que el cuerpo del jugador cambia.
6. Confirmar que el preview cambia igual que el jugador.
7. Desequipar con right click o drag hacia zona vacia si aplica.
8. Confirmar que stats en UI cambian.

## Historial de cambios

- 2026-07-14: Se documento el flujo actual. El equipamiento usa
  `GameEvents.bone_equipped`, `bone_unequipped` e `inventory_changed`.
- 2026-07-14: Se preparo la migracion de `BoneDatabase` a datos limpios con
  `BoneDataCatalog`, manteniendo intactos los consumidores actuales.
- 2026-07-14: Se agrego `BoneDefinition` como `Resource` de Godot y
  `BoneDataCatalog` ahora puede convertir cada definicion a ese tipo.
- 2026-07-14: Se agregaron campos pasivos de ataque/combo a los huesos y limbs
  generados para preparar previews y futuras reglas de cadenas de combate.
- 2026-07-14: Se movieron los huesos hechos a mano iniciales a
  `data/bones/*.tres`. La migracion sigue siendo gradual porque el diccionario
  queda como fallback.
- 2026-07-14: Se mantuvo compatibilidad legacy en `BoneDatabase` con cache
  `BONES`, `definitions` y `reset_cache`.
- 2026-07-14: Se agregaron campos de calidad para preparar ordenamiento,
  estado visual y balance futuro sin cambiar el contrato de equipamiento. Estos
  campos no representan rareza de loot.
- 2026-07-14: Se agregaron campos de mutacion para preparar variantes visuales,
  cuerpo hibrido y respuestas especiales sin acoplarlas todavia al rig.
- 2026-07-14: Se agregaron campos de peso granulares manteniendo `weight` como
  compatibilidad para animacion.
- 2026-07-14: Se agregaron campos de set/sinergia como metadata pasiva para
  futuras reglas de combinacion.
- 2026-07-14: Se agregaron modificadores porcentuales por calidad separados de
  `quality_multiplier` para preparar balance granular.
- 2026-07-14: Se definieron calidades canonicas (`chatarra`, `fragil`,
  `comun`, `fuerte`, `legendario`) y se migraron los huesos base a esos ids.
- 2026-07-14: Se definieron rarezas/mutaciones canonicas y se migraron los
  valores legacy `Common`, `Uncommon`, `Rare` y `hybrid_growth`.
- 2026-07-14: Se agrego `docs/bone_data_structure.md` como referencia principal
  de estructura de datos de huesos para programadores.
- 2026-07-14: El jugador ahora inicia como cabeza fija, necesita torso para
  acoplar extremidades, y el rig muestra solo las partes recuperadas.
- 2026-07-14: Se agregaron hurtboxes por parte del cuerpo al rig. Equipamiento
  ahora puede ajustar cajas de dano por pieza usando campos `hitbox_*`.
- 2026-07-14: Se separo el consumo de hurtboxes entre jugador y enemigos usando
  grupos distintos sin duplicar los campos de authoring.
- 2026-07-15: `BoneRulesService` aplica calidad, modificadores porcentuales y
  carga equipada al calculo determinista de stats del jugador.
