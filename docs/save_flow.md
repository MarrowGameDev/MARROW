# Flujo de guardado

Este documento describe que se guarda, en que orden se restaura y por que ese
orden es un contrato y no una preferencia.

## Objetivo del sistema

Una partida debe poder cerrarse y reabrirse sin que el jugador pierda piezas,
sin que una calidad cambie, y sin que un cofre ya vaciado vuelva a dar loot.

## Scripts principales

- `scripts/save_service.gd`: lee y escribe el archivo, y conoce el orden de
  reconstruccion. No tiene estado de escena ni guarda referencias.
- `scripts/save_coordinator.gd`: nodo que decide CUANDO se guarda y encuentra al
  jugador. Va en escenas jugables.
- `scripts/bone_instance_service.gd`: `serialize()` / `restore()` del registro
  de piezas. Existian desde antes; este sistema es su primer consumidor.
- `scripts/player_inventory_component.gd`: `restore_items`.
- `scripts/player_equipment_component.gd`: `apply_equipment_state`.
- `scripts/chest.gd`: `restore_state`.
- `scripts/bone_trial_gate.gd`: `restore_completed_state`.

## Archivo

`user://marrow_save.json`, JSON con indentacion. `SaveService.SAVE_VERSION`
gobierna la compatibilidad: una version que no se entiende se **rechaza
entera**, no se aplica a medias. Un archivo corrupto se trata igual que si no
existiera, porque rechazar es recuperable y aplicar a medias no.

## Que se guarda

| Clave | Contenido | Por que |
| --- | --- | --- |
| `instances` | `BoneInstanceService.serialize()` | Identidad y calidad de cada pieza |
| `inventory` | Array de `instance_id` | Lo que el jugador carga |
| `equipment` | slot -> `instance_id` | Lo que lleva puesto |
| `world.chests` | `[{id, unlocked, opened}]` | Contenedores vaciados y desbloqueados |
| `world.trials` | Array de `trial_id` | Pruebas superadas |
| `world.enemies` | `[{key, alive, health, position, yaw, detached_limbs}]` | Quien sigue vivo, herido o desmembrado |
| `player` | Vida y posicion | Donde estaba y como estaba |
| `rng.loot_state` | Posicion del RNG de loot | Que cargar no repita las mismas tiradas |

El multiplicador de calidad **no** se guarda: se deriva de `quality_id` a traves
de `BoneQualityService`, asi que retocar la tabla retoca todas las piezas ya
existentes. Esa es una decision de `BoneInstanceService` que este sistema
respeta.

Los presets de build **no** estan aqui a proposito. Ya persisten aparte y
correctamente en `user://equipment_builds.cfg`, y son una preferencia del
jugador que deberia sobrevivir a empezar una partida nueva.

## Orden de restauracion

Esto es el contrato del sistema. Invertir dos pasos cualesquiera deja al jugador
llevando piezas que no existen.

1. **`instances`**. Todo lo de abajo son ids dentro de este registro.
2. **`inventory`** via `restore_items`. Deliberadamente NO es `collect_bone` en
   bucle: recolectar anuncia un pickup y, para un `bone_id` plano, crea una
   pieza NUEVA con una tirada de calidad nueva. Una restauracion resucita las
   piezas que el jugador ya tenia.
3. **`equipment`** via `apply_equipment_state`, que aplica en `APPLY_ORDER`:
   torso antes que extremidades, porque `TORSO_REQUIRED_SLOTS` no puede
   engancharse sin el.
4. **Mundo**: enemigos primero, luego recuento de camps, luego cofres y trials.
   Ese orden importa: un camp que recuenta antes de que sus enemigos esten
   restaurados desbloquearia un cofre que el jugador no gano.
5. **RNG**.

`apply()` devuelve un reporte con lo aplicado y lo que no pudo aplicarse, para
que el llamador informe en vez de adivinar.

## Ids desconocidos

Un `instance_id` guardado que ya no existe en el registro se descarta del
inventario en vez de conservarse: una pieza sin instancia se veria como un tile
sin nombre y podria equiparse sin dar stats. `SaveCoordinator` avisa por
`push_warning` cuando eso pasa, porque el silencio pareceria una carga correcta
con equipo faltante.

## Cofres y trials

Un trial restaurado **no** emite `trial_completed`. Ese evento significa "el
jugador acaba de lograrlo", y cualquier cosa que lo escuche (un cofre bloqueado
por trial, un paso de tutorial) volveria a dispararse en cada carga.

Como consecuencia, el estado `unlocked` de un cofre se guarda junto a `opened`.
Sin eso, un cofre que el jugador se gano pasando un trial quedaria cerrado para
siempre despues de cargar.

`EXTERNAL` es la excepcion: otro sistema en la escena posee ese desbloqueo y lo
re-deriva de estado vivo (un camp cuenta sus enemigos). Dejar que el save lo
pisara pondria a los dos fuera de sincronia, asi que en ese modo solo se honra
`opened`.

Los camps no tienen entrada propia en el save: su cofre de recompensa es un
`LootChest` como cualquier otro y ya esta en el grupo `loot_chests`. El camp
espeja el estado por `chest_state_changed`.

## Cuando se guarda

**Guardado manual por defecto.** El autoguardado esta apagado
(`SaveCoordinator.autosave_enabled = false`). Autoguardar en cada cofre y cada
trial hacia imposible repetir una corrida limpia: conservabas el progreso pero
los enemigos volvian, lo cual se lee como un mundo inconsistente, no como una
funcion. Un arranque nuevo empieza de cero salvo que el jugador pida continuar.

Lo que el jugador controla:

- Boton **SAVE** en juego (esquina inferior izquierda), construido por
  `SaveCoordinator` con el mismo estilo DIY que el resto de la UI.
- Boton **NEW GAME** en juego: borra el archivo y recarga la escena, para que
  "partida nueva" signifique lo mismo que un primer arranque.
- **CONTINUE** en el menu principal, deshabilitado cuando no hay nada que
  cargar. Es la unica ruta que carga una partida. **NEW RUN** siempre arranca
  limpio.

`SaveCoordinator.load_requested_on_start` es `static` porque
`change_scene_to_file` destruye el menu que puso la peticion.

Si se enciende `autosave_enabled`, los disparadores son puertas de un solo
sentido: `chest_opened`, `trial_completed` y cierre de ventana. Matar enemigos y
recoger pickups nunca autoguardan: pasan constantemente.

## Enemigos y el registro de bajas

Un enemigo muerto **sigue muerto** al cargar. Dos casos, y hacen falta los dos:

- El que respawnea queda en el arbol (oculto, sin colision, fuera del grupo
  `enemies`), asi que puede describirse a si mismo. Al restaurarse muerto vuelve
  a esperar su respawn como lo habria hecho.
- El que NO respawnea hace `queue_free()` al morir, asi que a la hora de guardar
  ya no existe para ser consultado. `SaveCoordinator` anota su clave al recibir
  `enemy_defeated` -- el unico momento en que todavia se puede identificar -- y
  se la pasa a `SaveService.capture` como `defeated_keys`. Sin esto volveria
  vivo, que es justo la inconsistencia que el estado del mundo debe evitar.

La clave de un enemigo es su ruta bajo la raiz del mundo
(`SaveService.enemy_save_key`). Renombrar un enemigo en el editor le hace perder
su estado guardado; la alternativa era un id autorado por enemigo mas un
validador de unicidad.

`restore_save_state` es **silencioso**: no emite `enemy_defeated`, no suelta
loot, no desprende miembros y no reproduce el pop de muerte. Repetir cualquiera
de esas cosas al cargar le daria al jugador un segundo juego de drops y
volveria a disparar cada desbloqueo de camp.

Los camps recuentan (`DemoEnemyCamp.refresh_state`) despues de restaurar
enemigos y antes de restaurar cofres. Al reves, un camp desbloquearia un cofre
que el jugador no gano.

**No se guarda a proposito**: restos de miembros desprendidos, proyectiles en
vuelo, temporizadores de IA y estado de busqueda. Son momentaneos, y
restaurarlos dejaria a un enemigo congelado a mitad de windup apuntando a un
jugador que ya no esta ahi.

Al arrancar, el coordinador espera un frame antes de cargar. Los constructores
del mundo (`tutorial_island_builder`, los camps) crean sus nodos durante
`_ready`, asi que antes de ese frame no hay nada en los grupos de cofres.

## Escenas de prueba

Las escenas de sandbox (`testing_environment.tscn`,
`dummy_testing_environment.tscn`) **no** llevan `SaveCoordinator`, para que una
sesion de pruebas no pueda pisar una partida real. `SaveService.set_save_path`
existe como hook de test por la misma razon.

Ambas incluyen tres cofres, uno por modo que la demo no puede mostrar lado a
lado: `TestChestOpen` (sin bloqueo, suelta pickups), `TestChestDirect`
(entrega directa al inventario) y `TestChestGated` (exige un Arm Bone equipado,
para confirmar que el bloqueo sigue equipar y desequipar en vivo). Como no hay
coordinador, se reinician con R y nunca tocan un archivo.

## Puntos delicados

- Cada cofre colocado necesita `chest_id` unico. Sin el no se guarda y su loot
  reaparece.
- `SaveService` no debe adquirir referencias a nodos. Recibe jugador y raiz de
  mundo por parametro; quien los encuentra es `SaveCoordinator`.
- Si se agrega un sistema persistente nuevo, exponer un `restore_*` explicito y
  silencioso en el propio nodo en vez de reconstruir su estado desde eventos.

## Como probar

```text
godot --headless --path . --script tools/headless_save_roundtrip_check.gd
godot --headless --path . --script tools/headless_world_chests_check.gd
```

El roundtrip cubre: piezas con calidades mezcladas, un set equipado, un cofre
vaciado, un trial superado, borrado total de memoria, recarga, y comparacion
pieza por pieza mas los stats derivados. Ademas verifica que una version futura
y un archivo corrupto se rechazan, y que cargar dos veces es idempotente.

Manual:

1. Recoger piezas, equipar un set, abrir un cofre.
2. Cerrar el juego y reabrir.
3. Confirmar inventario, equipo y calidades identicos.
4. Confirmar que el cofre abierto sigue vacio.

## Historial de cambios

- 2026-08-04: Sistema creado. Estrena `BoneInstanceService.serialize/restore`,
  que existian sin llamador desde su implementacion.
- 2026-08-04 (cambio de politica, pedido desde juego): autoguardado apagado por
  defecto; guardar pasa a ser una decision del jugador via botones SAVE / NEW
  GAME en juego y CONTINUE en el menu. Se agrego estado de enemigos al save,
  incluyendo el registro de bajas para los que se liberan al morir.
