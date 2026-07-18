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
