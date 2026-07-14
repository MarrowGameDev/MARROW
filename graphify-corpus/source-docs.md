# Source Documentation Index

## project.godot

; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="Marrow Tier 0 Prototype"
run/main_scene="res://scenes/main_menu.tscn"
config/features=PackedStringArray("4.7")

[autoload]

GameEvents="*res://scripts/game_events.gd"

[display]

window/size/viewport_width=1280
window/size/viewport_height=720

[input]

move_forward={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":87,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_back={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":83,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":65,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":68,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
attack={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":1,"canceled":false,"pressed":false,"double_click":false,"script":null)
]
}
ranged_attack={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":2,"canceled":false,"pressed":false,"double_click":false,"script":null)
]
}
toggle_bow={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":49,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
jump={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":32,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
sprint={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194325,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
inventory={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194306,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
interact={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":69,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
equip={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":81,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
stealth_finish={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":70,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}

## README.md

# MARROW

## Programmer Flow Docs

Current gameplay flows are documented in `docs/flow_index.md`.

From this point forward, functional changes should update the matching flow doc:

- `docs/inventory_flow.md`
- `docs/equipment_flow.md`
- `docs/combat_flow.md`
- `docs/drops_flow.md`
- `docs/camera_flow.md`

## AGENTS.md

# AGENTS.md

Guia obligatoria para cualquier cambio en Marrow. Todo trabajo debe priorizar estabilidad, escalabilidad, desacoplamiento y claridad de gameplay. Si una solicitud contradice estas reglas, primero explicar el riesgo y proponer una alternativa mas segura.

## Principios Del Proyecto

- Mantener el juego jugable despues de cada cambio. No romper inventario, camara, combate, enemigos, pickups, rig ni escena principal para avanzar una feature aislada.
- Preferir cambios pequenos, verificables y por sistema. Evitar mezclar UI, combate, datos, enemigos y camara en el mismo cambio si no es estrictamente necesario.
- El codigo debe ser facil de extender. Antes de agregar condiciones nuevas a `player.gd`, `enemy.gd` o `player_inventory_ui.gd`, evaluar si corresponde mover la regla a un componente, servicio, Resource o escena dedicada.
- El `Player` debe actuar como orquestador, no como contenedor infinito de reglas. Inventario, equipamiento, stats, camara, combate, pickups y UI deben vivir en modulos especializados.
- La UI debe ser responsive por calculo de viewport, no por arreglos puntuales para una resolucion especifica.
- Mantener compatibilidad con sistemas existentes cuando se migra arquitectura. Las migraciones deben ser graduales y con adaptadores si hace falta.

## Estructura Esperada

- `scripts/`: logica principal del juego. Separar componentes, servicios y controladores por responsabilidad.
- `scripts/rig/`: rig modular, animacion procedural y escenas de prueba relacionadas con cuerpo/personaje.
- `scenes/`: escenas Godot reutilizables. Evitar construir todo por codigo si una escena dedicada mejora inspeccion y reutilizacion.
- `docs/`: documentacion de arquitectura, flujos, decisiones tecnicas y sistemas.
- `assets/`: recursos visuales/audio/datos importables.
- `graphify-out/`, `.godot/`, caches y salidas generadas no deben tratarse como fuente de verdad.

## Uso Del Grafo De Arquitectura

- Antes de empezar cambios que toquen sistemas conectados, usar el grafo generado como referencia inicial para entender relaciones, dependencias e impacto probable.
- Consultar `graphify-out/graph.html` para navegacion visual y `graphify-corpus/dependency-map.md`, `graphify-corpus/scene-map.md` y `graphify-corpus/system-map.md` para revisar dependencias concretas.
- El grafo y el corpus son apoyo de analisis, no fuente de verdad. La fuente de verdad sigue siendo `scripts/`, `scenes/`, `docs/`, `project.godot` y este `AGENTS.md`.
- Si el grafo contradice el codigo, confiar en el codigo y corregir el proceso de generacion si corresponde.
- No editar manualmente `graphify-out/` ni `graphify-corpus/graphify-out/`. Regenerar esos artefactos mediante el workflow o `tools/build_graphify_corpus.py`.
- No commitear caches de Graphify ni salidas temporales. Si aparece `graphify-out/cache/` o `graphify-corpus/graphify-out/`, eliminarlo del control de versiones.

## Reglas De Arquitectura

- Una clase debe tener una responsabilidad principal. Si un archivo empieza a mezclar entrada, UI, datos, reglas de balance, efectos visuales y persistencia, dividirlo.
- Usar componentes para estado y comportamiento reutilizable:
  - inventario: coleccion, stacks, filtros, ordenamiento, seleccion.
  - equipamiento: slots, equipar, desequipar, validaciones.
  - stats: calculo final desde base stats + huesos + calidad + sinergias.
  - camara: input, sensibilidad, colisiones, modos.
  - combate: ataques, hitboxes, cooldowns, backstab, combos.
- Usar servicios para reglas puras sin estado de escena, por ejemplo reglas de huesos, slots, drops, pickups, balance y validacion.
- Usar senales/eventos para comunicar sistemas desacoplados. UI, objetivos, tutoriales, drops y enemigos no deben llamarse entre si si una senal de `GameEvents` resuelve el flujo.
- Evitar dependencias circulares. Si dos sistemas necesitan conocerse demasiado, crear una interfaz pequena, un evento o un servicio intermedio.
- Mantener nodos de escena como composicion. No ocultar dependencias criticas en busquedas fragiles de rutas profundas si pueden exportarse o inyectarse.

## Godot Y GDScript

- Usar `class_name` cuando una clase sea reutilizable o parte del dominio del juego.
- Usar tipos explicitos en variables, argumentos y retornos siempre que sea razonable.
- Usar `@export` para parametros de tuning que deban ajustarse desde editor.
- Usar `preload` para dependencias estables y `load` solo cuando haya una razon para carga dinamica.
- Evitar strings magicos para acciones, slots, rarezas o estados. Centralizar constantes o usar Resources.
- Evitar duplicar reglas entre UI y gameplay. La UI muestra decisiones; no debe inventar validaciones distintas.
- No depender de orden accidental de hijos en escena para logica critica. Nombrar nodos importantes y validar su existencia.
- Validar `null` e `is_instance_valid()` cuando se retienen referencias a nodos que pueden liberarse.
- No hacer trabajo pesado en `_process` si puede hacerse por evento, timer, cache o senal.
- Mantener `_physics_process` para movimiento/fisica y `_process` para visual/estado no fisico.

## Datos Y Resources

- Las definiciones de huesos deben evolucionar hacia datos limpios y editables, preferiblemente `Resource` cuando el dato sea de dominio.
- Mantener una capa de compatibilidad cuando se migren diccionarios existentes a Resources.
- El calculo de stats debe ser determinista y testeable sin depender de UI ni escena principal.
- Todo dato de balance debe tener nombre claro, unidades claras y documentacion minima.
- Rareza, calidad, peso, durabilidad, mutaciones y sinergias deben agregarse como campos de datos, no como ramas dispersas por scripts.

## Inventario, Equipamiento Y UI

- Inventario y equipamiento son sistemas distintos. Inventario guarda piezas disponibles; equipamiento decide que pieza esta activa en cada slot.
- Drag and drop debe delegar validaciones a reglas compartidas, no duplicarlas en widgets.
- Toda UI debe calcularse con el viewport disponible y probarse mentalmente en 1280x720, 1366x768, 1920x1080 y relaciones ultrawide.
- Evitar textos largos en controles compactos. Si un label puede cortarse, debe tener abreviatura responsive o layout alternativo.
- Los controles visuales deben mantener altura, alineacion vertical y separacion consistente al cambiar resolucion.
- No ocultar informacion importante sin reemplazo. Si una zona se compacta, debe mostrar una version abreviada pero comprensible.
- La UI no debe modificar reglas de gameplay directamente salvo mediante metodos publicos del sistema propietario.

## Combate, Enemigos Y Feel

- Separar deteccion, decision y feedback. Ejemplo: detectar hit/backstab, resolver dano, luego disparar animacion/sonido/camara.
- Evitar que enemigos dependan directamente de detalles internos del jugador. Usar metodos publicos, senales o servicios compartidos.
- Los cambios de feel deben ser configurables: pausas, camera shake, flashes, knockback, sensibilidad y timings.
- Toda mecanica nueva de combate debe considerar: cooldown, feedback visual, feedback sonoro, estado de muerte, pausa/inventario y compatibilidad con equipamiento.
- La IA debe modelarse por estados claros. Evitar condicionales enormes sin nombres de estado.

## Camara Y Controles

- La camara debe estar desacoplada del inventario y del combate. Otros sistemas pueden pedir modo, bloqueo o pausa, pero no manipular sus internals.
- Sensibilidad, inversion de eje y estados especiales deben guardarse como configuracion, no como constantes enterradas.
- Al cambiar input, preservar compatibilidad con `InputMap` y configuraciones guardadas.
- Cualquier cambio de controles debe actualizar UI, documentacion y defaults.

## Escenas De Prueba Y Validacion

- Para sistemas complejos, crear o mantener escenas de prueba dedicadas antes de integrar en `main.tscn`.
- Como minimo, validar manualmente cuando aplique:
  - abrir/cerrar inventario.
  - equipar/desequipar huesos.
  - recoger pickups.
  - atacar y recibir dano.
  - comportamiento basico de enemigos.
  - camara y movimiento.
  - preview/rig del personaje.
- Si Godot CLI esta disponible, usar validacion headless cuando sea posible. Si no esta disponible, reportarlo claramente.
- No afirmar que algo fue probado si solo se inspecciono el codigo.

## Git Y Cambios

- Antes de editar, revisar `git status --short --branch`.
- No revertir cambios ajenos sin instruccion explicita.
- Mantener commits pequenos y enfocados por sistema.
- No commitear caches, artefactos generados, archivos temporales ni resultados de editor que no sean fuente.
- Antes de cerrar una tarea, revisar `git diff --check` y resumir archivos tocados.
- Si hay archivos staged y unstaged mezclados, no asumir que todo pertenece al cambio actual.

## Documentacion

- Cada sistema nuevo o refactor importante debe tener una nota en `docs/` o actualizar la documentacion existente.
- Documentar flujos, no solo clases. Ejemplos: inventario, equipamiento, combate, drops, camara, enemigos, rig.
- Registrar decisiones tecnicas cuando se elija una arquitectura que afecte futuras features.
- La documentacion debe explicar responsabilidades, dependencias y puntos de extension.

## Criterios Para Aceptar Un Cambio

- El cambio cumple la solicitud sin introducir deuda innecesaria.
- La responsabilidad queda en el modulo correcto.
- No se duplican reglas entre gameplay y UI.
- El comportamiento sigue funcionando en resoluciones pequenas y grandes si toca UI.
- El codigo tiene nombres claros, tipos razonables y errores manejados.
- El cambio es verificable con prueba manual, escena de prueba o comando.
- Se actualizo documentacion si cambio arquitectura, datos o flujo de usuario.

## Reglas Para Asistentes

- Leer el contexto local antes de proponer arquitectura.
- Preferir patrones existentes del repo sobre abstracciones nuevas.
- Si una tarea pide "arreglar rapido", aun asi evitar parches que bloqueen escalabilidad.
- Si una tarea toca sistemas grandes, proponer un corte incremental: estabilizar, extraer responsabilidad, validar, documentar.
- Si algo no puede verificarse, decirlo de forma explicita y concreta.
- No incluir planes de roadmap externos en este archivo. Este documento define reglas permanentes, no tareas pendientes.

## docs/camera_flow.md

# Flujo de camara

Este documento describe la camara de tercera persona, movimiento relativo a
camara, zoom de apuntado y pruebas de camara.

## Objetivo del sistema

La camara debe seguir al jugador, orbitar con mouse, colisionar con paredes,
apoyar movimiento relativo a camara, permitir aim/left shoulder para bow, y dar
un punto de disparo consistente desde el centro de pantalla.

## Scripts y escenas principales

- `scripts/player_camera_controller.gd`: componente principal de camara.
- `scenes/player.tscn`: contiene `CameraPivot`, `SpringArm3D` y `Camera3D`.
- `scripts/player.gd`: delega input/estado a la camara y usa helpers de aim.
- `scenes/testing_environment.tscn`: escena para probar camara con paredes,
  rampas, player real y enemigos.

## Responsabilidades

`PlayerCameraController`:
- Captura/libera mouse.
- Sigue al jugador con smoothing.
- Aplica yaw/pitch por mouse.
- Limita pitch.
- Controla zoom con rueda.
- Usa `SpringArm3D` para collision de camara.
- Cambia a aim zoom.
- Expone `get_flat_forward`, `get_flat_right`.
- Expone `get_center_aim_point`.

`Player`:
- Pide vectores de camara para movimiento.
- Usa camara forward cuando ataca parado.
- Activa/desactiva aim zoom al cargar bow.
- Deshabilita look cuando inventario esta abierto o jugador muerto.

## Flujo de movimiento relativo a camara

1. `Player._physics_process` lee input WASD.
2. `_get_camera_relative_move_direction` pide flat forward/right al controller.
3. Calcula direccion en mundo.
4. Player rota/facing segun direccion o aim.
5. Animator recibe velocidad final.

## Flujo de aim

1. Player mantiene ataque ranged.
2. `PlayerCameraController.set_aim_zoom(true, distance)` activa zoom.
3. La camara aplica offset de hombro izquierdo.
4. Al soltar, player pregunta `get_center_aim_point`.
5. El raycast desde centro de pantalla devuelve punto de impacto o punto lejano.
6. El proyectil se dispara hacia ese punto.
7. `set_aim_zoom(false)` vuelve al zoom normal.

## Flujo de mouse

- En gameplay: mouse capturado.
- En inventario: look deshabilitado y mouse visible.
- `Escape` puede liberar mouse.
- Click recaptura mouse si look esta habilitado.

## Eventos relacionados

- `GameEvents.inventory_open_changed(player, is_open)`: indica que la camara
  debe quedar bloqueada/visible segun el estado del inventario. Actualmente el
  player llama directamente `camera_controller.set_look_enabled`; si se mueve a
  evento, actualizar este archivo.

## Puntos delicados

- No mover la camara desde `Player` directamente. Usar
  `PlayerCameraController`.
- Si se cambia el punto de aim, probar arco, finger bones y enemigos ranged.
- Si se cambian offsets de shoulder aim, probar visibilidad del cuerpo y del
  objetivo.
- Si se cambia collision mask del SpringArm, probar paredes en
  `TESTING ENVIRONMENT`.

## Como probar

En `TESTING ENVIRONMENT`:

1. Caminar alrededor de paredes altas y bajas.
2. Acercar/alejar con rueda.
3. Apuntar con bow y confirmar shoulder camera.
4. Disparar al centro de pantalla.
5. Abrir inventario y confirmar que camara no gira.
6. Cerrar inventario y confirmar que mouse/look vuelve.
7. Subir rampas y confirmar que la camara no se inclina raro.

## Historial de cambios

- 2026-07-14: Se documento el flujo actual de camara.
- 2026-07-14: Se agrego `TESTING ENVIRONMENT` como escena unica para probar
  camara, enemigos, movimiento, animaciones y rig.

## docs/change_documentation_policy.md

# Politica de documentacion de cambios

Desde este punto, todo cambio funcional debe actualizar el archivo de flujo que
corresponda. La meta es que otro programador pueda leer la documentacion y
entender que sistema se toco, por que se toco, y que comportamiento debe probar.

## Archivos responsables

- Inventario: `docs/inventory_flow.md`
- Equipamiento: `docs/equipment_flow.md`
- Combate: `docs/combat_flow.md`
- Drops y pickups: `docs/drops_flow.md`
- Camara: `docs/camera_flow.md`

Si un cambio toca mas de un flujo, actualizar todos los archivos afectados.
Ejemplo: un nuevo ataque con arco que cambia la camara debe actualizar combate y
camara.

## Que documentar en cada cambio

Agregar una entrada corta en la seccion `Historial de cambios` del archivo
correspondiente:

- Fecha.
- Scripts o escenas tocadas.
- Comportamiento nuevo o corregido.
- Eventos de `GameEvents` nuevos, emitidos o escuchados.
- Pruebas recomendadas en el editor o en `TESTING ENVIRONMENT`.

## Regla practica

Antes de cerrar un cambio, preguntar:

1. El programador que revise esto sabra donde vive la logica?
2. Sabra que eventos conectan el sistema?
3. Sabra como probar si sigue funcionando?

Si alguna respuesta es no, falta documentacion.

## docs/combat_flow.md

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

## docs/current_system_status.md

# MARROW Current System Status

This document records the current gameplay architecture before the next larger
refactor pass.

## Inventory

- `PlayerInventoryUI` owns inventory presentation, tabs, item tiles, details,
  settings, paper doll slots, and the character preview.
- `PlayerInventoryComponent` owns collected inventory state.
- `PlayerEquipmentComponent` owns equipped state.
- `Player` remains the gameplay orchestrator and exposes stable methods for UI,
  pickups, gates, and tests.
- Equipped copies are filtered out of the carried item grid, while duplicate
  bone ids can remain as separate inventory copies.
- The character preview is rendered in an isolated `SubViewport` world with its
  own small room backdrop, so the preview clone stays outside the playable
  world and can be framed independently.

## Combat

- `Player` owns attack input, bow input, stealth finish input, attack cooldowns,
  damage, and attack hitbox spawning.
- `AttackHitbox` applies direct melee damage to enemies it overlaps.
- Stealth finishes are validated by the enemy using distance and the player's
  position behind the enemy facing direction.

## Camera

- `PlayerCameraController` owns third-person orbit, mouse capture, zoom, camera
  collision, and aim ray helpers.
- `Player` delegates mouse capture/release to the camera controller when
  inventory opens or closes.
- Player movement is camera-relative.

## Enemies

- `Enemy` owns AI state, vision/search, contact attacks, ranged attacks, gorilla
  rock throws, limb detachment, crawling, respawn, and bone recovery.
- Enemies can recover detached parts after a safe delay.
- Enemy labels and drops use slot-aware bone names.
- Lizard wall climb uses normal collision and upward climb velocity instead of
  direct position movement through walls.

## Bone Data

- `BoneDefinition` is the Godot `Resource` type for one hand-authored bone.
- Initial hand-authored bones now live as `.tres` assets in `data/bones/`.
- `BoneDataCatalog` loads `.tres` Resources first and uses its in-code
  dictionaries only as temporary fallback during gradual migration.
- `BoneDatabase` remains the compatibility layer that normalizes catalog data
  into the flat fields current systems expect.
- `BoneDatabase.BONES` is still populated for legacy direct reads, and
  `BoneDatabase.reset_cache()`/`reload_from_catalog()` refresh the cache.
- Gameplay consumers should still use `BoneRulesService`, `EquipmentRulesService`
  or `BoneDatabase`, not `BoneDefinition` or `BoneDataCatalog` directly.

## Testing

- `scenes/testing_environment.tscn` is the unified sandbox for camera, enemies,
  movement, animation, rig, drops, and equipment checks.
- `scenes/main_menu.tscn` exposes both the playable demo and testing
  environment.

## Rig

- `ModularSkeletonRig` creates sockets and visual equipment parts.
- `ProceduralPlayerAnimator` animates sockets from resolved movement velocity and
  equipped bone data.
- Crawl mode lowers the body and uses stronger arm pulls with tucked legs.

## Documentation Boundary

All future functional changes should update the relevant flow file listed in
`docs/flow_index.md`.

## docs/drops_flow.md

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
4. Mientras se mantiene interact, `DropPickupRulesService` calcula progreso.
5. Cuando el hold completa, pickup llama `player.collect_bone`.
6. Se emite `pickup_collected`.
7. Se emite `pickup_focus_changed(..., false)`.
8. El pickup se elimina.

## Camp chest

1. `DemoEnemyCamp` registra enemigos.
2. Escucha `GameEvents.enemy_defeated`.
3. Cuando todos estan muertos, unlock.
4. Emite `camp_state_changed`.
5. Si el player mantiene interact en el cofre, llama `collect_bone`.
6. Emite `camp_chest_opened`.

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

## docs/equipment_flow.md

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
- 2026-07-14: Se movieron los huesos hechos a mano iniciales a
  `data/bones/*.tres`. La migracion sigue siendo gradual porque el diccionario
  queda como fallback.
- 2026-07-14: Se mantuvo compatibilidad legacy en `BoneDatabase` con cache
  `BONES`, `definitions` y `reset_cache`.

## docs/flow_index.md

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

## docs/godot_signal_guidelines.md

# Godot Signal Guidelines

These rules keep Marrow's scenes modular while the project is still small.

## Prefer Event Names

Signals should describe what happened, not what another node must do.

Good:
- `bone_collected`
- `trial_completed`
- `player_died`

Avoid:
- `update_inventory`
- `open_win_screen`
- `tell_manager_trial_done`

## Signal Up, Call Down

Child nodes and world objects announce events upward or globally.
Managers and parent nodes decide how to react and can call methods downward.

Examples in this project:
- `BoneTrialGate` emits `GameEvents.trial_completed`.
- `ArenaGoalManager` listens and opens the exit when enough trials are complete.
- `OpenWorldStage` emits `GameEvents.stage_entered`.
- `WorldMapManager` listens and updates the map UI.

## Pass Useful Data

Signals should carry the information listeners need without forcing them to
look back into the emitter.

Examples:
- `bone_collected(bone_id, collector)`
- `bone_equipped(bone_id, slot, player)`
- `camp_chest_opened(camp, reward_bone_id, player)`

## Keep Emitters Decoupled

After emitting a signal, the emitter should not wait for a specific listener to
do something. If the emitter needs an immediate local result, use a direct method
call instead.

For now, pickups and camp chests still call `player.collect_bone(...)` directly
because that is the immediate gameplay action. They also emit events afterward so
future systems like audio, analytics, achievements, and tutorials can react.

## Use `GameEvents` Sparingly

`GameEvents` is for cross-scene gameplay events that distant systems may need.
Do not put every button hover or tiny local interaction on the global bus.

## docs/inventory_flow.md

# Flujo de inventario

Este documento describe como se recoge, guarda y muestra el inventario del
jugador.

## Objetivo del sistema

El inventario guarda huesos obtenidos por pickups, drops o cofres. La UI permite
verlos, filtrarlos por tipo, revisar detalles, arrastrarlos a slots de equipo y
modificar controles desde la seccion de settings.

## Scripts y escenas principales

- `scripts/player.gd`: orquestador del jugador. Crea `PlayerInventoryComponent`
  y `PlayerInventoryUI`, expone metodos que la UI usa como `get_inventory_items`,
  `equip_bone`, `unequip_slot`, `show_bone_info` y `clear_bone_info`.
- `scripts/player_inventory_component.gd`: guarda `bone_inventory`, recibe
  `collect_bone`, expone snapshots y emite cambios por eventos.
- `scripts/player_inventory_ui.gd`: construye la pantalla de inventario, tabs,
  grid, detalles, settings, paper doll y preview 3D.
- `scripts/ui_bone_item.gd`: tile arrastrable de un hueso en el grid.
- `scripts/ui_bone_slot.gd`: slot visual del paper doll.
- `scripts/ui_inventory_empty_slot.gd`: zona para soltar items/equipamiento
  cuando aplica.
- `scripts/bone_rules_service.gd`: display name, color, descripcion y textos de
  stats.
- `scripts/equipment_rules_service.gd`: slot de cada hueso y reglas de slots.
- `scripts/bone_database.gd`: fachada compatible para leer definiciones de
  huesos.
- `scripts/bone_definition.gd`: `Resource` editable de Godot para un hueso
  hecho a mano.
- `scripts/bone_data_catalog.gd`: datos limpios de autoria para huesos
  hechos a mano.

## Eventos usados

- `GameEvents.bone_collected(bone_id, collector)`: se emite cuando el jugador
  recibe un hueso.
- `GameEvents.inventory_changed(player, items, stats)`: snapshot de inventario
  para UI y sistemas externos.
- `GameEvents.inventory_open_changed(player, is_open)`: inventario abierto o
  cerrado.
- `GameEvents.bone_equipped(bone_id, slot, player)`: la UI escucha para refrescar
  el paper doll.
- `GameEvents.bone_unequipped(bone_id, slot, player)`: la UI escucha para
  refrescar el paper doll.

## Flujo actual

1. Un pickup, limb pickup o cofre llama `player.collect_bone(bone_id)`.
2. `Player.collect_bone` delega a `PlayerInventoryComponent.collect_bone`.
3. `PlayerInventoryComponent` agrega el `bone_id` a `bone_inventory`.
4. El componente emite `GameEvents.inventory_changed`.
5. Tambien emite `GameEvents.bone_collected`.
6. `PlayerInventoryUI` escucha `inventory_changed` y reconstruye tiles + textos.
7. Cuando el inventario se abre, `Player._toggle_inventory` llama
   `inventory_ui.set_open` y emite `inventory_open_changed`.

## Responsabilidades

`PlayerInventoryComponent`:
- Posee la lista real de huesos.
- Permite duplicados.
- No conoce la UI.
- Solo emite eventos/snapshots.

`PlayerInventoryUI`:
- No debe poseer estado de gameplay.
- Lee datos mediante metodos publicos del player.
- Puede llamar comandos del player cuando el usuario hace acciones de UI.
- Mantiene el preview 3D en un `SubViewport` aislado.

`Player`:
- Sigue siendo orquestador.
- Decide cuando pausar el juego al abrir inventario.
- Coordina input global y comunica UI con componentes.

## Datos de huesos

El inventario debe seguir leyendo nombres, colores, descripciones y textos de
stats mediante `BoneRulesService`. Internamente, `BoneDatabase` normaliza
`BoneDefinition` Resources cargados por `BoneDataCatalog`.

La ruta actual es:
- primero cargar `.tres` desde `data/bones/`.
- si falta un Resource, usar el diccionario temporal de `BoneDataCatalog`.
- convertir el `BoneDefinition` al formato plano que ya espera la UI.

No conectar la UI directamente a `BoneDefinition` ni `BoneDataCatalog`. La UI
debe seguir usando `BoneRulesService` para que los assets `.tres`, los fallbacks
y los huesos generados sigan una sola ruta.

Compatibilidad:
- Las llamadas actuales a `BoneDatabase.get_def`, `display_name`, `color`,
  `slot`, `quality`, `description` y `effect_text` deben seguir funcionando.
- `BoneDatabase.BONES` se mantiene como cache legacy de diccionarios planos para
  herramientas/codigo viejo que todavia lo lean directamente.
- Si se modifica un `.tres` durante una herramienta/editor, llamar
  `BoneDatabase.reset_cache()` o `reload_from_catalog()` antes de leer de nuevo.

## Puntos delicados

- Duplicados: el inventario permite varios huesos con el mismo id. La UI debe
  filtrar solo las copias equipadas, no esconder todos los duplicados.
- Pausa: la UI procesa mientras el arbol esta pausado.
- Settings: controles modificados se guardan en `user://control_settings.cfg`.
- Interaccion: si el jugador esta en rango de pickup, el inventario no debe
  abrirse con la misma tecla de interact.

## Como probar

En `TESTING ENVIRONMENT`:

1. Abrir inventario con `Tab`.
2. Revisar que aparecen huesos iniciales de prueba.
3. Arrastrar huesos a slots.
4. Cambiar categoria.
5. Ir a settings y cambiar una tecla.
6. Recoger un drop real y confirmar que aparece sin reiniciar la UI.

## Historial de cambios

- 2026-07-14: Se documento el flujo actual. El inventario ya usa
  `GameEvents.inventory_changed` para desacoplar componentes y UI.
- 2026-07-14: Se preparo la migracion de datos de huesos. La UI sigue usando
  `BoneRulesService`, mientras `BoneDatabase` convierte `BoneDataCatalog` al
  formato compatible.
- 2026-07-14: Se creo `BoneDefinition` como `Resource` de Godot para que los
  huesos puedan convertirse luego a assets editables sin cambiar la UI.
- 2026-07-14: Se migraron los huesos hechos a mano a `.tres` en `data/bones/`.
  `BoneDataCatalog` carga Resources primero y conserva diccionarios como
  fallback gradual.
- 2026-07-14: Se reforzo compatibilidad de `BoneDatabase`; `BONES` vuelve a
  poblarse al cargar la clase y existen `definitions`/`reset_cache`.

## docs/open_world_map_layout.md

# Marrow Open-World Map Layout Notes

## Current Goal

The map is now arranged as a grey-box open world with named stage regions and difficulty bands. It should feel closer to a Mario/Zelda overworld: a safe hub, nearby starter zones, side paths, and harder regions farther out.

## Mesh-Swap Rule

Each map region is an instance of:

`scenes/open_world_stage.tscn`

Inside that scene, the important node is:

`OpenWorldStage/StageBody/StageMesh`

To change a stage's physical layout/art later:

1. Open the stage instance or inherited scene in Godot.
2. Replace the mesh on `StageMesh`.
3. Keep the node name `StageMesh`.
4. Keep the sibling `StageCollision`.

At runtime, `scripts/open_world_stage.gd` copies `StageMesh.mesh` into `StageCollision.shape`, so the playable surface follows the mesh.

## Metadata

The stage script has exported fields for:

- `stage_id`
- `stage_name`
- `difficulty`
- `recommended_bone`
- `description`
- `stage_color`
- `trigger_size`

Those are not terrain geometry. They are labels and progression metadata. The terrain/art itself should stay concentrated in `StageMesh`.

## Current Regions

- `BonefieldHub`: Difficulty 1, safe center.
- `FirstHuntField`: Difficulty 2, starter enemies and first bones.
- `ReachRidge`: Difficulty 3, Arm Bone / reach-focused area.
- `QuickrootRun`: Difficulty 4, Leg Bone / speed-focused area.
- `HeavyRuin`: Difficulty 5, Heavy Bone / power-focused area.
- `RibfenBonus`: Difficulty 4, optional side-stage for Rib Bone.
- `ElderMarrowGate`: Difficulty 7, future high-difficulty zone.

## Next Coder Step

Once the layout feels readable, move enemies/trials into the matching stage regions and add stage-specific spawn points. Do not create real art yet; first confirm the overworld route makes players naturally understand where each bone matters.

## docs/project_graph_map.md

# Marrow Project Graph Map

This file exists so Graphify can index the current Godot/GDScript architecture.
The local Graphify extractor does not currently parse `.gd` files as code in
this workspace, so this map mirrors the important script relationships.

## Runtime Entry

`project.godot` runs `scenes/main_menu.tscn`.

`scenes/main_menu.tscn` can open:
- `scenes/main.tscn`
- `scenes/testing_environment.tscn`

`project.godot` autoloads `GameEvents` from `scripts/game_events.gd`.

## GameEvents

`GameEvents` is the global gameplay event bus.

Signals:
- `bone_collected(bone_id, collector)`
- `bone_equipped(bone_id, slot, player)`
- `bone_unequipped(bone_id, slot, player)`
- `inventory_changed(player, items, stats)`
- `inventory_open_changed(player, is_open)`
- `pickup_focus_changed(pickup, bone_id, player, in_range)`
- `pickup_collected(bone_id, pickup, collector)`
- `drop_spawned(bone_id, pickup, source)`
- `enemy_defeated(enemy, dropped_bone_id)`
- `player_died(player)`
- `trial_completed(trial_id, trial_name)`
- `exit_reached(player)`
- `stage_entered(stage)`
- `stage_exited(stage)`
- `objective_updated(source, objective_id, title, body)`
- `tutorial_hint_requested(source, hint_id, text, priority)`
- `camp_state_changed(camp, unlocked, opened, remaining_enemies)`
- `camp_chest_opened(camp, reward_bone_id, player)`

Event relationships:
- `Player.collect_bone` emits `GameEvents.bone_collected`.
- `Player.equip_bone` emits `GameEvents.bone_equipped`.
- `Player.unequip_slot` emits `GameEvents.bone_unequipped`.
- `Player._die_player` emits `GameEvents.player_died`.
- `BoneTrialGate._try_complete_with` emits `GameEvents.trial_completed`.
- `ExitPortal._reach_exit` emits `GameEvents.exit_reached`.
- `OpenWorldStage._on_body_entered` emits `GameEvents.stage_entered`.
- `OpenWorldStage._on_body_exited` emits `GameEvents.stage_exited`.
- `DemoEnemyCamp._open_chest` emits `GameEvents.camp_chest_opened`.
- `ArenaGoalManager` listens to `trial_completed`, `exit_reached`, and `player_died`.
- `WorldMapManager` listens to `stage_entered` and `stage_exited`.

## Player

`scripts/player.gd` owns player movement, combat input, inventory state,
equipment state, health state, and the inventory UI.

Important state:
- `bone_inventory` stores collected bone ids and allows duplicate ids as separate carried copies.
- `equipped` maps equipment slots to bone ids.
- `slot_widgets` maps UI slot names to `BoneSlotWidget` instances.
- `items_grid` contains `BoneItemTile` instances.
- `inventory_preview_rig` shows equipped bones in the inventory preview.

Important methods:
- `_physics_process` handles movement, inventory toggle, category cycling, and Q equip.
- `collect_bone` adds a bone to the inventory and emits `bone_collected`.
- `equip_bone` equips a bone in its database slot, recalculates stats, syncs preview, and emits `bone_equipped` only when the equipped slot changes.
- `unequip_slot` clears a slot, recalculates stats, syncs preview, and emits `bone_unequipped`.
- `_recalculate_stats` applies all equipped bone bonuses.
- `_build_inventory_ui` builds the full inventory screen.
- `_build_paper_doll` lays out the character preview and equipment slots.
- `_sync_inventory_preview` mirrors `equipped` into `ModularSkeletonRig`.

Player relationships:
- `Player` reads definitions from `BoneDatabase`.
- `Player` uses `BoneItemTile` for draggable inventory tiles.
- `Player` uses `BoneSlotWidget` for droppable equipment slots.
- `Player` uses `ModularSkeletonRig` for visual equipment.
- `Player` uses `ProceduralPlayerAnimator` for socket animation.
- `Player` uses `PlayerCameraController` for third-person mouse look.
- `Player` owns inventory and equipment rules; `PlayerInventoryUI` owns inventory presentation.
- `Player` spawns `AttackHitbox` for attacks.

## Player Camera

`scripts/player_camera_controller.gd` defines `PlayerCameraController`.

`PlayerCameraController`:
- lives on `Player/CameraPivot`.
- keeps `CameraPivot` as a top-level visual pivot that follows the player position.
- uses `Player/CameraPivot/SpringArm3D` for zoom distance and camera collision.
- uses `Player/CameraPivot/SpringArm3D/Camera3D` as the active camera.
- captures and hides the mouse during gameplay.
- supports Escape to release the mouse and click to recapture it.
- releases and shows the mouse while inventory is open.
- rotates camera yaw/pitch from `InputEventMouseMotion`.
- clamps pitch between configurable min/max angles.
- zooms with the mouse wheel between configurable min/max distances.
- smooths pivot follow and zoom distance in `_process`.
- exposes flat camera forward/right vectors for camera-relative movement.

`Player`:
- asks `PlayerCameraController` to capture/release mouse when inventory opens or closes.
- uses camera-relative movement so WASD follows the camera direction.
- uses camera forward for attacks while the player is standing still.
- freezes camera look while the inventory is open by releasing the mouse through the camera controller.

## Bone Data

`scripts/bone_definition.gd` defines `BoneDefinition`, the Godot `Resource`
type for one hand-authored bone.

`data/bones/*.tres` contains the current hand-authored bone assets.

`scripts/bone_data_catalog.gd` resolves bone ids. It loads `.tres`
`BoneDefinition` assets first and falls back to its temporary in-code dictionary
only when an asset is missing.

`scripts/bone_database.gd` is the compatibility API. It normalizes catalog data
into the flat fields current gameplay systems still expect.

Compatibility contract:
- Existing calls such as `get_def`, `has_bone`, `all_ids`, `display_name`,
  `display_name_with_slot`, `color`, `slot`, `quality`, `description`,
  `effect_text`, `enemy_float_bonus` and `enemy_int_bonus` must keep working.
- `BoneDatabase.BONES` remains a populated legacy dictionary cache for direct
  reads by older tools/scripts.
- `definitions()` returns the same legacy dictionary cache.
- `reset_cache()` and `reload_from_catalog()` rebuild that cache from current
  Resources/fallback dictionaries.

Current bone ids:
- `arm_bone`
- `leg_bone`
- `heavy_bone`
- `dummy_bone`
- `rib_bone`

Each definition can include:
- `BoneDefinition.identity` fields: display name, quality, color, slot, tags,
  description.
- `BoneDefinition.player_*` fields: player-facing stat bonuses.
- `BoneDefinition.enemy_*` fields: enemy profile bonuses.
- `BoneDefinition.visual_*` fields: optional scale/offset/rotation visual data.

Consumers:
- `Player` uses stat bonuses and slot data through services/components.
- `Bone` and `LimbBonePickup` use slot-aware display names and colors.
- `Enemy` uses enemy bonuses, drop data, and slot-aware display names.
- `BoneTrialGate` uses required bone slot-aware display names and colors.
- Inventory UI widgets use slot-aware display names, colors, slot labels, and effect text.

Rule: gameplay and UI should not read `BoneDefinition` or `BoneDataCatalog`
directly yet. Use `BoneRulesService`, `EquipmentRulesService`,
`DropPickupRulesService` or `BoneDatabase` so generated limb bones and
hand-authored bones stay compatible.

Migration rule: when adding a new hand-authored bone, create a `.tres` in
`data/bones/`, add its id/path to `BoneDataCatalog.RESOURCE_PATHS`, and keep
dictionary entries only as temporary fallback.

## Inventory UI

`scripts/ui_bone_item.gd` defines `BoneItemTile`.

`BoneItemTile`:
- displays a collected unequipped bone.
- starts drag data with `bone_id` and source `item`.
- shows hover details through `Player.show_bone_info`.
- accepts slot drag data to unequip a worn bone.

`scripts/ui_bone_slot.gd` defines `BoneSlotWidget`.

`BoneSlotWidget`:
- displays one equipment slot.
- accepts dropped bones only when `BoneDatabase.slot(bone_id)` matches `slot_name`.
- calls `Player.equip_bone` on drop.
- calls `Player.unequip_slot` on right click.
- shows worn bone details through `Player.show_bone_info`.

`scripts/player_inventory_ui.gd` defines `PlayerInventoryUI`.

`PlayerInventoryUI`:
- owns inventory UI layout, tabs, responsive sizing, settings screen, item grid, paper doll, and preview rig.
- renders the character preview inside an isolated `SubViewport` world with a dedicated room backdrop, separate from the playable world.
- receives inventory data through player snapshot methods instead of reaching into player state directly.
- calls player commands such as `equip_bone` and `unequip_slot` only when the user performs equip actions.
- filters equipped copies by count so duplicate bone ids can remain as separate inventory tiles.
- resets the visible category to `all` when the inventory opens.
- does not recalculate player stats; `Player` remains the owner of gameplay state.

## Pickups and Rewards

`scripts/bone.gd` defines a world pickup with hold-to-collect behavior.

`Bone`:
- tracks `player_in_range`.
- reserves the player's E interaction through `enter_bone_pickup_range`.
- calls `Player.collect_bone` after the hold timer completes.
- frees itself after collection.

`scripts/limb_bone_pickup.gd` is another pickup path for limb/body rewards.

`scripts/demo_enemy_camp.gd` defines `DemoEnemyCamp`.

`DemoEnemyCamp`:
- registers enemies.
- unlocks a chest when all registered enemies are cleared.
- calls `Player.collect_bone` for the reward.
- emits `GameEvents.camp_chest_opened`.

## Arena Goals

`scripts/bone_trial_gate.gd` defines `BoneTrialGate`.

`BoneTrialGate`:
- checks whether the player has the required bone equipped.
- marks the trial complete.
- emits `GameEvents.trial_completed(trial_id, trial_name)`.

`scripts/arena_goal_manager.gd` defines `ArenaGoalManager`.

`ArenaGoalManager`:
- tracks completed trials.
- listens to `GameEvents.trial_completed`.
- opens exits after `required_trials` are complete.
- listens to `GameEvents.exit_reached` to show the win screen.
- listens to `GameEvents.player_died` to show game over.

`scripts/exit_portal.gd` defines `ExitPortal`.

`ExitPortal`:
- opens when `ArenaGoalManager` calls `open_exit`.
- emits `GameEvents.exit_reached` when the player reaches an open exit.

## Open World Map

`scripts/open_world_stage.gd` defines `OpenWorldStage`.

`OpenWorldStage`:
- exposes stage metadata such as `stage_id`, `stage_name`, difficulty, recommended bone, and description.
- emits `GameEvents.stage_entered` and `GameEvents.stage_exited`.
- can rebuild collision from its stage mesh.

`scripts/world_map_manager.gd` defines `WorldMapManager`.

`WorldMapManager`:
- listens to stage enter/exit events.
- stores the current stage.
- updates the map UI from `OpenWorldStage.get_stage_summary`.

## Enemy and Combat

`scripts/enemy.gd` owns enemy behavior.

`Enemy`:
- finds the player by group.
- applies contact damage through `Player.take_player_damage`.
- can receive alerts from other enemies.
- validates stealth finishes by range and whether the player is behind the enemy facing direction.
- drops a bone pickup by setting `Bone.set_bone_id`.

`scripts/attack_hitbox.gd` defines a short-lived attack area.

`AttackHitbox`:
- is spawned by `Player`.
- ignores the owning player.
- calls `take_damage` on enemies it overlaps.
- frees itself after a short lifetime.

## Modular Rig

`scripts/rig/modular_skeleton_rig.gd` defines `ModularSkeletonRig`.

`ModularSkeletonRig`:
- creates sockets for body, head, arms, legs, and feet.
- maps gameplay slots to sockets through `SLOT_TO_SOCKETS`.
- equips a bone by hiding base visuals and adding colored parts to matching sockets.
- exposes `get_equipped_bone_defs` for animation weight response.

`scripts/rig/procedural_player_animator.gd` defines `ProceduralPlayerAnimator`.

`ProceduralPlayerAnimator`:
- animates the rig sockets based on velocity, facing, speed, and equipped bone defs.
- uses a lower body pose, stronger arm pulls, and tucked legs in crawl mode.
- responds to attack events.
- bends limb joints when rigged limb data exists.

## Generated World

`scripts/tutorial_island_builder.gd` builds the demo island layout.

It positions the player, creates or updates open world stages, places enemies,
registers camp enemies, and configures stage metadata for the playable loop.

## Guidance Docs

`docs/godot_signal_guidelines.md` defines signal naming and decoupling rules.

`docs/current_system_status.md` records the current inventory, combat, camera,
enemy, and rig boundaries before the component refactor.

`docs/open_world_map_layout.md` describes the demo island route and stage regions.

`docs/rig_notes.md` describes modular rig and procedural animation setup.

## docs/rig_notes.md

# Marrow — Modular Rig / Procedural Animation notes

Isolated prototype for the "Modular Rigging and Procedural Animation" brief.
**Not wired into the real player yet** (brief Phase G) — test it in `rig_test.tscn` first.

## How to test
Open `scenes/rig_test.tscn` in Godot and run it (F6 / "Run Current Scene").

- **WASD** — move. Body bobs, torso leans, arms/legs swing, and the whole figure
  turns smoothly toward the movement direction. Standing still = subtle idle breathing.
- **Space** — attack: a quick forward arm thrust + torso twist that blends back out
  (Phase E), readable while idle or walking.
- **Q** — cycles equipping **Arm → Leg → Heavy** into their slots. The grey limb is
  swapped for a bone-colored one; Heavy is bigger (visual_scale) and heavier.
- Walk **forward onto the ramp** (in front of spawn) to see foot placement (Phase F):
  each foot raycasts down and plants on the surface, tilting to the slope.

## Architecture (animate sockets, not meshes)
- `scripts/rig/modular_skeleton_rig.gd` (`ModularSkeletonRig`) — builds Node3D
  sockets in `_ready()` and hangs a grey box on each. `equip_bone(id, def)` /
  `unequip_slot(slot)` swap the socket's visual. Equipped bones are children of
  sockets, so they inherit socket motion for free.
- `scripts/rig/procedural_player_animator.gd` (`ProceduralPlayerAnimator`) —
  `update_from_player(delta, velocity, max_speed, facing, equipped_defs)` moves
  the sockets from the ACTUAL velocity (so slopes/knockback/speed bonuses all read
  correctly). Layers: idle breathing, walk bob, torso lean/sway, arm+leg swing,
  turn smoothing, weight response.
- `scripts/bone_database.gd` — single source of bone data; added `weight` (and
  `visual_scale` on Heavy).
- `scripts/rig/rig_test_player.gd` — sandbox movement controller (no combat/inventory).

## Tuning variables (exports on ProceduralAnimator)
walk_cycle_speed 8.0 · body_bob_amount 0.08 · body_sway_amount 0.04 ·
torso_lean_amount 0.12 · arm_swing_amount 0.45 · leg_swing_amount 0.35 ·
turn_smoothing 12.0 · idle_breath_amount 0.025 · heavy_weight_swing_slowdown 0.65

## Phase E/F tuning (exports on ProceduralAnimator)
attack_overlay_duration 0.16 · attack_overlay_blend_speed 18 · attack_arm_forward 1.1 ·
attack_torso_twist 0.35 · foot_raycast_up/down 0.6/1.4 · foot_lift 0.06 ·
foot_smoothing 14 · foot_align_to_normal true (uncheck foot_placement_enabled to disable).

## Known limitations / TODO
- Socket positions & limb sizes are hand-estimated grey-box values — expect to
  nudge them once seen in a real window.
- Body facing yaw uses `atan2(facing.x, facing.z)`; if the figure faces backwards,
  flip the sign (orientation not verified visually).
- Attack overlay sign (arm forward/back) not visually verified — flip
  `attack_arm_forward` if it thrusts the wrong way.
- Feet are independent of the swinging leg boxes (no knee IK yet, per the brief's
  grey-box rule); on steep slopes there may be a visible leg/foot gap.
- Foot placement done on flat ground + a ramp; steps not added (CharacterBody3D
  needs step-up logic to climb vertical steps).
- Not merged into the real player (Phase G) — do that only after this feels good.

