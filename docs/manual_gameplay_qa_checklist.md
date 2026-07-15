# Manual Gameplay QA Checklist

Fecha base: 2026-07-15

Este checklist define una pasada manual repetible para validar que MARROW sigue
jugable despues de cambios pequenos. No reemplaza pruebas automatizadas ni una
revision en Godot; sirve para dejar evidencia consistente antes de abrir o
cerrar un PR.

## Alcance

- Escena principal y menu.
- Movimiento, camara y estados basicos del jugador.
- Inventario, equipamiento y preview.
- Pickups, drops y recuperacion de huesos.
- Combate cuerpo a cuerpo, rango, backstab y enemigos.
- Rig modular y progresion visual del cuerpo.
- Layout de UI en resoluciones comunes.

## Preflight

1. Confirmar rama de trabajo:
   - `git status --short --branch`
   - La rama no debe ser `main` para cambios de Codex.
2. Confirmar que no hay conflictos:
   - `git diff --name-only --diff-filter=U`
3. Confirmar higiene de diff:
   - `git diff --check`
4. Confirmar si Godot CLI esta disponible:
   - `godot --version`
   - `godot4 --version`

Si Godot no esta disponible en terminal, registrar que la validacion runtime
queda pendiente en editor.

## Arranque

1. Abrir `project.godot`.
2. Ejecutar desde `scenes/main_menu.tscn`.
3. Entrar al demo jugable.
4. Volver al menu si existe flujo de regreso.
5. Entrar a `scenes/testing_environment.tscn` desde el menu.

Resultado esperado:
- El menu carga sin errores visibles.
- El demo y la escena de prueba cargan sin bloqueo.
- No aparecen errores nuevos de scripts o nodos faltantes en la consola.

## Movimiento Y Camara

Validar en demo y en testing environment:

1. Movimiento en todas las direcciones.
2. Movimiento relativo a la camara.
3. Salto o movimiento especial disponible en el estado actual.
4. Rotacion de camara con mouse.
5. Colision de camara contra geometria cercana.
6. Pausa o apertura de inventario libera/captura el mouse segun corresponda.
7. Ataque o animacion no provoca desplazamiento involuntario persistente.

Resultado esperado:
- El jugador mantiene control despues de atacar, abrir inventario y cerrar
  inventario.
- No hay jitter persistente de camara o cuerpo en reposo.
- No hay teletransportes ni hundimiento en geometria.

## Inventario, Equipamiento Y Preview

1. Abrir inventario.
2. Cambiar entre pestanas o filtros disponibles.
3. Seleccionar un hueso y revisar panel de detalle.
4. Equipar una pieza compatible.
5. Desequipar una pieza.
6. Intentar equipar una pieza incompatible si existe una disponible.
7. Confirmar que la pieza equipada no se duplica en la grilla de inventario.
8. Confirmar que copias duplicadas validas siguen listadas como copias
   separadas.
9. Revisar que el preview se mantiene dentro de su viewport.
10. Cerrar inventario y verificar que gameplay retoma control normal.

Resultado esperado:
- La UI delega validaciones a los sistemas de equipamiento.
- El preview no aparece en el mundo jugable.
- No hay texto cortado en controles principales.
- El estado equipado coincide con el rig visible.

## Pickups, Drops Y Huesos

1. Spawnear o encontrar pickups.
2. Recoger un pickup valido.
3. Confirmar que aparece en inventario.
4. Derrotar o danar un enemigo hasta provocar drop si la escena lo permite.
5. Recoger el drop.
6. Revisar que nombre, slot y rareza/calidad se muestran de forma coherente.

Resultado esperado:
- Los pickups no se duplican al recogerlos.
- El inventario se actualiza sin abrir/cerrar forzado.
- Los nombres de drops son slot-aware cuando aplica.

## Combate Y Enemigos

1. Atacar a un dummy o enemigo cuerpo a cuerpo.
2. Confirmar cooldown y feedback visual.
3. Recibir dano de un enemigo activo.
4. Validar muerte o estado bajo vida si aplica.
5. Usar ataque a distancia si el estado/equipamiento lo permite.
6. Probar backstab desde detras del enemigo.
7. Probar que el backstab no se activa desde frente o lateral.
8. Validar comportamiento basico de busqueda/persecucion.
9. Para lizard, validar climb contra pared si esta presente.

Resultado esperado:
- Los enemigos no dependen de rutas fragiles del jugador.
- El backstab respeta posicion y direccion del enemigo.
- La animacion de ataque no deja al jugador bloqueado.

## Rig Y Progresion Visual

1. Revisar estado head-only si el flujo lo permite.
2. Equipar torso y confirmar que cambia la progresion visual.
3. Equipar brazos y piernas.
4. Observar animacion en reposo, movimiento, salto/crawl y ataque.
5. Confirmar que sockets visibles corresponden a equipo activo.

Resultado esperado:
- Las partes no recuperadas permanecen ocultas.
- El rig no muestra piezas duplicadas ni flotantes.
- El preview y el jugador comparten la misma progresion visual esperada.

## Resoluciones De UI

Probar mentalmente o en editor, segun disponibilidad:

- 1280x720
- 1366x768
- 1920x1080
- Relacion ultrawide

Resultado esperado:
- Inventario y paneles caben en pantalla.
- Labels criticos no se cortan sin alternativa.
- Botones y slots mantienen alineacion y separacion consistente.

## Registro De Evidencia

Para cada PR, registrar:

- Rama.
- Commit.
- Escena validada.
- Resolucion usada.
- Pasos ejecutados.
- Resultado: pass, fail o pendiente.
- Errores de consola relevantes.
- Capturas o video si el cambio toca UI, camara, rig o animacion.

Formato corto:

```text
Rama:
Commit:
Escena:
Resolucion:
Pasos:
Resultado:
Pendientes:
```
