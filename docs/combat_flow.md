# Flujo de combate

Este documento describe combate del jugador, enemigos, proyectiles, stealth,
danio, limb loss, huida y respuesta de AI.

## Objetivo del sistema

El combate debe permitir probar melee, arco/finger bones, stealth finish,
enemigos normales, enemigos ranged, gorillas, lizards, dano por contacto,
perdida de limbs, crawling, drops y reacciones de AI.

## Scripts y escenas principales

- `scripts/player.gd`: input de ataque, arco, stealth finish, dano recibido y
  muerte.
- `scenes/attack_hitbox.tscn` + `scripts/attack_hitbox.gd`: hitbox melee.
- `scripts/arrow_projectile.gd`: flechas, finger bones, saliva y proyectiles
  compartidos.
- `scripts/enemy.gd`: AI, vision, hearing, melee, ranged, gorilla rock throw,
  lizard saliva, damage, limb detach, flee, crawl, death y respawn.
- `scripts/enemy_rock_projectile.gd`: roca de gorilla.
- `scripts/player_camera_controller.gd`: aim point para disparos.
- `scripts/rig/procedural_player_animator.gd`: animaciones de ataque, aim,
  crawl y climb blend.
- `scripts/bone_definition.gd`, `scripts/bone_database.gd` y
  `scripts/bone_data_catalog.gd`: stats de huesos que modifican perfiles de
  combate del jugador y enemigos.

## Eventos usados

- `GameEvents.enemy_defeated(enemy, dropped_bone_id)`.
- `GameEvents.player_died(player)`.
- `GameEvents.drop_spawned(bone_id, pickup, source)`.

## Flujo melee del jugador

1. `Player._physics_process` detecta input `attack` cuando no esta apuntando.
2. Se respeta cooldown.
3. Se calcula direccion usando camara o facing.
4. Se instancia `AttackHitbox`.
5. `AttackHitbox` revisa overlaps y `body_entered`.
6. Si el cuerpo tiene `take_damage`, llama `take_damage(damage, hit_pos, player)`.
7. `Enemy.take_damage` aplica knockback, dano, limb loss y muerte si corresponde.

## Flujo ranged del jugador

1. `toggle_bow` equipa/oculta bow.
2. Mantener y soltar click carga el disparo.
3. La camara entra en aim zoom/left shoulder.
4. `PlayerCameraController.get_center_aim_point` calcula el punto del centro de
   pantalla.
5. `Player` instancia `ArrowProjectile`.
6. Si no hay bow equipado, el player tira finger bones.
7. El proyectil llama `take_damage` en enemigos.
8. Si el enemigo no ve al player, `Enemy` entra en search hacia el atacante.

## Flujo stealth

1. `Player` busca target con `can_be_stealth_finished_by`.
2. El enemigo valida distancia y que el player este detras.
3. UI muestra `get_stealth_prompt_text`.
4. Al presionar stealth:
   - Si enemy health <= threshold, muere.
   - Si tiene demasiada vida, recibe dano extra y responde atacando/buscando.

## Flujo de dano enemigo

`Enemy.take_hit`:

1. Reduce health.
2. Llama `_maybe_start_low_health_flee`.
3. Llama `_detach_limbs_for_damage` si no es killing hit.
4. Actualiza label/flash/sound.
5. Si health llega a 0, llama `die`.

## AI de enemigos

Estados principales:
- idle wander
- vision chase
- search last known position
- return to spawn
- flee low health
- bone recovery
- ranged windup
- rock throw windup
- saliva windup
- crawl when both legs are lost

Vision:
- Cono + distancia.
- Line of sight salvo lizards que pueden ver a traves de paredes si esta activo.

Stats por hueso:
- La forma editable nueva es `BoneDefinition.enemy_*`.
- `BoneDataCatalog` carga `BoneDefinition` desde `data/bones/*.tres` primero y
  usa sus datos internos solo como fallback temporal.
- `BoneDatabase` los normaliza a campos planos como
  `enemy_move_speed_bonus`, `enemy_contact_damage_bonus`,
  `enemy_max_health_bonus`, `enemy_detection_range_bonus`,
  `enemy_visual_scale` y `enemy_flee_chance`.
- `BoneRulesService.enemy_profile_for` es el punto de lectura para `Enemy`.

Mutacion:
- Los campos `mutation_id`, `mutation_family`, `mutation_stage`,
  `mutation_intensity` y `mutation_tags` viajan por `BoneDefinition` y
  `BoneDatabase`.
- Familias canonicas actuales: vacio, `corrupto`, `maldito`, `especial`,
  `hibrido`.
- Mutacion no cambia combate automaticamente todavia. Debe activarse desde una
  regla explicita para evitar que un dato de authoring cambie balance sin querer.
- Los limbs generados de gorilla/lizard ya exponen familias de mutacion para
  futuras respuestas visuales o AI.

Ataque/combo por hueso:
- `BoneDefinition` ahora expone `attack_type`, `attack_tags`, `combo_family`,
  `combo_step`, `combo_window`, `combo_tags` y `combo_finisher`.
- `BoneDatabase` y `BoneRulesService` entregan esos campos con compatibilidad
  para huesos hechos a mano y limbs generados.
- `Player` usa `combo_window` como ventana visual para mantener una cadena de
  animacion simple si el jugador vuelve a atacar a tiempo.
- `ProceduralPlayerAnimator.trigger_attack(combo_step)` alterna tres poses:
  golpe derecho, golpe izquierdo y finisher con ambos brazos/torso.
- Si el jugador sigue solo como cabeza, `trigger_attack` usa una duracion visual
  propia y reemplaza las poses de brazos por un salto de cabeza: primero
  comprime/carga hacia atras, luego salta hacia adelante y arriba hasta una
  altura cercana a medio torso. Al caer, esa posicion adelantada se guarda como
  nuevo inicio local del ciclo; el siguiente golpe empieza desde donde quedo la
  cabeza y no desde el rest original. El salto usa Z local positivo porque esa
  es la direccion visual hacia adelante del rig del jugador. La posicion
  acumulada se guarda en mundo horizontal y luego se convierte a local del rig,
  para evitar teleports cuando el jugador se mueve o gira lateralmente.
- Mientras ese ataque esta activo, `Player` lee
  `get_head_only_attack_world_offset()` y se lo pasa a la camara como offset
  horizontal acumulado. La camara no sigue el arco vertical de la cabeza.
- Estos campos no cambian cooldown, hitbox, dano ni input automaticamente. Para
  activar combos con gameplay real se debe crear una regla de combate explicita
  y probarla en `TESTING ENVIRONMENT`.

Modificadores porcentuales:
- `quality_damage_percent`, `quality_speed_percent` y
  `quality_health_percent` describen intencion de balance por calidad.
- Combate no multiplica dano, velocidad ni salud con esos campos todavia. Si se
  activan, debe hacerse en una formula documentada y testeada.

Nucleo del jugador:
- La cabeza es el nucleo fijo del jugador. La vida base representa sobrevivir
  como cabeza.
- Recuperar torso y extremidades aumenta `max_health`; la logica existente de
  stats recupera la diferencia de vida cuando sube el maximo.
- Si una regla futura destruye la cabeza del jugador, debe llamar a la muerte
  del jugador directamente.

Hurtboxes del jugador:
- `ModularSkeletonRig` crea hurtboxes por socket y `Player` se registra como
  `damage_owner`.
- Flechas enemigas, saliva y rocas escuchan `area_entered` contra el grupo
  `player_body_hurtboxes` y llaman `take_player_body_part_damage(body_part, ...)`.
- Si el jugador tiene hurtboxes activos, los proyectiles enemigos ignoran el
  capsule principal para evitar dano con el cuerpo invisible. El capsule se
  mantiene para movimiento/colision general.
- Actualmente `take_player_body_part_damage` delega a `take_player_damage`.
  La separacion queda lista para dano por cabeza/torso/extremidades.

Hurtboxes de enemigos:
- `Enemy._setup_procedural_character()` registra al enemigo como owner de los
  hurtboxes del rig usando el grupo `enemy_body_hurtboxes`.
- `AttackHitbox` escucha `area_entered` y llama
  `take_enemy_body_part_damage(body_part, ...)` para melee.
- Flechas y finger bones del jugador tambien escuchan `enemy_body_hurtboxes`.
- Si un enemigo tiene hurtboxes activos, melee/proyectiles del jugador ignoran
  el capsule principal del enemigo para evitar dano duplicado.
- Cuando una extremidad enemiga se desprende, su hurtbox se desactiva; cuando
  el enemigo recupera la parte, el hurtbox vuelve a activarse.

Lizard wall climb:
- El lizard ya no atraviesa paredes con `global_position`.
- Usa `move_and_slide`.
- Cuando el probe detecta pared adelante, aplica `lizard_wall_climb_speed` en Y.
- El blend visual se controla con `lizard_wall_climb_blend`.

## Puntos delicados

- No volver a mover enemigos con `global_position +=` para locomocion normal.
  Eso salta fisica y causa bugs como atravesar paredes.
- Si se agrega un nuevo tipo de ataque, documentar:
  - input
  - cooldown/charge
  - script del proyectil o hitbox
  - evento emitido
  - como reacciona `Enemy`
- Si el ataque afecta camera/aim, actualizar tambien `camera_flow.md`.
- Si el ataque crea drops o limbs, actualizar tambien `drops_flow.md`.
- Si un cambio de combate necesita ajustar stats de huesos hechos a mano,
  respetar `BoneDefinition` y mantener `BoneRulesService` como punto de lectura.
- Si se agrega un nuevo input de combate, actualizar tambien
  `docs/tutorial_flow.md` para que el tutorial de controles lo ensene.

## Como probar

En `TESTING ENVIRONMENT`:

1. Spawn normal con `1`.
2. Probar melee.
3. Spawn gorilla con `2`, confirmar rock throw.
4. Spawn lizard con `3`, confirmar saliva y wall climb.
5. Spawn ranged con `4`, confirmar flechas enemigas.
6. Probar bow/finger bones del player.
7. Atacar limbs hasta crawling.
8. Confirmar que muerte emite drops.

## Historial de cambios

- 2026-07-14: Se documento el flujo actual.
- 2026-07-14: Lizard wall climb corregido para usar colision normal y subir al
  detectar pared, en vez de atravesar usando posicion global.
- 2026-07-14: Se documento la preparacion de datos limpios para stats de huesos
  usados por combate y perfiles enemigos.
- 2026-07-14: Se agrego `BoneDefinition` como `Resource`; combate sigue leyendo
  perfiles normalizados mediante `BoneRulesService`.
- 2026-07-14: Los stats de huesos hechos a mano ya pueden venir de Resources
  `.tres` en `data/bones/` sin cambiar `Enemy`.
- 2026-07-14: Se agregaron campos de mutacion para huesos hechos a mano y limbs
  generados, sin activar efectos automaticos de combate.
- 2026-07-14: Se agregaron campos de ataque/combo a `BoneDefinition`,
  `BoneDatabase` y `BoneRulesService`; quedan como metadata hasta que exista
  una regla real de combos.
- 2026-07-14: Se agregaron animaciones simples de combo en tres pasos. La cadena
  es visual solamente y no cambia dano ni hitboxes.
- 2026-07-14: Se documento el inicio como cabeza fija y la recuperacion de vida
  al equipar torso/extremidades.
- 2026-07-14: Proyectiles enemigos ahora usan hurtboxes por parte del cuerpo del
  jugador cuando estan disponibles, manteniendo el capsule principal para
  locomocion.
- 2026-07-14: Melee, flechas y finger bones del jugador ahora usan hurtboxes por
  parte del cuerpo de enemigos mediante `enemy_body_hurtboxes`.
- 2026-07-14: Se limpio el ruteo de hurtboxes en melee/proyectiles con helpers
  pequenos para evitar duplicacion entre jugador y enemigos.
- 2026-07-14: La cabeza sola ahora tiene overlay de ataque propio: carga,
  salto hacia el enemigo y regreso visual al ciclo base. No cambia dano ni
  hitbox.
