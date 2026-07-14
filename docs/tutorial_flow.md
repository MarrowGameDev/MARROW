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
