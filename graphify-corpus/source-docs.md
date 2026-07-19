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
- `slot`: slot de equipamiento canonico (`head`, `torso`, `left_arm`,
  `right_arm`, `left_leg`, `right_leg`) o alias legacy aceptado durante
  migracion (`body`, `legs` -- los unicos dos que aparecen realmente en
  `data/bones/*.tres` hoy; no agregar aliases especulativos sin un
  consumidor real).
- `tags`: tags generales.
- `description`: texto visible para UI.

`EquipmentRulesService.normalize_slot_id` convierte aliases legacy a los ids
canonicos que usa el runtime. Los Resources viejos pueden seguir declarando
`body` o `legs`, pero los sistemas nuevos deben guardar y comparar slots
canonicos. `body` es un socket del rig; `torso` es el slot de equipamiento.

## Calidad

Calidad describe condicion o potencia de la pieza. No es rareza de loot.

La calidad pertenece a la PIEZA INDIVIDUAL, no al tipo de hueso. Se sortea una
sola vez, cuando la pieza se crea (drop, recompensa, pieza nueva), y no se
vuelve a sortear al recoger, equipar, abrir inventario, aplicar builds ni
refrescar el preview.

Ids canonicos, multiplicador y probabilidad (fuente de verdad:
`scripts/bone_quality_service.gd`, tabla `QUALITY_TABLE`):

| id | display | multiplicador | probabilidad | rank |
| --- | --- | --- | --- | --- |
| `frail` | Frail | 0.85 | 2.5 % | 0 |
| `worn` | Worn | 0.925 | 12.5 % | 1 |
| `normal` | Normal | 1.00 | 70 % | 2 |
| `strong` | Strong | 1.075 | 12.5 % | 3 |
| `pristine` | Pristine | 1.15 | 2.5 % | 4 |

La columna de probabilidad suma exactamente 100. `tools/validate_bone_quality.py`
lo verifica sin abrir Godot.

Ids previos al rename (espanol) siguen aceptados como alias legacy y mapean por
rank: `chatarra`->`frail`, `fragil`->`worn`, `comun`->`normal`,
`fuerte`->`strong`, `legendario`->`pristine`. Cualquier valor desconocido o
vacio normaliza a `normal`; nunca se sortea para datos legacy.

Formula (en `BoneRulesService.adjusted_player_bonus_for`):

    stat efectivo = stat base * multiplicador de calidad

La calidad solo escala stats numericos reales (`move_speed`, `attack_range`,
`attack_damage`, `max_health`). No toca slot, compatibilidad, ids, tags ni
ningun otro valor categorico. Calidad, rareza, mutacion y durabilidad siguen
siendo campos separados con vocabularios separados.

## Identidad De Pieza (instancias)

`scripts/bone_instance_service.gd` da identidad por pieza:

- `bone_id` nombra un TIPO (`arm_bone`).
- `instance_id` nombra una PIEZA concreta (`bone#7`) y es la fuente de verdad
  de su calidad.
- El instance_id no codifica nada: nunca `arm_bone_strong`. Identidad,
  definicion y calidad quedan separadas.
- El multiplicador no se guarda en la instancia; solo `quality_id`. El numero
  sale de la tabla, asi que retunear la tabla retunea todas las piezas
  existentes.
- Ruta de compatibilidad explicita: un String que no es instancia se resuelve a
  su calidad authored (o `normal` si no tiene) y jamas se sortea, para que los
  Strings existentes no cambien de significado en silencio.

La resolucion vive en un solo punto por capa: `BoneDatabase._type_id`,
`BoneRulesService.definition_for` y
`EquipmentRulesService.compatible_slots_for_bone` /
`generated_limb_definition_for`. Por eso cualquier API que aceptaba un
`bone_id` acepta ahora un `instance_id` sin cambios en el llamador.

Los builds guardan el TIPO por slot, no una pieza concreta. Atarlos a un
`instance_id` los volvia casi inservibles: perder o cambiar la pieza exacta que
estaba puesta al guardar rompia el build. Al aplicar, `_resolve_build_to_instances`
elige la MEJOR calidad disponible de ese tipo entre lo que llevas encima
(`frail < worn < normal < strong < pristine`), y si un tipo ocupa dos slots toma
dos piezas distintas, las dos mejores. Si no llevas ninguna copia del tipo, el
build falla y lo dice; no sustituye por otro tipo.

Los stacks agrupan por `bone_id + quality_id + mutacion`
(`BoneInstanceService.stack_key_for`), no solo por `bone_id`: apilar dos brazos
de calidad distinta ocultaria que tienen stats efectivos distintos.

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
drops o inventario hasta que exista una regla dedicada. En equipamiento,
`BoneRulesService.player_stats_with_equipment()` ya consume
`quality_multiplier`, `quality_damage_percent`, `quality_speed_percent`,
`quality_health_percent` y `quality_weight_percent` para calcular stats finales
del jugador de forma determinista.

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

## Alcance De Durabilidad, Mutacion Y Set/Sinergia

Estas tres secciones (Durabilidad, Mutacion, Set Y Sinergia) son
deliberadamente solo esquema de datos y helpers puros y deterministas en
`BoneRulesService`. Nada de esto esta conectado a gameplay todavia:

- La durabilidad no disminuye en runtime; no existe estado por copia.
- Reparar no hace nada; `durability_repair_cost_for` solo calcula un numero.
- Los sets/sinergias no aplican bonus a stats; `equipment_synergy_summary`
  solo resume que hay repetido.
- Las mutaciones no producen ningun efecto (visual, de rig, de IA o de
  combate).
- Ninguna de las funciones nuevas de `BoneRulesService` para estos temas
  tiene un llamador fuera de si misma o del validador que las prueba.

Esto es intencional: el objetivo de este hito era preparar datos y reglas
puras reutilizables, no implementar las mecanicas de juego. Ver
`docs/roadmap_1_165.md` objetivos 70-75, marcados "No iniciado".

## Durabilidad

Durabilidad describe resistencia authorable de la pieza, no el estado persistido
de una copia concreta del inventario.

Campos:
- `durability_max`: capacidad maxima de la pieza.
- `durability_start`: durabilidad inicial al crear o dropear la pieza.
- `durability_repair_cost`: coste relativo para reparar esa pieza.
- `durability_tags`: tags para futuras reglas de reparacion, rotura o UI.

`BoneRulesService.durability_profile_for(bone_id, current_durability)` calcula
un perfil determinista con `current`, `max`, `ratio`, `state`, `repair_cost` y
`tags`. Los estados canonicos son `intact`, `cracked` y `broken`.

El Resource no debe guardar el desgaste runtime de cada copia. Ese estado debe
vivir luego en inventario/save y consultar estas reglas compartidas.

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

`BoneRulesService.mutation_profile_for(bone_id)` centraliza id, familia, etapa,
intensidad y tags para que UI, drops o combate futuro no dupliquen lecturas.

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

`BoneRulesService.synergy_profile_for(bone_id)` entrega la metadata de una pieza
y `equipment_synergy_summary(equipment_state)` resume piezas equipadas por set,
synergy id, tags y familias de mutacion. Un set o synergy id queda activo cuando
aparece al menos dos veces. El resumen no aplica bonuses por si mismo.

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

Formula activa:
- Los bonuses directos (`player_move_speed`, `player_attack_range`,
  `player_attack_damage`, `player_max_health`) se escalan primero con
  `quality_multiplier`.
- `quality_damage_percent`, `quality_speed_percent` y
  `quality_health_percent` se acumulan y se aplican al resultado base + bonus.
- `quality_weight_percent` ajusta `equipment_weight` e `inventory_weight` por
  pieza.
- Si el peso equipado total supera el umbral libre, se aplica una penalizacion
  suave y acotada sobre la velocidad de movimiento.
- `quality_drop_percent` sigue reservado para reglas futuras de drops.

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

Antes de abrir PR, ejecutar la validacion read-only de datos:

```bash
python tools/validate_bone_data.py
```

El validador revisa rutas del catalogo, IDs duplicados, Resources `.tres` sin
referencia, slots, calidades, rarezas, familias de mutacion y rangos numericos
basicos. No modifica Resources ni requiere abrir Godot.

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
- Actualiza follow y offsets de animacion en `_physics_process`, sincronizado
  con `Player._physics_process`.
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
5. `PlayerCameraController.set_animation_follow_offset` actualiza el objetivo.
6. `PlayerCameraController._physics_process` suaviza ese offset y mueve el
   pivot de camara en el mismo reloj de fisica que el player.
7. La camara sigue solo la distancia horizontal del salto; el arco vertical se
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

## Diagnostico de jitter

La causa runtime del jitter debe confirmarse en Godot, pero el contrato estatico
mostraba una fuente concreta de desincronizacion: `Player._physics_process`
mueve con `move_and_slide`, actualiza el rig procedural y entrega el offset de
animacion, mientras `PlayerCameraController` aplicaba el follow suavizado en
`_process`. Esa mezcla de relojes podia muestrear el target entre ticks de
fisica y producir vibracion visible, especialmente durante offsets de cabeza o
cerca de colisiones.

Antes de tocar `Player`, `PlayerCameraController` o el rig procedural, correr:

```bash
python -B tools/validate_jitter_update_contract.py
```

Ese validador es estatico y read-only. Confirma el contrato actual de update:
`Player._physics_process` mueve con `move_and_slide`, luego llama
`ProceduralPlayerAnimator.update_from_player`, despues entrega offsets
horizontales de animacion a `PlayerCameraController.set_animation_follow_offset`,
y finalmente la camara suaviza follow y offset en `_physics_process`. El zoom
del `SpringArm3D` permanece en `_process` porque no mueve el target del player.

Para reproducir manualmente en `TESTING ENVIRONMENT`:

1. Probar idle, caminar, sprintar, saltar y caer con camara activa.
2. Repetir rozando paredes y esquinas para confirmar collision del SpringArm.
3. Acercar y alejar con rueda para confirmar que el zoom sigue suave.
4. Repetir abriendo/cerrando inventario para confirmar que el bloqueo de look no
   introduce vibracion.
5. Comparar head-only, torso-only y cuerpo completo.
6. Repetir ataques de head launch y reattach de torso, anotando si el jitter
   aparece durante el offset de animacion o despues de volver a cero.
7. Comparar smoothing normal contra smoothing bajo/casi apagado desde el
   inspector.
8. Comparar rig procedural habilitado contra deshabilitado temporalmente desde
   la escena de prueba.
9. Probar la misma ruta con FPS estable y FPS bajo si el editor lo permite.
10. Confirmar que no existe doble interpolacion: el pivot de camara se mueve en
    `_physics_process`, mientras `_process` solo ajusta `SpringArm3D.spring_length`.

## Comportamiento Esperado Sobre 60 FPS Y Physics Interpolation

`project.godot` no sobreescribe `physics/common/physics_ticks_per_second`
(el default de Godot 4 es 60) ni `physics/common/physics_interpolation`
(el default es `false`, apagado). Con el follow de camara en
`_physics_process`, esto implica:

- A 60 FPS o menos, el pivot de camara se actualiza en el mismo tick de
  fisica que el movimiento del jugador. No deberia haber diferencia visible
  respecto al comportamiento anterior en `_process` para ese caso, salvo la
  correccion de orden ya descrita en "Diagnostico de jitter".
- Por encima de 60 FPS (monitor con mas Hz que la tasa de fisica), el motor
  sigue corriendo `_physics_process` a 60 Hz. El pivot de camara ahora se
  mueve en pasos discretos de fisica en vez de interpolar cada frame de
  render, lo que puede sentirse menos fluido que un follow en `_process`
  puro, aunque evita el desfase de un tick contra el movimiento del jugador
  que motivo este fix. Este es el trade-off estandar documentado por Godot
  para mover camara en `_physics_process`.
- `physics_interpolation = true` es la herramienta que Godot ofrece
  especificamente para ese caso (interpola la posicion visual entre ticks de
  fisica sin mover la logica de gameplay a `_process`). No se activo en esta
  rama: es un cambio de configuracion de proyecto con superficie mas amplia
  que este fix puntual (afecta todo nodo con `top_level`/fisica, no solo la
  camara), y activarlo sin poder probarlo con FPS alto en este equipo seria
  especulativo. Queda como candidato a evaluar en una rama separada si el
  jitter persiste en runtime por encima de 60 FPS.

## Escrituras Directas De global_position (Examinadas, No Modificadas)

`tools/validate_jitter_update_contract.py` senala dos escrituras directas a
`global_position` en `scripts/player.gd` como sospechosas de jitter porque
evitan `move_and_slide()`. Se examinaron sin corregirlas especulativamente,
ya que ninguna es parte del movimiento normal por frame:

- `player.gd:1331` (`_detach_head_from_torso_after_miss`): teleport de una
  sola vez cuando el torso se separa de la cabeza. Ya tiene compensacion de
  camara: fija `detached_camera_offset_carry` y
  `detached_camera_offset_carry_timer = 0.16`, que
  `_update_camera_animation_follow_offset` (`player.gd:1069-1071`) usa para
  interpolar `animation_offset` hacia el offset del salto durante 0.16s en
  vez de que la camara salte de golpe con el jugador.
- `player.gd:1556` (`_align_player_body_pose_to_detached_torso_marker`,
  llamada una sola vez desde `_finish_reattach_head_to_detached_torso` al
  completar el reattach): tambien es un teleport de una sola vez, pero **no**
  se encontro ningun mecanismo equivalente de `*_carry` que compense la
  camara para este caso. Es asimetrico respecto al detach.

Esto es una observacion, no un fix: no se toco ninguna de las dos escrituras
en esta rama. Si el jitter reportado ocurre especificamente al completar un
reattach de torso, el paso 6 de "Diagnostico de jitter" arriba ya pide
anotar ese momento por separado; la ausencia de compensacion en el reattach
es el sospechoso principal a revisar primero si esa prueba lo confirma.

## Historial de cambios

- 2026-07-14: Se documento el flujo actual de camara.
- 2026-07-14: Se agrego `TESTING ENVIRONMENT` como escena unica para probar
  camara, enemigos, movimiento, animaciones y rig.
- 2026-07-14: La camara ahora puede seguir offsets horizontales de animacion;
  se usa para acompanar el ataque de cabeza sin copiar su salto vertical.
- 2026-07-15: Se agrego diagnostico estatico de contrato de update para jitter,
  sin modificar runtime ni confirmar todavia la causa.
- 2026-07-15: Se sincronizo el follow de camara y el offset horizontal de
  animacion con `_physics_process`; runtime queda pendiente de validacion en
  Godot.
- 2026-07-15: Se documento el comportamiento esperado sobre 60 FPS y la
  relacion con `physics_interpolation` (no activado, candidato a rama
  separada). Se examinaron las dos escrituras directas de `global_position`
  senaladas por el validador (`player.gd:1331` y `:1556`, ambas teleports de
  un solo evento del mecanismo de detach/reattach de torso, no movimiento
  por frame) sin modificarlas: la de detach ya compensa la camara con
  `detached_camera_offset_carry`; la de reattach no tiene compensacion
  equivalente, lo cual queda registrado como sospechoso a revisar si el
  jitter runtime se confirma en ese momento especifico. Godot 4.7 esta
  disponible en este equipo (ver `docs/p0_runtime_validation_suite.md`),
  pero confirmar o descartar el jitter en si requiere un humano jugando la
  escena; no se afirma aqui que el jitter haya quedado resuelto.

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
- `scripts/backstab_rules_service.gd`: regla pura de cono trasero para stealth
  finish/backstab. Recibe posicion, facing y threshold; no accede a la escena.
- `scripts/ballistics_service.gd`: regla pura de lanzamiento para proyectiles con
  gravedad (saliva, flecha enemiga, roca de gorilla). Recibe posiciones y tuning,
  devuelve la velocidad de lanzamiento. Ver "Solve balistico compartido".
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

## Solve balistico compartido

Los tres proyectiles con gravedad usan `BallisticsService.solve_launch_velocity()`:
saliva de lizard (`enemy.gd:508`), flecha enemiga (`:574`) y roca de gorilla
(`:644`). Antes el mismo solve estaba copiado en los tres, y las copias
DERIVARON — cada una fallaba distinto:

- La roca sumaba `+ gorilla_rock_throw_upward_boost` ENCIMA de la solucion, o sea
  llegaba (boost * travel_time) alta: +2.29 m a 10 m.
- Saliva y flecha clampeaban `travel_time` en la division pero usaban el valor
  crudo en el termino de gravedad, asi que por debajo de `0.1 * speed` metros los
  dos terminos no coincidian y el tiro salia ALTO: medido +0.44 m a 0.3 m con la
  saliva. `lizard_saliva_min_range` (2.2) solo gatea el INICIO del ataque; el
  windup re-apunta cada frame, asi que correrle encima al lizard cae justo en esa
  zona.
- Ninguna de las dos compensaba el paso de fisica (ver abajo).

Reglas del servicio:

- `arc` loftea alargando el VUELO, nunca sumando velocidad vertical. Cualquier
  termino sumado encima falla por exactamente (velocidad_sumada * travel_time).
- `travel_time` se clampea AL DECLARARLO y la velocidad horizontal se deriva de
  ese valor ya clampeado, asi que de cerca el proyectil simplemente vuela mas
  lento en vez de irse alto.
- `physics_step_seconds` compensa el integrador: los proyectiles corren
  `velocity.y -= g*dt` y despues `position += velocity*dt` (Euler semi-implicito),
  que pierde 0.5*g*T*dt contra la parabola analitica. La correccion es
  `v0 = dy/T + 0.5*g*(T + dt)`. OJO: el signo depende del orden — con Euler
  explicito (posicion con la velocidad VIEJA) seria `(T - dt)`. El error escala
  con la gravedad: ~1 cm en la saliva (g 1.5), ~6 cm en la flecha (g 5), ~22 cm en
  la roca (g 32).
- Cambiar speed/gravity/arc no puede desviar el tiro: el solve se re-deriva.

El bow del jugador usa el OTRO metodo del servicio,
`solve_launch_velocity_fixed_speed()`, y la diferencia importa:

- Los enemigos apuntan a un objetivo conocido y pueden inflar la velocidad
  vertical libremente. En el bow la VELOCIDAD significa algo: `player.gd:606`
  hace `charged_speed = bow_arrow_speed * lerpf(0.9, 1.15, charge_ratio)`, asi
  que resolver la vertical como los enemigos le daria a un tiro a medio cargar la
  energia de uno completo. Por eso el bow resuelve el ANGULO con la velocidad fija.
- Devolver ZERO cuando el objetivo esta fuera de alcance no es un fallo, es la
  respuesta: le avisa al `Player` que dispare derecho en vez de inventar energia.
  Eso es lo que evita que apuntar al cielo abierto (el raycast devuelve `ray_end`
  a 90 m) se convierta en un morterazo. Alcance maximo plano a v=18, g=4 es
  v^2/g = 81 m.
- Se elige la raiz PLANA de las dos posibles (a 10 m son 3.7 grados); la otra es
  un lob de mortero.
- Los finger bones NO usan el servicio: siguen con su `launch_velocity.y = 0.65`.
  Es el mismo anti-patron de constante aditiva, pero no hay reticle para ellos
  (`_start_bow_aim` solo corre con `bow_equipped`), asi que no rompen ninguna
  promesa; son un lob corto a ~6.6 m.

## Peso del golpe: la curva de ataque

`_attack_pose_strength()` define la FORMA del swing melee y es de donde sale la
sensacion de impacto.

Antes era `sin(phase * PI)`: un arco simetrico que entraba y salia a la misma
velocidad, sin anticipacion y sin snap. Por eso se sentia flotado — un golpe pega
porque la parte rapida es rapida EN RELACION a una parte lenta antes.

Ahora `_attack_strike_curve()` hace anticipacion -> golpe -> follow-through:

- `attack_windup_portion` (0.45): se echa para atras, desacelerando.
- `attack_strike_portion` (0.18): sale disparado a extension completa. Corto = seco.
- El resto: vuelve, mas lento de lo que fue.
- `attack_anticipation` (0.35): cuanto se echa para atras.

La curva devuelve NEGATIVO durante el windup, y ahi esta el truco: todas las poses
de combo hacen `rotation -= strength * amount`, asi que un valor negativo echa el
brazo para atras solo, sin tocar ninguna pose.

Son FRACCIONES de la duracion, no segundos: retimear el swing conserva el feel.

### El HOLD, o por que el golpe no se veia

`attack_strike_hold` (0.16) mantiene la extension completa despues del golpe.
Snap y legibilidad tiran para lados opuestos: un golpe corto se siente seco pero
pasa por el pico en dos frames y no llega a leerse. El hold compra las dos cosas —
el golpe sigue siendo rapido, pero la POSE se queda puesta.

Medido a 0.70s: swing entero 42 frames (antes 10 a 0.16s), 8 frames cerca de
extension completa, 7 frames clavado en el pico (phase 0.50 -> 0.70).

### Duracion y cooldown se mueven JUNTOS

`attack_overlay_duration` (0.70) y `Player.attack_cooldown` (0.85) estan acoplados:
los pasos 3 y 4 corren 1.15x, o sea 0.805s, y eso tiene que terminar ANTES de que
el siguiente click este permitido. El melee normal NO tiene gate anti-stacking (ese
gate es solo para head-launch), asi que una animacion mas larga que el cooldown deja
que el siguiente click reinicie la pose a mitad del swing: se ve el windup una y otra
vez y el golpe nunca. Por eso subir uno solo no sirve.

Historial: 0.16 (10 frames, invisible) -> 0.38 (primer intento, seguia siendo un
pico instantaneo) -> 0.70 + hold. OJO: el cooldown 0.45 -> 0.85 es un cambio de
ritmo de combate real, no solo visual — casi la mitad de ataques por segundo.

Solo afecta al combo melee normal: head-only y torso-only tienen sus propias
duraciones (`head_only_attack_duration`, `torso_head_attack_duration`).

Se saco el piso `maxf(_attack_blend * 0.35, ...)` que tenia la curva vieja: mantenia
el brazo a 35% de la pose entre golpes, lo que peleaba con la anticipacion y con la
vuelta a descanso.

### Por que se sentia robotico

Dos causas, las dos estructurales, no de tuning:

1. **El brazo era un palo rigido.** `_animate_joints()` ASIGNA el codo desde el
   ciclo de CAMINATA (`walk_time`, `speed_ratio`), asi que durante un golpe el codo
   seguia haciendo su bend de caminar e ignoraba el ataque por completo. Ahora
   `_whip_elbow()` suma el movimiento del ataque ENCIMA: strength negativo (windup)
   lo amartilla mas, positivo (golpe) lo estira. Medido: el codo se desvia 50.5
   grados respecto de un codo que no atacó — antes era 0. Funciona porque
   `_apply_attack_overlay` corre DESPUES de `_animate_joints`, y porque ahora hay
   codos (ver `rig_notes.md`).
2. **Todas las articulaciones se movian en lockstep.** Las poses manejaban brazo.x,
   brazo.z, torso.y y torso.x con el MISMO `strength` en el MISMO frame. Un cuerpo
   real arrastra: el torso lidera, el hombro lo sigue, la mano llega ultima.
   `_attack_strength_lagged(lag)` samplea la misma curva mas temprano, asi que la
   articulacion se retrasa. Medido: torso pico en phase 0.63, hombro 0.70, codo
   0.83 — el miembro arrastra 76 ms de punta a punta.

Tuning: `attack_overlap_arm` (0.07), `attack_overlap_elbow` (0.13),
`attack_elbow_whip` (0.9). El lag se clampea en 0, asi que una articulacion
retrasada simplemente todavia no arranco, no lee el windup al reves.
`_whip_elbow` no hace nada en un rig sin split (enemigos): no hay codo.

## Combo de brazos: el paso 4 (arm sword)

El combo melee cicla derecha -> izquierda -> ambos -> **arrancarse el brazo
izquierdo y usarlo de espada**.

- `Player._next_combo_animation_step()` incluye el paso 4 SOLO con los dos brazos
  equipados (`_has_both_arms_equipped()`). Con un brazo no hay nada que agarrar, y
  ademas `_combo_step_for_equipped_arms()` remapea el paso al brazo que existe, asi
  que el paso 4 nunca cae en un socket escondido.
- `ProceduralPlayerAnimator._apply_arm_sword_pose()` es SOLO POSE: no desequipa
  nada y no reparenta nada. El slot `left_arm` sigue equipado todo el tiempo, asi
  que stats, paper doll y el bow (que exige ambos brazos) no se enteran.
- El brazo queda ARRANCADO durante `arm_sword_swing_count` (3) golpes y recien
  despues vuelve. Eso obliga a separar dos cosas que parecen una:
  - `_apply_arm_sword_pose(strength)` es el movimiento POR GOLPE (brazo derecho +
    torso), manejado por `_attack_pose_strength()`.
  - `_update_arm_sword(delta)` es el AGARRE, con su propio blend
    `_arm_sword_hold` y corriendo TODOS los frames. No puede depender de
    `strength`: entre golpes strength cae a 0 y el brazo volveria al hombro
    despues del primero. Ademas `_apply_attack_overlay` deja de llamarse cuando
    `_attack_blend` decae, asi que el agarre no puede vivir ahi.
- `Player._next_combo_animation_step()` devuelve el paso 4 mientras
  `is_arm_sword_held()`: el combo no avanza hasta que el brazo vuelve.
- Se suelta cuando el ULTIMO golpe termino de reproducirse
  (`_arm_sword_swings >= count and _attack_timer <= 0`), no cuando empieza, o el
  brazo se volveria al hombro a mitad del swing. Tambien se suelta por
  `arm_sword_hold_timeout` (1.6 s sin golpes) para no quedar arrancado para
  siempre si el jugador deja de atacar, y si se desequipa el brazo.
- Orden en `update_from_player`: `_update_arm_sword` va DESPUES del attack overlay
  (para leer la mano ya con el swing aplicado) y ANTES de `_animate_waist` (para
  que el carry rote la hoja y el brazo que la sostiene como una pieza rigida y la
  hoja no se despegue de la mano).
- `_right_hand_rig_position()` devuelve la punta del antebrazo en espacio del rig
  (el padre del socket del brazo izquierdo), con fallback a la punta del brazo
  entero en un rig sin codo.
- Medido: golpe 1 el brazo queda a 0.749 m del hombro; ENTRE golpes se queda a
  0.813 m (hold 1.00, no vuelve); a mitad del golpe 3 sigue agarrado; al soltar
  vuelve a 0.0085 m del hombro. Equipamiento intacto en todo momento.
- Tuning: `arm_sword_swing` (1.5), `arm_sword_torso_twist` (0.45),
  `arm_sword_lunge` (0.30), `arm_sword_blade_pitch` (-1.57, de colgando a
  horizontal hacia adelante), `arm_sword_swing_count` (3),
  `arm_sword_hold_speed` (14), `arm_sword_hold_timeout` (1.6).
- NOTA: es un floreo visual. Si alguna vez se quiere que el brazo QUEDE arrancado,
  eso ya no es pose: hay que desequipar de verdad y entonces si cambian stats, el
  bow deja de andar y el paper doll tiene que mostrar el slot vacio.

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
2. El enemigo valida distancia y delega el cono trasero en
   `BackstabRulesService.is_attacker_behind_target()`.
3. UI muestra `get_stealth_prompt_text`.
4. Al presionar stealth:
   - `Player` bloquea ataques, inventario/equip y movimiento normal durante la
     ejecucion corta.
   - `Player` dispara la pose de finisher con `animator.trigger_stealth_finish_attack()`
     (ver "Animacion y sincronizacion de impacto" abajo).
   - `Enemy.try_stealth_finish` solo inicia la ejecucion; no aplica dano todavia.
     `_begin_stealth_execution` NO gira al enemigo hacia el jugador.
   - El impacto se aplica una sola vez, disparado por
     `ProceduralPlayerAnimator.attack_impact_reached` (o por
     `backstab_execution_impact_timer` como respaldo si la senal no llega).
   - `Enemy.apply_stealth_finish_impact` resuelve muerte o ambush y evita un
     segundo impacto con `stealth_execution_impact_applied`.
   - `finish_stealth_execution` o `cancel_stealth_execution` limpian el estado y
     restauran control/IA.

### Correcciones 2026-07-16

- **Freeze si el jugador moria o el juego se pausaba durante un backstab**:
  `_update_backstab_execution` nunca se volvia a llamar tras el `return`
  temprano de `paused or is_dead` en `_physics_process`, asi que
  `cancel_stealth_execution` jamas se disparaba y el enemigo objetivo quedaba
  con `stealth_execution_player` seteado para siempre (IA congelada, imposible
  de volver a backstabear). Se movio la cancelacion antes de ese `return`.
- **Segundo freeze relacionado, mas sutil**: incluso con lo anterior corregido,
  si el enemigo objetivo se liberaba (`queue_free`) durante la ejecucion (por
  ejemplo, un ambush letal cuyo cadaver se limpia antes de que termine la
  ventana de recovery), `_is_backstab_executing()` (`backstab_execution_target
  != null`) empezaba a devolver `false` de golpe -- GDScript compara un Object
  liberado como igual a `null`, no solo `is_instance_valid()` lo detecta -- y
  `_update_backstab_execution` retornaba en su primera linea sin llegar nunca
  a la limpieza. Resultado: `can_attack` quedaba en `false` para siempre; el
  jugador no podia volver a atacar. Se agrego `backstab_execution_in_progress`
  (bool plano, sin el problema de comparacion) como la fuente de verdad de
  "hay un backstab en curso", separada de la validez de la referencia al
  objetivo.
- **La victima ya no gira para mirar a su atacante**: `_begin_stealth_execution`
  y `_update_stealth_execution_hold` llamaban `_turn_toward` cada frame durante
  toda la ejecucion, dando pistas visuales que contradicen un stealth kill.
  Se eliminaron ambas llamadas.
- **Direccion global coherente**: `Enemy._facing_from_rotation()` mezclaba
  `rotation.y` (local al padre) con `global_position` (global) en el calculo
  del cono trasero. Ahora usa `global_transform.basis.z`, el equivalente
  global exacto de la misma formula, correcto incluso si el enemigo queda
  parentado bajo un nodo rotado.
- **Reaccion del enemigo**: ya existia via `apply_stealth_finish_impact` ->
  `take_hit()` (flash + punch scale) en el caso de ambush sobrevivido, o
  `die()` en el caso letal. No se agrego nada nuevo aqui; se confirmo que
  funciona.

### Animacion y sincronizacion de impacto

Antes, `trigger_attack(3, false)` no garantizaba la pose de finisher: con
exactamente un brazo equipado (un estado muy comun antes de completar el
equipo), `_combo_step_for_equipped_arms()` en
`ProceduralPlayerAnimator` sobreescribia el paso de combo 3 a 1 o 2,
cayendo silenciosamente al swing generico de un brazo en vez de la pose de
finisher (giro de torso + lunge + inclinacion de cabeza). Se agrego
`trigger_stealth_finish_attack()`, que fuerza esa pose de finisher via un
flag (`_is_stealth_finish_attack`) sin importar que este equipado.

El impacto se sincroniza ahora con una senal real del animador,
`attack_impact_reached`, emitida una vez por ataque cuando la fase del
ataque cruza `attack_windup_portion` (el momento en que el golpe realmente
"conecta", no el timer fijo adivinado antes). `backstab_execution_impact_timer`
sigue existiendo como respaldo (si el animador es null o la senal no llega
por alguna razon), pero ya no es el disparador principal.

### Validacion geometrica de backstab

Antes de cambiar la regla de stealth finish, ejecutar:

```bash
python tools/validate_backstab_geometry.py
```

El arnes reproduce la formula de `BackstabRulesService` sin abrir Godot y
comprueba que `Enemy._is_player_behind()` delegue en ese servicio. Cubre frente,
detras, laterales, enemigos rotados, angulos del cono trasero y posiciones con
offset vertical. Esta validacion es estatica; la confirmacion visual/runtime de
que `facing_direction` coincide con el frente real del enemigo debe hacerse en
`TESTING ENVIRONMENT`. A diferencia de antes, los chequeos de contrato
(`verify_backstab_service_shape`, `verify_enemy_uses_backstab_service`,
`verify_backstab_execution_contract`) ahora SI afectan el exit code -- antes
solo imprimian `WARNING` y el script podia salir 0 aunque se vaciara por
completo `BackstabRulesService`. Verificado adversarialmente: revertir el fix
de freeze o reintroducir el giro hacia el atacante hace fallar el validador.

### Evidencia runtime (Godot 4.7 headless, 2026-07-16)

Verificado con una escena de prueba temporal (jugador + enemigo real,
eliminada tras el uso), no solo con el validador estatico:

- Backstab exitoso letal: deteccion "detras" correcta con geometria rotada,
  ejecucion completa, dano aplicado (enemigo murio), limpieza correcta
  (`can_attack` vuelve a `true`, estado de ejecucion vuelve a vacio).
- Objetivo invalido a mitad de ejecucion (el enemigo se libera tras morir):
  confirmado que ya NO deja `can_attack` bloqueado para siempre (bug
  encontrado y corregido en esta misma sesion, ver arriba).
- Muerte del jugador a mitad de un backstab (por un segundo enemigo):
  confirmado que el enemigo objetivo queda con `stealth_execution_player ==
  null` (no congelado) despues de la muerte.
- Senal `attack_impact_reached` del animador: confirmada disparando durante
  la animacion, antes de que la ejecucion termine.

Pendiente de prueba manual en editor (no cubierto por la escena headless, que
no simula input de teclado/mouse ni observacion visual humana):

- Pausa real (abrir inventario) a mitad de un backstab -- el codigo usa la
  MISMA rama de fix que la muerte, pero no se ejecuto ese camino especifico.
- Confirmacion visual de que la pose de finisher se ve distinta a un swing
  normal, y que la reaccion del enemigo (flash/punch scale o death-pop) se
  lee bien en pantalla.
- Camara durante la ejecucion (no se toco codigo de camara en esta rama).

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
- 2026-07-15: `scripts/player.gd`, `scripts/ballistics_service.gd` — el bow del
  jugador ahora pega donde apunta el reticle. Era el unico tirador del juego sin
  solve: disparaba en linea recta al punto del raycast mientras la gravedad (4.0)
  tiraba la flecha abajo, asi que caia 0.64 m bajo el reticle a 10 m, 2.51 m a
  20 m y 5.61 m a 30 m. Peor: como la carga escala la velocidad (0.9x-1.15x), la
  caida variaba 62% con cuanto se mantenia el click, o sea no existia un hold-over
  aprendible; y tirando plano desde 0.85 m la flecha tocaba el piso a ~11-13 m
  mientras los enemigos ranged atacan desde 13 m CON solve correcto. Nuevo
  `solve_launch_velocity_fixed_speed()`: resuelve el ANGULO con la velocidad fija
  en vez de la vertical, asi la carga sigue significando velocidad (medido: la
  velocidad se preserva a 0.01 m/s y el punto de impacto NO se mueve entre carga
  0.0, 0.5 y 1.0). Fuera de alcance devuelve ZERO y el `Player` dispara derecho,
  que es lo que evita que apuntar al cielo se vuelva un morterazo. Medido: error
  vertical 0.000 m a 5/10/20/30 m y con el objetivo +-6 m de altura; rechaza 200 m,
  cielo empinado y apuntar recto arriba; elige la raiz plana (3.7 grados a 10 m).
  Los finger bones no cambian (no tienen reticle). Se borro
  `_get_pointer_aim_direction()`, que quedo sin uso. Pruebas: en
  `TESTING ENVIRONMENT`, equipar ambos brazos, tomar el bow (`1`) y disparar a un
  enemigo a ~10 m y a ~20 m; debe pegar en el punto del reticle a cualquier carga.
- 2026-07-15: `scripts/ballistics_service.gd` (nuevo), `scripts/enemy.gd` — el
  solve balistico estaba copiado en tres lugares y las copias derivaron, cada una
  fallando distinto; ahora los tres usan `BallisticsService`. La saliva y la
  flecha enemiga ganan dos correcciones: (1) el clamp de `travel_time` estaba
  aplicado solo en la division y no en el termino de gravedad, asi que por debajo
  de `0.1 * speed` metros el tiro salia ALTO — medido +0.44 m a 0.3 m con la
  saliva, o sea el lizard escupia por encima de la cabeza si le corrias encima
  (`lizard_saliva_min_range` 2.2 solo gatea el inicio del ataque, pero el windup
  de 0.28 s re-apunta cada frame); (2) compensacion del paso de fisica, que en la
  saliva son ~1 cm a 12 m y en la flecha ~6 cm a 18 m — real pero invisible, muy
  lejos de los 22 cm de la roca, porque el error escala con la gravedad (1.5 vs
  32). La formula `v0 = dy/T + 0.5*g*(T + dt)` se verifico con tres derivaciones
  independientes que intentaron refutarla (3/3 la confirmaron exacta, no
  aproximada, para Euler semi-implicito) y ademas por simulacion. Medido con el
  servicio: peor error 1.1 mm en 60 combinaciones de rango x altura para saliva y
  roca, y 0.2 mm para la flecha. Pruebas: en `TESTING ENVIRONMENT`, spawnear un
  lizard (`3`) y correrle encima hasta ~0.5 m; la saliva debe pegar y no pasar por
  arriba. Un gorilla (`2`) y un ranged (`4`) deben seguir pegando a distancia.
- 2026-07-15: `scripts/enemy.gd`, `scripts/enemy_rock_projectile.gd` — la roca de
  gorilla ahora pega donde esta el jugador y se siente pesada.
  `_throw_held_rock()` sumaba `gorilla_rock_throw_upward_boost` (2.6) ENCIMA de la
  solucion balistica, asi que la roca llegaba (boost * travel_time) metros ALTA:
  medido +0.91 m a 4 m y +2.29 m a 10 m, o sea pasaba por arriba de la cabeza
  siempre. La saliva hace el mismo solve pero sin ese termino, por eso si pegaba.
  Ahora el boost se reemplaza por `gorilla_rock_throw_arc` (0.15), que loftea
  alargando el VUELO en vez de romper la punteria, y el solve ademas compensa el
  paso de fisica: el proyectil integra con Euler semi-implicito (velocidad antes
  que posicion), que pierde 0.5*g*T*step contra la parabola analitica — sin
  compensar quedaba ~0.26 m bajo a 10 m. Medido: error < 1 mm de 4 a 10 m, y
  tambien con el objetivo 2 m arriba o abajo. Peso: `gorilla_rock_gravity`
  24 -> 32 (cae mas fuerte; tambien sube el arco, porque el solve compensa para
  mantener el hang time), `gorilla_rock_throw_speed` 10.5 -> 12.0 (mantiene el
  angulo de lanzamiento ~48 grados con la gravedad nueva) y nuevo export
  `EnemyRockProjectile.tumble_speed` 0.22 (antes 0.8 hardcodeado, giraba ~1.3
  vueltas por segundo y se leia como piedrita). Cambiar speed/gravity/arc no puede
  desviar el tiro: el solve se re-deriva de ellos. NOTA: la saliva
  (`enemy.gd:509`) comparte el mismo error de discretizacion de Euler y queda un
  poco baja; no se toco en este cambio. Pruebas: en `TESTING ENVIRONMENT`,
  spawnear un gorilla (`2`), dejarse ver a ~8-10 m y confirmar que la roca pega en
  el cuerpo y no pasa por encima.
- 2026-07-15: `scripts/arrow_projectile.gd`, `scripts/enemy_rock_projectile.gd` —
  `configure()` escribia `global_position` cuando el nodo todavia no estaba en el
  arbol. Los cuatro llamadores configuran ANTES de `add_child` (`enemy.gd:509`
  saliva, `:570` flecha, `:636` roca, y `player.gd:704` bow) y tienen que hacerlo,
  porque `_ready()` -> `_build_visuals()` necesita `projectile_style` y `radius`
  ya seteados; invertir el orden construiria el visual equivocado. Cada proyectil
  disparado loggeaba `Condition "!is_inside_tree()" is true. Returning:
  Transform3D()`. Ahora `configure()` guarda el punto de spawn y `_ready()` lo
  aplica con el nodo ya en el arbol; sigue funcionando si algun dia se llama
  despues de `add_child`. Son DOS scripts distintos con el mismo bug: la roca usa
  `enemy_rock_projectile.gd`, la saliva y la flecha usan `arrow_projectile.gd`.
  Verificado: posicion mundial correcta incluso con el padre desplazado y rotado
  (guardar una posicion local se habria offseteado en silencio). Pruebas: en
  `TESTING ENVIRONMENT`, spawnear un lizard (saliva), un ranged (flecha) y un
  gorilla (roca) y confirmar que no hay errores en consola y que los proyectiles
  salen del cuerpo del enemigo.
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
- 2026-07-15: `scripts/player.gd`, `scripts/enemy.gd`,
  `scripts/backstab_rules_service.gd` — stealth finish ahora separa deteccion,
  inicio de ejecucion, momento de impacto y limpieza. `Player` bloquea ataque,
  inventario/equip, salto y movimiento durante una ventana corta; `Enemy` pausa
  IA/ataques mientras `stealth_execution_player` esta activo. El dano se aplica
  desde `apply_stealth_finish_impact` una sola vez y queda pendiente validarlo en
  runtime con las guias P0 de `TESTING ENVIRONMENT`.
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
- Quality percentage modifiers now feed the deterministic player stat formula
  for damage, speed, health and equipped weight; drop tuning remains passive.
- Canonical rarity ids are `comun`, `corrupto`, `maldito`, `especial` and
  `legendario`; canonical mutation families are empty, `corrupto`, `maldito`,
  `especial` and `hibrido`.
- Bone durability fields define authoring defaults for max durability, starting
  durability, repair cost and durability tags. Runtime wear is not stored on the
  Resource.
- Bone attack/combo fields are present as passive metadata for future combat
  chains; current attacks still come from the existing player/enemy combat code.
- Bone weight fields now distinguish animation weight, physical weight,
  equipment load and inventory weight while keeping legacy `weight`. Equipped
  load can apply a capped movement-speed penalty through `BoneRulesService`.
- Bone set/synergy fields can be summarized from equipped state through
  `BoneRulesService.equipment_synergy_summary`; no automatic set bonuses are
  applied to stats yet, and durability does not decrease at runtime.
- Gameplay consumers should still use `BoneRulesService`, `EquipmentRulesService`
  or `BoneDatabase`, not `BoneDefinition` or `BoneDataCatalog` directly.

## Testing

- `scenes/testing_environment.tscn` is the unified sandbox for camera, enemies,
  movement, animation, rig, drops, and equipment checks.
- The testing environment status panel includes P0 validation guide sections
  that can be cycled with F1/F2 for jitter, inventory/preview, pickups/drops,
  backstab runtime geometry, and rig progression checks.
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

## Seguimiento y QA

1. `docs/manual_gameplay_qa_checklist.md`
   - Pasada manual repetible para validar gameplay, UI, combate, camara, rig y
     evidencia de PR.
2. `docs/roadmap_progress.md`
   - Tabla operativa de lotes, ramas, evidencia, PRs y pendientes.
3. `docs/p0_runtime_validation_suite.md`
   - Guia especifica para la suite P0 dentro de `scenes/testing_environment.tscn`.
4. `docs/roadmap_1_165.md`
   - Fuente numerada y auditable del roadmap tecnico.
5. `docs/repo_stability_and_graphify.md`
   - Politica de Graphify, line endings, caches y preflight de commits.

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
- `scripts/player_equipment_builds_component.gd`: guarda y aplica presets de
  equipamiento usando el estado real de `PlayerEquipmentComponent`.
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
- Cachea el snapshot de equipamiento ya aplicado con exito para evitar
  recrear piezas del rig preview cuando llegan eventos redundantes (ver
  `docs/inventory_flow.md` seccion de historial, 2026-07-15: el snapshot solo
  se guarda despues de equipar cada pieza, no antes).
- Muestra filtros por los seis slots canonicos de equipo: `head`, `torso`,
  `left_arm`, `right_arm`, `left_leg` y `right_leg`.
- Ordena los stacks visibles por slot corporal, rareza, calidad y nombre antes
  de crear tiles.

### Slots de inventario y equipamiento

`EquipmentRulesService.CANONICAL_BODY_SLOTS` es la fuente de verdad para los
slots de equipo que la UI debe mostrar. Los ids canonicos son:

- `head`
- `torso`
- `left_arm`
- `right_arm`
- `left_leg`
- `right_leg`

`body` y `legs` son los unicos aliases legacy con datos reales hoy (verificado
por grep en `data/bones/*.tres`); se normalizan en
`EquipmentRulesService.normalize_slot_id`. La UI puede leer huesos viejos con
esos slots, pero no debe crear nuevas categorias ni nuevo estado con esos ids,
y no se deben agregar aliases especulativos sin un consumidor real. `body`
sigue existiendo como socket del rig; `torso` es el slot de equipamiento.
Un hueso legacy `legs` puede equiparse en `right_leg` o `left_leg` mediante
drag/drop dirigido al slot visual, o mediante equipar-siguiente (tecla E),
que ahora resuelve al primer lado libre en vez de forzar siempre
`right_leg` (ver historial de cambios).

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
- Contrato de stacks: hoy el grid muestra una tile por copia visible. Antes de
  agregar un contador `xN`, mantener la misma semantica: contar equipados por id,
  omitir solo esa cantidad de copias del inventario, y dejar visibles las copias
  sobrantes. Validar con:

```bash
python -B tools/validate_inventory_stack_contract.py
```

- Stacks visuales: despues de filtrar copias equipadas, el grid agrupa las
  copias visibles con el mismo id en una sola tile y muestra `xN` cuando hay mas
  de una. El drag sigue enviando solo `bone_id`; equipar consume una copia por
  la ruta existente de `PlayerEquipmentComponent`.
- Filtros: `All` muestra todos los huesos compatibles; las categorias de slot
  usan `EquipmentRulesService.inventory_filter_matches_bone` para no duplicar
  reglas entre UI y gameplay.
- Pausa: la UI procesa mientras el arbol esta pausado.
- Settings: controles modificados se guardan en `user://control_settings.cfg`.
- Build presets: la pestaña de settings permite guardar y aplicar 3 builds de
  equipamiento en `user://equipment_builds.cfg`. Cada build guarda slots
  canonicos no-core; la cabeza fija no se reemplaza ni se guarda como pieza
  aplicable.
- Al aplicar un build, `PlayerEquipmentBuildsComponent` valida primero que las
  copias necesarias existan en inventario, que los slots sean compatibles y que
  cualquier extremidad venga acompanada de torso. La UI solo muestra el resultado
  de esa validacion.
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
9. Arrastrar `arm_bone` a `Left Arm` y luego a `Right Arm`; debe aceptar ambos
   lados si hay torso.
10. Arrastrar `leg_bone` a `Left Leg` y luego a `Right Leg`; cada lado debe
    mostrar solo su pierna correspondiente en jugador y preview.
11. Cambiar filtros `Head`, `Torso`, `L. Arm`, `R. Arm`, `L. Leg` y `R. Leg`;
    cada filtro debe mostrar solo piezas compatibles con ese slot.
12. En Settings, guardar un build con torso + extremidades, cambiar piezas y
    aplicar el build; debe restaurar los slots guardados si existen copias.
13. Guardar un build que use el mismo `bone_id` en dos lados y confirmar que al
    aplicarlo sin dos copias disponibles muestra error sin cambiar parcialmente
    el equipamiento.

### Pruebas manuales especificas del preview 3D (pendientes de ejecutar en editor)

Godot esta disponible en este equipo (ver `docs/p0_runtime_validation_suite.md`
para el procedimiento headless), pero estas pruebas requieren un humano
observando el render y no se pueden confirmar solo con validadores de texto:

1. Equipar una pieza y confirmar que el preview la muestra sin re-crear el
   rig completo (sin parpadeo de todas las partes al equipar solo una).
2. Desequipar esa pieza y confirmar que desaparece del preview.
3. Abrir y cerrar el inventario varias veces seguidas con el mismo
   equipamiento y confirmar que no hay parpadeo ni nodos duplicados (el
   `sync_preview()` cacheado deberia omitir el re-render).
4. Redimensionar la ventana o cambiar de resolucion (1280x720, 1366x768,
   1920x1080, ultrawide) con el inventario abierto y confirmar que el
   preview no queda en blanco ni con tamano cero.
5. Si alguna pieza no aparece en el preview inmediatamente despues de
   equipar, volver a abrir/cerrar el inventario y confirmar que aparece (el
   fix de esta sesion depende de que sync_preview() reintente slots cuya
   definicion no se resolvio en el primer intento).

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
- 2026-07-15: El preview 3D cachea el equipamiento ya renderizado y omite syncs
  redundantes cuando `equipped` no cambio desde el ultimo `sync_preview()`.
  Esto evita reconstruir las piezas del rig en cada apertura del inventario
  cuando el equipamiento no cambio.
- 2026-07-15 (correccion): la entrada anterior tambien agrego un
  redimensionamiento manual de `SubViewport` en el layout responsive
  (`_sync_preview_viewport_size()`), revirtiendo sin decirlo la decision del
  2026-07-14 de arriba. Se elimino de nuevo: `inventory_preview_container`
  usa `stretch = true`, por lo que `SubViewportContainer` ya redimensiona su
  unico `SubViewport` hijo automaticamente cuando el container cambia de
  tamano. No se encontro evidencia de un render con tamano cero causado por
  esto; si aparece un bug concreto de tamano, investigar la causa raiz antes
  de reintroducir un resize manual una tercera vez.
- 2026-07-15 (correccion): `sync_preview()` marcaba el snapshot de
  equipamiento como sincronizado ANTES de intentar equipar cada pieza en el
  rig de preview. Si `BoneRulesService.definition_for(bone_id)` devolvia un
  diccionario vacio para alguna pieza (definicion todavia no resuelta), esa
  pieza quedaba cacheada como "ya renderizada" sin haberse dibujado nunca, y
  llamadas posteriores a `sync_preview()` con el mismo equipamiento no
  reintentaban esa pieza. Ahora el snapshot solo incluye los slots donde la
  definicion se aplico con exito, y se asigna despues del loop de equipar,
  no antes.
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
- 2026-07-15: Se normalizo inventario/equipamiento a seis slots canonicos
  (`head`, `torso`, `left_arm`, `right_arm`, `left_leg`, `right_leg`). Los slots
  legacy siguen aceptandose como aliases de lectura, y la UI ahora filtra,
  ordena y equipa por compatibilidad compartida desde `EquipmentRulesService`.
- 2026-07-15: Se agregaron build presets de equipamiento con guardado local,
  validacion de copias disponibles, compatibilidad de slots y aplicacion mediante
  `PlayerEquipmentComponent`.
- 2026-07-15: Se corrigio el equip-next para piernas (ver
  `docs/equipment_flow.md` para el detalle completo del bug y el bug de
  tipado que se encontro de paso), se removieron 7 aliases de slot legacy
  sin datos reales, y se elimino un metodo de equipamiento sin llamadores.
  Se agrego comparador con deltas de stats reales al pasar el mouse sobre
  un hueso, y feedback verde/rojo en los slots del paper doll durante
  drag and drop segun compatibilidad. El idioma visible de la UI ya era
  consistente (ingles en toda la pantalla de inventario/settings); no se
  cambio.

Pruebas manuales pendientes para lo de arriba (Godot 4.7 disponible, ver
`docs/p0_runtime_validation_suite.md`, pero esto requiere observar el
render):
1. Recoger dos `leg_bone` genericos, equipar-siguiente (`E` u la tecla
   configurada) hasta que ambos esten puestos, y confirmar visualmente que
   una pierna del rig es distinta del estado anterior a ambos lados (no
   solo el diccionario de estado).
2. Pasar el mouse sobre un hueso del mismo slot que uno ya equipado y
   confirmar que aparece la linea "vs equipped ...".
3. Arrastrar un hueso sobre un slot compatible e incompatible y confirmar
   el color verde/rojo del borde; soltar fuera de cualquier slot y
   confirmar que el borde vuelve a su color normal.

- 2026-07-18 (correccion responsive): `_apply_paper_doll_responsive_layout`
  escalaba cada `BoneSlotWidget` dos veces. `BoneSlotWidget.setup()` posiciona
  sus hijos en offsets absolutos derivados del tamano 88x88 con el que se
  construye y no se re-maqueta al cambiar de tamano, asi que `scale` es lo que
  realmente redimensiona el slot. Al asignar ademas `size = 88 * doll_scale`,
  el rect de *input* del control quedaba en `88 * doll_scale^2` mientras el
  visual quedaba en `88 * doll_scale`. Como `doll_scale` esta clampeado a
  0.55-1.75 y casi nunca vale exactamente 1.0, los blancos de drop de slots
  vecinos se solapaban: a 1920x1080 y 2560x1080 los rects de brazo y pierna
  se intersectaban, de modo que arrastrar un hueso podia equiparlo en el slot
  equivocado. Ahora el rect del control queda en el tamano base (88x88) y solo
  `scale` lo redimensiona.

  Verificado con `tools/headless_inventory_check.gd` (Godot 4.7 headless), que
  instancia el jugador real, recorre las 9 pestanas en 1280x720, 1366x768,
  1920x1080, 2560x1080 y 1024x600, y afirma que el rect de input de cada slot
  coincide con su visual y que ningun par de slots se solapa. El chequeo se
  probo contra el codigo con el bug (falla, reportando los solapamientos
  brazo/pierna) y contra el corregido (pasa).

Pendiente de confirmacion visual humana: que el paper doll se vea centrado y
sin recortes en cada resolucion (el chequeo headless valida geometria, no
render).

- 2026-07-18 (dimensiones y centrado): correcciones sobre lo reportado
  visualmente (el paper doll no se veia centrado y los textos se pisaban).
  Cuatro causas reales, todas verificadas por captura y no solo por lectura:

  1. `BoneSlotWidget` y `BoneItemTile` maquetaban a offsets absolutos
     derivados de un tamano de diseno fijo (82x80 y 96x86) y no se
     re-maquetaban nunca. Ahora `BoneSlotWidget.resize()` re-posiciona todos
     sus hijos para el tamano pedido, y el paper doll lo llama en cada pasada
     responsive en lugar de usar `scale`. Esto elimina de raiz el doble
     escalado corregido el 2026-07-18 anterior.
  2. Los labels de nombre tenian `autowrap` pero altura fija. Godot no
     recorta labels por defecto, asi que un nombre de dos lineas ("Enemy Left
     Arm Bone") se dibujaba encima del caption del slot de abajo. Ahora las
     bandas de texto se reservan por separado y los labels usan
     `max_lines_visible` + `OVERRUN_TRIM_ELLIPSIS` + `clip_text`.
  3. El doll vivia en un `MarginContainer` que lo estiraba a todo el panel
     (medido: >1000 px de ancho contra una figura de ~500 px) mientras sus
     hijos se posicionaban desde el origen del doll, dejando toda la holgura
     a la derecha y abajo. Con `SIZE_SHRINK_CENTER` el contenedor lo
     dimensiona a su minimo y lo centra por layout.
  4. La pestana Builds no tenia layout responsive: previews de tamano fijo
     que ademas absorbian la altura sobrante del card (custom_minimum_size es
     solo un piso), empujando el resumen y los botones Save/Apply fuera del
     panel a 1280x720. Ahora hay `_apply_builds_responsive_layout`, los
     previews estan fijados con `SHRINK_CENTER`, el resumen esta limitado a 3
     lineas con altura reservada, y los cards son mas anchos (hasta 340 px) y
     quedan centrados verticalmente.

  Ademas la grilla rellena `inventory_visible_rows` filas en vez de 4 fijas,
  que era lo que dejaba una banda vacia bajo la ultima fila a 1080p.

  Verificacion: `tools/headless_inventory_check.gd` (geometria: rect de input
  == visual, sin solapes entre slots, bandas de texto disjuntas, doll centrado
  dentro de su panel, en 1280x720 / 1366x768 / 1920x1080 / 2560x1080 /
  1024x600) y `tools/screenshot_inventory.gd`, que renderiza la escena real y
  guarda PNGs de Inventario y Builds a 1280x720 y 1920x1080 para inspeccion
  visual. Este segundo tool existe porque la pasada anterior aprobo la
  geometria mientras la pantalla seguia viendose mal: revisar solo numeros no
  alcanzaba. Correr sin `--headless` (headless no tiene renderer).

Pendiente: no se ejercito drag and drop real (equipar arrastrando) ni la
navegacion con teclado; eso sigue requiriendo una sesion manual.

- 2026-07-18 (centrado de extremidades): brazos y piernas subieron 48 unidades
  de diseno (arms y 190 -> 142, legs y 286 -> 238) para que el bloque
  brazos+piernas quede centrado con el frame del preview. El frame va de y 92 a
  y 376 (centro 234); antes el bloque iba de 190 a 374 (centro 282), 48 abajo.
  Ahora va de 142 a 326, centro 234 exacto. Cabeza y torso no se movieron.

  De paso la geometria del paper doll pasa a constantes `PAPER_DOLL_*` con una
  sola definicion. Antes las posiciones estaban escritas dos veces
  (`_build_paper_doll` y la pasada responsive) y que esas dos copias se
  desincronizaran es literalmente el bug que ya se documento arriba; ahora no
  puede repetirse.

  `tools/headless_inventory_check.gd` afirma el centrado: compara el centro
  vertical del bloque brazos+piernas contra el centro del frame del preview en
  las cinco resoluciones. Probado contra las posiciones viejas (falla en las 5,
  desviacion de 30-61 px segun resolucion) y contra las nuevas (pasa).

- 2026-07-18 (calidad en el ciclo de vida): la instancia conserva
  `bone_id` + `quality_id` en inventario, equipar/desequipar, stacks, builds,
  rollback y preview. `unequip_slot` solo borra el mapeo de slot, asi que la
  pieza sigue en `bone_inventory` y vuelve siendo la misma instancia.
  `PlayerStatsComponent.calculate` recibe el equipment state con instance_ids,
  de modo que ya opera sobre stats efectivos.

  Stack key = `bone_id | quality_id | mutacion | durabilidad`. La durabilidad
  hoy es authored por tipo (no hay desgaste por pieza), pero entra en la clave
  ahora para que agregar desgaste luego no pueda fusionar en silencio una
  pieza intacta con una agrietada.

  UI: filtro de calidad (All + las 5) y orden (Default / Quality: Lowest first
  / Quality: Highest first), ambos combinables con el filtro corporal. Cada
  tarjeta muestra la calidad como texto y un acento del color del tier. El
  panel de detalles muestra nombre, slot, calidad, multiplicador,
  `base -> efectivo` y la comparacion contra la pieza equipada, con efectivos
  en ambos lados.

## docs/manual_gameplay_qa_checklist.md

# Manual Gameplay QA Checklist

Fecha base: 2026-07-15

Este checklist define una pasada manual repetible para validar que MARROW sigue
jugable despues de cambios pequenos. No reemplaza pruebas automatizadas ni una
revision en Godot; sirve para dejar evidencia consistente antes de abrir o
cerrar un PR.

## Alcance

- Escena principal y menu.
- Movimiento, camara y estados basicos del jugador.
- Inventario, equipamiento y preview.
- Pickups, drops y recuperacion de huesos.
- Combate cuerpo a cuerpo, rango, backstab y enemigos.
- Rig modular y progresion visual del cuerpo.
- Layout de UI en resoluciones comunes.

## Preflight

1. Confirmar rama de trabajo:
   - `git status --short --branch`
   - La rama no debe ser `main` para cambios de Codex.
2. Confirmar que no hay conflictos:
   - `git diff --name-only --diff-filter=U`
3. Confirmar higiene de diff:
   - `git diff --check`
4. Confirmar si Godot CLI esta disponible:
   - `godot --version`
   - `godot4 --version`

Si Godot no esta disponible en terminal, registrar que la validacion runtime
queda pendiente en editor.

## Arranque

1. Abrir `project.godot`.
2. Ejecutar desde `scenes/main_menu.tscn`.
3. Entrar al demo jugable.
4. Volver al menu si existe flujo de regreso.
5. Entrar a `scenes/testing_environment.tscn` desde el menu.

Resultado esperado:
- El menu carga sin errores visibles.
- El demo y la escena de prueba cargan sin bloqueo.
- No aparecen errores nuevos de scripts o nodos faltantes en la consola.

## Movimiento Y Camara

Validar en demo y en testing environment:

1. Movimiento en todas las direcciones.
2. Movimiento relativo a la camara.
3. Salto o movimiento especial disponible en el estado actual.
4. Rotacion de camara con mouse.
5. Colision de camara contra geometria cercana.
6. Pausa o apertura de inventario libera/captura el mouse segun corresponda.
7. Ataque o animacion no provoca desplazamiento involuntario persistente.

Resultado esperado:
- El jugador mantiene control despues de atacar, abrir inventario y cerrar
  inventario.
- No hay jitter persistente de camara o cuerpo en reposo.
- No hay teletransportes ni hundimiento en geometria.

## Inventario, Equipamiento Y Preview

1. Abrir inventario.
2. Cambiar entre pestanas o filtros disponibles.
3. Seleccionar un hueso y revisar panel de detalle.
4. Equipar una pieza compatible.
5. Desequipar una pieza.
6. Intentar equipar una pieza incompatible si existe una disponible.
7. Confirmar que la pieza equipada no se duplica en la grilla de inventario.
8. Confirmar que copias duplicadas validas siguen listadas como copias
   separadas.
9. Revisar que el preview se mantiene dentro de su viewport.
10. Cerrar inventario y verificar que gameplay retoma control normal.

Resultado esperado:
- La UI delega validaciones a los sistemas de equipamiento.
- El preview no aparece en el mundo jugable.
- No hay texto cortado en controles principales.
- El estado equipado coincide con el rig visible.

## Pickups, Drops Y Huesos

1. Spawnear o encontrar pickups.
2. Recoger un pickup valido.
3. Confirmar que aparece en inventario.
4. Derrotar o danar un enemigo hasta provocar drop si la escena lo permite.
5. Recoger el drop.
6. Revisar que nombre, slot y rareza/calidad se muestran de forma coherente.

Resultado esperado:
- Los pickups no se duplican al recogerlos.
- El inventario se actualiza sin abrir/cerrar forzado.
- Los nombres de drops son slot-aware cuando aplica.

## Combate Y Enemigos

1. Atacar a un dummy o enemigo cuerpo a cuerpo.
2. Confirmar cooldown y feedback visual.
3. Recibir dano de un enemigo activo.
4. Validar muerte o estado bajo vida si aplica.
5. Usar ataque a distancia si el estado/equipamiento lo permite.
6. Probar backstab desde detras del enemigo.
7. Probar que el backstab no se activa desde frente o lateral.
8. Validar comportamiento basico de busqueda/persecucion.
9. Para lizard, validar climb contra pared si esta presente.

Resultado esperado:
- Los enemigos no dependen de rutas fragiles del jugador.
- El backstab respeta posicion y direccion del enemigo.
- La animacion de ataque no deja al jugador bloqueado.

## Rig Y Progresion Visual

1. Revisar estado head-only si el flujo lo permite.
2. Equipar torso y confirmar que cambia la progresion visual.
3. Equipar brazos y piernas.
4. Observar animacion en reposo, movimiento, salto/crawl y ataque.
5. Confirmar que sockets visibles corresponden a equipo activo.

Resultado esperado:
- Las partes no recuperadas permanecen ocultas.
- El rig no muestra piezas duplicadas ni flotantes.
- El preview y el jugador comparten la misma progresion visual esperada.

## Resoluciones De UI

Probar mentalmente o en editor, segun disponibilidad:

- 1280x720
- 1366x768
- 1920x1080
- Relacion ultrawide

Resultado esperado:
- Inventario y paneles caben en pantalla.
- Labels criticos no se cortan sin alternativa.
- Botones y slots mantienen alineacion y separacion consistente.

## Registro De Evidencia

Para cada PR, registrar:

- Rama.
- Commit.
- Escena validada.
- Resolucion usada.
- Pasos ejecutados.
- Resultado: pass, fail o pendiente.
- Errores de consola relevantes.
- Capturas o video si el cambio toca UI, camara, rig o animacion.

Formato corto:

```text
Rama:
Commit:
Escena:
Resolucion:
Pasos:
Resultado:
Pendientes:
```

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

## docs/p0_runtime_validation_suite.md

# P0 Runtime Validation Suite

Fecha base: 2026-07-15

Esta suite agrupa las validaciones runtime de mayor riesgo dentro de
`scenes/testing_environment.tscn`. No corrige P0 por si sola: prepara una pasada
manual reproducible para observar backstab, preview, jitter, inventario,
equipamiento, pickups, enemigos, camara y rig antes de aplicar fixes.

## Escena

- `scenes/testing_environment.tscn`
- Script: `scripts/testing_environment.gd`
- Validador estatico: `python -B tools/validate_p0_runtime_suite.py`

La escena muestra un panel con enemigos activos, controles de spawn, una guia
P0 por seccion y un registro de resultados por chequeo. Usa:

- `F1`: siguiente guia P0.
- `F2`: guia P0 anterior.
- `O`: escribir el resultado observado (libera el mouse, `Enter` guarda, `Esc` cancela).
- `P`: registrar PASS para la guia P0 activa.
- `F`: registrar FAIL para la guia P0 activa.
- `1`: enemigo normal.
- `2`: gorilla.
- `3`: lizard.
- `4`: ranged.
- `5`: dummy pasivo.
- `Backspace`: eliminar el ultimo enemigo.
- `R`: reiniciar la escena.
- `Esc`: volver al menu (o cancelar edicion de notas si esta activa).

## Registro De Resultados (PASS/FAIL/observado/evidencia)

Cada vez que se presiona `P` o `F`, la escena escribe una entrada en
`user://p0_validation_log.txt` (fuera del repo, en la carpeta de datos de
usuario de Godot) con:

- Marca de tiempo (`Time.get_datetime_string_from_system()`).
- Numero y titulo de la guia P0 activa.
- Resultado (`PASS` o `FAIL`).
- Texto observado escrito con `O` (o `"(no notes typed with O)"` si no se
  escribio nada).
- Evidencia automatica: FPS, tasa de fisica, modo de mouse, enemigos vivos y
  sus nombres, posicion y estado `is_dead` del jugador si existe, y el estado
  de equipamiento del jugador si el metodo esta disponible.

El panel en pantalla muestra el conteo de PASS/FAIL de la sesion y el ultimo
resultado registrado. Esto es una herramienta de captura de evidencia para un
humano frente al teclado, **no** un test automatizado: la evidencia es un
respaldo objetivo de lo que la maquina puede observar en el momento del
registro, no un reemplazo del juicio del tester sobre si el comportamiento es
correcto.

## Ejecucion Headless Real (No Solo Estatica)

A diferencia de los validadores en `tools/*.py` (que solo revisan texto fuente
o reimplementan formulas en Python), esta escena SI puede ejecutarse con el
motor real en modo headless. Requiere un paso previo que no estaba
documentado antes:

```powershell
# 1. Una sola vez por checkout: construir el cache de class_name globales.
#    Sin este paso, cargar la escena falla con "Parse Error: Identifier
#    'X' not declared in the current scope" para casi todas las clases
#    con class_name (BoneRulesService, EquipmentRulesService, etc.),
#    porque .godot/global_script_class_cache.cfg todavia no existe.
Godot_v4.7-stable_win64_console.exe --headless --editor --quit --path .

# 2. Correr la escena real N frames y salir solo:
Godot_v4.7-stable_win64_console.exe --headless --path . scenes/testing_environment.tscn --quit-after 60
```

Verificado en este repositorio (2026-07-15, Godot 4.7.stable): tras el
warmup, la escena carga sin `SCRIPT ERROR`, el jugador spawnea, el
inventario de prueba se siembla (`Collected bone: ...` por consola) y los
enemigos se generan. Esto prueba que la escena y el arbol de nodos son
validos en runtime, no solo por inspeccion de codigo.

Limite honesto: correr la escena sin interaccion no ejerce las teclas de
juego (mover, atacar, equipar, backstab) ni las teclas `O/P/F` de este
registro. Confirmar esos flujos sigue requiriendo un humano jugando la
escena; esta ejecucion automatizada solo prueba que la escena arranca y
corre sin excepciones durante N frames.

Nota: el paso 1 y la ejecucion de la escena reimportan algunos `.import`
binarios (modelos/texturas). Revisar `git status` despues y descartar ese
ruido si no es intencional (`git checkout -- '*.import'`), para no
commitear cambios de import accidentales.

## Secciones P0

### Movement, Camera, And Jitter

Objetivo: reproducir o descartar jitter persistente antes de tocar camara,
player o animador.

Registrar:

- FPS aproximado si el editor lo muestra.
- Si el jugador esta en piso, rampa, pared cercana o aire.
- Si el inventario fue abierto/cerrado antes del jitter.
- Si el jitter aparece con ataque, idle, salto o movimiento continuo.

### Inventory, Equipment, And Preview

Objetivo: comprobar que el inventario seeded permite equipar cuerpo completo y
que el preview no duplica nodos ni comparte mundo jugable.

Registrar:

- Pieza equipada o desequipada.
- Si el tile desaparece solo cuando corresponde.
- Si los stacks `xN` siguen representando duplicados.
- Si preview y jugador real coinciden.

### Pickups, Drops, And Enemy Profiles

Objetivo: comprobar que los perfiles de enemigo siguen spawneando, reaccionan y
generan drops/pickups observables.

Registrar:

- Perfil usado.
- Drop observado.
- Si el pickup se puede recoger.
- Si el inventario se actualiza sin reabrir.

### Backstab Runtime Geometry

Objetivo: validar el comportamiento real, no solo el producto punto estatico.

Registrar:

- Angulo aproximado: frente, lateral o detras.
- Perfil del enemigo.
- Si aparece prompt o se ejecuta stealth finish.
- Si hubo dano duplicado o estado bloqueado.

### Rig And Body Progression

Objetivo: observar progresion visual y estabilidad del rig con piezas equipadas.

Registrar:

- Estado corporal: head-only, torso, brazos, piernas.
- Si izquierda/derecha se ven invertidas.
- Si el preview coincide con el rig del jugador.
- Si el ataque o movimiento deja piezas flotantes.

## Resultado Esperado

Cada pasada manual debe terminar con una evidencia corta (complementaria al
registro automatico en `user://p0_validation_log.txt` descrito arriba):

```text
Rama:
Commit:
Escena:
Resolucion:
Guia P0:
Sistemas habilitados:
Pasos ejecutados:
Resultado observado:
Errores de consola:
Pendientes:
```

Si Godot no esta disponible, no marcar como validado runtime. Ejecutar los
validadores estaticos y dejar esta guia lista para una pasada manual en
editor. Si Godot SI esta disponible pero solo en modo headless (sin un
humano frente al teclado), seguir sin marcar los chequeos interactivos
(equipar, atacar, backstab, etc.) como validados: la ejecucion headless sin
interaccion solo prueba que la escena carga y corre sin excepciones, no que
el comportamiento observado sea correcto. Ver la seccion "Ejecucion Headless
Real" arriba para el procedimiento exacto y sus limites.

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

## docs/repo_stability_and_graphify.md

# Repo Stability And Graphify Policy

Fecha base: 2026-07-15

Este documento define como mantener estable el repositorio mientras el roadmap
avanza por ramas de hito. No cambia gameplay.

## Estado Actual

- `graphify-out/` y `graphify-corpus/` siguen versionados como artefactos
  revisables del mapa de arquitectura.
- `graphify-out/cache/` y `graphify-corpus/graphify-out/cache/` son caches y no
  deben entrar al control de versiones.
- El workflow de Graphify solo debe ejecutarse en `main` y `develop`.
- Las ramas feature, fix y test no deben incluir regeneraciones de Graphify.
- Los cambios de line endings deben controlarse mediante `.gitattributes`, no
  por normalizaciones masivas accidentales.

## Politica De Ramas

- Las ramas de gameplay no deben modificar `graphify-out/` ni
  `graphify-corpus/` salvo que el hito sea explicitamente de arquitectura o
  estabilidad del repositorio.
- Si Graphify aparece modificado en una rama de gameplay, tratarlo como salida
  generada accidental y no incluirlo en el commit.
- No usar `Accept Both Changes` en JSON generado.
- No configurar `merge=ours` como solucion silenciosa permanente.
- Si un conflicto de Graphify bloquea un PR, resolverlo en una rama de
  estabilidad o regenerarlo desde la rama oficial, no mezclarlo con la feature.

## Regeneracion

Graphify se regenera con el workflow `.github/workflows/update-graphify.yml`.
El flujo esperado es:

1. Cambios funcionales entran primero por PR normal.
2. El workflow corre en `main` o `develop`.
3. El bot crea un commit `chore: actualiza grafo de arquitectura` solo si la
   salida cambia.
4. Las ramas siguientes parten de la punta actualizada de `origin/main`.

No regenerar Graphify manualmente en ramas de inventario, combate, camara,
preview, jitter, enemigos, stats, animaciones o progresion.

## Line Endings

`.gitattributes` define LF para scripts, escenas, resources, documentacion,
workflows, JSON y archivos `.import`.

Esta politica no normaliza archivos ya existentes por si sola. Si un archivo
aparece modificado solo por CRLF/LF, no debe incluirse automaticamente. Crear
una rama exclusiva de normalizacion solo si hay evidencia de que el ruido de
line endings bloquea el trabajo.

## Preflight De Commit

Antes de cada commit:

```powershell
git status --short --branch
git diff --check
git diff --stat
git diff --name-status
git diff
```

Comprobar especificamente:

- Sin conflictos.
- Sin caches.
- Sin Graphify accidental.
- Sin archivos `.import` accidentales.
- Sin normalizacion masiva de line endings.
- Sin cambios fuera del hito.

## Fuente Del Roadmap

El roadmap numerado vive en `docs/roadmap_1_165.md`. Ese archivo es la fuente
auditable para clasificar objetivos como no iniciados, preparados, parciales,
integrados o validados.

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

## Head model (skull)
The player's head is `assets/skull.glb` instead of a grey box. Wired in
`player.tscn` via `ModularSkeletonRig.head_model_scene`.

- Both the base head box AND the equipped head bone are built by `_make_limb()`,
  so that is the only hook needed. It has to cover both:
  `PlayerEquipmentComponent.equip_starting_core()` equips `head_bone` on spawn and
  `_base_socket_should_show()` returns false for an equipped socket, so the head
  you actually SEE is the equipped bone's visual — swapping only the base box
  would look like nothing happened.
- `head_model_scale` 0.32: skull.glb measures ~0.96 x 1.00 x 0.96 around its own
  origin, and the grey head box it replaces is 0.32 (LIMB_GEO). It MULTIPLIES the
  bone's `visual_scale`, so a bigger head bone still reads bigger. Measured in
  play: the visible head is 0.307 x 0.319 x 0.306.
- `head_model_rotation_deg` is `(0, -90, 0)` in `player.tscn`. skull.glb's face
  points down its own **+X**, established from two in-game observations that agree:
  at rotation 0 it looked left, and at +90 it looked backward. The mesh is
  near-symmetric (0.959 vs 0.955 on X/Z), so its facing cannot be derived from its
  bounds — only from looking at it.
- Careful with left/right here: this rig's forward is **+Z** (`_animate_facing`
  sets `rotation.y = atan2(flat.x, flat.z)`, aiming the node's +Z along facing),
  which is 180 deg from Godot's standard -Z forward. That flip swaps handedness:
  facing +Z the character's right is **-X** and its LEFT is **+X**. Assuming
  Godot's usual "+X is right" here gives exactly the wrong sign.
- `equip_bone()` ADDS `visual_rotation`/`visual_offset` rather than assigning
  them. Assigning discarded `head_model_rotation_deg` on the EQUIPPED head (the
  visible one) while the hidden base box rotated correctly. Every current bone has
  a zero `visual_rotation`, so `+=` is identical to `=` for them.
- `head_model_keep_material` (true) keeps the imported skull material instead of
  flat-tinting it with the bone colour the grey boxes use.
- With no `head_model_scene` assigned the grey box is used, so enemies (which
  share `ModularSkeletonRig`) are unaffected.
- Hitboxes are unchanged: `_apply_equipped_body_hitbox()` sizes from the bone
  data, not the visual.

## Split limbs (elbows and knees)
`ModularSkeletonRig.use_split_limbs` (on in `player.tscn`) splits each arm/leg
into an upper and a lower half with a bending elbow/knee.

Socket tree when split (right side; left mirrors):

    right_arm_socket            (0.28, 0.30, 0)   shoulder — swing pivot
    ├── MeshInstance3D  box(0.16, 0.29, 0.16) @ -0.145   -> base_visuals["right_arm"]
    └── right_arm_lower_socket  (0, -0.29, 0)     ELBOW — bend pivot
        └── MeshInstance3D  box(0.16, 0.29, 0.16) @ -0.145 -> base_visuals["right_arm_lower"]

    right_leg_socket            (0.16, -0.35, 0)  hip
    ├── MeshInstance3D  box(0.18, 0.31, 0.18) @ -0.155   -> base_visuals["right_leg"]
    └── right_leg_lower_socket  (0, -0.31, 0)     KNEE
        ├── MeshInstance3D  box(0.18, 0.31, 0.18) @ -0.155 -> base_visuals["right_leg_lower"]
        └── right_foot_socket   (0, -0.27, 0.06)  MOVED off the hip

The torso splits too, into a chest and an abdomen meeting at a WAIST socket at the
body origin (`body` keeps the chest, `body_lower` hangs the abdomen below it):

    body_socket                 (0, 0, 0)        root / waist
    ├── MeshInstance3D  box(0.5, 0.35, 0.28) @ +0.175  -> base_visuals["body"]        CHEST
    └── body_lower_socket       (0, 0, 0)        WAIST — structural only
        └── MeshInstance3D  box(0.5, 0.35, 0.28) @ -0.175 -> base_visuals["body_lower"] ABDOMEN

Proportions (split rig only — enemies keep the old 0.5 torso / 0.18 legs):

| part | size | note |
|---|---|---|
| chest (`body`) | 0.50 x 0.35 x 0.28 | UNCHANGED — width pinned by the arm sockets |
| waist (`body_lower`) | 0.40 x 0.35 x 0.22 | 0.80 of the chest wide, 0.79 deep |
| thigh / shin | 0.16 x 0.31 x 0.16 | narrowed from 0.18 to fit inside the waist |
| hip socket X | +-0.12 | `SPLIT_SOCKET_LAYOUT`, was +-0.16 |

The arithmetic that has to close, and why each number is what it is:
- **Legs inside the waist:** hip 0.12 + half-leg 0.08 = 0.20 = waist half-width. Flush
  by design, not a near miss — the thigh starts at y=-0.35 where the waist ends, so
  there is no shared height and nothing to z-fight. The leg's outer wall simply
  continues the waist's downward, which is what a hip looks like.
- **The hip HAD to move.** Keeping it at 0.16 requires waist >= 0.32 + legWidth; even
  at a 0.16 leg that is a 0.48 waist — a 0.01/side taper, invisible. There is no
  version of this that keeps the sockets.
- **The FOOT sets the floor.** `LIMB_GEO["*_foot"]` (0.2 wide) is shared with enemies
  and has no split-only override, so foot width is immovable, and the foot centres on
  its leg socket X. Hip 0.10 would put the feet at x[0.00,0.20] — touching at the
  centreline and fusing into one slab. Hip 0.12 gives a 0.04 gap. That floor is what
  fixes the waist at 0.40 rather than a slimmer 0.36.
- **The 0.04 gap is stable:** legs only rotate about X, and crawl/wall-climb offsets
  push them APART, so rest is the worst case.
- **The chest cannot narrow.** Arm sockets sit at +-0.28 with a 0.16 arm, so the arm
  buries 0.05 of itself in the chest. That embed is what makes a shoulder read as a
  joint; at a 0.40 chest the arms come away from the body. Leaving it also gives the
  waist its reference edge — a taper is contrast.
- **Z tapers too** (0.28 -> 0.22). The waist has no bend, so static geometry is its
  only cue; a width-only taper vanishes in profile.

### The waist bend
The chest leans at the waist and the head and arms come with it, giving a
two-segment spine instead of a rigid plank. Tuning lives in the animator's
`Waist` export group (`waist_bend_lean` 0.10 is the main read; set it to 0 to
disable the feature at runtime).

- `_build_waist_joint()` inserts a `waist_joint` Node3D between the body socket
  and the chest mesh. It sits at body-local ZERO because the waist plane IS the
  body origin, which makes moving the chest mesh onto it a NUMERIC IDENTITY.
- It is NOT in `sockets`, on purpose. A new socket key would silently need a
  `LIMB_GEO` entry (else a 0.2 m cube), an `ENEMY_HITBOX_ACCURACY_SCALE` entry
  (else a default scale) and a `_base_socket_should_show` branch (else `return
  true`, rendering an unearned chest). Staying out of the dict sidesteps all three
  plus the marker/equip/hitbox loops. `get_waist_joint()` returns null on an
  unsplit rig, and that null IS the animator's gate — the animator is shared and
  has no per-rig flag.
- `get_socket_attach("body")` returns the pivot, so equipped torso art and the
  chest hurtbox bend with it.
- **NOT routed through `_animate_joints`.** That writer is for elbows and knees:
  it ASSIGNS rotation (stomping other writers), its `joint_bend_base` 0.12 +
  `joint_bend_swing` 0.7 would give the chest a permanent 0.12–0.82 rad flex every
  step, and its `bend_sign` keys off the substring `"arm"`.

**The head and arms are NOT reparented under the chest** — and that is the
load-bearing decision. Reparenting is the obvious way to make them follow, but
`_capture_rest()` stores every socket's PARENT-LOCAL rest pose, so it silently
redefines what `_rest_pos["head"]` means and six families break at once:
torso-spring (`head.position = body.position + offset`), the head-only ground
constants (rig-space −0.85 fused with chest-space rest.x/z), the 12
`_world_horizontal_offset_to_local` call sites (rig-basis directions applied in a
tilted frame), `rig.to_local` across the player.gd boundary, the doubled crawl
drops, and — the one nothing warns about — `body.scale`'s squash-and-stretch,
which would suddenly squash the head and both arms.

So `_apply_waist_carry()` ADDS the transform a hierarchy would have contributed,
by hand, after every other writer. No socket changes parent, so no space changes
and all six are structurally absent. **Verified equivalent:** the carried head and
a real parent transform agree to 0.00000 m.

Two consequences to respect:
- **`_animate_waist(delta)` MUST stay last in `update_from_player`.** A writer
  added below it escapes the carry, and the head silently stops following the
  chest. This is the price of the carry over a real hierarchy.
- `_waist_target_angle()` returns exactly 0.0 in head-only, torso-spring, crawl,
  the detach/reattach states and the demo — every mode that owns the head socket
  or already pitches the torso. `_apply_waist_carry` early-returns on
  `is_zero_approx`, so those modes are bit-identical to a build with no waist.

Do the real reparent only when something needs a writer BETWEEN the waist and the
head/arms (IK, a skinned chest, per-socket physics), or when the ordering rule
above actually bites.

**The ABDOMEN (`body_lower`) does NOT bend, deliberately** (`LOWER_UNDER_UPPER["body_lower"]` sets
`bend: false`, so it is never registered in `limb_joints`). The head and arm
sockets are SIBLINGS of `body`, not children, so a bending waist would swing the
chest away from them and tear the figure apart. The split is an attach point for
swapping in a chest and an abdomen mesh, not an animated joint. Making it bend
means first reparenting head/arms under the chest — a much larger animator change.
Note the torso box is CENTRED on its socket (offset +0.175 for the chest), unlike
the limbs which hang from theirs (-0.145 / -0.155).

Rules that keep this safe:

- **Lower sockets are CHILDREN of their upper**, like `FOOT_UNDER_LEG` already
  does for feet. They cannot go in `SOCKET_LAYOUT`: that loop `add_child()`s every
  socket to the RIG, so a lower limb declared there would be a sibling and neither
  the shoulder swing nor the elbow bend would carry it.
- **`base_visuals[key]` stays a flat key -> MeshInstance3D map.** Each half gets
  its OWN key. Do not make it a container: `enemy.gd:1366` casts
  `base_visuals[limb_key] as MeshInstance3D` and reads `.mesh`, and a container
  would null that cast and silently stop enemy limbs from spawning.
- **Do not parent the elbow under the upper MESH.** Tempting (hiding a parent
  hides descendants), but `equip_bone()` hides `base_visuals[key]`, so equipping
  any arm bone would make the forearm vanish.
- **All limb geometry goes through `_limb_geo_for()`, never `LIMB_GEO` directly.**
  That helper is what swaps a split upper limb to its half-length
  `SPLIT_UPPER_GEO` box. `_make_limb` originally read the dict directly, which
  left the upper arm at full 0.58 with the forearm overlapping it — and desynced
  the art from the hurtbox, because the hitbox builders already used the helper.
- **Zero-diff invariant.** The halves reconstruct the original box exactly:
  arm 0.29+0.29=0.58, leg 0.31+0.31=0.62, and the foot resolves to leg-space -0.58
  either way. Verified: split and unsplit silhouettes match to 0.00000. If the
  split is ever suspected of moving the pose, set `joint_bend_base` and
  `joint_bend_swing` to 0 — the rig must then be identical to the unsplit one.
  CAUTION: this invariant is necessary but NOT sufficient. It only measures how
  DEEP a limb reaches, which is identical whether or not the upper half was
  shortened — it passed while the uppers were still full length. Check each
  segment's own LENGTH too (0.29 / 0.31), not just the limb's total extent.
- **Vocabulary boundary.** The `*_lower` keys are a RENDER + HITBOX concern only.
  They belong in `LIMB_GEO`, `SPLIT_UPPER_GEO`, `ENEMY_HITBOX_ACCURACY_SCALE` and
  `SLOT_TO_SOCKETS`. Never in `LIMB_TO_SLOT`, `primary_limb_keys_for_slot`,
  `LIMB_DISPLAY`, `DETACHABLE_LIMBS`/`PICKUP_ELIGIBLE_LIMBS` or
  `detached_limb_keys` — a lower key there generates a bone id like
  `normal_right_arm_lower_bone` that `slot_for_bone` cannot parse, so the drop
  silently no-ops.
- **`_base_socket_should_show()` must name the lower keys.** They otherwise fall
  through to `return true`, and with body progression on an unearned forearm
  renders alone while its upper half is correctly hidden.
- **`_animate_joints()` reads `kind` FIRST.** The skinned entry has `"skel"`; the
  socket entry does not, and `var skel: Skeleton3D = info["skel"]` HALTS the
  script rather than failing soft like the rest of this codebase.
- Equipment needed one constant: `SLOT_TO_SOCKETS` gained the lower keys, so
  `equip_bone`'s existing per-socket loop paints both halves. No slot changed.

`use_split_limbs` is a TEMPORARY migration adapter (AGENTS.md: "migraciones
graduales y con adaptadores"). It is off for enemies so their paths stay
byte-identical. Remaining cuts:
- **Cut 2 — enemies.** `enemy.gd` fans `_set_rig_limb_visible`,
  `_limb_recovery_group`, `_recovery_group_key` and `_spawn_detached_limb_piece`
  over `rig.limb_socket_group()` / `rig.get_limb_meshes()`, THEN flip
  `enemy.tscn`. Flip it first and a detached arm leaves a floating forearm with a
  live hurtbox.
- **Cut 3 — proportions + delete the flag.** `apply_gorilla_proportions` /
  `apply_lizard_proportions` resize whole limbs; applied to a half they render a
  ~1.3 m arm. Then remove the flag. If it outlives cut 3 it is permanent debt.
- `foot_placement_enabled` (off by default) assigns `foot.position` in the foot's
  parent space, which is now the ROTATING knee. Resolve that before enabling it.

## Socket markers (model-swap build aid)
`ModularSkeletonRig.show_socket_markers` (on in `player.tscn`) puts a small
magenta ball on every socket ORIGIN — 12 of them: pelvis, neck, both shoulders,
both elbows, both hips, both knees, both ankles.

Why they are worth having: the animator only ever rotates and moves SOCKETS —
`_swing()` turns the shoulder/hip, `_animate_joints()` turns the elbow/knee,
`_anchor_socket_to_body()` re-anchors arms in torso-spring mode. So a socket
origin is exactly the point a real model's joint has to land on. Line a model's
shoulder up with the shoulder ball and the procedural animation needs no
compensation; miss it and every pose is off by that offset forever.

- Parented AT the socket, so a marker inherits every rotation the animator
  applies. Verified: the elbow marker travels 0.618 m through a walk cycle.
- Drawn unshaded with depth-test off, so a marker buried inside a limb box is
  still readable. No shadow, no collision, no Area3D.
- NOT registered in `base_visuals`. That dict is the limb registry: it drives
  equip/progression visibility and enemy dismemberment clones
  `base_visuals[key].mesh`, so a marker in there could ragdoll away as a limb.
- Default OFF, because enemies share this rig. Verified: with the export off, no
  marker nodes exist at all and the hurtbox count is unchanged.
- Known interaction: `set_head_only_visual_guard(true)` hides every head-socket
  child that is not an equipped head part, so the NECK marker disappears in
  head-only mode. Harmless for an overlay; do not "fix" it by special-casing the
  guard.
- Tune with `socket_marker_radius` (0.035) and `socket_marker_color`.

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

## docs/roadmap_1_165.md

# Roadmap Tecnico 1-165

Fecha base: 2026-07-15. Ultima actualizacion: 2026-07-16 (integracion de 9
ramas de hito en `origin/develop`, ver `docs/roadmap_progress.md`).

Este archivo es la fuente auditable del roadmap tecnico. Los estados son
conservadores: un objetivo no se marca como cumplido si solo existe metadata,
documentacion o una prueba estatica sin integracion/runtime cuando el objetivo
requiere gameplay.

Estados usados:

- No iniciado.
- Preparado.
- Parcial.
- Integrado.
- Validacion pendiente.
- Validado estaticamente.
- Validado manualmente.
- Bloqueado.
- Obsoleto por implementacion existente.

## Tabla

| N | Sistema | Objetivo | Estado actual | Evidencia / pendiente |
| --- | --- | --- | --- | --- |
| 1 | Repo | Mantener trabajo fuera de `main` mediante ramas de hito. | Integrado | 2026-07-16: 9 ramas de hito trabajadas, validadas y fusionadas en `origin/develop` (no en `main`); ver `docs/roadmap_progress.md`. |
| 2 | Repo | Mantener commits pequenos y reversibles dentro de cada rama. | Parcial | Commits anteriores pequenos; seguir auditando por PR. |
| 3 | Repo | Evitar force-push y reescritura de historial. | Preparado | Politica en goal y docs; sin evidencia de force-push local. |
| 4 | Repo | Crear preflight de commits reproducible. | Integrado | `docs/repo_stability_and_graphify.md`. |
| 5 | Repo | Definir politica de line endings. | Integrado | `.gitattributes`. |
| 6 | Repo | Evitar commits accidentales de `.import`. | Preparado | Politica documentada; requiere disciplina en PRs. |
| 7 | Repo | Definir politica de caches. | Integrado | `.gitignore` y politica Graphify. |
| 8 | Repo | Definir politica Graphify para ramas feature. | Integrado | Workflow limitado y politica documentada. |
| 9 | Arquitectura | Confirmar componentes de inventario existentes. | Preparado | `PlayerInventoryComponent` documentado; requiere auditoria puntual por rama. |
| 10 | Arquitectura | Confirmar componentes de equipamiento existentes. | Preparado | `PlayerEquipmentComponent` documentado; requiere auditoria puntual. |
| 11 | Arquitectura | Confirmar componentes de stats existentes. | Preparado | `PlayerStatsComponent` documentado; requiere auditoria puntual. |
| 12 | Arquitectura | Evitar duplicar reglas entre UI y gameplay. | Parcial | Politica documentada; validacion continua pendiente. |
| 13 | Arquitectura | Usar servicios compartidos para reglas de slots. | Integrado | 2026-07-16: seis slots canonicos (`head`, `torso`, `left_arm`, `right_arm`, `left_leg`, `right_leg`) integrados en `develop` via `feat/inventory-equipment-ux-core`; solo `body` y `legs` como aliases legacy con datos reales (7 aliases especulativos sin consumidor eliminados). |
| 14 | Arquitectura | Usar catalogo de huesos como fuente de datos. | Parcial | `BoneDataCatalog` existe; migracion incompleta. |
| 15 | Arquitectura | Mantener `Player` como orquestador. | Parcial | Estado documentado; hotspots siguen grandes. |
| 16 | Arquitectura | Documentar arquitectura por flujos. | Integrado | `docs/flow_index.md` y docs de flujo. |
| 17 | QA | Probar inventario con checklist manual. | Preparado | Checklist existe; ejecucion runtime pendiente. |
| 18 | QA | Probar combate con checklist manual. | Preparado | Checklist existe; ejecucion runtime pendiente. |
| 19 | QA | Probar camara y movimiento con checklist manual. | Preparado | Checklist existe; ejecucion runtime pendiente. |
| 20 | QA | Probar rig y preview con checklist manual. | Preparado | Checklist existe; ejecucion runtime pendiente. |
| 21 | Docs | Mantener docs de inventario actualizadas. | Parcial | `docs/inventory_flow.md`; actualizar por cada hito. |
| 22 | Docs | Mantener docs de equipamiento actualizadas. | Parcial | `docs/equipment_flow.md`; seis slots pendiente. |
| 23 | Docs | Mantener docs de combate actualizadas. | Parcial | `docs/combat_flow.md`; backstab runtime pendiente. |
| 24 | Docs | Mantener docs de camara actualizadas. | Parcial | `docs/camera_flow.md`; jitter runtime pendiente. |
| 25 | Docs | Mantener docs de drops actualizadas. | Parcial | `docs/drops_flow.md`; drops side-aware pendiente. |
| 26 | Docs | Mantener docs de tutorial actualizadas. | Parcial | `docs/tutorial_flow.md`. |
| 27 | Docs | Mantener estado actual del sistema. | Parcial | `docs/current_system_status.md`; revisar tras hitos. |
| 28 | Docs | Mantener mapa de arquitectura. | Parcial | Graphify versionado; politica actualizada. |
| 29 | Datos | Definir ids estables de huesos. | Parcial | Resources existentes; auditoria de ids pendiente. |
| 30 | Datos | Definir nombres visibles. | Parcial | Resources existentes; glosario UI pendiente. |
| 31 | Datos | Definir rarezas. | Integrado | Documentado en historial y `BoneDefinition`. |
| 32 | Datos | Definir mutaciones. | Integrado | Documentado en historial y `BoneDefinition`. |
| 33 | Datos | Definir peso. | Integrado | 2026-07-16: `BoneRulesService.player_stats_with_equipment` aplica `equipment_weight` a una penalizacion de velocidad con umbral y techo; verificado en Godot 4.7 headless con datos reales (`equipment_weight: 3.2`, `load_speed_penalty: 0.012`). |
| 34 | Datos | Definir stats base. | Parcial | Metadata existe; comparador pendiente. |
| 35 | Datos | Definir sets y sinergias. | Parcial | Metadata pasiva; reglas activas pendientes. |
| 36 | Datos | Definir ataque y combo. | Parcial | Metadata pasiva; combate avanzado pendiente. |
| 37 | Datos | Definir modificadores porcentuales de calidad. | Integrado | 2026-07-16: `quality_damage_percent`/`speed_percent`/`health_percent`/`weight_percent` se suman y limitan (+-75%) y se aplican al calculo final de stats; verificado headless con datos reales de hueso. |
| 38 | Datos | Definir calidades. | Integrado | Documentado en `docs/bone_data_structure.md`. |
| 39 | Datos | Definir rarezas y mutaciones en docs. | Integrado | Documentacion existente. |
| 40 | Datos | Documentar estructura de datos de huesos. | Integrado | `docs/bone_data_structure.md`. |
| 41 | Inventario | Stacks visuales reales. | Parcial | Contador `xN` integrado; runtime pendiente. |
| 42 | Inventario | Tiles con cantidad y drag and drop. | Parcial | `ui_bone_item.gd` y validador; runtime pendiente. |
| 43 | Inventario | Comparador de stats. | Integrado | 2026-07-16: panel de info compara hueso bajo cursor vs equipado en el mismo slot (deltas reales via `BoneRulesService.adjusted_player_bonus_for`); verificado headless: "vs equipped Torso Bone: Speed -1.7, Damage +2.3, HP +0.3". |
| 44 | Inventario | Mostrar subidas y bajadas de stats. | Integrado | 2026-07-16: mismo cambio que 43; deltas con signo (+/-) por stat. |
| 45 | Inventario | Filtro por slot. | Integrado | Preexistente a esta sesion; confirmado funcional por `EquipmentRulesService.inventory_filter_matches_bone` y las 6 tabs de la UI. |
| 46 | Inventario | Filtro por rareza. | No iniciado | Pendiente; sin dato de rareza expuesto en filtro. |
| 47 | Inventario | Filtro por peso. | No iniciado | Pendiente. |
| 48 | Inventario | Filtro por dano. | No iniciado | Pendiente. |
| 49 | Inventario | Filtro por defensa. | No iniciado | No aplica: el proyecto no tiene stat de defensa (ver fila 67). |
| 50 | Inventario | Ordenar por nuevo. | No iniciado | Pendiente; no existe campo de orden de adquisicion. |
| 51 | Inventario | Ordenar por rareza o calidad. | Integrado | Preexistente; `compare_bones_for_inventory` ordena por slot -> rareza -> calidad -> nombre (compuesto, no seleccionable por el usuario). |
| 52 | Inventario | Ordenar por slot. | Integrado | Mismo comparador que fila 51. |
| 53 | Inventario | Ordenar por poder. | No iniciado | Pendiente; no existe metrica de "poder". |
| 54 | Inventario | Ordenar por nombre. | Integrado | Mismo comparador que fila 51 (ultimo criterio de desempate). |
| 55 | Inventario | Tooltip con color por calidad. | Integrado | Preexistente a esta sesion; panel de info ya mostraba calidad. |
| 56 | Inventario | Tooltip con resumen. | Integrado | Preexistente; `show_bone_info` ya incluia efecto y descripcion. |
| 57 | Inventario | Feedback de slot valido. | Integrado | 2026-07-16: `BoneSlotWidget` pinta el borde verde durante un drag compatible, via `can_equip_bone_in_slot`. |
| 58 | Inventario | Feedback de slot invalido. | Integrado | 2026-07-16: mismo cambio que 57, borde rojo para drag incompatible; se restaura en `NOTIFICATION_DRAG_END`. |
| 59 | Inventario | Confirmacion o animacion al equipar. | No iniciado | Solo hay `print()` de consola y el evento `bone_equipped`; sin confirmacion visual de usuario. |
| 60 | Builds | Guardar builds de equipamiento. | Integrado | 2026-07-16: `PlayerEquipmentBuildsComponent` persiste 3 slots en `user://equipment_builds.cfg`; verificado headless (guardar, recargar). |
| 61 | Builds | Cambiar builds de equipamiento. | Integrado | 2026-07-16: `apply_build` aplica un build guardado via `PlayerEquipmentComponent`; ahora con rollback real si la aplicacion falla a mitad de camino (snapshot previo + reaplicacion si la verificacion post-apply falla). Verificado headless en 5 escenarios: valido, vacio, pieza ausente, slot incompatible, rollback forzado. |
| 62 | Builds | Validar builds disponibles. | Integrado | `validate_build_state` revisa copias disponibles, torso requerido para extremidades, y compatibilidad de slot antes de aplicar. |
| 63 | Stats | Formula determinista de stats. | Parcial | `PlayerStatsComponent` existe; ampliar reglas. |
| 64 | Stats | Comparacion contra pieza equipada. | No iniciado | Pendiente. |
| 65 | Stats | Balance inicial de calidad. | Integrado | 2026-07-16: `quality_multiplier` escala bonuses directos; unidades y formula documentadas en `docs/equipment_flow.md`. |
| 66 | Stats | Balance inicial de peso. | Integrado | 2026-07-16: `EQUIPMENT_FREE_WEIGHT`/`EQUIPMENT_LOAD_SPEED_PENALTY_*` activos y documentados con ejemplo numerico. |
| 67 | Stats | Defensa en calculo final. | No iniciado | Pendiente. |
| 68 | Stats | Movilidad en calculo final. | Parcial | Stats actuales; auditoria pendiente. |
| 69 | Stats | Stamina en calculo final. | No iniciado | Pendiente. |
| 70 | Durabilidad | Durabilidad de huesos. | No iniciado | Pendiente. |
| 71 | Durabilidad | Estado roto o agrietado. | No iniciado | Pendiente. |
| 72 | Durabilidad | Reparacion de huesos. | No iniciado | Pendiente. |
| 73 | Sinergias | Bonus de set completos. | No iniciado | Pendiente. |
| 74 | Sinergias | Bonus de set parciales. | No iniciado | Pendiente. |
| 75 | Sinergias | Efectos negativos y mutaciones. | No iniciado | Pendiente. |
| 76 | Backstab | Validar frente bloqueado. | Validado estaticamente | `validate_backstab_geometry.py` (ahora con exit code real); geometria confirmada en Godot 4.7 headless con enemigo real, pero solo para el caso "detras", no explicitamente "frente" en runtime. |
| 77 | Backstab | Validar laterales bloqueados. | Validado estaticamente | Igual que fila 76; caso lateral no ejercido en runtime esta sesion. |
| 78 | Backstab | Validar detras permitido. | Validado manualmente | 2026-07-16: confirmado en Godot 4.7 headless con jugador y enemigo reales, geometria rotada (`can_be_stealth_finished_by` = true, ejecucion completa). |
| 79 | Backstab | Validar enemigos rotados. | Validado manualmente | 2026-07-16: `_facing_from_rotation()` corregido a `global_transform.basis.z` (antes mezclaba yaw local con posicion global); caso de prueba con `rotation.y = PI` confirmado en headless. |
| 80 | Backstab | Confirmar forward logico y visual. | Validado manualmente | 2026-07-16: confirmado logicamente (headless); confirmacion visual en editor sigue pendiente. |
| 81 | Backstab | Centralizar regla compartida. | Integrado | `BackstabRulesService.is_attacker_behind_target` ya centralizada; sin duplicacion encontrada. |
| 82 | Backstab | Ajustar distancia valida. | No iniciado | Sin evidencia de que la distancia actual (`stealth_finish_range = 2.2`) sea incorrecta; no se toco. |
| 83 | Backstab | Ajustar umbral angular. | No iniciado | Sin evidencia de que `stealth_behind_dot = 0.45` sea incorrecto; no se toco. |
| 84 | Backstab | Prevenir doble dano. | Integrado | Preexistente (guardas en 3 capas); ahora con un segundo camino de disparo (senal del animador) que pasa por la MISMA guarda `backstab_execution_damage_applied`, verificado headless. |
| 85 | Backstab | Cooldown o ventana de ejecucion. | Integrado | Preexistente; `backstab_execution_recovery_timer` y bloqueo de input durante ejecucion. |
| 86 | Backstab | Animacion base de ejecucion. | Validado manualmente | 2026-07-16: `trigger_stealth_finish_attack()` fuerza la pose de finisher (antes `trigger_attack(3, false)` caia silenciosamente al swing generico con un solo brazo equipado). Confirmacion visual en pantalla sigue pendiente. |
| 87 | Backstab | Reaccion del enemigo. | Integrado | Preexistente: `apply_stealth_finish_impact` llama `take_hit()` (flash + punch scale) o `die()`; confirmado por lectura de codigo, no se agrego nada nuevo. |
| 88 | Backstab | Sincronizar momento de impacto. | Validado manualmente | 2026-07-16: nueva senal `attack_impact_reached` del animador, emitida en la fase de golpe real; timer fijo queda como respaldo. Disparo de la senal confirmado en headless. |
| 89 | Backstab | Restaurar control tras ejecucion. | Validado manualmente | 2026-07-16: corregidos 2 bugs de freeze (jugador muere/pausa a mitad de ejecucion; objetivo liberado a mitad de ejecucion). Confirmado headless: `can_attack` se restaura correctamente en ambos casos. |
| 90 | Backstab | Fallback para enemigos incompatibles. | Integrado | Preexistente; rama `elif backstab_execution_target.has_method("take_damage")` en `_apply_backstab_impact_once` (defensivo, dificil de alcanzar en la practica). |
| 91 | Backstab | Documentar flujo final. | Integrado | `docs/combat_flow.md` actualizado 2026-07-16 con todos los fixes, evidencia runtime y pendientes de prueba manual explicitos. |
| 92 | Cuerpo jugador | Contrato de dano corporal. | No iniciado | Pendiente. |
| 93 | Cuerpo jugador | Perdida de partes. | No iniciado | Pendiente. |
| 94 | Cuerpo jugador | Partes permitidas. | No iniciado | Pendiente. |
| 95 | Cuerpo jugador | Penalizaciones por parte perdida. | No iniciado | Pendiente. |
| 96 | Cuerpo jugador | Recuperacion de partes. | No iniciado | Pendiente. |
| 97 | Cuerpo jugador | Tiempo de recogida. | No iniciado | Pendiente. |
| 98 | Cuerpo jugador | Feedback visual de perdida. | No iniciado | Pendiente. |
| 99 | Cuerpo jugador | Feedback sonoro de perdida. | No iniciado | Pendiente. |
| 100 | Cuerpo jugador | Integracion con inventario. | No iniciado | Pendiente. |
| 101 | Cuerpo jugador | Integracion con equipamiento. | No iniciado | Pendiente. |
| 102 | Cuerpo jugador | Integracion con animacion. | No iniciado | Pendiente. |
| 103 | Cuerpo jugador | Compatibilidad con slots corporales. | Integrado | 2026-07-16: seis slots canonicos integrados via `feat/inventory-equipment-ux-core`. |
| 104 | Cuerpo jugador | Compatibilidad con camara. | No iniciado | Pendiente. |
| 105 | Cuerpo jugador | Validacion de recuperacion. | No iniciado | Pendiente. |
| 106 | Enemigos | Variante rapida. | Parcial | Enemigos existentes; catalogacion pendiente. |
| 107 | Enemigos | Variante tanque. | Parcial | Enemigos existentes; catalogacion pendiente. |
| 108 | Enemigos | Variante crawler. | Parcial | Crawling documentado; runtime pendiente. |
| 109 | Enemigos | Variante lanzadora. | Parcial | Ranged/gorilla/lizard existen; auditoria pendiente. |
| 110 | Enemigos | Minijefes. | No iniciado | Pendiente. |
| 111 | Enemigos | Estado corporal enemigo. | Parcial | Limb detachment existe; consolidar reglas. |
| 112 | Enemigos | Perdida de brazos. | Parcial | Existe en drops/limbs; validar side-aware. |
| 113 | Enemigos | Perdida de piernas. | Parcial | Existe en drops/limbs; validar side-aware. |
| 114 | Enemigos | Perdida de torso. | Parcial | Existe parcialmente; validar. |
| 115 | Enemigos | Partes recuperables. | Parcial | Documentado; runtime pendiente. |
| 116 | Enemigos | Alertas grupales. | Parcial | Estado actual documentado; validar. |
| 117 | Enemigos | Ruido. | Parcial | Documentado en combate; validar. |
| 118 | Enemigos | Reaccion a muerte. | Parcial | Drops/eventos existentes; validar. |
| 119 | Enemigos | Drop inteligente. | Parcial | Servicios existentes; ampliar. |
| 120 | Enemigos | Claridad visual del drop. | Parcial | Pendiente UX. |
| 121 | Drops | Preservar slot canonico del drop. | Integrado | 2026-07-16: `DropPickupRulesService`/`EquipmentRulesService` ya usan los seis slots canonicos; `slot_for_bone` para huesos bilaterales ahora resuelve al primer lado libre en vez de forzar siempre el mismo lado (ver fila 43 del backlog original de equip-next). |
| 122 | Drops | Preservar lado de origen cuando aplique. | No iniciado | Pendiente. |
| 123 | Camara | Reproducir jitter. | Preparado | Validador diagnostico; runtime pendiente. |
| 124 | Camara | Aislar camara habilitada/deshabilitada. | No iniciado | Pendiente runtime. |
| 125 | Camara | Aislar rig procedural. | No iniciado | Pendiente runtime. |
| 126 | Camara | Comparar `_process` y `_physics_process`. | Integrado | Follow de camara movido a `_physics_process` (rama previa a esta sesion); 2026-07-16: confirmado que sigue coherente tras los merges posteriores (orden padre-antes-que-hijo intacto). Comportamiento sobre 60 FPS y relacion con `physics_interpolation` documentados en `docs/camera_flow.md`. |
| 127 | Camara | Corregir causa demostrada del jitter. | No iniciado | Pendiente causa. |
| 128 | Camara | Sensibilidad configurable. | No iniciado | Pendiente. |
| 129 | Camara | Invertir eje Y. | No iniciado | Pendiente. |
| 130 | Camara | Persistencia de controles. | No iniciado | Pendiente. |
| 131 | Camara | Modo crawler. | No iniciado | Pendiente. |
| 132 | Camara | Modo combate. | No iniciado | Pendiente. |
| 133 | Camara | Lock-on. | No iniciado | Pendiente. |
| 134 | Animacion | Animaciones por equipamiento. | No iniciado | Pendiente. |
| 135 | Animacion | Animacion de pickup. | No iniciado | Pendiente. |
| 136 | Animacion | Animacion de crawlers. | Parcial | Rig tiene estados; validar. |
| 137 | Animacion | Feedback sonoro. | No iniciado | Pendiente. |
| 138 | Animacion | Feedback visual. | Parcial | Algunos flashes existen; consolidar. |
| 139 | Animacion | Transiciones de ataque. | Parcial | Combo visual existe; validar. |
| 140 | Animacion | Transiciones de dano. | Parcial | Enemigos tienen feedback; validar. |
| 141 | Animacion | Transiciones de muerte. | Parcial | Enemigos tienen muerte/drops; validar. |
| 142 | Progresion | Arbol de mejoras. | No iniciado | Pendiente. |
| 143 | Progresion | NPC. | No iniciado | Pendiente. |
| 144 | Progresion | Mesa de ensamblaje. | No iniciado | Pendiente. |
| 145 | Mundo | Zonas por salto. | No iniciado | Pendiente. |
| 146 | Mundo | Zonas por escalada. | No iniciado | Pendiente. |
| 147 | Mundo | Zonas por alas. | No iniciado | Pendiente. |
| 148 | Mundo | Zonas por fuerza. | No iniciado | Pendiente. |
| 149 | Mundo | Pruebas por brazos. | Parcial | Trial gates existen; validar y ampliar. |
| 150 | Mundo | Pruebas por piernas. | Parcial | Trial gates existen; validar y ampliar. |
| 151 | Mundo | Pruebas por torso. | Parcial | Trial gates existen; validar y ampliar. |
| 152 | Mundo | Pruebas por cabeza. | Parcial | Trial gates existen; validar y ampliar. |
| 153 | Objetivos | ArenaGoalManager narrativo. | Parcial | Manager existe; ampliar narrativa. |
| 154 | Objetivos | Misiones. | Parcial | Tutorial/checklist existe; sistema formal pendiente. |
| 155 | Objetivos | Tutoriales. | Parcial | Tutorial flow existe; validar runtime. |
| 156 | Objetivos | Recompensas de arenas. | Parcial | Arena flow existe; validar. |
| 157 | Objetivos | Salida/portal de objetivo. | Parcial | Exit portal existe; validar. |
| 158 | Objetivos | Registro de progreso de demo. | Parcial | ArenaGoalManager; persistencia pendiente. |
| 159 | Mantenimiento | Actualizar docs por cambio funcional. | Parcial | Politica existe; aplicar por PR. |
| 160 | Mantenimiento | Ejecutar validadores por rama. | Parcial | Validadores existen; checklist por PR. |
| 161 | Mantenimiento | Revisar caches por rama. | Preparado | Politica documentada. |
| 162 | Mantenimiento | Revisar conflictos por rama. | Preparado | Preflight documentado. |
| 163 | Mantenimiento | Mantener commits pequenos. | Preparado | Politica documentada. |
| 164 | Mantenimiento | Registrar decisiones arquitectonicas. | Preparado | Docs de flujo y politica. |
| 165 | Mantenimiento | Refrescar roadmap tras grupos de ramas integradas. | Integrado | 2026-07-16: este archivo refrescado tras integrar 9 ramas en `origin/develop`; `docs/roadmap_progress.md` actualizado con la tabla de ramas. Sigue siendo un proceso manual, no automatizado. |

## docs/roadmap_progress.md

# Roadmap Progress

Fecha base: 2026-07-15. Ultima actualizacion: 2026-07-16.

Este archivo mantiene una tabla operativa de lotes pequenos para MARROW. Su
objetivo es que cada cambio tenga rama, evidencia y estado verificable sin
tocar `main` directamente.

## Reglas De Seguimiento

- Cada lote debe vivir en una rama dedicada desde `origin/main`.
- Evitar mezclar runtime, UI, datos y documentacion salvo que el cambio lo
  requiera.
- Preferir lotes de bajo conflicto antes de tocar hotspots como
  `scripts/player.gd`, `scripts/enemy.gd`, `scripts/player_inventory_ui.gd`,
  `scripts/rig/procedural_player_animator.gd`, `scripts/rig/modular_skeleton_rig.gd`,
  `scenes/main.tscn` o `project.godot`.
- Registrar validacion real. Si algo no se ejecuto, dejarlo como pendiente.
- Abrir PR en borrador cuando el lote este listo para revision.

## Estado De Lotes

| Fecha | Rama | Tipo | Objetivo | Estado | Evidencia | Pendiente |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-07-15 | `docs/qa-validation-baseline` | Docs / QA | Crear checklist manual y tablero de seguimiento para futuros lotes. | Integrado en `main`; validado estaticamente. | Incluido por la cascada de integracion; `git diff --check`; revision documental. | Ejecutar checklist manual dentro de Godot. |
| 2026-07-15 | `chore/data-bone-validator` | Tools / Datos | Validar integridad de definiciones de huesos y compatibilidad del catalogo. | Integrado en `main`; validado estaticamente. | PR #1; `python -B tools\validate_bone_data.py` OK. | Ejecutar flujo manual de pickups/equipamiento con datos reales. |
| 2026-07-15 | `test/p0-backstab-validation` | Tools / Combate | Cubrir casos de backstab frente, detras, laterales y enemigos rotados sin tocar IA general. | Integrado en `main`; validado estaticamente. | PR #2; `python -B tools\validate_backstab_geometry.py` OK. | Confirmar manualmente en `scenes/testing_environment.tscn` o escena equivalente. |
| 2026-07-15 | `test/p0-preview-validation` | Tools / Preview | Registrar contrato estatico del preview de inventario sin reconstruir `SubViewport` ni `World3D`. | Integrado en `main`; validado estaticamente. | PR #3; `python -B tools\validate_inventory_preview_contract.py` OK. | Validar render, equip/unequip y lifecycle dentro de Godot. |
| 2026-07-15 | `test/p0-jitter-diagnostics` | Tools / Camara / Rig | Diagnosticar contrato de actualizacion de movimiento, camara y rig sin aplicar correccion especulativa. | Integrado en `main`; validado estaticamente con advertencias. | PR #3; `python -B tools\validate_jitter_update_contract.py` OK; advierte hipotesis runtime no demostradas. | Reproducir jitter en runtime antes de cualquier fix. |
| 2026-07-15 | `test/inventory-stack-contract` | Tools / Inventario | Validar que el inventario oculte solo las copias equipadas y conserve duplicados visibles. | Integrado en `main`; validado estaticamente. | PR #3; `python -B tools\validate_inventory_stack_contract.py` OK. | Probar abrir inventario, recoger duplicados y equipar/desequipar en juego. |
| 2026-07-15 | `feature/inventory-stack-count` | UI / Inventario | Mostrar cantidades `xN` agrupando duplicados visibles sin cambiar payload de drag and drop. | Integrado en `main`; validado estaticamente. | PR #3; `python -B tools\validate_inventory_stack_count.py` OK. | Confirmar layout responsive y comportamiento drag/drop en runtime. |
| 2026-07-15 | `integration/marrow-validation-cascade` | Integracion | Juntar lotes de validacion en cascada y limitar Graphify Actions a `main` y `develop`. | Integrado en `main`; remoto de ramas de trabajo ya podado. | PR #3; `45be471` incluido en `origin/main`; Graphify limitado por workflow. | Monitorear checks de GitHub y ejecutar QA manual post-merge. |
| 2026-07-15 | `chore/repo-stability-and-graphify` | Repo / CI / Docs | Definir politica de Graphify, line endings y fuente auditable del roadmap 1-165. | Integrado en `develop`; validado estaticamente. | `.gitattributes`, `docs/repo_stability_and_graphify.md`, `docs/roadmap_1_165.md`; merge a `develop`. | Abrir PR `develop` hacia `main` solo despues de validar la cascada completa. |
| 2026-07-16 | `chore/repo-stability-and-graphify` | Repo / CI | Cerrar el pendiente de `.gitignore` para el output anidado accidental de Graphify. | Integrado en `develop`. | `.gitignore` actualizado; verificado que 0 archivos requerian renormalizacion (`git ls-files --eol`). | Ninguno. |
| 2026-07-16 | `test/p0-runtime-validation-suite` | Tools / QA | Convertir la guia P0 en un flujo de registro PASS/FAIL/observado/evidencia. | Integrado en `develop`. | Teclas O/P/F en `testing_environment.gd`; log en `user://p0_validation_log.txt`; verificado headless (Godot 4.7, escena real corre 60 frames sin error tras warmup de cache de clases). | Ejecucion manual interactiva de las teclas O/P/F (headless no simula input). |
| 2026-07-16 | `feat/bone-stats-quality-and-weight` | Datos / Stats | Corregir orden de redondeo, exponer claves sin consumidor, documentar unidades. | Integrado en `develop`. | Fix de `aggregate_player_bonuses` (sumar floats, redondear una vez); `get_inventory_stats_snapshot` expone weight/quality; verificado headless con datos reales de hueso. | Ninguno. |
| 2026-07-16 | `fix/inventory-preview-stability` | Inventario / Preview | Corregir orden del snapshot y eliminar resize manual redundante. | Integrado en `develop`. | `sync_preview` cachea solo tras aplicar con exito; `_sync_preview_viewport_size` eliminado (redundante bajo `stretch=true`); verificado headless, escena corre sin error. | Pruebas manuales de render (equipar/desequipar, reapertura, resoluciones). |
| 2026-07-16 | `fix/player-camera-movement-stability` | Camara | Documentar comportamiento sobre 60 FPS y examinar escrituras directas de `global_position`. | Integrado en `develop`. | Documentacion agregada; asimetria encontrada entre detach (compensado) y reattach (sin compensar) de torso/cabeza, registrada sin corregir. | Confirmar/descartar jitter con un humano jugando; QA runtime del reattach. |
| 2026-07-16 | `feat/inventory-equipment-ux-core` | Inventario / Equipamiento | Corregir bug de piernas, limpiar aliases, agregar comparador/deltas/feedback de drag. | Integrado en `develop`. | Bug real de equip-next (siempre `right_leg`) corregido; bug de tipado de GDScript encontrado y corregido de paso; verificado headless: `{"left_leg": "leg_bone", "right_leg": "leg_bone"}`. | Ninguno de lo especificado; UI en ingles ya consistente. |
| 2026-07-16 | `feat/inventory-build-presets` | Inventario / Builds | Implementar aplicacion transaccional real con rollback. | Integrado en `develop`. | Snapshot previo + reaplicacion si falla la verificacion post-apply; bug preexistente de compilacion (`display_name` inexistente) encontrado y corregido; verificado headless en 5 escenarios (valido, vacio, pieza ausente, slot incompatible, rollback forzado). | Ninguno. |
| 2026-07-16 | `feat/bone-durability-mutations-and-synergies` | Datos | Elegir Ruta A (esquema de datos puro) y documentar honestamente el alcance. | Integrado en `develop`. | Cero llamadores externos confirmado por grep; validador y docs corregidos para no sugerir funcionalidad runtime. | Ruta B (runtime real) queda para una rama futura si se decide implementarla. |
| 2026-07-16 | `fix/combat-backstab-stability` | Combate | Corregir freeze, animacion faltante, sincronizacion de impacto. | Integrado en `develop`. | 2 bugs de freeze corregidos (muerte/pausa a mitad de ejecucion; objetivo liberado a mitad de ejecucion); pose de finisher forzada; senal de impacto del animador; verificado headless con jugador y enemigo reales. | Pausa real en editor (mismo codigo que muerte, no ejercido); confirmacion visual de pose/reaccion/camara. |

## Backlog Tecnico Inmediato

| Prioridad | Sistema | Lote sugerido | Riesgo | Validacion minima |
| --- | --- | --- | --- | --- |
| P0 | Git / proceso | Mantener trabajo de Codex fuera de `main` con ramas por lote. | Bajo | `git status --short --branch` antes y despues. |
| P0 | QA | Ejecutar este checklist en `scenes/testing_environment.tscn` antes de PRs funcionales. | Bajo | Evidencia manual por escena y resolucion. |
| P1 | Combate | Revisar backstab con casos frente/lateral/detras antes de cambiar reglas. | Medio | Dummy/enemigo activo, posiciones controladas, sin cambios especulativos. |
| P1 | Movimiento / camara | Reproducir jitter o head movement antes de parchear. | Medio | Video o pasos exactos, escena y estado del jugador. |
| P1 | Rig / preview | Verificar sincronizacion entre jugador y preview antes de tocar sockets. | Medio | Equip/unequip torso, brazos y piernas en inventario. |
| P2 | Datos de huesos | Migrar mas definiciones a `.tres` sin romper `BoneDatabase`. | Medio | Cache reload, inventario, drops y equipamiento. |
| P2 | Docs | Actualizar flujo afectado con cada cambio funcional. | Bajo | `docs/flow_index.md` apunta al flujo correcto. |

## Plantilla De Lote

```text
Fecha:
Rama:
Tipo:
Objetivo:
Archivos previstos:
Riesgo:
Validacion:
Resultado:
PR:
Pendientes:
```

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

