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
`BoneDefinition` Resources creados desde `BoneDataCatalog`, que usa una
estructura mas limpia:

- `identity`: nombre, rareza, color, slot, tags y descripcion.
- `player_stats`: bonuses que ve el jugador al equipar.
- `enemy_stats`: bonuses que usan enemigos y perfiles de combate.
- `visual`: datos opcionales para escala/peso visual.

No conectar la UI directamente a `BoneDefinition` ni `BoneDataCatalog` todavia.
Esa capa existe para preparar una migracion futura a `.tres`, JSON o una tabla
exportada.

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
