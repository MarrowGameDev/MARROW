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
- `scripts/combat_targeting_service.gd`: reglas puras de auto-target para
  ataques head-launch (head-only y torso-only). No accede a la escena: recibe
  posiciones candidatas y devuelve el indice del mejor objetivo.
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

## Auto-target de ataques head-launch

Aplica solo a head-only y torso-only, donde la cabeza se lanza fuera del cuerpo.
En torso-only un fallo detacha la cabeza del torso, asi que apuntar mal mientras
uno se mueve costaba la cabeza en pleno combate.

1. `Player._try_attack` llama `_acquire_head_launch_target()` antes de disparar
   el animator, para que el lanzamiento arranque ya apuntado.
2. Se juntan los nodos vivos del grupo `enemies` y sus posiciones. Un nodo sin
   propiedad `alive` se considera targeteable.
3. `CombatTargetingService.best_target_index()` elige el mas cercano dentro de
   `Player.head_launch_target_range` (1.9). Empata a favor del que esta al frente
   segun `DEFAULT_BEHIND_BIAS`, pero un enemigo detras sigue siendo valido.
4. `Player._push_head_launch_attack_aim()` manda la direccion al animator en cada
   frame desde `_update_procedural_animation`, antes de `update_from_player`.
5. `ProceduralPlayerAnimator._update_head_launch_attack_aim()` reorienta el
   lanzamiento en vuelo mientras no haya aterrizado. Al aterrizar la direccion se
   congela para que el offset de aterrizaje sea consistente.
6. El `AttackHitbox` sigue al socket `head` con `follow_forward_offset = 0`, asi
   que al apuntar la cabeza el hitbox va con ella y el golpe conecta.
7. Sin enemigo en rango no hay target: se usa el facing de siempre y un fallo al
   aire sigue detachando la cabeza (ese castigo no cambio).

### Delay entre saltos

`attack_cooldown` (0.45) es mas corto que las animaciones head-launch (torso
0.56, recoils 0.58-0.66), asi que por si solo dejaba arrancar un salto nuevo
antes de que aterrizara el anterior y las poses se apilaban.

- `ProceduralPlayerAnimator.is_head_launch_attack_busy()` es true mientras el
  salto sigue resolviendo: en vuelo, en hit recoil, cayendo tras un fallo, o
  esperando que el `Player` consuma el detach.
- `Player._try_attack` corta temprano si el modo es head-launch y
  `_is_head_launch_attack_blocked()`. Esto pasa antes de gastar `can_attack`, asi
  que un click bloqueado no consume el cooldown normal.
- `Player._update_head_launch_recovery(delta)` mantiene
  `head_launch_recovery_timer` en `head_launch_attack_recovery` (0.12) mientras
  esta busy y lo descuenta despues, asi que hit, fallo y aterrizaje limpio
  reciben la misma recuperacion sin rastrear como termino el ataque.
- El melee normal no cambia: solo se gatea cuando el modo es head-launch.

### Torso sin piernas: brazo o cabeza

Un torso sin piernas lanza la cabeza SOLO si no tiene ningun brazo equipado.
Alcanza con UN brazo para que el ataque pase a ser el combo de brazo.

- `ProceduralPlayerAnimator._torso_head_launch_available()` = torso-spring y
  `not _has_any_arm_equipped()`. Gobierna `trigger_attack()` y
  `_apply_attack_overlay()`.
- `Player._is_torso_head_launch_combat_mode()` (antes `_is_torso_only_combat_mode`)
  agrega la misma condicion de brazo, y tiene que moverse en conjunto con el
  animator: rutea el hitbox (esfera que sigue al socket `head` vs caja melee
  normal), el lock de movimiento, el gate anti-stacking y el detach por fallo. Si
  quedara en true con un brazo equipado, el hitbox apuntaria a la cabeza mientras
  el brazo hace el swing.
- Con un solo brazo, `_combo_step_for_equipped_arms()` fuerza el paso del combo al
  brazo que existe (derecho -> paso 1, izquierdo -> paso 2). El combo normal
  alterna derecho/izquierdo/ambos, y un paso sobre un socket vacio se ve como si
  el ataque no hiciera nada. Con progression apagada (rig sandbox, enemigos) todos
  los grey-box estan presentes y el ciclo normal se mantiene.
- Consecuencia buscada: con un brazo no hay lanzamiento, asi que tampoco hay
  detach de cabeza por fallar ni desplazamiento del cuerpo.

### Que ataques lanzan la cabeza

`trigger_attack(combo_step, allow_head_launch)` es el unico punto de entrada de
animacion de ataque, y no todos los ataques deben tirar la cabeza:

- `_try_attack()` (melee) pasa `allow_head_launch = true`: en head-only y
  torso-only lanza la cabeza. Es el unico que desplaza al jugador.
- `_try_bow_shot()` (ranged/finger bones) y `_try_stealth_finish()` pasan
  `false`: solo quieren feedback. Una cabeza que salta 0.85 m para disparar un
  proyectil se ve mal y, con el catch-up del cuerpo, movia al jugador; en
  torso-only ademas un lanzamiento fallado detacha la cabeza.
- Con `allow_head_launch = false` se usa el overlay normal y los flags de launch
  quedan en "landed", asi que `is_head_launch_attack_busy()` es false: no hay lock
  de movimiento ni desplazamiento.
- Los tres pasan primero por `Player._head_launch_attack_input_blocked()`. Un
  lanzamiento en vuelo es dueño del socket `head`: disparar otra cosa encima lo
  devolveria al suelo en el aire. Centralizarlo evita que un cambio futuro a
  `attack_cooldown` o `bow_cooldown` reabra el stacking.
- `ProceduralEnemyAnimator` desactiva `player_body_progression_enabled`, asi que
  los enemigos nunca entran en estos caminos y el default `true` no los cambia.

### Lock de movimiento en head-only

El salto se aplica como offset ENCIMA del movimiento del cuerpo, asi que un cuerpo
corriendo a `move_speed` sumaba su velocidad al lanzamiento y la cabeza se veia
teleportando. Con `Player.head_only_attack_locks_movement` (true) el ataque
compromete al jugador en el lugar mientras dura la animacion.

- `Player._is_head_only_attack_locking_movement()` pone `input_vector` en cero,
  igual que ya hacia `detached_torso_reattaching`. Solo se descarta el input de
  direccion: el knockback por dano sigue aplicando.
- Solo aplica a head-only, no a torso-only ni al melee normal.
- Medido en headless, atacando mientras se corre a 6 m/s: pico de la cabeza
  18.78 m/s antes, 15.31 m/s con el lock (identico a atacar quieto). El lock dura
  0.35s si el ataque falla y 0.68s si conecta (vuelo + hit recoil).

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
  altura por encima de medio torso. Al caer, esa posicion adelantada se guarda como
  nuevo inicio local del ciclo; el siguiente golpe empieza desde donde quedo la
  cabeza y no desde el rest original. El salto usa Z local positivo porque esa
  es la direccion visual hacia adelante del rig del jugador. La posicion
  acumulada se guarda en mundo horizontal y luego se convierte a local del rig,
  para evitar teleports cuando el jugador se mueve o gira lateralmente.
- Mientras ese ataque esta activo, `Player` lee
  `get_head_only_attack_world_offset()` y se lo pasa a la camara como offset
  horizontal acumulado. La camara no sigue el arco vertical de la cabeza.
- Si el jugador tiene torso pero no piernas, `trigger_attack` usa el flujo
  `torso_head_attack_*`: el torso se comprime como resorte, prepara el disparo,
  lanza la cabeza hacia la direccion del enemigo y el hitbox esferico del craneo
  sigue ese socket durante `torso_head_attack_hitbox_lifetime`. Cuando hay
  contacto, la cabeza entra en un recoil alto y vuelve al socket guardado del
  torso.
- Para camera follow, `Player` primero consulta
  `get_head_launch_attack_world_offset()`, que cubre tanto cabeza-sola como
  torso-solo. Si no existe, mantiene el fallback anterior de cabeza-sola.
- Si `AttackHitbox` confirma contacto real, `Player` llama
  `confirm_head_only_attack_contact`. El animator entra en una pose separada de
  recoil: captura el punto de impacto, hace que la cabeza rebote/caiga hacia
  atras por la colision y vuelve hacia el punto inicial previo al golpe con
  easing suave y una pequena onda de asentamiento. Si el golpe falla, se
  mantiene la regla anterior de aterrizar adelante y continuar desde ahi.
- En modo solo cabeza, `Player._try_attack` crea un hitbox pequeno que sigue el
  socket real de `head` durante toda la animacion. El dano se aplica donde esta
  la cabeza visible: si ese hitbox toca un body, limb hurtbox u objeto, se
  confirma contacto y la cabeza entra en recoil desde su posicion real.
- Ese hitbox de cabeza sola ahora usa una esfera centrada en el socket `head`
  (`head_only_attack_hitbox_radius`) en vez de una caja, para que el golpe siga
  mejor la silueta redonda del craneo.
- El recoil ya no borra el offset de ataque al confirmar contacto; empieza desde
  la posicion actual de la cabeza. El hitbox de cabeza ignora cuerpos tipo
  ground/floor/ramp para evitar que la cabeza vuelva al inicio por tocar el piso.
- El recoil de cabeza captura la altura actual del socket `head` al contactar;
  el primer frame de recoil conserva la posicion local exacta del socket,
  incluyendo su colocacion visual X/Y. Despues del inicio,
  `head_only_hit_recoil_lift` funciona como minimo visible para el rebote.
  Tambien usa el offset horizontal actual del ataque y aplica
  `head_only_hit_recoil_horizontal_push` de forma gradual para empujar la cabeza
  hacia atras en el plano del suelo antes de volver al punto previo al golpe.
- En modo solo cabeza, `AttackHitbox` mantiene colision/dano pero apaga su mesh
  visual para que el flash del hitbox no parezca una segunda cabeza durante el
  salto. El mesh `Visual` del hitbox esta oculto por defecto en la escena y el
  script solo lo enciende para ataques normales, evitando un flash de un frame.
- El player tambien omite `_flash_player_attack` en modo solo cabeza, y el rig
  fuerza que solo el mesh de cabeza equipado sea visible bajo el socket de
  cabeza.
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
- Al registrar ese owner, `ModularSkeletonRig` reaplica los hurtboxes con
  `ENEMY_HITBOX_ACCURACY_SCALE`, reduciendo el aire alrededor de cabeza, torso,
  brazos, piernas y pies sin cambiar los hurtboxes del jugador.
- `AttackHitbox` escucha `area_entered` y llama
  `take_enemy_body_part_damage(body_part, ...)` para melee.
- Flechas y finger bones del jugador tambien escuchan `enemy_body_hurtboxes`.
- Los hurtboxes por parte tienen prioridad, pero melee/proyectiles del jugador
  vuelven al capsule principal del enemigo si el overlap del socket no llega.
  `already_hit` / `_has_hit` evitan dano duplicado.
- Cuando una extremidad enemiga se desprende, su hurtbox se desactiva; cuando
  el enemigo recupera la parte, el hurtbox vuelve a activarse.
- Gorillas usan hurtboxes por parte del cuerpo mas grandes y una collision shape
  principal mas ancha que el enemigo normal para cubrir su silueta.

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
6. Spawn dummy target con `5`, confirmar que no se mueve ni ataca.
7. Probar bow/finger bones del player.
8. Atacar limbs hasta crawling.
9. Confirmar que muerte emite drops.

## Historial de cambios

- 2026-07-14: Se documento el flujo actual.
- 2026-07-14: Se agrego `dummy_target_enabled` en `Enemy` y spawn con `5`
  en `TESTING ENVIRONMENT` para probar dano, limb loss y animaciones sin AI.
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
- 2026-07-14: Se ajustaron los hitboxes de gorilla: padding por limb en el rig y
  collision shape principal mas grande en `Enemy`.
- 2026-07-14: La cabeza sola ahora tiene overlay de ataque propio: carga,
  salto hacia el enemigo y regreso visual al ciclo base. No cambia dano ni
  hitbox.
- 2026-07-14: El recoil de impacto de cabeza sola dura mas y sostiene el
  contacto brevemente.
- 2026-07-14: Melee, flechas y finger bones vuelven a poder danar el capsule
  principal del enemigo si el hurtbox por parte no registra overlap.
- 2026-07-14: El hitbox melee de cabeza sola ahora es un volumen pequeno que
  sigue el socket real de la cabeza durante la animacion, evitando offset de
  dano y teleports por impacto forzado.
- 2026-07-14: Se evito el snap de mitad de ataque: el recoil conserva el offset
  actual al confirmar contacto y el hitbox de cabeza ignora piso/terreno.
- 2026-07-14: Se agrego lift vertical al recoil de cabeza sola para que el
  fallback/impacto sea visible por encima del suelo.
- 2026-07-14: La altura de recoil de cabeza sola ahora depende de la altura
  real del contacto, con `head_only_hit_recoil_lift` como minimo visible.
- 2026-07-14: El recoil de cabeza sola ahora tambien depende de la posicion
  horizontal real del contacto y agrega push en el plano del suelo.
- 2026-07-14: Se corrigio el snap horizontal de recoil: el empuje ya no se
  calcula desde el socket renderizado, sino desde el offset estable del ataque.
- 2026-07-15: Se corrigio la altura inicial del recoil: el primer frame usa la
  altura real de contacto y el lift minimo solo afecta el rebote posterior.
- 2026-07-15: El recoil de cabeza ahora captura la posicion local completa del
  socket `head` al contactar para evitar saltos visuales en X/Y al iniciar.
- 2026-07-15: Se aumento la altura general del ataque de cabeza sola:
  `head_only_attack_arc` 0.92, `head_only_hit_recoil_arc` 0.64 y
  `head_only_hit_recoil_lift` 0.46.
- 2026-07-15: El melee de cabeza sola usa hitbox esferico para coincidir mejor
  con el craneo, y los hurtboxes enemigos se recortan por parte con
  `ENEMY_HITBOX_ACCURACY_SCALE`.
- 2026-07-15: Se agrego ataque torso-solo: el torso se enrolla, lanza la cabeza
  hacia el enemigo y, al contactar, la cabeza hace recoil alto antes de volver a
  su socket.
- 2026-07-15: Se corrigio el snap post-recoil de torso-solo: al aterrizar, la
  cabeza queda fijada al socket vivo del torso y no vuelve a ejecutar el launch
  durante el blend-out.
- 2026-07-15: Los torsos pueden definir `head_socket_offset`; el ataque
  torso-solo usa ese socket vivo para lanzar y regresar la cabeza segun la
  forma del torso equipado.
- 2026-07-15: Si el ataque torso-solo lanza la cabeza y no contacta ningun
  enemigo, hurtbox u obstaculo valido, la cabeza se separa del torso. El player
  pasa a movimiento head-only, el torso equipado queda como marcador en el
  mundo, y solo se puede recuperar manteniendo `Interact` cerca de ese mismo
  torso.
- 2026-07-15: La separacion cabeza/torso ahora conserva la posicion visual de
  la cabeza lanzada y la interpola hasta el suelo con una breve caida, evitando
  el teleport antes de entrar al movimiento head-only.
- 2026-07-15: Se suavizo la caida detached-head: menos bounce, easing continuo
  sin pausa a media caida, menor roll extra y rotacion head-only amortiguada con
  `head_only_roll_speed_scale`.
- 2026-07-15: La transicion detached-head ahora cambia a modo head-only solo
  cuando la cabeza toca el suelo. El animator conserva el punto futuro de
  head-only para que el cambio de modo use la ultima ubicacion de la cabeza y no
  teleporte.
- 2026-07-15: Se acelero la caida detached-head (`detached_head_landing_duration`
  0.18) y `Player` conserva brevemente el offset de camara de la cabeza durante
  el cambio de modo para evitar que la camara salte al torso y vuelva.
- 2026-07-15: El cambio final a modo head-only ahora pasa la posicion local
  aterrizada a `enter_detached_head_state()` y hace un micro-blend de 0.08s hacia
  la pose normal de rodar, evitando el pequeno teleport al tocar suelo.
- 2026-07-15: El bow solo puede equiparse, mostrarse, apuntarse y dispararse si
  el player tiene ambos brazos equipados (`right_arm` y `left_arm`). Si falta
  cualquier brazo, el bow se apaga y el player conserva el fallback de finger
  bones.
- 2026-07-15: `scripts/rig/procedural_player_animator.gd` — el ataque head-only
  ya no se ve acelerado al atacar en movimiento. `_head_only_roll_angle` seguia
  acumulando giro de rodada mientras la cabeza estaba en el aire, asi que un
  ataque corriendo giraba ~671 grados en 0.34s contra ~189 quieto, tapando el
  roll propio del ataque. Ahora `_head_only_attack_airborne()` amortigua ese giro
  con `head_only_attack_roll_damping` (0.2) mientras dura el salto y el hit
  recoil: corriendo baja a ~222 grados (1.17x contra 1.0 quieto). No cambia dano,
  hitboxes ni cooldowns. Pruebas: en `TESTING ENVIRONMENT`, quedarse solo con la
  cabeza y atacar quieto, caminando y esprintando; el giro debe leerse igual en
  los tres casos.
- 2026-07-15: `scripts/rig/procedural_player_animator.gd` — corregido un salto de
  un frame en `_apply_head_only_attack_pose()`. La fase de carga hundia la cabeza
  0.22 m y la echaba atras 0.119 m, pero la fase de salto leia la pose desde el
  rest sin comprimir, asi que posicion, altura, rotacion y escala se soltaban de
  golpe (~0.23 m en un frame, ~15.5 m/s). Ahora la compresion se libera dentro del
  salto con `head_only_attack_release_portion` (0.25). El aterrizaje no cambia, asi
  que el punto de partida rodante documentado en `rig_notes.md` sigue igual.
  Pruebas: atacar quieto como cabeza y verificar que no haya tiron al pasar de
  carga a salto.
- 2026-07-15: Solo pruebas — `2` y `3` disparan un demo A/B de animacion (misma
  embestida, una a mano y otra con `Tween`) con una bola naranja orbitando como
  objetivo movil. Vive en `scripts/rig/rig_test_player.gd`, o sea solo en
  `rig_test.tscn`; no toca el `Player` real ni el combate. Detalle en
  `docs/rig_notes.md`.
- 2026-07-15: `scripts/combat_targeting_service.gd` (nuevo), `scripts/player.gd`,
  `scripts/rig/procedural_player_animator.gd` — los ataques head-launch
  (head-only y torso-only) ahora auto-apuntan al enemigo vivo mas cercano dentro
  de `head_launch_target_range` (1.9) en vez de lanzarse por
  `current_move_direction`. Antes, atacar mientras se strafeaba tiraba la cabeza
  al aire y en torso-only ese fallo la detachaba del torso. El animator reorienta
  el lanzamiento en vuelo con `set_head_launch_attack_aim()`, asi que un enemigo
  que se mueve durante el ataque se sigue rastreando; al aterrizar la direccion se
  congela. El hitbox ya seguia al socket `head`, asi que conecta solo con apuntar
  la cabeza. Sin enemigo en rango el comportamiento es el de antes. No cambia
  dano, cooldowns, hitboxes ni el melee normal. Nuevo evento de `GameEvents`:
  ninguno. Pruebas: en `TESTING ENVIRONMENT`, quedarse en torso-only, atacar a un
  enemigo cercano mientras se camina en circulos y hacia los costados; la cabeza
  debe conectar y volver al torso en vez de detacharse. Atacar al aire sin
  enemigos cerca debe seguir detachando.
- 2026-07-15: `scripts/player.gd`, `scripts/rig/procedural_player_animator.gd` —
  se agrego un delay real entre saltos head-launch. `attack_cooldown` (0.45) es
  mas corto que la animacion de torso (0.56) y que los recoils (0.58-0.66), asi
  que se podia disparar un salto nuevo antes de aterrizar el anterior y las poses
  se apilaban. Medido en headless spameando ataque 2s: antes 120 saltos, 119
  arrancados en el aire; ahora 6 saltos, 0 en el aire. Nuevo
  `is_head_launch_attack_busy()` en el animator y nuevo export
  `Player.head_launch_attack_recovery` (0.12) de recuperacion extra. El click
  bloqueado no consume `can_attack`, asi que no arruina el cooldown normal. El
  melee normal no se toca. Pruebas: en `TESTING ENVIRONMENT`, en head-only y
  torso-only, mantener/spamear click y verificar que cada salto termina antes de
  empezar el siguiente y que la cabeza no se queda flotando.
- 2026-07-15: `scripts/player.gd` — nuevo export `head_only_attack_locks_movement`
  (true): los ataques head-only comprometen al jugador en el lugar mientras corre
  la animacion, asi que la velocidad del cuerpo ya no se suma al lanzamiento de la
  cabeza. Medido corriendo a 6 m/s: pico de la cabeza 18.78 -> 15.31 m/s, igual
  que atacando quieto. Reusa el patron de `detached_torso_reattaching` (pone
  `input_vector` en cero); el knockback por dano sigue aplicando. No toca
  torso-only ni el melee normal. Pruebas: en `TESTING ENVIRONMENT`, quedar solo
  como cabeza, correr y atacar; la cabeza debe moverse igual de rapido que
  atacando quieto.
- 2026-07-15: `scripts/player.gd`, `scripts/rig/procedural_player_animator.gd` —
  el lunge head-only ahora mueve al jugador en vez de alejar la cabeza del
  cuerpo. Antes cada ataque sumaba 0.85 m a `_head_only_base_world_offset` y nada
  movia la capsula, asi que la cabeza se separaba sin limite (medido: 0.85, 1.70,
  2.55, 3.40 m tras cuatro ataques) y ese drift ademas se filtraba al follow
  offset de camara por `get_head_launch_attack_world_offset()`. Ahora al aterrizar
  el animator levanta `has_head_only_body_catch_up_request()` y el `Player` lo
  consume en el mismo frame con `_apply_head_only_lunge_displacement()`, que usa
  `move_and_collide` para no atravesar paredes. Medido: la cabeza queda a 0.00 m
  del cuerpo tras cada ataque, el cuerpo avanza 0.85 m por ataque y no hay pop al
  aterrizar (peor frame 15.3 m/s, igual al pico del propio lanzamiento). Un golpe
  que conecta no desplaza: el recoil devuelve la cabeza al cuerpo. Pruebas: en
  `TESTING ENVIRONMENT`, quedar solo como cabeza y atacar al aire varias veces
  seguidas; la cabeza y la capsula deben seguir juntas y la camara no debe
  quedarse atras. Atacar contra una pared no debe atravesarla.
- 2026-07-15: `scripts/attack_hitbox.gd` — los ataques ya no registran hits
  fantasma contra el piso. `_is_ground_like_body()` clasificaba por substring del
  NOMBRE del nodo (`ground/floor/terrain/stagebody/ramp`), asi que toda superficie
  caminable que no se llamara asi contaba como pared: `VillageBridge`,
  `FieldBridge`, `NorthBridge`, `VillageCliff` (tutorial_island_builder) y
  `RigPosePlatform` (testing_environment). Parado sobre cualquiera de ellas, la
  esfera del hitbox head-launch tocaba el StaticBody3D y disparaba
  `_confirm_contact` -> `hit_confirmed` -> `confirm_head_only_attack_contact()`,
  o sea la cabeza rebotaba como si hubiera golpeado a un enemigo y, en torso-only,
  ese falso hit tapaba el detach por fallo. Ahora la clasificacion es geometrica:
  es piso si el hitbox esta a la altura de la cara superior del cuerpo o mas
  arriba (`GROUND_CONTACT_TOLERANCE` 0.05), leyendo el AABB de sus
  `CollisionShape3D`. Esto ademas resuelve el caso que ningun nombre ni grupo
  puede expresar: `VillageCliff` mide 1 m, su techo es piso y su costado es pared.
  Sin shape usable se lo trata como obstaculo, que es lo que las paredes esperan.
  Medido con la geometria real: parado sobre bridge/cliff/platform no hay hit;
  chocar contra `VillageKeep` o el costado del cliff si lo hay. Pruebas: en la
  isla tutorial, pararse en un puente y atacar como cabeza; no debe haber recoil.
- 2026-07-15: `scripts/player.gd` — `get_noise_radius()` estaba invertido:
  devolvia 6.5 esprintando y 9.0 caminando, y `Enemy._can_hear_player()` compara
  `dist <= noise_radius`, asi que esprintar te hacia MAS silencioso que caminar.
  Los valores estaban al reves. Ahora son los exports
  `noise_radius_normal` (6.5) y `noise_radius_sprinting` (9.0), configurables
  como pide AGENTS.md para cambios de feel; enterrarlos como literales es lo que
  tapo la inversion. Pruebas: en `TESTING ENVIRONMENT`, atacar cerca de un enemigo
  caminando y esprintando; esprintar debe alertarlo desde mas lejos.
- 2026-07-15: `scripts/rig/procedural_player_animator.gd` — corregida la posicion
  de los brazos con torso sin piernas. Los sockets son hermanos del socket `body`,
  no hijos, y `_swing()` solo escribe rotacion, asi que cuando
  `_animate_torso_spring()` baja el torso a `torso_spring_ground_socket_y` (-0.58)
  la cabeza se re-ancla pero los brazos se quedaban a su altura de hombro parado
  (0.30), flotando ~0.88 m arriba del torso. Ahora `_anchor_socket_to_body()` los
  re-ancla con el offset de rest respecto del body. Segunda causa en
  `_animate_wobble()`: el slide reseteaba `base_pos` al rest, pisando la pose;
  `crawl_mode` ya tenia esa excepcion y ahora tambien `_is_torso_spring_only()`.
  Medido: brazo a 0.302 sobre el torso (antes 0.877). Pruebas: en
  `TESTING ENVIRONMENT`, equipar torso sin piernas y mirar los hombros.
- 2026-07-15: `scripts/player.gd`, `scripts/rig/procedural_player_animator.gd` —
  con torso sin piernas y al menos UN brazo equipado, el ataque usa el combo de
  brazo en vez de lanzar la cabeza. Detalle en la seccion "Torso sin piernas:
  brazo o cabeza". `Player._is_torso_only_combat_mode()` se renombro a
  `_is_torso_head_launch_combat_mode()` y ahora excluye el caso con brazo, asi que
  el hitbox vuelve a ser la caja melee normal y no hay lock, gate ni detach.
  Medido: sin brazos lanza la cabeza; con un brazo no lanza, no desplaza el cuerpo
  y el paso del combo cae en el brazo equipado. Pruebas: en
  `TESTING ENVIRONMENT`, torso sin piernas, atacar sin brazos (embestida de
  cabeza) y despues equipar un solo brazo y atacar (swing de ese brazo).
- 2026-07-15: `scripts/player.gd`, `scripts/rig/procedural_player_animator.gd` —
  los ataques ranged y el stealth finish ya no lanzan la cabeza. `_try_bow_shot()`
  y `_try_stealth_finish()` llamaban `animator.trigger_attack()`, el mismo punto
  de entrada del melee, asi que en head-only disparar un finger bone con click
  derecho reproducia la embestida completa: medido, desplazaba al jugador 0.85 m y
  le bloqueaba el movimiento 0.35s en un ataque a distancia. En torso-only ademas
  podia detachar la cabeza por "fallar" un lanzamiento que nunca se quiso hacer.
  Antes del catch-up del cuerpo esto solo desviaba el visual de la cabeza, asi que
  pasaba como rareza cosmetica. Ahora `trigger_attack(combo_step,
  allow_head_launch)` recibe `false` desde ranged y stealth, y los tres caminos
  pasan por `_head_launch_attack_input_blocked()`, que antes solo estaba en
  `_try_attack()` (ranged se apoyaba en `bow_cooldown` 0.75 > 0.34 por suerte, no
  por diseño). Medido: melee sigue desplazando 0.85 m, ranged y stealth 0.00 m y
  sin lock. Enemigos no afectados. Pruebas: en `DUMMY TESTING ENVIRONMENT`, como
  cabeza, click derecho no debe moverte ni congelarte; click izquierdo si debe
  embestir.
- 2026-07-15: `scripts/testing_environment.gd` — en `dummy_only_mode` el dummy
  ahora se respawnea con `2` en vez de `1` (`1` ya no hace nada ahi; en el
  `TESTING ENVIRONMENT` normal `2` sigue siendo gorilla). Nuevo `_try_spawn_dummy()`
  + `_has_live_dummy()`: si el dummy sigue vivo se rechaza el respawn en vez de
  apilar otro sobre el mismo marker; al morir o quitarlo con Backspace vuelve a
  permitirse. `5` sigue sirviendo para respawnear y respeta el mismo bloqueo. El
  label de estado muestra "2 or 5: respawn dummy target" o
  "(blocked, dummy already up)". El `TESTING ENVIRONMENT` normal no cambia: `5`
  ahi todavia permite varios dummies. Pruebas: en `DUMMY TESTING ENVIRONMENT`,
  apretar `2` con el dummy vivo no debe spawnear nada; matarlo y apretar `2` debe
  traerlo de vuelta.
