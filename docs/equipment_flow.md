# Flujo de equipamiento

Este documento describe como un hueso pasa del inventario al cuerpo del jugador
y como cambia stats/rig visual.

## Objetivo del sistema

Equipar huesos debe modificar el slot correcto del cuerpo, refrescar stats,
actualizar el rig visual y avisar a UI/sistemas externos sin que esos sistemas
dependan directamente del componente.

## Scripts y escenas principales

- `scripts/player_equipment_component.gd`: estado real de equipo por slot.
- `scripts/player_equipment_builds_component.gd`: presets guardables de
  equipamiento que delegan aplicacion real en `PlayerEquipmentComponent`.
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

1. La UI o el input de equip next llama `player.equip_bone(bone_id)`. Si el
   usuario suelta una pieza sobre un slot especifico, la UI pasa tambien
   `target_slot`.
2. `Player` delega a `PlayerEquipmentComponent.equip_bone`.
3. El componente resuelve compatibilidad con
   `EquipmentRulesService.compatible_slots_for_bone` y normaliza el slot con
   `EquipmentRulesService.normalize_slot_id`.
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

## Flujo de build presets

1. La UI llama `player.save_equipment_build(index)` para capturar el equipo
   actual no-core.
2. `PlayerEquipmentBuildsComponent` normaliza slots, omite la cabeza fija y
   guarda el build en `user://equipment_builds.cfg`.
3. La UI llama `player.apply_equipment_build(index)`.
4. El componente valida inventario disponible, slots compatibles y torso
   requerido antes de tocar el equipo.
5. Si la validacion falla, no aplica cambios parciales y devuelve un mensaje
   para la UI.
6. Si la validacion pasa, desequipa slots no presentes en el build y equipa en
   orden estable: torso, brazos, piernas.
7. `PlayerEquipmentComponent` recalcula stats, actualiza rig y emite eventos por
   la ruta normal.

## Reglas de slots

El punto central es `EquipmentRulesService`.

Slots principales:
- `head`
- `torso`
- `left_arm`
- `right_arm`
- `left_leg`
- `right_leg`

Aliases legacy aceptados (solo los que tienen consumidor real en
`data/bones/*.tres`; no agregar aliases especulativos):
- `body` -> `torso`
- `legs` -> compatible con `right_leg` y `left_leg` (equip-next resuelve al
  primer lado libre via `PlayerEquipmentComponent._first_open_compatible_slot`;
  `normalize_slot_id("legs")` sigue devolviendo `right_leg` como valor unico
  por defecto para contextos que necesitan un solo id, como display/orden)

`torso` es el slot de equipamiento. `body` sigue siendo un socket del rig y un
valor legacy en datos viejos. No se debe mezclar socket del rig, slot de equipo
y parte corporal sin pasar por `EquipmentRulesService`.

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
  - El torso (`torso`, alias legacy `body`) debe equiparse antes de brazos o
    piernas.
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
- Las piezas legacy hechas a mano pueden seguir declarando `body` o `legs`
  durante la migracion. El runtime debe normalizarlas antes de guardar estado
  de equipamiento, pintar el rig o validar drops.
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
- Los campos de durabilidad (`durability_max`, `durability_start`,
  `durability_repair_cost`, `durability_tags`) describen resistencia y coste de
  reparacion por tipo de pieza. `BoneRulesService` calcula perfiles y estados,
  pero equipar una pieza no desgasta ni repara automaticamente todavia.
- Rareza y mutacion siguen siendo metadata pasiva hasta que una regla de drops,
  rig o combate las consuma explicitamente.
- Los campos de mutacion (`mutation_id`, `mutation_family`, `mutation_stage`,
  `mutation_intensity`, `mutation_tags`) describen transformaciones potenciales
  de una pieza. No deben cambiar rig/stats automaticamente hasta que exista una
  regla de equipamiento que los consuma. `mutation_profile_for` centraliza su
  lectura para futuros consumidores.
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

### Unidades Y Formula De Peso/Calidad (`BoneRulesService`)

Todas las constantes viven en `scripts/bone_rules_service.gd`. No hay
unidades fisicas reales (kg, etc.); son numeros de diseno adimensionales
calibrados por prueba y error, igual que el resto del balance del proyecto.

- `EQUIPMENT_FREE_WEIGHT := 3.0`: suma de `equipment_weight` (peso ya
  ajustado por calidad) que el jugador carga sin penalizacion. Mismas
  unidades que `weight`/`equipment_weight` en los `.tres` de hueso.
- `EQUIPMENT_LOAD_SPEED_PENALTY_PER_WEIGHT := 0.06`: fraccion de
  `move_speed` que se resta por cada unidad de `equipment_weight` que
  excede `EQUIPMENT_FREE_WEIGHT`. Ejemplo: 5.0 de peso equipado con 3.0
  libres deja 2.0 sobre el umbral, penalizacion = 2.0 * 0.06 = 0.12 (12%).
- `EQUIPMENT_LOAD_SPEED_PENALTY_MAX := 0.30`: techo de la penalizacion de
  velocidad (30%), sin importar cuanto peso adicional se equipe.
- `PLAYER_STAT_PERCENT_LIMIT := 0.75`: techo/piso (+-75%) para la suma de
  `quality_damage_percent`, `quality_speed_percent`, `quality_health_percent`
  y `quality_weight_percent` acumulados por todas las piezas equipadas.
- Orden de aplicacion en `player_stats_with_equipment()`: 1) sumar bonuses
  planos (`move_speed_bonus`, etc.) ajustados por `quality_multiplier` por
  pieza; 2) sumar y limitar los porcentajes de calidad; 3) calcular la
  penalizacion de carga desde `equipment_weight` total; 4) aplicar
  `(1 + porcentaje) * (1 - penalizacion_de_carga)` sobre velocidad, y
  `(1 + porcentaje)` sobre dano/vida.
- `attack_damage` y `max_health` se redondean una sola vez, despues de sumar
  los bonuses de todas las piezas equipadas como floats. Redondear cada
  pieza por separado antes de sumar inflaria el total con mas piezas
  equipadas incluso si la suma real no cambia (ver comentario en
  `adjusted_player_bonus_for`).
- Los campos de set/sinergia (`set_id`, `set_name`, `set_piece_key`,
  `set_tags`, `synergy_ids`, `synergy_tags`, `synergy_score`) permiten detectar
  combinaciones de piezas. `equipment_synergy_summary` puede detectar sets e
  ids repetidos en el equipo, pero no aplica bonuses automaticamente todavia.
- Build presets no son una segunda fuente de estado. Solo persisten una
  intencion de equipamiento y deben revalidarse contra inventario y reglas
  actuales cada vez que se aplican.
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
5. Confirmar que `Left Arm`, `Right Arm`, `Left Leg` y `Right Leg` cambian solo
   el lado correspondiente.
6. Confirmar que el preview cambia igual que el jugador.
7. Desequipar con right click o drag hacia zona vacia si aplica.
8. Confirmar que stats en UI cambian.
9. Guardar un build en Settings, modificar equipo y aplicar el build guardado.
10. Intentar aplicar un build que necesita dos copias del mismo hueso teniendo
    solo una copia; debe mostrar error y no dejar cambios parciales.
11. Presionar Apply una vez y confirmar que el boton cambia a "Confirm?" y el
    equipo NO cambia todavia; presionar de nuevo dentro de unos segundos y
    confirmar que ahora si aplica. Presionar Apply una vez y esperar mas de
    4 segundos sin presionar de nuevo; confirmar que el boton vuelve a decir
    "Apply" y no paso nada.
12. Guardar sobre un build ya ocupado y confirmar que tambien pide una
    segunda pulsacion; guardar sobre un build vacio y confirmar que NO la
    pide (aplica directo).

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
- 2026-07-15: Se agregaron campos de durabilidad authorable y helpers puros
  para perfiles de durabilidad, mutacion y resumen de sinergias equipadas.
- 2026-07-15: Equipamiento adopto seis slots canonicos (`head`, `torso`,
  `left_arm`, `right_arm`, `left_leg`, `right_leg`). `body` y `legs` quedan como
  aliases legacy normalizados por `EquipmentRulesService`; el rig conserva sus
  sockets `body`/`body_lower` sin usarlos como ids de estado de equipo.
- 2026-07-15: Se agregaron build presets de equipamiento. La persistencia vive
  en `PlayerEquipmentBuildsComponent`, la aplicacion usa
  `PlayerEquipmentComponent`, y cada apply revalida copias, torso y
  compatibilidad de slots.
- 2026-07-15: `BoneRulesService` aplica calidad, modificadores porcentuales y
  carga equipada al calculo determinista de stats del jugador.
- 2026-07-15: Se documentaron unidades y formula exacta de peso/calidad. Se
  corrigio `aggregate_player_bonuses` para sumar bonuses de dano/vida como
  floats y redondear una sola vez (antes cada pieza equipada redondeaba por
  separado, inflando el total con mas piezas equipadas). Se expusieron
  `equipment_weight`, `inventory_weight`, `load_speed_penalty` y los
  `quality_*_percent` en `Player.get_inventory_stats_snapshot()`, que antes
  se calculaban y se descartaban sin ningun consumidor. No se agrego
  defensa, stamina ni movilidad: esos stats no existen en el proyecto.
- 2026-07-15 (correccion): `_slot_for_request` resolvia el slot por defecto
  de un hueso bilateral (`legs`, o `right_arm` sin `limb_key`) llamando a
  `EquipmentRulesService.slot_for_bone`, una funcion pura sin estado que
  siempre devuelve el primer slot compatible. Equipar-siguiente con dos
  huesos de pierna genericos nunca podia alcanzar `left_leg`. Se agrego
  `PlayerEquipmentComponent._first_open_compatible_slot`, que consulta el
  `equipped` real del componente y elige el primer slot compatible vacio.
  Verificado en Godot 4.7 headless: dos `leg_bone` equipados via
  equip-next ahora terminan en `{"left_leg": "leg_bone", "right_leg":
  "leg_bone"}`. De paso se encontro y corrigio un bug de tipado de
  GDScript: `compatible_slots_for_bone` devolvia arrays literales sin
  tipar explicitamente, lo cual fallaba en runtime ("Trying to assign an
  array of type Array to a variable of type Array[String]") para
  cualquier llamador externo a la clase que asignara el resultado a una
  variable tipada; ahora construye el array con `.append()`.
- 2026-07-15: Se eliminaron 7 de los 9 aliases legacy de slot (`ribs`,
  `ribcage`, `chest`, `arm_left`, `arm_right`, `leg_left`, `leg_right`):
  ningun archivo en `data/bones/*.tres` ni codigo en `scripts/` los produce
  (verificado por grep). Solo quedan `body` y `legs`, que si tienen datos
  reales. `tools/validate_bone_data.py` actualizado para no exigirlos.
- 2026-07-15: Se elimino `PlayerEquipmentComponent.get_equipped_bone_defs`
  (cero llamadores; existe una funcion homonima pero distinta en
  `ModularSkeletonRig` que si se usa).
- 2026-07-15: El panel de informacion del inventario ahora compara el hueso
  bajo el cursor contra el equipado en el mismo slot (deltas de
  move_speed/attack_range/attack_damage/max_health via
  `BoneRulesService.adjusted_player_bonus_for`, los unicos stats de hueso
  que existen). No se inventaron stats de defensa/peso para la comparacion.
- 2026-07-15: `BoneSlotWidget` pinta el borde del slot en verde/rojo
  mientras un drag lo sobrevuela, segun `can_equip_bone_in_slot`, y lo
  restaura en `NOTIFICATION_DRAG_END`.
- 2026-07-15 (correccion): `PlayerEquipmentBuildsComponent.apply_build`
  aplicaba el estado objetivo y solo reportaba si no coincidia del todo;
  nunca deshacia el cambio parcial. Ahora guarda un snapshot del
  equipamiento antes de aplicar y reaplica ese snapshot si la
  verificacion post-apply falla. Verificado en Godot 4.7 headless con 5
  escenarios (build valido, build vacio, pieza no disponible, slot
  incompatible, y un rollback forzado): el estado final tras el rollback
  forzado coincidio exactamente con el estado previo a la aplicacion. De
  paso se encontro y corrigio un bug preexistente desde el primer commit
  de esta rama: `_summary_for_state` llamaba
  `BoneRulesService.display_name` (nunca existio), lo cual rompia la
  compilacion de GDScript de `player.gd` completo -- el validador estatico
  nunca pudo detectarlo porque no ejecuta GDScript.
- 2026-07-15: Guardar sobre un build no vacio y Aplicar un build ahora
  requieren una segunda pulsacion del mismo boton dentro de 4 segundos
  para confirmar (sin dialogo nativo, mismo estilo DIY del resto de la UI).
