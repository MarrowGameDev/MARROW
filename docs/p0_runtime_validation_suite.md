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
