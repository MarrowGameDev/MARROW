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
