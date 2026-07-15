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
