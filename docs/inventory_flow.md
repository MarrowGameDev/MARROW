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
