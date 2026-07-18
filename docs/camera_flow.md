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
