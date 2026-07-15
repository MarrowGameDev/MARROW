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
anim_demo_procedural={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":50,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
anim_demo_tween={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":51,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
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

## docs/bone_data_structure.md

# Bone Data Structure

Este documento describe la estructura actual de datos de huesos. Es la
referencia para agregar, migrar o revisar huesos sin romper compatibilidad.

## Objetivo

Los huesos hechos a mano deben vivir como `BoneDefinition` Resources en
`data/bones/*.tres`. El runtime todavia lee datos normalizados mediante
`BoneDatabase` y `BoneRulesService`, porque partes del proyecto siguen esperando
diccionarios planos.

Regla principal:
- Authoring: editar `BoneDefinition` / `.tres`.
- Runtime: leer desde `BoneRulesService`, `EquipmentRulesService`,
  `DropPickupRulesService` o `BoneDatabase`.
- No leer `BoneDataCatalog.DEFINITIONS` desde gameplay nuevo.

## Resolucion De Datos

1. `BoneDataCatalog.RESOURCE_PATHS` apunta un `bone_id` a un `.tres`.
2. `BoneDataCatalog.resource_for(id)` carga el Resource si existe.
3. `BoneDataCatalog.clean_definition_for(id)` entrega el esquema limpio.
4. `BoneDataCatalog.legacy_definition_for(id)` convierte a diccionario plano.
5. `BoneDatabase.reload_from_catalog()` llena `BoneDatabase.BONES`.
6. `BoneRulesService.definition_for(id)` resuelve huesos hechos a mano y limbs
   generados de enemigos.

Ids hechos a mano actuales:
- `head_bone`: nucleo fijo inicial, slot `head`, no debe dropear como loot
  normal.
- `torso_bone`: torso starter, slot `body`, habilita acoplar extremidades.
- `arm_bone`
- `leg_bone`
- `heavy_bone`
- `dummy_bone`
- `rib_bone`

## Identidad

Campos principales:
- `bone_id`: id estable, por ejemplo `arm_bone`.
- `display_name`: nombre visible.
- `color`: color fisico del hueso.
- `slot`: slot de equipamiento (`right_arm`, `left_arm`, `body`, `legs`,
  `head`).
- `tags`: tags generales.
- `description`: texto visible para UI.

## Calidad

Calidad describe condicion o potencia de la pieza. No es rareza de loot.

Ids canonicos:
- `chatarra`
- `fragil`
- `comun`
- `fuerte`
- `legendario`

Campos:
- `quality`
- `quality_rank`
- `quality_score`
- `quality_multiplier`
- `quality_color`
- `quality_damage_percent`
- `quality_speed_percent`
- `quality_health_percent`
- `quality_drop_percent`
- `quality_weight_percent`

Los porcentajes son metadata pasiva. No se aplican automaticamente a combate,
drops, inventario o equipamiento hasta que exista una regla dedicada.

## Rareza

Rareza describe obtencion, categoria de loot o peso futuro de drops. No es
calidad.

Ids canonicos:
- `comun`
- `corrupto`
- `maldito`
- `especial`
- `legendario`

Campos:
- `rarity`
- `rarity_rank`
- `rarity_color`
- `rarity_drop_weight`

`rarity_drop_weight` esta listo para tablas ponderadas, pero no cambia drops
automaticamente todavia.

## Mutacion

Mutacion describe variantes visuales, biologicas o de comportamiento que una
regla futura puede consumir.

Familias canonicas actuales:
- vacio (`""`)
- `corrupto`
- `maldito`
- `especial`
- `hibrido`

Campos:
- `mutation_id`
- `mutation_family`
- `mutation_stage`
- `mutation_intensity`
- `mutation_tags`

Mutacion no debe modificar rig, AI o combate por si sola. Debe haber una regla
documentada que lea estos campos.

## Ataque Y Combo

Estos campos preparan cadenas de combate y previews sin activar combos reales.

Campos:
- `attack_type`
- `attack_tags`
- `combo_family`
- `combo_step`
- `combo_window`
- `combo_tags`
- `combo_finisher`

Ejemplo: un brazo puede declarar `attack_type = "melee"` y
`combo_family = "starter_strikes"`.

Uso actual:
- `combo_window` puede mantener viva una cadena visual de ataques.
- `combo_step`/`combo_family` describen authoring, pero no cambian dano.
- La animacion simple de combo vive en `ProceduralPlayerAnimator`.

Esto no cambia cooldown, dano, input ni hitbox hasta que el sistema de combate
lo consuma explicitamente.

## Set Y Sinergia

Campos:
- `set_id`
- `set_name`
- `set_piece_key`
- `set_tags`
- `synergy_ids`
- `synergy_tags`
- `synergy_score`

Estos campos son metadata pasiva para futuras reglas de combinacion. No aplican
bonuses automaticamente.

## Stats Del Jugador

Campos limpios:
- `player_move_speed`
- `player_attack_range`
- `player_attack_damage`
- `player_max_health`

Campos legacy equivalentes:
- `move_speed_bonus`
- `attack_range_bonus`
- `attack_damage_bonus`
- `max_health_bonus`

El inicio del juego usa `head_bone` como pieza fija y `max_health` base bajo.
`torso_bone`, brazos y piernas pueden aumentar `max_health`; al subir el maximo,
`PlayerStatsComponent` recupera esa diferencia de vida.

## Stats De Enemigos

Campos:
- `enemy_move_speed`
- `enemy_attack_range`
- `enemy_contact_damage`
- `enemy_max_health`
- `enemy_detection_range`
- `enemy_visual_scale`
- `enemy_flee_chance`

`Enemy` debe leerlos mediante servicios o helpers existentes, no desde el
Resource directamente.

## Visual Y Peso

Campos:
- `weight`: compatibilidad legacy para animacion procedural.
- `weight_class`: `light`, `medium`, `heavy`, etc.
- `physical_weight`: peso en mundo.
- `equipment_weight`: carga al equipar.
- `inventory_weight`: coste/peso en inventario.
- `visual_scale`
- `visual_offset`
- `visual_rotation`
- `head_socket_offset`
- `hitbox_size`
- `hitbox_offset`
- `hitbox_scale`
- `hitbox_rotation`

`head_socket_offset` aplica a torsos (`slot = body`). Define donde debe vivir
el socket/origen de la cabeza relativo al torso equipado durante estados donde
la cabeza depende directamente del torso, como torso-only spring y ataques que
lanzan la cabeza desde el torso. Si queda en `Vector3.ZERO`, el animador usa su
fallback actual para mantener compatibilidad con huesos viejos.

`hitbox_*` controla las cajas de dano por parte del cuerpo en
`ModularSkeletonRig`. Si `hitbox_size` queda en `Vector3.ZERO`, el rig calcula
el tamano desde la geometria base del socket y `hitbox_scale`/`visual_scale`.
Usa `hitbox_offset` y `hitbox_rotation` cuando una malla importada no coincide
con el centro/orientacion de la caja base.

## Agregar Un Hueso Nuevo

1. Crear un `BoneDefinition` `.tres` en `data/bones/`.
2. Agregar `bone_id` y path en `BoneDataCatalog.RESOURCE_PATHS`.
3. Agregar fallback temporal en `BoneDataCatalog.DEFINITIONS` solo si hace falta
   compatibilidad durante migracion.
4. Confirmar que `BoneDatabase.get_def(bone_id)` devuelve los campos planos.
5. Probar equipamiento/drops en `scenes/testing_environment.tscn`.
6. Actualizar docs relevantes si el hueso introduce una regla nueva.

## Compatibilidad

`BoneDefinition.to_clean_dictionary()` mantiene el esquema organizado.
`BoneDefinition.to_legacy_dictionary()` mantiene el contrato plano que ya usan
UI, enemigos, drops, rig y herramientas.

Si se agrega un campo nuevo:
- agregarlo al Resource;
- agregarlo al clean dictionary;
- agregarlo al legacy dictionary si gameplay/UI debe leerlo;
- agregar parser en `from_clean_dictionary`;
- agregar getter en `BoneDatabase` o `BoneRulesService` si alguien lo consume;
- documentarlo en este archivo y en el flujo afectado.

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
- Aplica `set_animation_follow_offset` para seguir offsets visuales horizontales
  de animacion sin mover verticalmente la camara.
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

## Flujo de camara por animacion

1. `ProceduralPlayerAnimator` calcula el offset hacia adelante del ataque cuando
   el jugador sigue siendo solo cabeza.
2. `Player._update_procedural_animation` lee
   `get_head_only_attack_world_offset`.
3. Ese offset ya viene en mundo horizontal e incluye tanto el salto actual como
   la posicion adelantada acumulada por golpes anteriores.
4. `Player` lo entrega a la camara con Y en cero.
5. `PlayerCameraController.set_animation_follow_offset` suaviza ese offset en
   el pivot de camara.
6. La camara sigue solo la distancia horizontal del salto; el arco vertical se
   queda en la animacion del socket de cabeza.

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
- 2026-07-14: La camara ahora puede seguir offsets horizontales de animacion;
  se usa para acompanar el ataque de cabeza sin copiar su salto vertical.

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
- The inventory preview uses the same body progression visibility as the player:
  fixed head first, torso required, limbs visible only after recovery/equip.

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

- Full schema reference lives in `docs/bone_data_structure.md`.
- `BoneDefinition` is the Godot `Resource` type for one hand-authored bone.
- Initial hand-authored bones now live as `.tres` assets in `data/bones/`.
- `BoneDataCatalog` loads `.tres` Resources first and uses its in-code
  dictionaries only as temporary fallback during gradual migration.
- `BoneDatabase` remains the compatibility layer that normalizes catalog data
  into the flat fields current systems expect.
- `BoneDatabase.BONES` is still populated for legacy direct reads, and
  `BoneDatabase.reset_cache()`/`reload_from_catalog()` refresh the cache.
- Bone quality fields describe part quality/condition and balancing metadata;
  they are intentionally separate from loot rarity.
- Canonical quality ids are `chatarra`, `fragil`, `comun`, `fuerte` and
  `legendario`; UI can localize display text separately.
- Quality percentage modifiers are stored as passive metadata for damage, speed,
  health, drop and weight tuning; no automatic formula consumes them yet.
- Canonical rarity ids are `comun`, `corrupto`, `maldito`, `especial` and
  `legendario`; canonical mutation families are empty, `corrupto`, `maldito`,
  `especial` and `hibrido`.
- Bone attack/combo fields are present as passive metadata for future combat
  chains; current attacks still come from the existing player/enemy combat code.
- Bone weight fields now distinguish animation weight, physical weight,
  equipment load and inventory weight while keeping legacy `weight`.
- Bone set/synergy fields are present as passive metadata; no automatic set
  bonuses are active yet.
- Gameplay consumers should still use `BoneRulesService`, `EquipmentRulesService`
  or `BoneDatabase`, not `BoneDefinition` or `BoneDataCatalog` directly.

## Testing

- `scenes/testing_environment.tscn` is the unified sandbox for camera, enemies,
  movement, animation, rig, drops, and equipment checks.
- TESTING ENVIRONMENT can spawn a passive dummy target with `5`; it stays still,
  does not attack, and keeps normal damage/limb-loss reactions active.
- `scenes/dummy_testing_environment.tscn` is a separate passive-target room that
  only spawns dummy enemies for focused animation, damage, limb, and hitbox
  checks.
- `scenes/main_menu.tscn` exposes both the playable demo and testing
  environments.

## Tutorial

- `ArenaGoalManager` owns the demo help panel and now shows a live controls
  tutorial checklist.
- The checklist reads current bindings through `DropPickupRulesService`, so it
  follows control remaps instead of hardcoded key text.
- Tutorial progress listens to direct input plus `GameEvents` for pickup,
  inventory open, and equip events.

## Rig

- `ModularSkeletonRig` creates sockets and visual equipment parts.
- `ProceduralPlayerAnimator` animates sockets from resolved movement velocity and
  equipped bone data.
- Crawl mode lowers the body and uses stronger arm pulls with tucked legs.
- Attack animation now supports a simple three-step combo overlay: right strike,
  left strike, and two-arm finisher. It is visual only.
- Player body progression mode hides unrecovered body parts. Head-only movement
  uses a simple hop/roll pose until the torso is equipped.

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

Rareza:
- Los campos `rarity`, `rarity_rank`, `rarity_color` y `rarity_drop_weight`
  viven en `BoneDefinition` y pasan por `BoneDatabase`.
- `rarity_drop_weight` no cambia drops automaticamente todavia; queda listo
  para cuando se defina una tabla de drops ponderada.
- `quality_drop_percent` permite expresar una intencion de ajuste porcentual por
  calidad. No modifica drops automaticamente hasta que exista una regla clara en
  `DropRulesService`.
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
- 2026-07-14: Se agregaron campos de rareza y peso de drop por rareza sin
  activar todavia reglas ponderadas de loot.

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
  No aplicar `quality_multiplier` a stats automaticamente hasta que una regla de
  balance lo defina explicitamente.
- Los modificadores porcentuales por calidad (`quality_damage_percent`,
  `quality_speed_percent`, `quality_health_percent`, `quality_drop_percent`,
  `quality_weight_percent`) son metadata granular. Pueden alimentar balance
  futuro, pero equipamiento no los aplica automaticamente todavia.
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
  animacion procedural actual.
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
6. `docs/bone_data_structure.md`
   - Estructura de `BoneDefinition`, compatibilidad, calidades, rarezas,
     mutaciones, ataque/combo, stats, peso y pasos para agregar huesos.
7. `docs/tutorial_flow.md`
   - Tutorial de controles, hints del demo y checklist de onboarding.

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

### Validacion estatica del preview

Antes de cambiar el preview del inventario, ejecutar:

```bash
python -B tools/validate_inventory_preview_contract.py
```

El validador confirma que la UI conserva el `SubViewportContainer`, el
`SubViewport`, un `World3D` propio, luces/camara de preview, rig modular
separado, sincronizacion desde eventos de equipamiento y escalado responsive del
paper doll. Es una validacion estatica; render, lifecycle visual y
sincronizacion real al equipar/desequipar siguen requiriendo prueba en
`TESTING ENVIRONMENT`.

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

Campos de calidad:
- `quality` sigue siendo el texto visible que ya usa la UI.
- `quality_rank` permite ordenar o filtrar por estado/calidad de la pieza.
- `quality_score` puede usarse para comparar piezas sin depender del texto.
- `quality_multiplier` queda reservado para balance si una pieza debe escalar
  stats, rewards o valor.
- `quality_color` permite colorear estado/calidad sin cambiar el color fisico
  del hueso.
- `quality_damage_percent`, `quality_speed_percent`,
  `quality_health_percent`, `quality_drop_percent` y
  `quality_weight_percent` permiten mostrar o comparar intenciones de balance
  por calidad sin aplicar reglas automaticas.
- Calidades canonicas: `chatarra`, `fragil`, `comun`, `fuerte`,
  `legendario`.
- Calidad no es rareza. Rareza de loot vive en `rarity`/`rarity_rank`.

Campos de rareza:
- `rarity` describe rareza de loot/obtencion, separada de la calidad fisica o
  funcional de la pieza.
- `rarity_rank` permite ordenar o filtrar por rareza.
- `rarity_color` permite mostrar rareza sin cambiar el color fisico del hueso.
- `rarity_drop_weight` queda disponible para futuras reglas de drops.
- Rarezas canonicas: `comun`, `corrupto`, `maldito`, `especial`,
  `legendario`.
- Mutaciones canonicas actuales: vacio, `corrupto`, `maldito`, `especial`,
  `hibrido`.

Campos de peso:
- `weight` se mantiene como campo legacy para animacion procedural.
- `weight_class` permite mostrar o filtrar piezas como light/medium/heavy.
- `physical_weight` describe peso fisico de la pieza en mundo.
- `equipment_weight` queda disponible para carga al equipar.
- `inventory_weight` queda disponible para limites o coste de inventario.

Campos de set/sinergia:
- `set_id`, `set_name`, `set_piece_key` y `set_tags` describen a que conjunto
  pertenece una pieza.
- `synergy_ids`, `synergy_tags` y `synergy_score` preparan filtros o previews
  de combinaciones.
- La UI puede mostrar estos datos, pero no debe calcular bonuses de set hasta
  que exista una regla de equipamiento dedicada.

Campos de ataque/combo:
- `attack_type` describe la categoria principal de uso de combate o movimiento.
- `attack_tags` y `combo_tags` permiten filtros o detalles en UI.
- `combo_family`, `combo_step`, `combo_window` y `combo_finisher` preparan la
  lectura de cadenas de ataque.
- Inventario puede mostrar estos datos, pero no debe cambiar ataques, hitboxes,
  dano ni combos automaticamente.

## Puntos delicados

- Duplicados: el inventario permite varios huesos con el mismo id. La UI debe
  filtrar solo las copias equipadas, no esconder todos los duplicados.
- Pausa: la UI procesa mientras el arbol esta pausado.
- Settings: controles modificados se guardan en `user://control_settings.cfg`.
- El tutorial de controles debe leer los bindings actuales con
  `DropPickupRulesService.action_binding_text`, para que el texto visible siga
  los cambios hechos en settings.
- Interaccion: si el jugador esta en rango de pickup, el inventario no debe
  abrirse con la misma tecla de interact. Como inventario usa `Tab` e interact
  usa `E`, Tab no se bloquea por pickups cercanos.
- Progresion corporal: el inventario puede contener torso/extremidades, pero el
  slot de cabeza es fijo. Si se intenta equipar brazos o piernas sin torso,
  `PlayerEquipmentComponent` bloquea la accion y emite hint.

## Como probar

En `TESTING ENVIRONMENT`:

1. Abrir inventario con `Tab`.
2. Revisar que aparecen huesos iniciales de prueba.
3. Arrastrar huesos a slots.
4. Cambiar categoria.
5. Ir a settings y cambiar una tecla.
6. Recoger un drop real y confirmar que aparece sin reiniciar la UI.
7. Intentar equipar brazo/pierna sin torso y confirmar que se bloquea.
8. Equipar `torso_bone`, luego brazo/pierna, y confirmar que el preview agrega
   solo las partes recuperadas.

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
- 2026-07-14: Se agregaron campos de calidad a `BoneDefinition` y al formato
  legacy: rank, score, multiplier y color.
- 2026-07-14: Se agregaron campos de rareza separados de calidad:
  `rarity`, `rarity_rank`, `rarity_color` y `rarity_drop_weight`.
- 2026-07-14: Se agregaron campos de peso para inventario/equipamiento sin
  cambiar todavia limites de carga.
- 2026-07-14: Se agregaron campos de set/sinergia para futuras vistas y reglas
  de combinacion.
- 2026-07-14: Se reforzo el arranque de controles. El menu y el player limpian
  pausa residual al entrar, la UI valida `user://control_settings.cfg`, y
  `Player` tiene fallback directo de teclado/mouse para WASD, Tab, Space,
  Shift, ataques y acciones principales si `InputMap` queda incompleto.
- 2026-07-14: Se limpio el layout responsive del inventario para no redimensionar
  manualmente paneles con anchors ni el `SubViewport` cuando el container ya
  esta en modo stretch.
- 2026-07-15: `scripts/player.gd` — se elimino el fallback de teclado/mouse
  agregado el 2026-07-14 (la entrada de arriba ya no aplica). Ese fallback
  hardcodeaba las teclas fisicas (`KEY_W`, `KEY_E`, ...) y las OR-eaba dentro de
  `_input_pressed` / `_input_just_pressed` / `_input_just_released` /
  `_get_move_input_vector`, asi que el rebinding de la UI nunca podia
  DESasignar un default: rebindear Move Forward fuera de W dejaba W caminando
  para siempre, y lo mismo para las otras 12 acciones. Verificado que las 13
  acciones estan declaradas en `project.godot`, o sea que el fallback era
  redundante. Ahora los helpers leen solo el `InputMap`. Pruebas: abrir
  settings, rebindear Move Forward a otra tecla y confirmar que W ya no camina;
  reiniciar y confirmar que el binding persiste desde
  `user://control_settings.cfg`.

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
  - Starter `torso_bone` pickup sits near player spawn so the opening order is
    head first, then torso, then extremities.
- `FirstHuntField`: Difficulty 2, starter enemies and first bones.
- `ReachRidge`: Difficulty 3, Arm Bone / reach-focused area.
- `QuickrootRun`: Difficulty 4, Leg Bone / speed-focused area.
- `HeavyRuin`: Difficulty 5, Heavy Bone / power-focused area.
- `RibfenBonus`: Difficulty 4, optional side-stage for Rib Bone.
- `ElderMarrowGate`: Difficulty 7, future high-difficulty zone.

## Next Coder Step

Once the layout feels readable, move enemies/trials into the matching stage regions and add stage-specific spawn points. Do not create real art yet; first confirm the overworld route makes players naturally understand where each bone matters.

## Change History

- 2026-07-14: Tutorial island builder now uses local positions for existing
  scene nodes and generated spawns. This avoids `global_transform` errors before
  nodes are fully inside the scene tree.

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
- `ArenaGoalManager` listens to `bone_collected`, `bone_equipped`,
  `inventory_open_changed` and `tutorial_hint_requested` to update the controls
  tutorial checklist.
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
- `Player` starts with `head_bone` equipped as a fixed core and enables body
  progression visibility on `ModularSkeletonRig`.

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

Detailed schema reference: `docs/bone_data_structure.md`.

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
- Quality helpers such as `quality_rank`, `quality_score`,
  `quality_multiplier` and `quality_color` are additive and do not replace the
  existing `quality` text.
- Rarity helpers such as `rarity`, `rarity_rank`, `rarity_color` and
  `rarity_drop_weight` are additive and separate from quality.
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
- `BoneDefinition.quality_*` fields: quality rank, score, multiplier, quality
  color and granular percent modifiers for damage, speed, health, drops and
  weight. These describe part quality/condition, not loot rarity.
  Canonical quality ids are `chatarra`, `fragil`, `comun`, `fuerte` and
  `legendario`.
- `BoneDefinition.rarity_*` fields: loot rarity metadata and optional drop
  weighting. Canonical ids are `comun`, `corrupto`, `maldito`, `especial` and
  `legendario`.
- `BoneDefinition.mutation_*` fields: mutation family, stage, intensity and
  tags for future visual, rig, AI or combat hooks. Canonical families are empty,
  `corrupto`, `maldito`, `especial` and `hibrido`.
- `BoneDefinition.attack_*` and `BoneDefinition.combo_*` fields: passive attack
  and combo authoring metadata for future combat chains.
- `BoneDefinition.weight*` fields: legacy animation weight plus weight class,
  physical weight, equipment weight and inventory weight.
- `BoneDefinition.set_*` and `BoneDefinition.synergy_*` fields: passive set
  membership and synergy metadata for future combination rules.
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
- supports body progression visibility: head first, torso required, limbs only
  when equipped.

`scripts/rig/procedural_player_animator.gd` defines `ProceduralPlayerAnimator`.

`ProceduralPlayerAnimator`:
- animates the rig sockets based on velocity, facing, speed, and equipped bone defs.
- uses a lower body pose, stronger arm pulls, and tucked legs in crawl mode.
- responds to attack events and supports three simple combo poses.
- bends limb joints when rigged limb data exists.

## Generated World

`scripts/tutorial_island_builder.gd` builds the demo island layout.

It positions the player, creates or updates open world stages, places enemies,
registers camp enemies, and configures stage metadata for the playable loop.
It also spawns the starter `torso_bone` pickup near the player start.

## Guidance Docs

`docs/godot_signal_guidelines.md` defines signal naming and decoupling rules.

`docs/current_system_status.md` records the current inventory, combat, camera,
enemy, and rig boundaries before the component refactor.

`docs/open_world_map_layout.md` describes the demo island route and stage regions.

`docs/rig_notes.md` describes modular rig and procedural animation setup.

`docs/tutorial_flow.md` describes the demo controls tutorial and onboarding
checklist.

## docs/rig_notes.md

# Marrow — Modular Rig / Procedural Animation notes

Isolated prototype for the "Modular Rigging and Procedural Animation" brief.
**Not wired into the real player yet** (brief Phase G) — test it in `rig_test.tscn` first.

## How to test
Open `scenes/rig_test.tscn` in Godot and run it (F6 / "Run Current Scene").

- **WASD** — move. Body bobs, torso leans, arms/legs swing, and the whole figure
  turns smoothly toward the movement direction. Standing still = subtle idle breathing.
- **Attack** — cycles simple combo poses: right-arm strike, left-arm strike,
  then a heavier two-arm/torso finisher.
- **Q** — cycles equipping **Arm → Leg → Heavy** into their slots. The grey limb is
  swapped for a bone-colored one; Heavy is bigger (visual_scale) and heavier.
- Walk **forward onto the ramp** (in front of spawn) to see foot placement (Phase F):
  each foot raycasts down and plants on the surface, tilting to the slope.

### Animation A/B demo (rig sandbox only)
`2` and `3` play the SAME head lunge authored two ways, so the two styles can be
compared. Both read the `head_only_attack_*` tuning, so retuning moves them
together and any difference is the authoring style, not the numbers.

Lives in `scripts/rig/rig_test_player.gd`, so it is confined to `rig_test.tscn`
and never reaches the shipping `Player`. The animator keeps the demo poses
(`trigger_demo_attack_procedural` / `trigger_demo_attack_tween` /
`set_demo_target_world_position`) because that is animation code and both scenes
share the animator, but nothing triggers them outside the sandbox.

- **2** — `ProceduralPlayerAnimator.trigger_demo_attack_procedural()`: per-frame
  math with hand-written easing helpers (`_ease_out_quad` and friends).
- **3** — `ProceduralPlayerAnimator.trigger_demo_attack_tween()`: a `Tween` chain,
  easing by name (`TRANS_QUAD` + `EASE_OUT`).

An orange ball spawns on first press and orbits the player as a moving target.
Key `2` re-aims mid-flight and tracks it; key `3` commits to wherever the ball was
when the tween was built and misses by ~40 deg. That is the real trade: identical
output, the tween is nicer to author, only the procedural version can react to a
runtime target. Measured headless: both trace the same arc (peak 0.9199 vs 0.9197).

Because `_animate_body()` rebuilds `head.position` from rest every frame, the
tween cannot own the socket — it drives values that `_apply_demo_pose()` writes at
the end of the animator's frame. An `AnimationPlayer` would hit the same wall.
The demo hijacks the head socket regardless of equipped state, and settles back to
a pose captured at trigger time, so it may pop slightly if triggered mid-sprint.

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
- `scripts/bone_database.gd` — compatibility layer for bone data; `weight`
  remains the legacy animation weight while `physical_weight`,
  `equipment_weight`, `inventory_weight` and `weight_class` are available for
  future rig/inventory rules.
- `scripts/rig/rig_test_player.gd` — sandbox movement controller (no combat/inventory).

## Tuning variables (exports on ProceduralAnimator)
walk_cycle_speed 8.0 · body_bob_amount 0.08 · body_sway_amount 0.04 ·
torso_lean_amount 0.12 · arm_swing_amount 0.45 · leg_swing_amount 0.35 ·
turn_smoothing 12.0 · idle_breath_amount 0.025 · heavy_weight_swing_slowdown 0.65

## Phase E/F tuning (exports on ProceduralAnimator)
attack_overlay_duration 0.16 · attack_overlay_blend_speed 18 · attack_arm_forward 1.1 ·
attack_torso_twist 0.35 · foot_raycast_up/down 0.6/1.4 · foot_lift 0.06 ·
foot_smoothing 14 · foot_align_to_normal true (uncheck foot_placement_enabled to disable).
Head-only attack tuning: `head_only_attack_duration`,
`head_only_attack_charge_portion`, `head_only_attack_lunge`,
`head_only_attack_arc`, `head_only_attack_charge_squash`,
`head_only_attack_roll`, `head_only_attack_release_portion` 0.25 (fraction of the
jump over which the charge compression unwinds; 0 restores the old one-frame
snap) and `head_only_attack_roll_damping` 0.2 (how much rolling spin survives
while the head is airborne mid-attack; 1.0 restores the old behaviour).
Hit recoil tuning: `head_only_hit_recoil_duration`,
`head_only_hit_recoil_hold`, `head_only_hit_recoil_arc`,
`head_only_hit_recoil_lift`, `head_only_hit_recoil_horizontal_push`,
`head_only_hit_recoil_roll` and `head_only_hit_recoil_settle`.

Head-launch auto-aim:
- `Player` pushes a world-space aim into
  `ProceduralPlayerAnimator.set_head_launch_attack_aim(direction, valid)` every
  frame (before `update_from_player`). `valid = false` restores the old behaviour
  of launching down the player's facing direction.
- `trigger_attack` seeds `_head_only_attack_direction` /
  `_torso_head_attack_direction` from that aim, and
  `_update_head_launch_attack_aim()` keeps re-reading it every frame while the
  launch is in the air, so an enemy that moves mid-attack is tracked. The
  direction freezes on landing so the landing offset matches the pose reached.
- The animator knows nothing about enemies. Enemy lookup and range rules live in
  `Player` + `CombatTargetingService` (see `docs/combat_flow.md`).

Combo overlay:
- `Player` passes a combo step into `ProceduralPlayerAnimator.trigger_attack`.
- Step 1 uses right arm + torso twist.
- Step 2 uses left arm + opposite torso twist.
- Step 3 uses both arms, deeper lunge, and a small head dip.
- If the player is only a head, combo arm poses are skipped. The head instead
  squashes backward to charge, jumps forward/up toward the target direction,
  reaches above mid-torso height, and lands forward into a new rolling start
  point. That forward landing is now a real displacement of the PLAYER: on
  landing the animator raises `has_head_only_body_catch_up_request()` and the
  Player consumes it the same frame, moving the capsule to the head with
  `move_and_collide` (so lunging into a wall stops at the wall). Previously the
  landing accumulated into `_head_only_base_world_offset` and only the head
  visual moved, so the head drifted 0.85 m further from the capsule on every
  attack, forever — and that drift also leaked into the camera follow offset via
  `get_head_launch_attack_world_offset()`. A hit does not displace the player:
  the recoil returns the head to the body instead. The launch uses the rig's positive
  local Z direction so it moves forward in game view. The landed offset is
  stored as a world-horizontal vector and converted into rig-local space each
  frame, so turning or strafing sideways does not rotate the old landing offset
  and teleport the head.
- The landing frame applies the newly accumulated landed offset immediately,
  instead of waiting for the next animation tick. This prevents a one-frame
  snap/ghost where the head briefly appears at the previous start point.
- If `AttackHitbox` confirms a real contact, the head-only attack switches into
  a separate hit recoil pose. It captures the exact local `head` socket position
  at impact, including the screen X/Y placement, and blends from that pose back
  toward the pre-impact start point while the camera follows the horizontal
  recoil. The extra ground-plane push ramps in during the recoil instead of
  snapping on the impact frame. The recoil uses smoothstep easing plus a small
  damped settle wave. `head_only_hit_recoil_lift` is only used as a minimum
  bounce height after recoil starts, and `head_only_hit_recoil_horizontal_push`
  controls the extra shove along the ground plane. A miss still lands forward
  and becomes the next start point.
- Current head-only height tuning uses `head_only_attack_arc = 0.92`,
  `head_only_hit_recoil_arc = 0.64`, and `head_only_hit_recoil_lift = 0.46`.
- Head-only melee uses a small `AttackHitbox` volume that follows the rig's
  `head` socket every physics frame. Contact is driven by the visible head
  position, including the vertical arc/recoil, instead of forcing the animator to
  snap forward to a minimum impact offset.
- During that head-only attack, the animator exposes
  `get_head_only_attack_world_offset()` so the camera can follow the accumulated
  horizontal motion directly. The vertical arc stays visual on the head socket.
- `ModularSkeletonRig.set_head_only_visual_guard` runs during head-only movement
  to keep the equipped/core head mesh as the only visible mesh under the head
  socket. `Player` also calls the guard immediately when head-only melee starts,
  before spawning the attack hitbox, so the fallback grey head cannot overlap
  for the first rendered frame.
- This is visual only; melee damage and hitbox behavior are unchanged.

## Current player body progression
- The real player now enables body progression on `ModularSkeletonRig`.
- `Player._setup_procedural_character()` enables
  `player_body_progression_enabled` on `ProceduralPlayerAnimator`; enemies keep
  this disabled.
- The head is the fixed core. Torso must be equipped before arms or legs can
  attach.
- When the torso is missing, `ProceduralPlayerAnimator` uses
  `head_only_ground_socket_y` to place the head socket at ground height instead
  of the normal full-body head rest pose.
- Head-only movement increments `_head_only_roll_angle` from actual horizontal
  travel distance and applies that as rotation, so the head rolls along the
  ground instead of wobbling like a loose limb.
- The head-only vertical hop defaults to `0.0`, keeping the head planted unless
  designers intentionally tune bounce back in.
- The wobble pass skips the head while it is the only equipped core, so it does
  not reset the head back to the full-body rest height or overwrite the roll.
- When the torso is equipped but legs are still missing,
  `ProceduralPlayerAnimator` enters a torso-spring state. The torso compresses,
  launches upward/forward and settles like a spring from
  `torso_spring_ground_socket_y`, with the head placed from
  the equipped torso's `head_socket_offset` relative to the springing torso. If
  a torso has no socket data, the animator falls back to
  `torso_spring_head_offset`. The head adds a delayed
  `torso_spring_head_pop_amount` bounce so it rises a bit higher than the torso
  and settles back into place by the end of the cycle. The head uses extra side
  drift and rotation during this state so the torso-only movement reads more
  exaggerated than the full-body animation.
- Torso-only attack uses separate `torso_head_attack_*` tuning. The torso coils
  down, the head launches forward from the current torso spring socket, and the
  skull sphere hitbox follows the launched head. On confirmed contact, the head
  recoils high into the air and returns to the live torso socket position. Once
  landed, the overlay pins the head to that socket so it cannot replay the launch
  branch during blend-out.
- If the torso-only launch finishes without a confirmed contact, the animator
  exposes a detach request instead of snapping the head back. `Player` consumes
  that request, moves the character capsule to the launched head position,
  unequips the body slot, and leaves a simple detached torso marker in the
  world. The animator keeps the player in torso-attack mode until the launched
  skull reaches the future head-only ground position, then requests the actual
  detach. During that miss-fall window, the body stays in player/rig space
  instead of being pinned to a cached world transform. The abandoned torso marker
  is spawned from the player's current `VisualRoot` plus the rig origin before
  the capsule moves to the launched skull. The animator's stored transform is
  only a fallback; marker placement should follow where the player actually
  detached, not a stale pose from a previous location. After the X/Z anchor is
  chosen, `Player` raycasts downward and lifts the marker by half the torso mesh
  height so the abandoned torso rests on the surface instead of floating at
  capsule height. This uses a plain `intended_marker_transform` and applies it
  after the marker is added to the scene, avoiding reads from a temporary
  unparented node's `global_position`.
  That lets head-only movement start at the exact location where the skull
  touched down. The landing uses a short
  `detached_head_landing_duration` with a continuous fall ease and only a small
  fading bounce; head-only rolling is damped by `head_only_roll_speed_scale` so
  the skull does not over-rotate. After the capsule moves to the landed head,
  `enter_detached_head_state()` receives that grounded local position and uses a
  tiny `detached_head_mode_blend_duration` handoff into normal rolling sway,
  avoiding the last ground-level pop. `Player` also carries the camera's
  head-launch offset briefly during the detach handoff, preventing a one-frame
  jump back to torso view. Holding `Interact` near that marker restores only the
  abandoned torso.
- Reattaching the abandoned torso uses the `Interact` hold as the animation
  timeline. `Player` keeps the character root where the skull currently is, then
  `set_detached_head_reattach_tornado_progress()` orbits the skull diagonally
  around the torso marker toward the future head socket. Releasing `Interact`
  before completion calls `cancel_detached_head_reattach_tornado_to_ground()`,
  making the skull fall back to the head-only ground pose instead of restoring
  the torso. Combat/movement input is paused only while the hold animation is
  actively being pressed.
- The tornado target uses the detached torso marker rotation plus the torso
  bone's `head_socket_offset` / `head_origin_offset`, instead of a fixed height.
  When the hold completes, `Player` captures the head's current world position,
  aligns the player rig's stable body pose and yaw to the detached torso marker,
  then reapplies the captured head position before restoring the torso. That
  means normal body animation resumes from the marker instead of moving or
  rotating the body after the head has attached. `play_detached_head_reattach_finish_blend()`
  only blends the head back into the normal full-body pose.
- Reattach only aligns the player root at completion, after the head has reached
  the torso marker. That alignment uses the current detached marker, not cached
  attack data, so the restored body remains in place instead of popping after
  the attachment finishes.
- Enemies use `ProceduralEnemyAnimator`, a thin subclass that keeps player body
  progression disabled. This prevents enemies without player equipment records
  from being treated as head-only bodies.
- Once the torso is equipped, the normal body/head rest pose takes over again.

## Body-part hurtboxes
- `ModularSkeletonRig` now creates one `Area3D` hurtbox per socket:
  `head`, `body`, `right_arm`, `left_arm`, `right_leg`, `left_leg`,
  `right_foot` and `left_foot`.
- Hurtboxes live under the same sockets as the visuals, so procedural animation,
  crawling, rolling head movement and equipped-part scaling all move the boxes
  with the visible body part.
- `set_body_hitbox_owner(owner, group)` labels the same socket boxes for the
  owning actor. Player boxes use `player_body_hurtboxes`; enemy boxes use
  `enemy_body_hurtboxes`.
- Enemy-owned hurtboxes are trimmed with `ENEMY_HITBOX_ACCURACY_SCALE` after
  ownership is assigned, so enemy damage checks hug each body part more tightly
  without shrinking the player's own recovery/progression hurtboxes.
- When a bone is equipped, `equip_bone()` reads `hitbox_size`,
  `hitbox_offset`, `hitbox_scale` and `hitbox_rotation`. If no explicit
  `hitbox_size` is provided, the rig derives the box from the part's visual
  scale and the default limb geometry.
- Player body progression enables only the recovered/equipped body part
  hurtboxes. In the head-only start, only the head hurtbox should receive
  projectile damage.
- Enemies register themselves as the owner of their rig hurtboxes. When limbs
  detach or recover, `Enemy._set_rig_limb_visible()` also disables/enables that
  limb's hurtbox.
- Gorilla proportions now apply custom padded hurtboxes for torso, head, arms,
  legs and feet after the larger limb visuals are created. `Enemy` also widens
  the main collision box for active gorilla profiles, so physical contact and
  body-part damage both match the larger silhouette better.

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

## docs/tutorial_flow.md

# Tutorial Flow

Este documento describe el tutorial de controles del demo.

## Objetivo

El jugador debe poder aprender controles basicos sin abrir documentacion externa
ni depender de texto fijo que se desactualice cuando cambian keybinds.

El inicio narrativo del demo ahora es:
1. El jugador despierta como cabeza fija.
2. Recoge/equipa el torso.
3. Luego puede acoplar brazos y piernas en cualquier orden.
4. Cada parte recuperada puede aumentar vida maxima y cambiar animacion.

## Sistema Actual

`ArenaGoalManager` construye el panel de ayuda del demo y escucha señales de
`GameEvents`.

El panel combina:
- hint activo del demo;
- checklist de controles;
- objetivo general de la isla.

La checklist usa bindings reales mediante
`DropPickupRulesService.action_binding_text(action)`, asi que si el jugador
cambia controles desde inventario/settings, el texto del tutorial puede mostrar
la tecla o mouse button actual.

## Pasos Del Tutorial De Controles

Pasos actuales:
- `move`: presionar cualquier input de movimiento.
- `sprint`: moverse mientras se sostiene sprint.
- `jump`: presionar salto.
- `attack`: presionar ataque.
- `bow`: presionar toggle de arco.
- `pickup`: recoger un hueso, detectado por `GameEvents.bone_collected`.
- `inventory`: abrir inventario, detectado por `GameEvents.inventory_open_changed`.
- `equip`: equipar un hueso, detectado por `GameEvents.bone_equipped`.
- Si el jugador intenta equipar una extremidad sin torso, el sistema emite un
  hint explicando que primero debe recuperar el torso.

Los pasos se muestran como `[ ]` pendiente y `[x]` completado.

## Eventos

Entradas directas revisadas por `ArenaGoalManager._process`:
- `move_forward`
- `move_back`
- `move_left`
- `move_right`
- `sprint`
- `jump`
- `attack`
- `toggle_bow`

Eventos desacoplados:
- `bone_collected`
- `bone_equipped`
- `inventory_open_changed`
- `tutorial_hint_requested`

## Reglas

- No hardcodear texto de teclas como `Tab`, `E` o `Left Click` en tutoriales
  nuevos si existe un action en `InputMap`.
- Usar `DropPickupRulesService.action_binding_text(action)` para texto visible.
- Si se agrega un control nuevo al demo, agregarlo a la checklist y actualizar
  este documento.
- Si el control pertenece a combate, actualizar tambien `docs/combat_flow.md`.
- Si el control pertenece a inventario/equipamiento, actualizar
  `docs/inventory_flow.md` o `docs/equipment_flow.md`.

## Como Probar

En el demo:

1. Iniciar `scenes/main.tscn`.
2. Confirmar que el panel muestra `Controls Tutorial`.
3. Moverse, sprintar, saltar y atacar.
4. Confirmar que esos pasos cambian a `[x]`.
5. Presionar el toggle de arco y confirmar que `Bow` cambia a `[x]`.
6. Recoger un hueso y confirmar que `Pick up bones` cambia a `[x]`.
7. Abrir inventario y confirmar que `Inventory` cambia a `[x]`.
8. Equipar un hueso y confirmar que `Equip a bone` cambia a `[x]`.
9. Confirmar que el primer pickup de torso permite pasar de cabeza sola a cuerpo
   con torso, y luego acoplar extremidades.

