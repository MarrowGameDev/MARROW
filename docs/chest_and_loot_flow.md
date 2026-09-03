# Flujo de cofres y tablas de loot

Este documento describe como un contenedor decide que entrega, cuando puede
abrirse y como esas piezas llegan al jugador.

## Objetivo del sistema

Un cofre debe ser una escena colocable, reutilizable y sin reglas propias de
contenido. Que sale de el es dato autorable; cuando se abre es una regla de la
escena; y la pieza que produce es indistinguible de una que solto un enemigo.

## Scripts, escenas y datos principales

- `scripts/loot_table_definition.gd`: `Resource` con una tabla autorada.
- `data/loot_tables/*.tres`: las siete tablas actuales, una por banda del mapa.
- `scripts/loot_table_service.gd`: reglas de tirada. Puro, sin estado de escena.
- `scenes/chest.tscn` + `scripts/chest.gd`: el contenedor (`LootChest`).
- `scripts/demo_enemy_camp.gd`: compone un `LootChest` con lock externo.
- `scripts/bone_instance_service.gd`: crea la pieza y fija su calidad.
- `scenes/bone.tscn`: el pickup que se instancia con `SPAWN_PICKUPS`.
- `scripts/drop_pickup_rules_service.gd`: hold-to-interact compartido.

## Eventos usados

- `GameEvents.chest_state_changed(chest, chest_id, unlocked, opened)`.
- `GameEvents.chest_opened(chest, chest_id, contents, player)`. `contents` son
  `instance_id`, no `bone_id`: cuando el cofre se anuncia abierto las piezas ya
  existen y ya tienen calidad.
- `GameEvents.drop_spawned(instance_id, pickup, chest)` por cada pickup creado.
- `GameEvents.camp_chest_opened(camp, reward_bone_id, player)` se sigue
  emitiendo para compatibilidad. No tiene consumidores hoy.
- `GameEvents.trial_completed` es lo que escucha un cofre con `lock_mode = TRIAL`.

## De donde salen los pesos

El peso de un hueso vive en el hueso, no en la tabla:
`BoneRulesService.rarity_drop_weight_for` resuelve tanto huesos autorados en
`data/bones/*.tres` como limbs generados de enemigos (`gorilla_left_arm_bone`),
asi que una tabla puede mezclar ambos sin saber la diferencia.

Este sistema es el primer consumidor real de `rarity_drop_weight` y de
`quality_drop_percent`. Antes eran campos autorados que nadie leia.

- `rarity_drop_weight` -> probabilidad relativa dentro de la tabla.
- `quality_drop_percent` -> sesgo de calidad del hueso, que se suma al
  `quality_bias` de la tabla.
- `weight_overrides` en la tabla es la excepcion, no la norma: solo para cuando
  una tabla concreta quiere otro enfasis.

`head_bone` tiene peso 0.0 y por eso el nucleo fijo nunca puede caer.

## Sesgo de calidad

`BoneQualityService.roll_quality_id_biased(bias)` inclina la escalera de
calidad. Un `bias` de +0.2 hace cada peldano un 20% mas probable que el de
abajo; Normal es siempre el pivote. El limite es `QUALITY_BIAS_LIMIT` (0.75),
el mismo `+-75%` que ya usa `BoneRulesService.PLAYER_STAT_PERCENT_LIMIT`.

Un `bias` de 0.0 delega en `roll_quality_id()`. Eso es deliberado: la ruta sin
sesgo tiene una sola implementacion, asi que las tablas de loot no pueden
separarse del comportamiento de drops que ya existia.

## Flujo de apertura

1. El jugador entra al `InteractArea` del cofre.
2. El cofre reserva el lock de interact del jugador (`enter_interact_range`).
3. Mientras se mantiene interact, el progreso lo calcula
   `DropPickupRulesService`, el mismo servicio que usan los pickups.
4. Al completar el hold, `LootChest.open()`:
   1. `LootTableService.roll_loot()` decide `[{bone_id, quality_id}]`.
   2. Por cada entrada, `BoneInstanceService.create_instance(bone_id, quality_id)`
      crea la pieza. Aqui, y solo aqui, la pieza empieza a existir.
   3. Segun `delivery_mode`, las piezas van al inventario o se instancian como
      pickups en un anillo alrededor de `LootSpawnPoint`.
   4. Se emite `chest_opened` y `chest_state_changed`.
5. El cofre libera el lock de interact y deja de procesar.

## Modos de bloqueo

| `lock_mode` | Quien lo abre | Uso |
| --- | --- | --- |
| `NONE` | Nadie, esta abierto | Cofres de exploracion por region |
| `EXTERNAL` | Otro sistema llama `unlock()` | `DemoEnemyCamp` al limpiar enemigos |
| `TRIAL` | `trial_completed` con `required_trial_id` | Recompensa detras de un gate |
| `EQUIPPED_BONE` | Tener `required_bone_id` equipado | Mismo contrato que `BoneTrialGate` |

`EQUIPPED_BONE` se evalua en vivo, no se fija: desequipar la pieza vuelve a
cerrar el cofre, igual que un gate vuelve a bloquear.

## Modos de entrega

- `SPAWN_PICKUPS` (default): instancia `scenes/bone.tscn` por pieza, con el
  mismo camino que usa `Enemy._drop_standard_bone_pickup`. Refuerza el flujo de
  pickup que el jugador ya conoce y no necesita UI nueva.
- `DIRECT_TO_INVENTORY`: llama `player.collect_bone` por pieza. Para
  recompensas que no pueden perderse.

## El handoff entre abrir y recoger

Este es el punto mas delicado de todo el sistema, y produjo un bug real: el
jugador abria un cofre y el loot "no aparecia".

Tres reglas lo sostienen, y las tres importan:

1. **Pulsacion fresca obligatoria.** El mismo hold que abre el cofre sigue
   apretado cuando las piezas caen al suelo. Sin regla, el pickup recien nacido
   contaba esa pulsacion como propia y se auto-recogia antes de ser visible.
   `DropPickupRulesService.next_fresh_press_latch` define la regla una sola vez;
   la usan `bone.gd`, `limb_bone_pickup.gd` y `chest.gd`. Tambien arregla el
   caso analogo de matar un enemigo con interact mantenido.
2. **El loot cae hacia quien abrio.** El anillo de spawn se orienta al jugador
   (`SPAWN_TOWARD_OPENER`). Antes salia siempre hacia el +Z local del cofre, asi
   que segun por donde llegaras el loot quedaba detras de la caja.
3. **El cofre dice que dio.** El label nombra las piezas mientras el jugador
   sigue ahi, y emite `tutorial_hint_requested` para el aviso en pantalla.
   Antes decia solo "Empty", indistinguible de un cofre realmente vacio. Una vez
   que el jugador se aleja el label pasa a "Already opened".

`Player.nearby_bone_pickups` existe y se incrementa/decrementa, pero **nadie lo
lee**: no sirve como exclusion entre interactuables. No confiar en el.

## Camps

`DemoEnemyCamp` ya no dibuja ni maneja un cofre. Instancia `chest.tscn` con
`lock_mode = EXTERNAL` y conserva una sola responsabilidad: contar enemigos
vivos y llamar `unlock()` / `lock()`.

- `reward_bone_id` sigue funcionando: se convierte en una tabla de un item via
  `LootTableService.single_bone_table`, asi que pasa por la misma tirada que
  todo lo demas.
- `loot_table_id` es lo preferido para camps nuevos y tiene prioridad.
- El camp espeja el estado de su cofre escuchando `chest_state_changed`. El
  cofre es la unica fuente de verdad de si la recompensa fue reclamada.

## Persistencia

Ver `docs/save_flow.md`. Lo relevante aqui: cada cofre colocado necesita un
`chest_id` unico. Sin el no puede guardarse y su loot reaparece en cada carga.
`tools/headless_world_chests_check.gd` falla si un cofre no tiene id o si dos
comparten uno.

## Puntos delicados

- El servicio decide QUE sale; el cofre decide CUANDO existe. No mover
  `create_instance` dentro de `LootTableService` o la calidad dejaria de rodarse
  una sola vez en un punto unico.
- No duplicar el hold prompt. Si un contenedor nuevo necesita hold, usar
  `DropPickupRulesService` como hacen `bone.gd`, `limb_bone_pickup.gd` y este
  cofre.
- No leer `BoneDatabase` ni `BoneDefinition` directamente desde una tabla o un
  cofre. Todo pasa por `BoneRulesService`.
- Al agregar una tabla hay que registrarla en `TABLE_PATHS` **y** en
  `TABLE_ORDER`. El orden explicito es lo que hace que una semilla reproduzca
  una secuencia; `validation_report()` avisa si falta en cualquiera de los dos.

## Como probar

Headless:

```text
godot --headless --path . --script tools/headless_loot_table_check.gd
godot --headless --path . --script tools/headless_chest_check.gd
godot --headless --path . --script tools/headless_camp_chest_check.gd
godot --headless --path . --script tools/headless_world_chests_check.gd
godot --headless --path . --script tools/headless_chest_handoff_check.gd
```

`headless_chest_handoff_check.gd` es el unico que conduce un jugador real en
`main.tscn` con la accion de interact real. Es el unico nivel al que el bug del
handoff se reproduce: llamar `chest.open()` directo nunca toca la ruta de input
donde vive.

No hay validador Python para tablas a proposito: las reglas de "tabla valida"
viven en `LootTableDefinition.validation_errors()`, y un parser que no puede
resolver limbs generados de enemigos seria una segunda fuente de verdad.

En las escenas de prueba (`testing_environment.tscn` y
`dummy_testing_environment.tscn`) hay tres cofres: `TestChestOpen`,
`TestChestDirect` y `TestChestGated`. Cubren los dos modos de entrega y el
bloqueo por pieza equipada, y como esas escenas no tienen `SaveCoordinator`
vuelven a estar cerrados en cada recarga con R.

Manual, en `scenes/main.tscn`:

1. Abrir el cofre del hub y confirmar que salen pickups fisicos.
2. Recoger uno y confirmar que entra al inventario con su calidad.
3. Limpiar un camp y confirmar que el cofre pasa de marron a dorado.
4. Pasar un trial gate y confirmar que su cofre se desbloquea.
5. Reabrir un cofre ya vaciado y confirmar que no da nada.

## Historial de cambios

- 2026-08-04: Sistema creado. Tablas de loot como `Resource`, cofre como escena
  reutilizable, `DemoEnemyCamp` refactorizado para componerlo, y primer
  consumidor real de `rarity_drop_weight` / `quality_drop_percent`.
- 2026-08-04 (correccion, reportado desde juego): "los cofres no dropean items".
  El loot SI se generaba; el hold que abria el cofre se lo comia. Tres arreglos:
  regla de pulsacion fresca en `DropPickupRulesService`, spawn orientado a quien
  abre, y label/aviso que nombra las piezas en vez de decir "Empty". Cubierto
  por `tools/headless_chest_handoff_check.gd`, que conduce un jugador real con
  input real.
