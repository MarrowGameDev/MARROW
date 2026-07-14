# AGENTS.md

Guia obligatoria para cualquier cambio en Marrow. Todo trabajo debe priorizar estabilidad, escalabilidad, desacoplamiento y claridad de gameplay. Si una solicitud contradice estas reglas, primero explicar el riesgo y proponer una alternativa mas segura.

## Principios Del Proyecto

- Mantener el juego jugable despues de cada cambio. No romper inventario, camara, combate, enemigos, pickups, rig ni escena principal para avanzar una feature aislada.
- Preferir cambios pequenos, verificables y por sistema. Evitar mezclar UI, combate, datos, enemigos y camara en el mismo cambio si no es estrictamente necesario.
- El codigo debe ser facil de extender. Antes de agregar condiciones nuevas a `player.gd`, `enemy.gd` o `player_inventory_ui.gd`, evaluar si corresponde mover la regla a un componente, servicio, Resource o escena dedicada.
- El `Player` debe actuar como orquestador, no como contenedor infinito de reglas. Inventario, equipamiento, stats, camara, combate, pickups y UI deben vivir en modulos especializados.
- La UI debe ser responsive por calculo de viewport, no por arreglos puntuales para una resolucion especifica.
- Mantener compatibilidad con sistemas existentes cuando se migra arquitectura. Las migraciones deben ser graduales y con adaptadores si hace falta.

## Estructura Esperada

- `scripts/`: logica principal del juego. Separar componentes, servicios y controladores por responsabilidad.
- `scripts/rig/`: rig modular, animacion procedural y escenas de prueba relacionadas con cuerpo/personaje.
- `scenes/`: escenas Godot reutilizables. Evitar construir todo por codigo si una escena dedicada mejora inspeccion y reutilizacion.
- `docs/`: documentacion de arquitectura, flujos, decisiones tecnicas y sistemas.
- `assets/`: recursos visuales/audio/datos importables.
- `graphify-out/`, `.godot/`, caches y salidas generadas no deben tratarse como fuente de verdad.

## Reglas De Arquitectura

- Una clase debe tener una responsabilidad principal. Si un archivo empieza a mezclar entrada, UI, datos, reglas de balance, efectos visuales y persistencia, dividirlo.
- Usar componentes para estado y comportamiento reutilizable:
  - inventario: coleccion, stacks, filtros, ordenamiento, seleccion.
  - equipamiento: slots, equipar, desequipar, validaciones.
  - stats: calculo final desde base stats + huesos + calidad + sinergias.
  - camara: input, sensibilidad, colisiones, modos.
  - combate: ataques, hitboxes, cooldowns, backstab, combos.
- Usar servicios para reglas puras sin estado de escena, por ejemplo reglas de huesos, slots, drops, pickups, balance y validacion.
- Usar senales/eventos para comunicar sistemas desacoplados. UI, objetivos, tutoriales, drops y enemigos no deben llamarse entre si si una senal de `GameEvents` resuelve el flujo.
- Evitar dependencias circulares. Si dos sistemas necesitan conocerse demasiado, crear una interfaz pequena, un evento o un servicio intermedio.
- Mantener nodos de escena como composicion. No ocultar dependencias criticas en busquedas fragiles de rutas profundas si pueden exportarse o inyectarse.

## Godot Y GDScript

- Usar `class_name` cuando una clase sea reutilizable o parte del dominio del juego.
- Usar tipos explicitos en variables, argumentos y retornos siempre que sea razonable.
- Usar `@export` para parametros de tuning que deban ajustarse desde editor.
- Usar `preload` para dependencias estables y `load` solo cuando haya una razon para carga dinamica.
- Evitar strings magicos para acciones, slots, rarezas o estados. Centralizar constantes o usar Resources.
- Evitar duplicar reglas entre UI y gameplay. La UI muestra decisiones; no debe inventar validaciones distintas.
- No depender de orden accidental de hijos en escena para logica critica. Nombrar nodos importantes y validar su existencia.
- Validar `null` e `is_instance_valid()` cuando se retienen referencias a nodos que pueden liberarse.
- No hacer trabajo pesado en `_process` si puede hacerse por evento, timer, cache o senal.
- Mantener `_physics_process` para movimiento/fisica y `_process` para visual/estado no fisico.

## Datos Y Resources

- Las definiciones de huesos deben evolucionar hacia datos limpios y editables, preferiblemente `Resource` cuando el dato sea de dominio.
- Mantener una capa de compatibilidad cuando se migren diccionarios existentes a Resources.
- El calculo de stats debe ser determinista y testeable sin depender de UI ni escena principal.
- Todo dato de balance debe tener nombre claro, unidades claras y documentacion minima.
- Rareza, calidad, peso, durabilidad, mutaciones y sinergias deben agregarse como campos de datos, no como ramas dispersas por scripts.

## Inventario, Equipamiento Y UI

- Inventario y equipamiento son sistemas distintos. Inventario guarda piezas disponibles; equipamiento decide que pieza esta activa en cada slot.
- Drag and drop debe delegar validaciones a reglas compartidas, no duplicarlas en widgets.
- Toda UI debe calcularse con el viewport disponible y probarse mentalmente en 1280x720, 1366x768, 1920x1080 y relaciones ultrawide.
- Evitar textos largos en controles compactos. Si un label puede cortarse, debe tener abreviatura responsive o layout alternativo.
- Los controles visuales deben mantener altura, alineacion vertical y separacion consistente al cambiar resolucion.
- No ocultar informacion importante sin reemplazo. Si una zona se compacta, debe mostrar una version abreviada pero comprensible.
- La UI no debe modificar reglas de gameplay directamente salvo mediante metodos publicos del sistema propietario.

## Combate, Enemigos Y Feel

- Separar deteccion, decision y feedback. Ejemplo: detectar hit/backstab, resolver dano, luego disparar animacion/sonido/camara.
- Evitar que enemigos dependan directamente de detalles internos del jugador. Usar metodos publicos, senales o servicios compartidos.
- Los cambios de feel deben ser configurables: pausas, camera shake, flashes, knockback, sensibilidad y timings.
- Toda mecanica nueva de combate debe considerar: cooldown, feedback visual, feedback sonoro, estado de muerte, pausa/inventario y compatibilidad con equipamiento.
- La IA debe modelarse por estados claros. Evitar condicionales enormes sin nombres de estado.

## Camara Y Controles

- La camara debe estar desacoplada del inventario y del combate. Otros sistemas pueden pedir modo, bloqueo o pausa, pero no manipular sus internals.
- Sensibilidad, inversion de eje y estados especiales deben guardarse como configuracion, no como constantes enterradas.
- Al cambiar input, preservar compatibilidad con `InputMap` y configuraciones guardadas.
- Cualquier cambio de controles debe actualizar UI, documentacion y defaults.

## Escenas De Prueba Y Validacion

- Para sistemas complejos, crear o mantener escenas de prueba dedicadas antes de integrar en `main.tscn`.
- Como minimo, validar manualmente cuando aplique:
  - abrir/cerrar inventario.
  - equipar/desequipar huesos.
  - recoger pickups.
  - atacar y recibir dano.
  - comportamiento basico de enemigos.
  - camara y movimiento.
  - preview/rig del personaje.
- Si Godot CLI esta disponible, usar validacion headless cuando sea posible. Si no esta disponible, reportarlo claramente.
- No afirmar que algo fue probado si solo se inspecciono el codigo.

## Git Y Cambios

- Antes de editar, revisar `git status --short --branch`.
- No revertir cambios ajenos sin instruccion explicita.
- Mantener commits pequenos y enfocados por sistema.
- No commitear caches, artefactos generados, archivos temporales ni resultados de editor que no sean fuente.
- Antes de cerrar una tarea, revisar `git diff --check` y resumir archivos tocados.
- Si hay archivos staged y unstaged mezclados, no asumir que todo pertenece al cambio actual.

## Documentacion

- Cada sistema nuevo o refactor importante debe tener una nota en `docs/` o actualizar la documentacion existente.
- Documentar flujos, no solo clases. Ejemplos: inventario, equipamiento, combate, drops, camara, enemigos, rig.
- Registrar decisiones tecnicas cuando se elija una arquitectura que afecte futuras features.
- La documentacion debe explicar responsabilidades, dependencias y puntos de extension.

## Criterios Para Aceptar Un Cambio

- El cambio cumple la solicitud sin introducir deuda innecesaria.
- La responsabilidad queda en el modulo correcto.
- No se duplican reglas entre gameplay y UI.
- El comportamiento sigue funcionando en resoluciones pequenas y grandes si toca UI.
- El codigo tiene nombres claros, tipos razonables y errores manejados.
- El cambio es verificable con prueba manual, escena de prueba o comando.
- Se actualizo documentacion si cambio arquitectura, datos o flujo de usuario.

## Reglas Para Asistentes

- Leer el contexto local antes de proponer arquitectura.
- Preferir patrones existentes del repo sobre abstracciones nuevas.
- Si una tarea pide "arreglar rapido", aun asi evitar parches que bloqueen escalabilidad.
- Si una tarea toca sistemas grandes, proponer un corte incremental: estabilizar, extraer responsabilidad, validar, documentar.
- Si algo no puede verificarse, decirlo de forma explicita y concreta.
- No incluir planes de roadmap externos en este archivo. Este documento define reglas permanentes, no tareas pendientes.
