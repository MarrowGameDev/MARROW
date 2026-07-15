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

La escena muestra un panel con enemigos activos, controles de spawn y una guia
P0 por seccion. Usa:

- `F1`: siguiente guia P0.
- `F2`: guia P0 anterior.
- `1`: enemigo normal.
- `2`: gorilla.
- `3`: lizard.
- `4`: ranged.
- `5`: dummy pasivo.
- `Backspace`: eliminar el ultimo enemigo.
- `R`: reiniciar la escena.
- `Esc`: volver al menu.

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

Cada pasada debe terminar con una evidencia corta:

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
validadores estaticos y dejar esta guia lista para una pasada manual en editor.
