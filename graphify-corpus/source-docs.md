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
run/main_scene="res://scenes/main.tscn"
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

## docs/current_system_status.md

# MARROW Current System Status

This document records the current gameplay architecture before the next larger
refactor pass.

## Inventory

- `PlayerInventoryUI` owns inventory presentation, tabs, item tiles, details,
  settings, paper doll slots, and the character preview.
- `Player` still owns inventory and equipment state through `bone_inventory` and
  `equipped`.
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

## Rig

- `ModularSkeletonRig` creates sockets and visual equipment parts.
- `ProceduralPlayerAnimator` animates sockets from resolved movement velocity and
  equipped bone data.
- Crawl mode lowers the body and uses stronger arm pulls with tucked legs.

## Next Refactor Boundary

The next architecture step should extract inventory and equipment ownership from
`Player` into dedicated components while keeping the current public methods
stable for UI, pickups, gates, and tests.

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

`project.godot` runs `scenes/main.tscn`.

`project.godot` autoloads `GameEvents` from `scripts/game_events.gd`.

## GameEvents

`GameEvents` is the global gameplay event bus.

Signals:
- `bone_collected(bone_id, collector)`
- `bone_equipped(bone_id, slot, player)`
- `bone_unequipped(bone_id, slot, player)`
- `player_died(player)`
- `trial_completed(trial_id, trial_name)`
- `exit_reached(player)`
- `stage_entered(stage)`
- `stage_exited(stage)`
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

## BoneDatabase

`scripts/bone_database.gd` is the single source of truth for bone definitions.

Current bone ids:
- `arm_bone`
- `leg_bone`
- `heavy_bone`
- `dummy_bone`
- `rib_bone`

Each definition can include:
- display name
- quality
- color
- slot
- player stat bonuses
- enemy stat bonuses
- visual scale and tags
- description

Consumers:
- `Player` uses stat bonuses and slot data.
- `Bone` and `LimbBonePickup` use slot-aware display names and colors.
- `Enemy` uses enemy bonuses, drop data, and slot-aware display names.
- `BoneTrialGate` uses required bone slot-aware display names and colors.
- Inventory UI widgets use slot-aware display names, colors, slot labels, and effect text.

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

