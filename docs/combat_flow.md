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
- `scripts/bone_database.gd` + `scripts/bone_data_catalog.gd`: stats de huesos
  que modifican perfiles de combate del jugador y enemigos.

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
- Los valores editables viven en `BoneDataCatalog.enemy_stats`.
- `BoneDatabase` los normaliza a campos planos como
  `enemy_move_speed_bonus`, `enemy_contact_damage_bonus`,
  `enemy_max_health_bonus`, `enemy_detection_range_bonus`,
  `enemy_visual_scale` y `enemy_flee_chance`.
- `BoneRulesService.enemy_profile_for` es el punto de lectura para `Enemy`.

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
  editar `BoneDataCatalog` y mantener `BoneRulesService` como punto de lectura.

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
