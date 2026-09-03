# MARROW — Auditoría Técnica y de Diseño

**Fecha:** 2 de septiembre de 2026
**Alcance:** `C:\Users\strik\OneDrive\Documentos\MARROW` — 70 `.gd` (~27.700 líneas), 16 `.tscn`, 30 `.md` (~14.700 líneas), 16 `.py`, 14 `.tres`, 153 MB.
**Método:** lectura completa de la documentación de flujos, del código fuente principal, de la capa de servicios y datos, de la infraestructura de verificación, del corpus y la salida de Graphify, del historial de Git y del PDF de planificación.
**Regla aplicada:** no se modificó ni un archivo. Todo lo que no pudo demostrarse con evidencia está marcado explícitamente.

---

## 0. Lo incómodo primero

Tres cosas antes de cualquier tabla, porque cambian el orden de todo lo demás.

### 0.1 Cinco semanas de trabajo existen en un solo disco duro, sin commit y sin push

`git status` en la rama `feat/loot-chest-scene` devuelve:

- **Sin trackear:** `scripts/chest.gd`, `scripts/loot_table_service.gd`, `scripts/loot_table_definition.gd`, `scripts/save_service.gd`, `scripts/save_coordinator.gd`, `scenes/chest.tscn`, `data/loot_tables/` (7 `.tres`), `docs/chest_and_loot_flow.md`, `docs/save_flow.md`, 6 checks headless nuevos y **`.agents/AGENTS.md`**.
- **Modificados sin commit:** 23 archivos, incluyendo `enemy.gd`, `scenes/main.tscn`, `game_events.gd`, `player_equipment_component.gd`.
- **Borrado:** `AGENTS.md` en la raíz (su reemplazo en `.agents/` está sin trackear, o sea que ahora mismo el archivo de reglas del proyecto **no existe en Git en ninguna parte**).

El último commit es `69e3483`, del **25 de julio**. Hoy es 2 de septiembre. Todo el subsistema de cofres, tablas de loot y persistencia — aproximadamente **1.700 líneas** más su documentación y sus pruebas — vive únicamente en el directorio de trabajo de una máquina. Un `git checkout .`, un `git stash` mal usado, un disco que falla o un reinstalar Windows y desaparece.

Esto no es una observación de higiene. Es el riesgo número uno del proyecto y no compite con ningún otro. **Impacto: crítico. Urgencia: ahora. Confianza: alta** (verificado directamente con `git status --short --branch`).

### 0.2 Nadie ha jugado MARROW

Esta es la conclusión más importante de la auditoría y no aparece en ningún documento del proyecto.

La infraestructura de verificación es genuinamente buena: 21 checks headless en Godot y 13 validadores Python. Pero **todos verifican aritmética, contratos y estructura. Ninguno verifica que el juego se sienta bien.** Y la propia documentación lo admite, repetidamente, en once lugares distintos:

- *"Confirmar esos flujos sigue requiriendo un humano jugando la escena"* — `p0_runtime_validation_suite.md:80`
- *"no se afirma aqui que el jitter haya quedado resuelto"* — `camera_flow.md:228`
- *"Pendiente de confirmacion visual humana"* — `inventory_flow.md:397`
- *"queda pendiente validarlo en runtime con las guias P0"* — `combat_flow.md:973`
- *"La matriz demuestra diferenciación matemática, no feel"* — `combat_balance.md:81`
- La tabla de `roadmap_progress.md` tiene una columna "Pendiente" y en 14 de 26 lotes dice alguna variante de *"confirmar a mano en el editor"*.

El PDF de planificación original (`outputs/marrow-remaining-tiers-coder-plan.pdf`, generado el 13 de julio) definía explícitamente un **Tier 1G — Playtest And Decision Gate**: *"Run at least 5 playtests with people who did not build it… Decision gate: continue only if swapping bones creates at least one genuinely interesting choice."* Y una regla global: *"Do not start Tier 2 art or save/load until Tier 1D-G are playtested."*

Ese gate nunca se ejecutó. El proyecto saltó directo a calidad de piezas, sinergias de set, presets de build, tablas de loot ponderadas y un sistema de guardado completo. Hoy hay **27.700 líneas construidas sobre un loop cuyo valor de juego nunca se comprobó con una persona**.

Esto no significa que el trabajo esté mal hecho — está notablemente bien hecho. Significa que el riesgo acumulado no es técnico: es que el bucle de "matar → cosechar → equipar → sentir la diferencia" resulte tibio, y que la respuesta a eso exija tocar los sistemas más profundos que ya están construidos encima.

**Impacto: crítico. Urgencia: ahora. Confianza: alta.**

### 0.3 Tu primo no está construyendo un prototipo, está construyendo una plataforma

Y lo está haciendo bien. Pero conviene que ambos lo vean con nombre propio, porque cambia qué conversación tienen que tener.

Lo que existe es una **capa de reglas pura, sin estado, testeable sin motor, con documentación de fronteras dentro del propio código** — las cabeceras de `synergy_rules_service.gd`, `chest.gd`, `save_service.gd` y `ballistics_service.gd` no describen qué hace el archivo, describen **qué se dejó deliberadamente fuera y por qué**. Eso es raro y es valioso.

Lo que también existe es una **capa de nodos que no siguió ese camino**: `player_inventory_ui.gd` con 3.617 líneas, `enemy.gd` con 2.353, `player.gd` con 2.017, comunicándose entre sí por strings (`player.call("equip_bone")`, `has_method("consume_head_only_body_catch_up_offset")`) en lugar de por interfaces tipadas.

La tensión entre esas dos mitades es la deuda técnica real del proyecto, y crece con cada feature.

---

## 1. Resumen ejecutivo

**MARROW es un juego de acción en tercera persona en Godot 4.7 donde el jugador es un esqueleto que se reconstruye a sí mismo con los huesos de sus enemigos.** La cabeza es el núcleo fijo e irreemplazable; todo lo demás — torso, dos brazos, dos piernas — se pierde, se recupera y se intercambia. Cada pieza cambia stats y animación, y las combinaciones producen sinergias. El mundo es un overworld tipo Zelda con siete regiones ordenadas por dificultad.

El pilar de diseño, formulado en el PDF de planificación, es: **"your body is your build"**.

**Estado real, en una línea:** hay un demo jugable con combate melee y a distancia, sigilo, desmembramiento, inventario completo con preview 3D, equipamiento por seis slots, sinergias activas, cofres con cuatro modos de bloqueo, siete tablas de loot y guardado/carga en disco. Todo verificado matemáticamente. Nada verificado como experiencia.

**Lo que falta no son features, son tres decisiones y un playtest.**

| Dimensión | Evaluación |
| --- | --- |
| Calidad de la capa de reglas | Alta — pura, documentada, testeable |
| Calidad de la capa de nodos | Media-baja — tres god objects, acoplamiento por strings |
| Calidad de la documentación | Alta en volumen, con 9 contradicciones reales y 3 documentos desfasados |
| Cobertura de verificación automática | Alta en aritmética, **nula en experiencia**, **cero CI que la ejecute** |
| Riesgo de pérdida de trabajo | **Crítico** — 1.700 líneas sin commit |
| Preparación para escalar contenido | Media — datos a medias en `.tres`, todo el balance de enemigos en código |
| Claridad de diseño de juego | **Baja en el punto que más importa**: qué pasa cuando el jugador muere |

---

## 2. Reconstrucción de qué es MARROW

Clasificación por nivel de evidencia. Nada de lo que sigue está inventado; lo que no tiene fuente se marca como **No definido**.

### 2.1 Confirmado

| Aspecto | Descripción | Evidencia |
| --- | --- | --- |
| **Motor** | Godot 4.7, GDScript | `project.godot`, `p0_runtime_validation_suite.md:74` |
| **Perspectiva** | 3ª persona, cámara orbital con `SpringArm3D`, aim sobre hombro izquierdo | `camera_flow.md:7-11,52-59` |
| **Fantasía central** | El jugador es un esqueleto; la cabeza es núcleo fijo (no se reemplaza, no se desequipa, si se rompe muere); torso, brazos y piernas se recuperan | `equipment_flow.md:142-145`, `combat_flow.md:588-589` |
| **Loop principal** | Explorar región → combatir → desmembrar enemigo → recoger limb como hueso → equiparlo → cambian stats y animación → afrontar región más difícil | `drops_flow.md:8-10,52-58`, `equipment_flow.md:104-107` |
| **Slots de equipamiento** | Seis canónicos: `head`, `torso`, `left_arm`, `right_arm`, `left_leg`, `right_leg`. Aliases legacy `body`→`torso`, `legs`→ambas piernas | `equipment_flow.md:84-98` |
| **Progresión** | **Corporal, no por niveles.** No hay XP, ni niveles, ni moneda en ninguna parte del proyecto | grep sin resultados en docs y código |
| **Mundo** | 7 regiones instanciadas de `open_world_stage.tscn`, con `stage_id`, `difficulty`, `recommended_bone`: BonefieldHub (1, hub seguro), FirstHuntField (2), ReachRidge (3, alcance), QuickrootRun (4, velocidad), HeavyRuin (5, poder), RibfenBonus (4, side-stage), ElderMarrowGate (7, "future high-difficulty zone") | `open_world_map_layout.md:42-50`, `scenes/main.tscn` |
| **Arquetipos de enemigo** | `normal`, `gorilla` (tanque, lanza rocas), `lizard` (movilidad, escupe saliva, trepa paredes), `ranged` (flechas), `dummy` (pasivo, para pruebas) | `combat_flow.md:28-30,650-655` |
| **Combate** | Melee con combo visual de 4 pasos; arco con balística real (exige ambos brazos); "finger bones" como fallback; sigilo con backstab y ejecución; head-launch (la cabeza como proyectil) | `combat_flow.md` completo |
| **Calidad de pieza** | Escalera de 5: frail 0.90 / worn 0.95 / normal 1.00 / strong 1.05 / pristine 1.10. Probabilidades 2.5/12.5/70/12.5/2.5 (suman exactamente 100). Se rueda **una sola vez**, al crear la pieza | `bone_quality_service.gd:31-67` |
| **Sinergias** | Activas y cableadas a stats reales. Familias por `set_id` con escalones excluyentes de 2 y 4 piezas; simetría (`matching_arms`, `matching_legs`); calidad (`high_quality_assembly`, 4+ piezas rank≥3) | `synergy_rules_service.gd:103-202` |
| **Loot** | 7 tablas `.tres`, una por banda de dificultad. Tirada ponderada por `rarity_drop_weight` + sesgo de calidad acumulativo. `head_bone` tiene peso 0.0, por eso el núcleo nunca cae | `data/loot_tables/`, `loot_table_service.gd` |
| **Cofres** | Escena reutilizable con 4 modos de bloqueo (`NONE`/`EXTERNAL`/`TRIAL`/`EQUIPPED_BONE`) y 2 de entrega (`SPAWN_PICKUPS`/`DIRECT_TO_INVENTORY`) | `chest.gd`, `chest_and_loot_flow.md:80-96` |
| **Persistencia** | `user://marrow_save.json`, versión 1, guardado **manual** (`autosave_enabled = false`). Guarda instancias, inventario, equipamiento, jugador, cofres, trials, enemigos y estado del RNG de loot | `save_service.gd`, `save_flow.md` |
| **UI** | Inventario completo: pestañas, paper-doll, grid con stacks `xN`, filtros por slot y calidad, orden, comparador vs equipado, preview 3D en `SubViewport`, 3 presets de build, pantalla de settings con rebinding de teclas | `player_inventory_ui.gd` |
| **Herramientas internas** | 21 checks headless, 13 validadores Python, escena de testing con suite P0 y log a disco, Graphify con workflow de CI | `tools/`, `.github/workflows/` |
| **Multiplayer** | **No existe** y no hay ninguna mención en el proyecto | grep sin resultados |

### 2.2 Inferido

| Aspecto | Inferencia | Base |
| --- | --- | --- |
| **Género** | Action-adventure / action-RPG ligero, estructura de overworld tipo Zelda | Ningún documento lo declara. Se deduce de `open_world_map_layout.md:5` (*"closer to a Mario/Zelda overworld"*) + combate melee/ranged/stealth + progresión por gates |
| **Experiencia buscada** | Experimentación con builds físicas: la recompensa es descubrir que un cuerpo distinto se juega distinto | `combat_balance.md:71-79` (matriz de 7 builds con perfiles claramente diferenciados) + el pilar "your body is your build" del PDF |
| **Loops secundarios** | Cofres por región; limpiar camps para desbloquear su cofre; superar trials para desbloquear cofres; guardar y comparar builds; sigilo como alternativa al combate frontal; estados degradados (rodar como cabeza, arrastrarse sin piernas) como gameplay propio | Múltiples fuentes convergentes |
| **Público objetivo** | Jugador de acción de nicho, tolerante a grey-box y a sistemas | No documentado; inferido del tono del proyecto |

### 2.3 Ambiguo

| Aspecto | Qué existe | Qué falta |
| --- | --- | --- |
| **Trials** | Se guardan, desbloquean cofres, existe `bone_trial_gate.gd`, emiten `trial_completed` | **Ningún documento explica qué es un trial ni cómo se completa.** `chest_and_loot_flow.md:85` describe `EQUIPPED_BONE` como *"Mismo contrato que BoneTrialGate"* — una referencia circular a un sistema no documentado |
| **Curación por recuperación = 8** | Aparece en `combat_balance.md:29` | No se documenta qué la dispara, si aplica al jugador o al enemigo, ni con qué frecuencia |
| **Umbral de ejecución = 40** | En `combat_balance.md:30` | No se documenta si es `<` o `<=`, ni si es absoluto o relativo a `max_health`. Ver §6.1 — en el código es un agujero |
| **Pérdida de miembros del enemigo** | `_detach_limbs_for_damage` existe y funciona | Ninguna fórmula, umbral ni probabilidad documentada. `combat_balance.md:33` solo dice *"escala con max_health"* |
| **Respawn de enemigos** | Implementado, con delays cerca/lejos | Ninguna regla de diseño documentada sobre cuándo y por qué debe reaparecer un enemigo |
| **Visión enemiga** | "cono + distancia + line of sight" | Sin ángulo ni rango documentados; `enemy_detection_range` existe como campo sin valores de referencia |
| **`stage.trigger_size`, `recommended_bone`, `stage_color`** | Declarados como metadata de región | Sin comportamiento runtime documentado |
| **Objetivo de la isla** | El panel de tutorial dice mostrar "el objetivo general de la isla" | No se documenta cuál es ese objetivo ni cómo se completa |

### 2.4 Contradictorio

Nueve contradicciones reales entre documentos, ordenadas por gravedad. Cada una es una decisión pendiente disfrazada de documentación.

| # | Contradicción | Fuentes |
| --- | --- | --- |
| **C1** | `attack_overlay_duration`: **0.70 vs 0.16** | `combat_flow.md:149` dice 0.70 con historial explícito `0.16→0.38→0.70`; `rig_notes.md:304` sigue listando 0.16 como tuning vigente |
| **C2** | `attack_cooldown`: **0.85 vs 0.45**, dentro del mismo documento | `combat_flow.md:149,157` dicen 0.85; `combat_flow.md:262,795` dicen 0.45. El razonamiento del gate anti-stacking se apoya en que 0.45 < 0.56 — con 0.85 esa premisa es falsa |
| **C3** | **Vocabulario canónico de calidad: inglés vs español** | `bone_data_structure.md:70-84` fija `frail/worn/normal/strong/pristine` como canónicos y degrada los españoles a alias legacy. `equipment_flow.md:177-179` e `inventory_flow.md:161-162` declaran `chatarra/fragil/comun/fuerte/legendario` como canónicos |
| **C4** | `rarity_drop_weight` y `quality_drop_percent`: **¿tienen consumidor o no?** | `chest_and_loot_flow.md:41-46` y `drops_flow.md:69-71` dicen que sí desde 2026-08-04. `bone_data_structure.md:173,307`, `equipment_flow.md:174-176` e `inventory_flow.md:170` siguen diciendo que no. Tres documentos quedaron atrás |
| **C5** | **Sets y sinergias: activos vs metadata pasiva**, dentro del mismo archivo | `bone_data_structure.md:176-184` dice "ya están conectados"; `bone_data_structure.md:271-277`, cinco secciones más abajo, dice *"metadata pasiva… No aplican bonuses automaticamente"* |
| **C6** | **Clave de stack: ¿incluye durabilidad?** | `bone_data_structure.md:132-134`: `bone_id + quality_id + mutacion` (tres). `inventory_flow.md:468-471`: `bone_id \| quality_id \| mutacion \| durabilidad` (cuatro). Misma función citada |
| **C7** | **Firma de `GameEvents.drop_spawned`** | `combat_flow.md:50` y `drops_flow.md:30`: `(bone_id, pickup, source)`. `chest_and_loot_flow.md:29`: `(instance_id, pickup, chest)`. Misma señal global, dos semánticas del primer parámetro |
| **C8** | **`rig_notes.md` se declara no integrado y a la vez describe el rig en producción** | Cabecera `:4` y cierre `:508`: *"Not wired into the real player yet (Phase G)"*. Contradicho por `:48`, `:82`, `:383` del mismo archivo y por todo `combat_flow.md` |
| **C9** | **Geometría de pierna: 0.18 vs 0.16** | `rig_notes.md:93-95` (diagrama) vs `:112,:126` (tabla y aritmética posterior) |

Menores, del mismo tipo: `camp_chest_opened` listado como evento en uso vs "sin consumidores hoy"; el contrato de tiles `xN` descrito como pendiente ocho líneas antes de describirlo como implementado; el slot del torso mezclando `body` y `torso` en prosa normativa.

### 2.5 No definido — requiere decisión humana

Estas no están documentadas de forma ambigua. Simplemente **no existen**, y hay que decidirlas antes de implementar nada encima.

1. **Qué pasa cuando el jugador muere.** Existe `GameEvents.player_died` y la regla de que romper la cabeza mata. No hay respawn, ni penalización, ni pantalla de muerte, ni pérdida de inventario, ni checkpoint. **Este es el hueco más grande del proyecto** — ver §10.
2. **Si la durabilidad existe como mecánica.** Hay 4 campos por hueso, funciones implementadas y cero consumidores. `roadmap_1_165.md` filas 70-72: "No iniciado".
3. **Si las mutaciones existen como mecánica.** 5 campos por hueso, cero efectos. Solo `rib_bone` tiene una autorada.
4. **Si los combos son reales o solo visuales.** 7 campos por hueso; únicamente `combo_window_for` se lee, y solo para alargar una animación.
5. **Si hay límite de inventario.** `inventory_weight` está calculado y sin consumidor.
6. **Economía y sinks.** No hay moneda, no hay coste de reparación real, no hay nada que consuma recursos. Ver §7.
7. **Narrativa.** Prácticamente inexistente: solo un arranque de cuatro líneas en `tutorial_flow.md:10-14`. Vocabulario sugerente (`ElderMarrowGate`, mutaciones `corrupto`/`maldito`) que existe solo como metadata.
8. **Qué es el `GuideWisp`.** Existe como escena y script, está instanciado en `main.tscn`, y **no aparece en ninguno de los 14 documentos de flujo** (grep sin resultados).

---

## 3. Estado real de implementación

Matriz documentación vs implementación. La columna **Estado** usa la escala que pediste. La columna **Doc vs código** señala el desfase.

| Sistema | Estado | Evidencia | Doc vs código |
| --- | --- | --- | --- |
| Movimiento + cámara orbital | **Funcional** | `player.gd:229-390`, `player_camera_controller.gd` completo con colisión de spring arm, zoom, aim-offset | Alineado. Jitter documentado como no resuelto |
| Combate melee + hitbox | **Funcional** | `player.gd:414-484`, `attack_hitbox.gd` | Alineado, con C1/C2 sin reconciliar |
| Combo de ataque (4 pasos) | **Funcional, solo visual** | `_next_combo_animation_step` `player.gd:962-987` | Documentado correctamente como visual |
| Arco / balística | **Funcional** | `player.gd:632-800` + `BallisticsService`; error vertical medido 0.000 m a 5/10/20/30 m | Alineado |
| "Finger bones" (sin arco) | **Parcial** | `player.gd:92-95,659-662`; sin visual propio ni feedback; reutiliza el script de flecha | No documentado como incompleto |
| Backstab / ejecución sigilosa | **Funcional con costuras** | Dos rutas de daño simultáneas: señal del animador (`player.gd:894`) **y** temporizador de respaldo (`:874-876`), con guarda compartida | Documentado; la duplicidad es una salvaguarda admitida |
| Head-launch / cabeza desprendida | **Prototipo avanzado** | ≈700 líneas entre `player.gd:1596-1875` y el animador; flujo completo miss→detach→buscar torso→reattach "tornado"; **5 booleanos paralelos de estado y ningún test headless** | Documentado con detalle; es el subsistema más grande y menos probado |
| IA de enemigos | **Funcional-prototipo** | `enemy.gd` completo: visión, oído, búsqueda, huida, retorno, 3 perfiles, 3 ataques a distancia, desmembramiento, recuperación de miembros, crawl | El lizard atraviesa paredes vía `use_line_of_sight = false` (`:2218`) — es un atajo, no visión real |
| Desmembramiento y drops | **Funcional** | `_detach_limbs_for_damage`, `_spawn_detached_limb_piece` | Los drops de enemigos **no están ponderados** por rareza; documentado como pendiente |
| Respawn de enemigos | **Frágil** | `_respawn_after_delay` `:1852-1859` hace polling en `await` **potencialmente infinito** hasta que el spawn salga del frustum | No documentado como riesgo |
| Inventario (colectar/stack/filtrar/ordenar/favoritos/lock/drop) | **Funcional** | `player_inventory_component.gd` + `rebuild_item_tiles` | Alineado |
| Equipamiento por 6 slots | **Funcional** | `player_equipment_component.gd:196-240`, con orden torso-primero y hints de rechazo | Alineado |
| Builds (guardar/aplicar/renombrar/borrar/rollback) | **Funcional** | `player_equipment_builds_component.gd:38-83` con rollback transaccional real | Un comentario en `:262-265` dice que el renombrado no existe; sí existe |
| Stats + calidad + sinergias | **Funcional** | `BoneRulesService.player_stats_with_equipment`, delegado limpiamente | **C4 y C5**: tres documentos dicen que esto no está conectado |
| Preview 3D del paper-doll | **Funcional** | `sync_preview` con caché por snapshot | Alineado |
| Rebinding de controles | **Funcional** | `player_inventory_ui.gd:3113-3136` con detección de conflictos | Vive en el archivo equivocado (§5) |
| Cofres + tablas de loot | **Funcional** | `chest.gd` + 7 `.tres` + `LootTableService`, 9 escenarios verificados headless | **Sin commit** |
| Persistencia (save/load) | **Funcional con huecos** | Roundtrip verificado con 84 piezas; rechaza versión desconocida | **Sin commit.** No guarda: RNG de calidad, `completed_trials` del panel, tiempo de run, pickups en el suelo |
| Camps de enemigos | **Funcional** | `demo_enemy_camp.gd` compone un `LootChest` | Alineado |
| Trial gates | **Funcional, sin diseño** | `bone_trial_gate.gd` funciona y persiste | **No hay ningún documento que explique qué es un trial** |
| Mundo abierto (7 regiones) | **Prototipo** | Regiones instanciadas con metadata y cofres | `open_world_map_layout.md:52-54`: *"move enemies/trials into the matching stage regions"* — **aún no hecho** |
| Tutorial / objetivos | **Funcional** | `arena_goal_manager.gd`, checklist de 8 pasos que lee los bindings reales | Alineado |
| Rig modular + animación procedural | **Funcional con deuda declarada** | `use_split_limbs` es un *"TEMPORARY MIGRATION ADAPTER"* (`modular_skeleton_rig.gd:180`) con 2 cortes pendientes | **C8**: `rig_notes.md` se declara no integrado |
| Rig con modelo real (`use_rigged_limbs`, `use_skeleton_model`) | **Muerto** | Ambos `false` por defecto; **ninguna escena los activa**. `_apply_rigged_limbs`, `_hang_basis`, tabla `RIGGED_LIMBS` nunca corren | No documentado como muerto |
| Foot placement (raycast por pie) | **Muerto** | `foot_placement_enabled := false`, no activado en ninguna escena | `rig_notes.md:252` lo documenta como bloqueado |
| Enemigos con codos/rodillas | **No existe** | `use_split_limbs` solo está activo en `player.tscn`; en `enemy.tscn` no. `_animate_joints` y `_whip_elbow` son no-op para enemigos | No documentado |
| Durabilidad | **Documentado, no implementado** | 4 campos por hueso, `durability_state_for` implementado, **0 consumidores** | `validate_bone_durability_synergy.py:11` lo admite: *"durability never decreases, repair does nothing"* |
| Mutaciones | **Documentado, no implementado** | 5 campos por hueso, **0 consumidores** en gameplay | Documentado honestamente |
| Combos de datos (`combo_family`, `combo_step`, `combo_finisher`) | **Documentado, no implementado** | Solo `combo_window_for` se lee (`player.gd:995`) | Documentado honestamente |
| Audio | **Placeholder** | Un único sonido: un WAV de 0.09 s generado proceduralmente (`enemy.gd:2314`, comentario: *"This is a placeholder"*) | No documentado |
| Feedback visual de daño del jugador | **Muerto de facto** | `_flash_player_damage` pinta `$MeshInstance3D`, que en `scenes/player.tscn:24` tiene `visible = false` | No documentado. **No verificado en pantalla** |
| Marcadores de socket (overlay de dev) | **Activado en producción** | `scenes/player.tscn:36` `show_socket_markers = true`; el propio rig dice *"Default OFF — this is a dev overlay"* | El jugador lleva bolas magenta en cada articulación |
| `scripts/_rt6.gd` | **Huérfano total** | 21 líneas de depuración ad-hoc; **cero referencias** en todo el repo | No documentado |
| `node_3d.tscn` (raíz) | **Huérfano** | `Node3D` vacío de 3 líneas, fuera de `scenes/`, cero referencias | No documentado |
| Graphify | **Funcional pero desfasado un mes** | Ver §4.4 | `AGENTS.md` lo declara "apoyo de análisis, no fuente de verdad" — correcto |
| CI | **Solo Graphify** | El único workflow reconstruye el grafo. **No hay ningún job que instale Godot ni ejecute un solo check** | No documentado como hueco |

---

## 4. Mapa arquitectónico

### 4.1 Forma general

```
project.godot → main_menu.tscn ──┬→ main.tscn (juego)
                                 ├→ testing_environment.tscn
                                 └→ dummy_testing_environment.tscn

           ┌──────────── GameEvents (bus global, 20 señales) ────────────┐
           │                                                             │
  Player ──┼── Componentes (Stats/Inventory/Equipment/Builds) ────── PlayerInventoryUI
    │      │        │                                                    │
    │   Enemy    ModularSkeletonRig ── ProceduralPlayerAnimator          │
    │      │                                                             │
  Chest ── LootTableService ── ArenaGoalManager / WorldMapManager ───────┘
    └──────────────────────────┬────────────────────────────────────┘
                    NÚCLEO DE REGLAS (estático, mutuamente cíclico)
     BoneRules ↔ BoneInstance ↔ BoneQuality ↔ EquipmentRules ↔ Synergy
                          ↕            ↕
                     BoneDatabase ↔ BoneDataCatalog → data/bones/*.tres
```

### 4.2 Sistemas globales

**Un solo autoload** (`project.godot:19-21`): `GameEvents`, un bus de 20 señales sin una línea de lógica ni estado. Esa disciplina es correcta y poco común.

**Once clases estáticas que funcionan como singletons de facto**, expuestas globalmente por `class_name`:

| Servicio | Líneas | Fan-in | Estado mutable |
| --- | ---: | ---: | --- |
| `BoneRulesService` | 782 | **32** | No |
| `BoneInstanceService` | 215 | **29** | `_instances`, `_next_index` |
| `BoneQualityService` | 337 | **24** | `_rng` |
| `EquipmentRulesService` | 735 | **22** | No |
| `DropPickupRulesService` | 170 | 8 | No |
| `LootTableService` | 303 | 7 | `_tables`, `_rng` |
| `SaveService` | 420 | 6 | `_save_path` |
| `SynergyRulesService` | 520 | 5 | No (puro por contrato) |
| `BoneDatabase` | 476 | 3 | `BONES` |
| `BoneDataCatalog` | 490 | 1 | No |
| `BallisticsService` / `BackstabRulesService` / `CombatTargetingService` | 112/25/66 | 2/1/1 | No |

Cambiar una firma en `BoneRulesService` toca dos tercios del proyecto.

**No hay capas de física configuradas.** `project.godot` no tiene `[layer_names]` ni sección `physics/`: todo vive en la capa 1 y la discriminación se hace a mano con `collision_layer = 0 / collision_mask = 1`, `has_method()` y grupos-string. Es funcional hoy y es una fuente de bugs cuando entren más tipos de objeto.

### 4.3 Flujo de eventos

Dos mecanismos coexisten. El bus global `GameEvents` (16 scripts lo usan) y las señales directas de Godot — de las cuales el proyecto define **solo dos propias**: `AttackHitbox.hit_confirmed` y `ProceduralPlayerAnimator.attack_impact_reached`.

Hallazgos verificados sobre las 20 señales del bus:

- **Cuatro señales se emiten y nadie las escucha**: `pickup_focus_changed`, `pickup_collected`, `drop_spawned`, `camp_chest_opened`. Se emiten desde 10 sitios. Son API muerta o preparada para el futuro; hay que decidir cuál.
- **Dos nodos se hablan a sí mismos a través del bus global**: `arena_goal_manager.gd` y `world_map_manager.gd` emiten `objective_updated` y lo escuchan ellos mismos, filtrando con `if source != self: return` (`:193` y `:40`). Es comunicación privada de un nodo consigo mismo pasando por un canal global.
- `tutorial_hint_requested` es la señal más promiscua: **8 emisores, 2 oyentes**, con un sistema de prioridad ad-hoc. La UI de inventario la intercepta para **robar el texto del motivo por el que un equipado fue rechazado** — lógica de dominio implementada como side-channel (§5.4).

### 4.4 Graphify: qué es y en qué estado está

Graphify es una herramienta externa (`uv tool install graphifyy`) que **no entiende GDScript**. El proyecto construye un puente:

```
tools/build_graphify_corpus.py  (468 líneas, regex sobre scripts/, scenes/, docs/)
   └─► graphify-corpus/architecture.py   ← Python SINTÉTICO: 58 clases y 1.136
                                            métodos falsos. Una clase por .gd y por
                                            .tscn; cada func GDScript es un
                                            `def gd_func_x(self): pass`; cada
                                            dependencia un `def depends_on_Y()`.
   └─► graphify graphify-corpus --code-only + export html
   └─► graphify-out/ (graph.json 1,5 MB — 1.977 nodos, 2.545 aristas)
   └─► commit automático "chore: actualiza grafo de arquitectura"
```

Se dispara solo en `main` y `develop`. `manifest.json` **solo trackea `architecture.py`**, lo que confirma que Graphify no ve ni un solo `.gd`.

**Está significativamente desfasado. Verificado:**

- `graph.json` dice `"built_at_commit": "de68f2e4…"` = *Merge PR #6*, ~20 de julio.
- Último commit que tocó `graphify-out/`: **20 de julio**. Último que tocó `scripts/`: **25 de julio**. Y encima hay cinco semanas de trabajo sin commit.
- `index.md` declara "GDScript files: 44 / scenes: 14 / docs: 19". Los valores reales hoy: **49 / 15 / 22** (sin contar lo no commiteado).

Consecuencia medida con `grep -c`:

| Símbolo | architecture.py | graph.json | dependency-map.md |
| --- | ---: | ---: | ---: |
| `LootChest` | 0 | 0 | 0 |
| `SaveService` | 0 | 0 | 0 |
| `SaveCoordinator` | 0 | 0 | 0 |
| `LootTableService` | 0 | 0 | 0 |
| `LootTableDefinition` | 0 | 0 | 0 |

**Todo el subsistema de cofres, loot y guardado —el trabajo más reciente— es invisible para Graphify.** Si lo consultas para entender el proyecto, estás mirando MARROW de hace mes y medio.

El mapa escrito a mano `docs/project_graph_map.md` existe precisamente porque *"the local Graphify extractor does not currently parse .gd files as code"*, y también está parcialmente obsoleto: lista los "current bone ids" sin `head_bone` ni `torso_bone`, y describe `_build_inventory_ui` como método de `Player` cuando vive en `PlayerInventoryUI`.

**Veredicto sobre Graphify:** el pipeline es ingenioso y la política que lo rodea (`repo_stability_and_graphify.md`) es sensata. Pero un grafo que se genera desde una traducción por regex a Python sintético, que se regenera solo en dos ramas, y que hoy ignora un subsistema entero, **no es una herramienta de comprensión del proyecto: es un artefacto que hay que mantener**. Como referencia inicial de dependencias sirve; como fuente de verdad no, y `AGENTS.md` ya lo dice.

### 4.5 Dependencias circulares — verificadas

El clúster de servicios estáticos de huesos es **fuertemente conexo**. Ciclos confirmados por lectura directa:

- `BoneDefinition` → `BoneQualityService` → `BoneInstanceService` → `EquipmentRulesService` → `BoneDefinition` (ciclo cerrado de 4 clases; el `Resource` de datos depende de tres servicios de reglas).
- `BoneRulesService` ↔ `SynergyRulesService` (mutuo).
- `BoneRulesService` ↔ `BoneInstanceService` ↔ `BoneDatabase` ↔ `BoneDataCatalog` (mutuos).
- `LootTableDefinition` → `BoneRulesService`, pese a que su propio comentario dice *"This Resource holds DATA ONLY"*.

Se detectaron **más de 50 ciclos de longitud 3-5**. Nada de esto rompe hoy porque GDScript resuelve `class_name` en tiempo de compilación y no por `preload()`. Pero el ciclo es real a nivel de diseño: **es imposible extraer `BoneRulesService` sin arrastrar los otros seis**, y `AGENTS.md` lo prohíbe explícitamente (*"Evitar dependencias circulares"*).

### 4.6 Evaluación por dimensión

| Dimensión | Nota | Justificación |
| --- | --- | --- |
| **Cohesión** | **Baja en 3 archivos, alta en el resto** | `player_inventory_ui.gd` (3.617) hace layout + reglas + 3 escenas 3D + rebinding + settings globales. `enemy.gd` (2.353) hace IA + 3 perfiles + 3 ataques ranged casi idénticos + desmembramiento + respawn + síntesis de audio. `player.gd` (2.017) sigue siendo orquestador tras extraer 4 componentes: no adelgazó, solo añadió una capa de reenvío |
| **Acoplamiento** | **Alto y del peor tipo: por strings** | `.call(` / `has_method(` aparece **80 veces en `player.gd`, 51 en `player_inventory_ui.gd`, 25 en `enemy.gd`, 22 en `save_service.gd``.` `player.gd` ↔ animador es un protocolo bidireccional de **20 métodos resuelto por cadena de texto**, con la variable ya tipada — el `has_method` no aporta nada salvo ocultar errores de refactor |
| **Separación de responsabilidades** | **Excelente en servicios, rota en nodos** | Las cabeceras de `synergy_rules_service.gd:15-21`, `chest.gd:6-13` y `save_service.gd:1-25` documentan **qué se dejó fuera y de quién es**. Eso sostiene la arquitectura. La capa de nodos no lo siguió |
| **Gameplay ↔ UI** | **Bidireccional y sin contrato** | `Player` **crea** la UI (`player.gd:216-218`) y le reenvía input. La UI llama de vuelta con `player.call("equip_bone")` × 15 métodos. La UI atraviesa al jugador para llegar a un componente (`player.get("equipment_builds_component")`) **y a su rig 3D** (`player.get("rig") as ModularSkeletonRig`, copiando 5 propiedades). **No son separables** |
| **Lógica ↔ persistencia** | **Con fugas** | `enemy.gd:232` hace `add_to_group(SaveService.ENEMY_RECORD_GROUP)` — un `CharacterBody3D` de IA importando el servicio de guardado. Hay **tres dueños de persistencia independientes** con tres formatos: `marrow_save.json` (SaveService), `equipment_builds.cfg` (componente de builds), `control_settings.cfg` (**la UI de inventario**) |
| **Datos ↔ comportamiento** | **Migración a medias** | Los `.tres` son autoritativos en teoría, pero `BoneDataCatalog` mantiene **406 líneas de diccionarios hardcodeados** como fallback — inalcanzable y **ya desincronizado** (contiene 0 bloques de durabilidad mientras los 7 `.tres` sí los tienen). Y el `Resource` de datos depende de tres servicios de reglas |
| **Uso de globales** | **Alto pero disciplinado** | 1 autoload es sano. Pero **7 piezas de estado estático mutable** sin reset coordinado, que **sobreviven a `change_scene_to_file`**. `save_coordinator.new_game()` borra el archivo y recarga la escena pero **no limpia el registro de instancias en memoria** — los `bone#N` de la partida anterior siguen vivos |
| **Duplicación** | **Residual, concreta y localizable** | `UNKNOWN_COLOR` definido 3 veces; `PLAYER_BONUS_DEFAULTS` 2 veces; `display_name_with_slot` implementado 3 veces con **dos vocabularios de slot incompatibles** (`BoneDatabase` mapea `"legs"→"Legs"`, `EquipmentRulesService` mapea `"legs"→right_leg→"Right Leg"`); `effect_text` duplicado; `bone.gd` y `limb_bone_pickup.gd` son dos rutas de pickup casi idénticas; el bloque de reseteo de `enemy.gd` aparece **5 veces**; los tres ataques a distancia del enemigo son tres copias de la misma estructura |
| **Extensibilidad** | **Media** | Añadir un hueso hecho a mano: un `.tres`. Añadir un **tipo de enemigo**: editar `enemy.gd`, `equipment_rules_service.gd` (~35 funciones de catálogo) y `modular_skeleton_rig.gd` (~50 vectores literales por perfil). Sin recurso de datos |
| **Testabilidad** | **Alta en servicios, nula en nodos** | Los servicios son `static` y puros: 100% testeables, y ya lo están. `player.gd` no se puede instanciar sin su escena (8 `@onready` con rutas `$`). La lógica de combate vive dentro de `_physics_process` y corrutinas: no hay punto de corte para aserciones |
| **UI construida por código** | **Total** | **No hay una sola escena `.tscn` de UI** en el proyecto. `arena_goal_manager`, `world_map_manager`, `main_menu`, `save_coordinator`, `testing_environment` y `player_inventory_ui` construyen todo con `Button.new()` / `Label.new()`. El layout es invisible al editor, no diffeable visualmente y no reutilizable |

---

## 5. Riesgos técnicos y deuda

Clasificados por **Impacto** (crítico/alto/medio/bajo) × **Urgencia** (ahora/próxima fase/futuro) × **Confianza** (alta/media/baja).

### 5.1 Críticos

| # | Hallazgo | I / U / C | Por qué |
| --- | --- | --- | --- |
| **R1** | **1.700 líneas sin commit ni push**: todo cofres+loot+save, 6 checks headless, 2 docs y `AGENTS.md` (borrado de la raíz, su reemplazo sin trackear) | Crítico / Ahora / **Alta** | Verificado con `git status`. Cualquier operación destructiva de Git o un fallo de disco lo borra. Cinco semanas de trabajo. No hay ninguna razón técnica para no commitear hoy |
| **R2** | **Ningún sistema ha sido validado como experiencia jugable.** Toda la verificación es aritmética o estructural | Crítico / Ahora / **Alta** | Once admisiones explícitas en la documentación. El decision gate del plan original (5 playtests) nunca se ejecutó, y se construyeron 5 capas de sistemas encima |
| **R3** | **No hay CI que ejecute la suite.** El único workflow reconstruye Graphify. Cero jobs que instalen Godot o corran un `headless_*` o un `validate_*` | Crítico / Ahora / **Alta** | 21 checks + 13 validadores que solo corren si alguien los escribe a mano, uno por uno. Además 3 validadores y 9 checks **ni siquiera están mencionados en `docs/`**, así que ni el runbook manual los cubre |

### 5.2 Altos

| # | Hallazgo | I / U / C | Por qué |
| --- | --- | --- | --- |
| **R4** | `stealth_finish_max_health = 40` **es igual a** `max_health = 40` por defecto (`enemy.gd:142,10`). Y `_apply_bone_identity` lo eleva a `max_health - 1` (`:2202`) | Alto / Ahora / **Alta** | `is_stealth_finish_lethal()` = `health <= 40`. Un enemigo estándar a vida llena **ya es ejecutable de un golpe**; uno con perfil de hueso lo es tras recibir 1 punto de daño. Es un exploit de balance, no un bug de código |
| **R5** | **`attack_hitbox._body_top_y` genera geometría de debug cada frame.** `_hit_current_overlaps()` corre por frame; para cada `StaticBody3D` solapado hace `find_children(...)` **y** `collider.shape.get_debug_mesh().get_aabb()` | Alto / Ahora / Media | `get_debug_mesh()` construye una malla. Por frame, por cuerpo, durante toda la vida del hitbox. El patrón es inequívoco; el impacto no está medido |
| **R6** | **N mundos 3D vivos y reconstruidos en cada refresco.** Cada tarjeta de build crea un `SubViewport` + `World3D` + 2 luces + 5 mallas de habitación + un `ModularSkeletonRig` completo. Con 3 builds son **5 mundos 3D**, y `_refresh_builds_screen` los destruye y recrea en cada clic de la barra lateral | Alto / Próxima fase / **Alta** | Verificado en `player_inventory_ui.gd:1975-2356` |
| **R7** | **`_respawn_after_delay` puede quedar en bucle infinito.** `while is_inside_tree() and not _spawn_is_out_of_perspective(): await create_timer(1.0)`. `die()` lo `await`ea, así que la corrutina de muerte queda viva indefinidamente | Alto / Próxima fase / **Alta** | `enemy.gd:1852-1859`. Si la cámara nunca deja de ver el punto de spawn, el enemigo nunca vuelve y la corrutina nunca termina |
| **R8** | **`max_health` se autodestruye.** `player.gd:1565` hace `max_health = int(calculated_stats["max_health"])`. El `@export = 50` deja de ser la base tras el primer recálculo | Alto / Próxima fase / **Alta** | El proyecto ya se quemó con esto: el comentario en `player_equipment_builds_component.gd:277-284` describe el bug ("mostraba Health 22 cuando el máximo real era 10"). El campo sigue siendo un doble sentido |
| **R9** | **Escaneo de grupo por frame de física.** `_find_stealth_target` recorre todos los enemigos cada frame desde `_update_stealth_finish_prompt`, y por cada uno invoca `BackstabRulesService`. O(enemigos) por frame sin culling previo | Alto / Próxima fase / **Alta** | `player.gd:1575,1877-1896` |
| **R10** | **Los validadores Python fijan código muerto.** `validate_inventory_build_presets.py:125-136` y `validate_inventory_preview_contract.py:32-60` **no ejecutan nada**: comprueban que existan cadenas literales en el `.gd` (`"func _save_equipment_build(index: int) -> void:"`) | Alto / Próxima fase / **Alta** | Borrar código muerto **rompe la validación**; renombrar una variable rompe la "prueba" sin que cambie el comportamiento. Incentivan conservar la basura |
| **R11** | **Estado global mutable sin reset coordinado.** 7 piezas estáticas sobreviven al cambio de escena. `new_game()` no limpia `BoneInstanceService._instances` | Alto / Próxima fase / **Alta** | Una partida nueva hereda el registro de piezas de la anterior. Solo existen `BoneInstanceService.reset()` y `LootTableService.reset_cache()`, y **ningún flujo de producción los invoca** |
| **R12** | **`BoneDatabase.get_def()` devuelve la referencia compartida, no una copia** (`:44-47`). Cualquier consumidor puede mutar la definición de un hueso para toda la sesión. Y `BoneDataCatalog._load_resource_for` **muta el `Resource` cacheado globalmente** (`:485-488`) | Alto / Próxima fase / Media | Los getters de arrays sí duplican; `get_def` no. Nadie lo explota hoy |

### 5.3 Medios

| # | Hallazgo | I / U / C |
| --- | --- | --- |
| **R13** | **Restaurar solo `state` del RNG sin `seed` no reanuda nada.** `set_rng_state` escribe `_rng.state`, pero `_ensure_rng()` ya hizo `randomize()` con otra semilla. La continuidad del loot tras cargar es ilusoria | Medio / Próxima fase / **Alta** |
| **R14** | **El RNG de calidad no se guarda.** Solo se persiste `LootTableService.rng_state()`; `BoneQualityService._rng` no se toca | Medio / Próxima fase / **Alta** |
| **R15** | **Drops de enemigos no reproducibles.** `DropPickupRulesService.choose_death_pickup_limb` usa `randi_range` global, fuera de todo RNG sembrable. `enemy.gd:1569` usa `randf()` directo | Medio / Próxima fase / **Alta** |
| **R16** | **Tras cargar partida, el panel dice "Completed: 0 / 3"** aunque los 3 gates estén verdes: los gates restauran en silencio sin emitir `trial_completed`, y `arena_goal_manager.completed_trials` no se persiste | Medio / Ahora / **Alta** |
| **R17** | **`_drop_bone` de `enemy.gd` es código inalcanzable.** `if rig != null and guarantee_limb_pickup_on_death: return` con ambas condiciones siempre ciertas en producción. Todo lo que sigue (incl. `_force_limb_pickup_drop`) está muerto | Medio / Próxima fase / **Alta** |
| **R18** | **Camino de "visuals" de `PlayerEquipmentComponent` muerto.** Con rig presente retorna en `:174`; quedan muertos `equipped_visuals`, `_tint_visual`, `EQUIPPED_BONE_SCENE`, los 4 `@onready` de sockets de `player.gd` y `get_equipment_socket_for_slot` | Medio / Próxima fase / **Alta** |
| **R19** | **Dos vocabularios de slot vivos.** `player.get_equipment_socket_for_slot` hace `match` **solo contra los legados** (`body`, `legs`): con ids canónicos devuelve `null` | Medio / Próxima fase / **Alta** |
| **R20** | **Triple repintado por un solo equipado.** `equip_bone` emite `inventory_changed` **y** `bone_equipped`; la UI reacciona a ambos y reconstruye la rejilla dos veces (una síncrona, una diferida) | Medio / Futuro / **Alta** |
| **R21** | **`LootTableService.table_for` cachea una tabla inválida** y sigue con solo un `push_warning`. En release un warning no se ve: una tabla rota reparte nada en silencio | Medio / Próxima fase / **Alta** |
| **R22** | **Un `chest_id` vacío o duplicado hace que el loot reaparezca en cada carga.** El chequeo vive solo en `headless_world_chests_check.gd` y **solo para `main.tscn`** | Medio / Próxima fase / **Alta** |
| **R23** | **Órdenes de inicialización load-bearing.** `player._ready()` son 15 pasos con dependencias implícitas (`health = max_health` **antes** de `stats_component.setup`); `_animate_waist` debe correr último en el animador; `SaveCoordinator` espera exactamente un frame antes de cargar | Medio / Próxima fase / **Alta** |
| **R24** | **`BoneDatabase._static_init()` carga los 7 `.tres` antes de cualquier `_ready`**, y bajo `godot --script` los autoloads no están registrados. Documentado extensamente en `headless_chest_check.gd:12-20`; 5 checks usan carga dinámica por esto | Medio / Futuro / **Alta** |
| **R25** | **Corrutinas sin cancelación.** `await get_tree().create_timer(attack_cooldown).timeout` seguido de `can_attack = true`: si el jugador muere o cambia la escena en esos 0.85 s, la corrutina reanuda sobre un objeto liberado. `_die_player` no toca `can_attack` | Medio / Próxima fase / **Alta** |
| **R26** | **El hitbox se autodestruye durante la pausa.** `SceneTreeTimer` corre con `process_always = true` por defecto, así que el `await` de lifetime avanza con el inventario abierto aunque `_physics_process` no corra | Medio / Futuro / Media |
| **R27** | **Parentado inconsistente de objetos spawneados.** Tres convenciones distintas para "el mundo": `get_tree().current_scene.add_child` (hitbox, proyectil del jugador), `get_parent().add_child` (drops, proyectiles de enemigo) y un fallback mixto | Medio / Futuro / **Alta** |
| **R28** | **`SaveService` descubre el mundo por grupos-string** (`"loot_chests"`, `"bone_trial_gates"`, `"enemy_records"`, `"enemy_camps"`). La persistencia depende de que cada nodo se auto-registre correctamente; un nodo que olvide el grupo desaparece del save sin error | Medio / Próxima fase / **Alta** |
| **R29** | **La clave del enemigo en el save es su ruta de escena.** Renombrar o reparentar un enemigo en el editor pierde su estado guardado. Documentado y aceptado, pero será una fuente de bugs cuando el mundo crezca | Medio / Futuro / **Alta** |

### 5.4 Deuda técnica declarada por el propio proyecto

Estas ya están reconocidas en comentarios. Vale la pena que estén en el backlog y no solo en prosa:

1. **`use_split_limbs`** — *"TEMPORARY MIGRATION ADAPTER… Delete it once enemies and the gorilla/lizard proportions are migrated — two rig topologies is debt"* (`modular_skeleton_rig.gd:180`). Con dos cortes pendientes: enemigos y proporciones. `rig_notes.md:241-253` advierte: *"If it outlives cut 3 it is permanent debt"*.
2. **`BoneDataCatalog.DEFINITIONS`** — 406 líneas de fallback declarado como *"temporary fallback during gradual migration"*, hoy inalcanzable y desincronizado.
3. **`quality_*_percent` de piezas generadas** mezclan especie y calidad en su nombre — *"renombrarlos queda como deuda cosmética"* (`combat_balance.md:50`).
4. **Drops de enemigos sin ponderar** — *"Unificar ambos caminos es trabajo pendiente"* (`drops_flow.md:74`).
5. **`Player.nearby_bone_pickups`** se incrementa y decrementa y **nadie lo lee**. Dos documentos advierten de no construir sobre él.
6. **`show_socket_markers = true` en producción**, contra la intención declarada del propio rig.

**Observación sobre el estilo de deuda:** no hay ni un solo `TODO`, `FIXME` o `HACK` literal en `scripts/`. La deuda no se marca, se narra en comentarios largos y bien escritos. Es muy legible para quien lee el archivo, y **completamente invisible para cualquier herramienta o para quien no lo lea**. Esa es una de las razones por las que tú no tienes una vista clara del proyecto.

---

## 6. Revisión de diseño de juego

Aquí dejo de mirar ingeniería. La pregunta es si los sistemas documentados forman una experiencia coherente.

### 6.1 Problemas de diseño identificados

| # | Problema | Gravedad | Evidencia |
| --- | --- | --- | --- |
| **D1** | **La muerte del jugador no tiene consecuencias definidas.** No hay respawn, ni penalización, ni pérdida, ni checkpoint, ni pantalla. Solo una señal `player_died` | **Crítica** | Sin esto no existe tensión, no existe riesgo, y por tanto **no existe una razón para preferir un build sobre otro**. Todo el pilar "your body is your build" se apoya en que perder importe |
| **D2** | **La ejecución sigilosa es prácticamente universal** (R4): cualquier enemigo estándar es ejecutable de un golpe | **Crítica** | Si un backstab mata siempre, el combate frontal —donde vive toda la diferenciación de builds— se vuelve la opción tonta. Es el exploit previsible más obvio del proyecto |
| **D3** | **No hay sinks. Nada consume nada.** No hay moneda, no hay durabilidad activa, no hay coste de reparación real, no hay límite de inventario | **Alta** | El inventario solo crece. Con drops garantizados y `allow_duplicates = false` en todas las tablas, el jugador acumula indefinidamente y las decisiones de equipar dejan de tener coste de oportunidad |
| **D4** | **Veinte campos por hueso no hacen nada.** Durabilidad (4), mutación (5), combo (7), más `physical_weight`, `synergy_score`, `quality_score`, `rarity_rank`, `set_tags` | **Alta** | Verificado: **cero llamadas** a 17 accessors de `BoneRulesService`. Es superficie de diseño que se autora, se valida, se documenta y no produce ninguna experiencia. Cada uno es una promesa al jugador que el juego no cumple |
| **D5** | **No hay progresión más allá de la geografía.** El único vector de avance es "ir a una región más difícil y equiparse mejor" | **Alta** | Sin XP, niveles, árbol, NPC ni mesa de ensamblaje (`roadmap_1_165.md` filas 142-144: "No iniciado"). El techo de progresión es 5 slots × piezas disponibles. Se agota rápido |
| **D6** | **El rango (`attack_range`) no tiene vía porcentual, deliberadamente.** Solo se suma | Media | Es una decisión consciente y documentada, pero significa que Arm Bone (+0.35) y Rib Bone (+0.25) compiten en un eje donde la calidad no escala nada. La calidad de un brazo importa poco |
| **D7** | **Cuatro familias de set están excluidas por degeneradas**: `core_body`, `training_bones`, `power_bones`, `hybrid_bones`. Y con `MAX_EQUIPPABLE_PIECES = 5` (la cabeza está soldada), **ningún escalón de 6 piezas es alcanzable jamás** | Media | El sistema de sets tiene 4 familias vivas de 8 definidas. La mitad del diseño de sets es inalcanzable |
| **D8** | **`head_bone` tiene `rarity_drop_weight = 0.0`** para que nunca caiga, pero `high_quality_assembly` *"cuenta la cabeza fija solo si su propia calidad rodada califica"*. **Dónde y cuándo se rueda la calidad de la cabeza no está documentado** | Media | Una sinergia depende de un valor cuyo origen nadie especificó |
| **D9** | **Mecánicas que compiten entre sí sin arbitraje.** Melee, arco, finger bones, backstab, head-launch, arm sword y los estados degradados (rodar, resorte, arrastrarse) son siete formas de resolver un encuentro | Media | Ninguna documentación explica cuándo debe preferirse cada una. Sin economía de riesgo, el jugador convergerá a la más segura — que hoy es el backstab (D2) |
| **D10** | **El demo empieza con el jugador como cabeza sola.** Es una apertura fuerte de diseño, pero el estado head-only es el subsistema con más código y menos pruebas | Media | Riesgo de que la primera impresión del juego sea la parte más frágil |
| **D11** | **Las 7 regiones existen pero están vacías.** `open_world_map_layout.md:52-54`: *"move enemies/trials into the matching stage regions and add stage-specific spawn points"* — pendiente | Media | Hay 10 cofres colocados y bandas de dificultad definidas, pero los enemigos están en el layout de la isla demo, no distribuidos por región |
| **D12** | **Sin audio y sin feedback de daño del jugador.** Un único WAV placeholder de 0.09 s; `_flash_player_damage` pinta un mesh que está oculto | Media | El PDF original lo señalaba como Tier 2G. Sin feedback, ningún playtest medirá bien el "feel" |

### 6.2 Variables que deben parametrizarse

Hoy el balance vive en tres sitios distintos: `.tres` (7 huesos + 7 tablas), `@export` en `.gd` (editables desde el editor) y **constantes duras en código** (no editables). Lo tercero es el problema.

**Constantes de balance que deberían ser datos:**

| Bloque | Ubicación | Contenido |
| --- | --- | --- |
| `QUALITY_TABLE` | `bone_quality_service.gd:31-67` | Los 5 multiplicadores y las 5 probabilidades. **Toda la economía de calidad** |
| `QUALITY_VISUALS` | `bone_quality_service.gd:100-151` | 5 perfiles de material × 6 campos |
| `FAMILY_RULES` / `SYMMETRY_RULES` / `QUALITY_RULES` | `synergy_rules_service.gd:103-202` | **Todos los bonos de set del juego** |
| Catálogo completo de miembros enemigos | `equipment_rules_service.gd:353-735` | ~35 funciones: bonos, pesos, durabilidad, escalas visuales, mutaciones, rarezas y combos de los ~15 tipos de hueso enemigo. **No existe ningún `.tres` para ellos** |
| Proporciones de gorilla y lizard | `modular_skeleton_rig.gd:283-360` | ~50 vectores literales por perfil. Cambiar la silueta de un enemigo es editar GDScript |
| Límites y umbrales | `bone_rules_service.gd:18-22` | `PLAYER_STAT_PERCENT_LIMIT` 0.75, `EQUIPMENT_FREE_WEIGHT` 6.0, penalización 0.04/unidad, techo 0.25, `DURABILITY_CRACKED_THRESHOLD` 0.4 |
| Rangos y pesos de rareza | `bone_definition.gd:487-532` | comun 1.0 … legendario 0.15 |
| Stats de enemigo duplicados | `testing_environment.gd:373-410` | **Segunda fuente de verdad** de gorilla 70/14/2.4, lizard 40/3.4, ranged 32/2.2/18.0, dummy 120/0/0. Puede divergir en silencio de `enemy.gd` |

**Magic numbers no exportados** (los realmente problemáticos, porque nadie puede ajustarlos sin editar código):

- Ruido de sigilo, cuatro valores dispersos: sprint 0.18 (`player.gd:349`), melee 0.55 (`:418`), disparo 0.45 (`:641`), finish 0.35 (`:820`).
- HUD en coordenadas absolutas para 1280×720: panel de vida en `Vector2(1040, 24)` (`player.gd:1932`), prompt de sigilo en `Vector2(430, 590)` (`:1965`). No responsive, en un proyecto cuya regla explícita es que la UI debe ser responsive por cálculo de viewport.
- `damage_per_limb *= 1.35` para gorilla (`enemy.gd:1478`), masa de miembro 0.35, radio de pickup 1.15, alturas de drop 0.05, y ~15 timings de flash/squash/lunge.
- Loft de finger bone `launch_velocity.y = 0.65` (`player.gd:766`) — el único proyectil que **no** usa `BallisticsService`.

**Invariante numérica sin test:** `attack_overlay_duration * 1.15 < attack_cooldown` (0.70 × 1.15 = 0.805 < 0.85). Está escrita solo en comentarios, cruza dos archivos, y **ningún test la comprueba**. Cambiar `attack_overlay_duration` a 0.75 rompe el combate en silencio.

### 6.3 Qué hay que balancear y cómo probarlo

No invento números donde la documentación no los establece. Lo que sí puedo decir es **qué variables necesitan una sesión de balance y con qué método**:

| Variable | Método de prueba |
| --- | --- |
| `stealth_finish_max_health` | Debe expresarse como **fracción de `max_health`** (p.ej. 0.3), no como absoluto. Test: matriz de `health/max_health` × arquetipo, con aserción de que ningún enemigo a >50% de vida sea ejecutable |
| `attack_cooldown` vs `attack_overlay_duration` | Test headless que falle si la invariante `overlay × 1.15 < cooldown` se rompe. Luego playtest de ritmo |
| Multiplicadores de calidad (0.90–1.10) | Rango del 20% total. Playtest: ¿un jugador nota la diferencia entre frail y pristine? Si no, el sistema entero de calidad es ruido |
| Bonos de sinergia (+2% a +6%) | Mismo problema, más agudo: 2% es indistinguible. Test A/B con builds extremos |
| `EQUIPMENT_FREE_WEIGHT` = 6.0 y techo de penalización 0.25 | La matriz muestra que solo Gorilla (8.22) y Heavy (6.40) superan el umbral, con 9% y 2% de penalización. **El peso casi no hace nada hoy** |
| `limb_pickup_drop_chance` = 0.35 | Determina el ritmo de adquisición. Debe medirse: piezas por minuto de juego |
| Sesgos de calidad de las 7 tablas (0.0 a 0.35) | Test de distribución con semilla fija, ya existe parcialmente en `headless_loot_table_check.gd` |
| Vida/daño por banda (40/10 normal, 70/14 gorilla) | Golpes-para-matar y golpes-para-morir, ya calculados en la matriz de builds. Falta la validación de que se sienta justo |
| Delays de respawn (120 s cerca / 30 s lejos) | Sin diseño detrás. Decidir primero si el respawn es una mecánica o un parche |

---

## 7. Requisitos reconstruidos

Clasificados como pediste, distinguiendo el nivel de compromiso de cada uno.

### 7.1 Requisitos funcionales — Confirmados

| ID | Requisito | Fuente |
| --- | --- | --- |
| RF-01 | El jugador comienza con `head_bone` equipado como núcleo fijo; no puede reemplazarse ni desequiparse | `equipment_flow.md:142-145` |
| RF-02 | Si la cabeza se rompe, el jugador muere | `equipment_flow.md:144` |
| RF-03 | El torso debe equiparse antes que cualquier extremidad (`TORSO_REQUIRED_SLOTS`, `APPLY_ORDER`) | `equipment_flow.md:468-479` |
| RF-04 | Los enemigos sueltan miembros físicos al recibir daño; **solo uno por enemigo** es recogible | `drops_flow.md:52-58` |
| RF-05 | Cada pieza equipada modifica move_speed, attack_range, attack_damage y max_health según fórmula determinista | `bone_rules_service.gd:689-714` |
| RF-06 | La calidad de una pieza se rueda **exactamente una vez**, al crearla, y nunca al recoger, equipar o abrir el inventario | `bone_data_structure.md:62-65` |
| RF-07 | El multiplicador de calidad escala solo los bonos positivos; los costes negativos no se alivian | `bone_data_structure.md:86-91` |
| RF-08 | Las sinergias se evalúan como función pura del estado de equipo, sin estado ni caché | `synergy_rules_service.gd:15-21` |
| RF-09 | Un cofre entrega loot **una sola vez**; cuatro modos de bloqueo y dos de entrega | `chest_and_loot_flow.md:80-96` |
| RF-10 | El guardado es manual; una versión de save desconocida se **rechaza entera**, nunca se aplica a medias | `save_flow.md:24-29` |
| RF-11 | Orden contractual de restauración: instancias → inventario → equipamiento → mundo → RNG | `save_service.gd:8-22` |
| RF-12 | El tutorial lee los bindings reales; **prohibido hardcodear texto de teclas** | `tutorial_flow.md:67-69` |
| RF-13 | Un pickup nacido bajo un dedo apretado no se auto-recoge (regla de pulsación fresca) | `drops_flow.md:96-98` |
| RF-14 | El arco exige **ambos brazos** equipados; sin ellos se lanzan finger bones | `equipment_flow.md:329-332` |
| RF-15 | La ejecución sigilosa requiere estar en el cono trasero del enemigo; la víctima no gira hacia el atacante | `combat_flow.md:350-392` |
| RF-16 | El inventario permite duplicados; las copias equipadas se filtran del grid | `inventory_flow.md:63-68` |
| RF-17 | Un build preset guarda `instance_id` exacto pero **requiere solo el tipo**, sustituyendo por la mejor calidad disponible y marcando el slot como `substituted` | `bone_data_structure.md:120-130` |
| RF-18 | Aplicar un build es transaccional: si la verificación post-apply falla, se hace rollback al snapshot previo | `equipment_flow.md:452-464` |

### 7.2 Requisitos funcionales — Pendientes de definición

| ID | Requisito | Estado |
| --- | --- | --- |
| RF-P1 | **Qué ocurre al morir el jugador** | **No definido.** Bloquea el vertical slice |
| RF-P2 | Qué es un trial y cómo se completa | **No documentado**, aunque implementado |
| RF-P3 | Si la durabilidad se consume, cómo y con qué coste de reparación | No definido (roadmap 70-72: "No iniciado") |
| RF-P4 | Si las mutaciones producen algún efecto | No definido (roadmap 75) |
| RF-P5 | Si los combos afectan daño, cooldown o hitbox | No definido |
| RF-P6 | Si existe límite o coste de inventario | No definido |
| RF-P7 | Qué dispara la "curación por recuperación = 8" | Ambiguo |
| RF-P8 | Fórmula de cuántos miembros caen por golpe | Ambiguo |
| RF-P9 | Regla de respawn de enemigos (diseño, no implementación) | Ambiguo |
| RF-P10 | Qué es el `GuideWisp` y qué papel cumple | No documentado en absoluto |
| RF-P11 | Cuál es el objetivo de la isla del demo | No definido |

### 7.3 Requisitos técnicos

| ID | Requisito | Origen |
| --- | --- | --- |
| RT-01 | Godot 4.7 / GDScript, sin dependencias externas de runtime | Confirmado |
| RT-02 | El cálculo de stats debe ser determinista y testeable **sin UI ni escena principal** | `AGENTS.md` |
| RT-03 | Las reglas puras viven en servicios `static` sin estado de escena | `AGENTS.md` + práctica establecida |
| RT-04 | La comunicación entre sistemas desacoplados usa `GameEvents`; los locales usan señales directas | `godot_signal_guidelines.md` |
| RT-05 | El save debe versionarse y rechazar versiones desconocidas | Implementado |
| RT-06 | La UI debe ser responsive por cálculo de viewport, no por parches por resolución | `AGENTS.md` — **incumplido en el HUD del jugador** |
| RT-07 | Las migraciones de arquitectura deben ser graduales y con adaptadores | `AGENTS.md` — cumplido (`use_split_limbs`, `BoneDatabase`) |
| RT-08 | Evitar strings mágicos para acciones, slots, rarezas o estados | `AGENTS.md` — **incumplido**: dos vocabularios de slot vivos, 80 `.call()` por string en `player.gd` |
| RT-09 | Evitar dependencias circulares | `AGENTS.md` — **incumplido**: >50 ciclos verificados en la capa de servicios |
| RT-10 | No commitear caches ni artefactos generados | `AGENTS.md` — cumplido |

### 7.4 Requisitos de calidad

| ID | Requisito | Estado hoy |
| --- | --- | --- |
| RC-01 | El juego debe quedar jugable después de cada cambio | Declarado en `AGENTS.md`; **no verificable hoy** porque no hay CI ni playtest |
| RC-02 | Cada sistema debe poder probarse sin arrancar el juego completo | Cumplido en servicios, **incumplido** en `player.gd`, `enemy.gd` y la UI |
| RC-03 | El layout debe funcionar en 1280×720, 1366×768, 1920×1080, 2560×1080 y 1024×600 | Verificado por `headless_inventory_check.gd` para "no desborda"; **no** para legibilidad. El HUD del jugador está en coordenadas absolutas |
| RC-04 | Adding a new bone requires changing one data table, not four scripts | Cumplido para huesos hechos a mano; **incumplido** para huesos de enemigo (3 archivos) |
| RC-05 | Rendimiento estable a 60 Hz de física | **No medido nunca.** R5 y R6 son riesgos concretos sin medición |
| RC-06 | La documentación debe explicar responsabilidades, dependencias y puntos de extensión | Cumplido en volumen; **9 contradicciones** y 3 documentos desfasados |

### 7.5 Requisitos de diseño

| ID | Requisito | Nivel |
| --- | --- | --- |
| RD-01 | **"Your body is your build"** — si un área no usa el intercambio de huesos, se rediseña o se corta | **Pilar** (PDF de planificación) |
| RD-02 | La progresión es corporal, no por niveles ni XP | **Confirmado** por ausencia total en todo el proyecto |
| RD-03 | El mapa se ordena por bandas de dificultad con un hueso recomendado por región | Confirmado |
| RD-04 | Los estados degradados (cabeza sola, torso sin piernas, arrastrarse) son gameplay, no game over | Confirmado |
| RD-05 | La calidad describe **condición de la pieza**, la rareza describe **obtención**. Nunca mezclarlas | Confirmado, y bien respetado en el código |
| RD-06 | No expandir contenido hasta que el loop central sea legible, repetible y fácil de tunear | **Propuesta del PDF, incumplida** |
| RD-07 | Cada mecánica necesita una prueba visible en la arena grey-box antes de considerarse hecha | **Propuesta del PDF, incumplida** |

---

## 8. Backlog priorizado

Nivel Épica → Feature → Tarea significativa. **Prioridad por dependencias y riesgo, no por interés.**

Prioridades: **P0** bloqueante · **P1** fundamental · **P2** importante para una experiencia jugable sólida · **P3** mejora · **P4** futuro.
Complejidad: **XS** <1 día · **S** 1-2 días · **M** 3-5 días · **L** 1-2 semanas · **XL** >2 semanas.

### Épica A — Salvar el trabajo y hacerlo verificable

| ID | Tarea | Objetivo / problema | Sistemas | Dep. | Prio | Compl. | Riesgo | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **A1** | Commitear y pushear todo el trabajo pendiente de `feat/loot-chest-scene` | 1.700 líneas existen en un solo disco. Restaurar `AGENTS.md` en Git | Repo | — | **P0** | XS | Bajo | `git status`: 23 modificados, 27 sin trackear, `AGENTS.md` borrado |
| **A2** | Abrir PR de `feat/loot-chest-scene` → `develop` y fusionar `develop` → `main` | Las 9 ramas de hito viven en `develop`; `main` está a mes y medio | Repo | A1 | **P0** | S | Medio | `roadmap_progress.md`: *"Abrir PR develop hacia main solo despues de validar la cascada"* |
| **A3** | Podar las 18 ramas locales muertas (`codex/*`, `test/*`, `chore/*` ya integradas) | El repo tiene 18 ramas locales y 5 remotas; nadie sabe cuál es la viva | Repo | A2 | P2 | XS | Bajo | `git branch -a` |
| **A4** | **Runner único de verificación**: un script (`tools/run_all_checks.py` o `Makefile`) que ejecute los 21 headless y los 13 validadores y devuelva un exit code | Hoy se corren a mano, uno por uno. 3 validadores y 9 checks ni siquiera están documentados | Tooling | A1 | **P0** | S | Bajo | Ausencia total de runner; `AGENTS.md:120` delega en el operador |
| **A5** | **CI que ejecute A4**: workflow con Godot headless en PR a `develop` y `main` | El único workflow existente reconstruye Graphify. Cero cobertura automática | CI | A4 | **P0** | M | Medio | `.github/workflows/` contiene un solo archivo |
| **A6** | Test de invariante `attack_overlay_duration × 1.15 < attack_cooldown` | Acoplamiento numérico cross-file escrito solo en comentarios | Combate | A4 | P1 | XS | Bajo | `animator:80-85`, `player.gd:33-36` |
| **A7** | Regenerar Graphify y decidir su papel | El grafo ignora cofres, loot y guardado | Tooling | A2 | P2 | XS | Bajo | §4.4 |

### Épica B — Cerrar decisiones de diseño abiertas

| ID | Tarea | Objetivo / problema | Sistemas | Dep. | Prio | Compl. | Riesgo | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **B1** | **Definir la muerte del jugador**: respawn, penalización, checkpoint, pantalla | No existe. Sin ella no hay tensión y ningún build es preferible a otro | Diseño / Combate / Save | — | **P0** | S (decisión) + M (impl.) | **Alto** | §2.5.1, `player_died` sin consecuencia |
| **B2** | **Decidir el vocabulario canónico de calidad** (inglés vs español) y actualizar los 3 documentos perdedores | C3: dos documentos declaran canónicos los ids españoles, uno los ingleses. El código usa los ingleses | Datos / Docs | — | **P0** | XS | Bajo | C3 |
| **B3** | **Decidir el destino de durabilidad, mutaciones y combos**: implementar o borrar los campos | 20 campos por hueso que se autoran, validan y documentan sin producir experiencia | Datos / Diseño | — | **P1** | S (decisión) | Medio | D4, roadmap filas 70-75 |
| **B4** | **Documentar qué es un trial** y su contrato | Sistema implementado, persistido y usado por cofres, sin una línea de diseño | Diseño / Docs | — | **P1** | XS | Bajo | RF-P2 |
| **B5** | Reconciliar C1, C2, C4, C5, C6, C7, C8, C9 en los documentos | Ocho contradicciones que hacen la documentación no confiable | Docs | B2 | **P1** | S | Bajo | §2.4 |
| **B6** | **Decidir el destino de las 4 señales sin oyente** (`pickup_focus_changed`, `pickup_collected`, `drop_spawned`, `camp_chest_opened`) | API muerta o futura; hoy nadie sabe cuál | Eventos | — | P2 | XS | Bajo | §4.3 |
| **B7** | Decidir si hay sinks (economía, límite de inventario, coste) | Sin sinks, el inventario solo crece y equipar deja de tener coste de oportunidad | Diseño | B3 | P2 | S | Medio | D3 |

### Épica C — Estabilizar el balance y cerrar exploits

| ID | Tarea | Objetivo / problema | Sistemas | Dep. | Prio | Compl. | Riesgo | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **C1** | **Arreglar `stealth_finish_max_health`**: convertirlo en fracción de `max_health` | Hoy cualquier enemigo estándar a vida llena es ejecutable de un golpe | Combate | — | **P0** | XS | **Alto** | R4 / D2: `enemy.gd:142` vs `:10`, y `:2202` |
| **C2** | Extraer `QUALITY_TABLE`, `FAMILY_RULES`, `SYMMETRY_RULES`, `QUALITY_RULES` a `Resource` | Toda la economía de calidad y sets vive en constantes de GDScript | Datos | A4 | P1 | M | Medio | §6.2 |
| **C3** | Extraer el catálogo de miembros enemigos a `.tres` | ~35 funciones hardcodeadas para ~15 tipos de hueso; añadir un enemigo toca 3 archivos | Datos | C2 | P1 | L | Medio | `equipment_rules_service.gd:353-735` |
| **C4** | Eliminar la segunda fuente de verdad de stats de enemigo en `testing_environment.gd` | Puede divergir en silencio de `enemy.gd` | QA / Enemigos | C3 | P2 | S | Medio | `testing_environment.gd:373-410` |
| **C5** | Exportar los magic numbers de sigilo, feedback y drop | Cuatro valores de ruido y ~15 timings no ajustables sin editar código | Combate | — | P2 | S | Bajo | §6.2 |
| **C6** | Mover el HUD del jugador a layout responsive | Coordenadas absolutas para 1280×720, contra la regla explícita del proyecto | UI | — | P2 | S | Bajo | `player.gd:1932,1965` |

### Épica D — Cortar la deuda de acoplamiento (incremental, no reescritura)

| ID | Tarea | Objetivo / problema | Sistemas | Dep. | Prio | Compl. | Riesgo | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **D1** | Sustituir los 20 `has_method(...)` del protocolo `player` ↔ animador por métodos tipados | La variable ya está tipada; el `has_method` solo oculta errores de refactor | Combate / Rig | A5 | **P1** | M | Medio | `player.gd:1183-1236` |
| **D2** | Sustituir los 15 `player.call("...")` de la UI por una interfaz tipada | Ningún error de nombre se detecta en compilación | UI | A5 | **P1** | M | Medio | `player_inventory_ui.gd:334-2241` |
| **D3** | **Extraer `ControlSettingsService`** (autoload) del `player_inventory_ui.gd`: rebinding, `InputMap` y `control_settings.cfg` | Cada instancia de jugador que se crea reconfigura el `InputMap` del proceso entero | UI / Input | A5 | **P1** | S | Medio | `player_inventory_ui.gd:227,3095-3428` |
| **D4** | Extraer de `player.gd`: `PlayerCombatComponent`, `PlayerRangedComponent`, `PlayerBackstabComponent`, `PlayerHUD` | 2.017 líneas; los componentes existentes solo añadieron una capa de reenvío | Jugador | A5, D1 | P1 | L | **Alto** | §4.6 |
| **D5** | Extraer `PlayerDetachedHeadComponent` (≈280 líneas + 5 booleanos de estado) | El subsistema más grande y con cero pruebas headless | Jugador | D4 | P2 | M | **Alto** | `player.gd:1596-1875` |
| **D6** | Mover a servicios la lógica de dominio de la UI: preview de sinergias, comparación de stats (3 implementaciones), stacking, detección de rechazo por hash | La UI **deduce** que un equipado falló comparando hashes, y **roba** el motivo de una señal global | UI / Reglas | D2 | P1 | M | Medio | §5 del informe de código |
| **D7** | Extraer los 3 perfiles de enemigo a estrategias o `Resource` | Hoy son `@export` + `if lizard_profile_active` esparcidos por 2.353 líneas | Enemigos | C3 | P2 | L | **Alto** | `enemy.gd:2191-2246` |
| **D8** | Factorizar el bloque de reseteo de `enemy.gd` (aparece 5 veces) y los 3 ataques ranged casi idénticos | Copia-pega evidente, ya divergió una vez en balística | Enemigos | — | P2 | S | Medio | `enemy.gd:1745,1780,1795,1837,1867` |
| **D9** | Unificar `bone.gd` y `limb_bone_pickup.gd` | Dos rutas de pickup casi idénticas | Drops | — | P3 | S | Bajo | §4.6 |
| **D10** | Consolidar `UNKNOWN_COLOR` (×3), `PLAYER_BONUS_DEFAULTS` (×2), `display_name_with_slot` (×3), `effect_text` (×2) | Duplicación literal con **dos vocabularios de slot incompatibles** | Servicios | B2 | P2 | S | Medio | §4.6 |
| **D11** | Romper el ciclo `BoneDefinition` → servicios: el `Resource` de datos no debe conocer las reglas | Ciclo cerrado de 4 clases; contradice `AGENTS.md` | Datos | C2 | P3 | M | **Alto** | §4.5 |

### Épica E — Limpieza

| ID | Tarea | Objetivo | Prio | Compl. | Riesgo |
| --- | --- | --- | --- | --- | --- |
| **E1** | Borrar `scripts/_rt6.gd` y `node_3d.tscn` (huérfanos verificados) | P2 | XS | Bajo |
| **E2** | **Reescribir `validate_inventory_build_presets.py` y `validate_inventory_preview_contract.py`** para que prueben comportamiento, no cadenas literales | P1 | S | Medio — hoy bloquean E3 |
| **E3** | Borrar el código muerto verificado: `_save_equipment_build`, `_apply_equipment_build`, `has_bone_equipped`, `recalculate_inventory_stats`, `_quality_counts_for`, `build_state_label`, `get_limb_meshes`, `limb_socket_group`, camino de "visuals" de `PlayerEquipmentComponent`, rama inalcanzable de `_drop_bone` | P2 | S | Medio |
| **E4** | Borrar `use_rigged_limbs` / `use_skeleton_model` y su soporte, o activarlos | P3 | S | Medio |
| **E5** | Sacar `DemoMode` (≈200 líneas) del animador de producción a la escena sandbox | P3 | S | Bajo |
| **E6** | Borrar `BoneDataCatalog.DEFINITIONS` (406 líneas de fallback inalcanzable y desincronizado) | P2 | XS | Medio |
| **E7** | Apagar `show_socket_markers` en `player.tscn` | P2 | XS | Bajo |
| **E8** | Cerrar `use_split_limbs`: cortes 2 (enemigos) y 3 (proporciones) | P3 | L | Alto |

### Épica F — Rendimiento y robustez

| ID | Tarea | Prio | Compl. | Riesgo |
| --- | --- | --- | --- | --- |
| **F1** | Cachear el top-Y por cuerpo en `attack_hitbox._body_top_y` (hoy genera `get_debug_mesh()` cada frame) | **P1** | S | Bajo |
| **F2** | Culling por distancia antes del escaneo de grupo en `_find_stealth_target` | P1 | XS | Bajo |
| **F3** | Reutilizar los `SubViewport` de las tarjetas de build en vez de destruirlos y recrearlos | P1 | M | Medio |
| **F4** | Poner un límite de iteraciones a `_respawn_after_delay` | P1 | XS | Bajo |
| **F5** | Cancelar las corrutinas de cooldown al morir el jugador o cambiar de escena | P1 | S | Medio |
| **F6** | Reset coordinado de estado estático en `new_game()` | **P1** | S | Medio |
| **F7** | `BoneDatabase.get_def()` debe devolver copia, no referencia compartida | P2 | XS | Medio |
| **F8** | Persistir el estado del RNG de calidad y sembrar `seed` además de `state` | P2 | S | Medio |
| **F9** | Sembrar el RNG de drops de enemigo (hoy `randi_range` global) | P2 | S | Medio |
| **F10** | Emitir/restaurar `completed_trials` al cargar partida (hoy el panel dice 0/3) | P2 | XS | Bajo |
| **F11** | Validar `chest_id` en `_ready()` del cofre, no solo en un check de `main.tscn` | P2 | XS | Bajo |
| **F12** | `LootTableService.table_for` debe fallar ruidosamente ante una tabla inválida, no cachearla | P2 | XS | Bajo |
| **F13** | Unificar el parentado de objetos spawneados en una sola convención | P3 | S | Medio |

### Épica G — Contenido y experiencia

| ID | Tarea | Prio | Compl. | Riesgo |
| --- | --- | --- | --- | --- |
| **G1** | Distribuir enemigos y trials en las 7 regiones con spawn points por región | **P2** | M | Medio |
| **G2** | Feedback de daño del jugador visible (hoy pinta un mesh oculto) | **P2** | S | Bajo |
| **G3** | Set de audio placeholder: golpe, muerte, pickup, equipar, cofre, trial | P2 | M | Bajo |
| **G4** | Confirmación visual al equipar (hoy solo `print()` y una señal) | P3 | S | Bajo |
| **G5** | Filtros de inventario por rareza y peso (roadmap 46-47: "No iniciado") | P3 | S | Bajo |
| **G6** | Codos y rodillas para enemigos (`use_split_limbs` en `enemy.tscn`) | P3 | M | Alto |

---

## 9. Roadmap por fases

Modifiqué las fases que propusiste en un punto: **inserté una fase de rescate antes de la clarificación**, porque hoy el riesgo mayor no es la ambigüedad sino la pérdida del trabajo. Y **moví el playtest antes del core gameplay**, porque construir más sistemas sobre un loop no validado es exactamente el error que el proyecto ya cometió una vez.

### Fase −1 — Rescate (1-2 días)

- **Objetivo:** que ninguna línea de código exista en un solo disco duro, y que la suite pueda ejecutarse con un comando.
- **Sistemas:** repo, CI, tooling.
- **Requisitos previos:** ninguno.
- **Tareas:** A1, A2, A4, A5.
- **Riesgos:** el merge de `feat/loot-chest-scene` → `develop` → `main` puede tener conflictos en `docs/` y en `scenes/main.tscn`. Hacerlo con la suite verde y sin regenerar Graphify en la rama, según la política ya escrita en `repo_stability_and_graphify.md`.
- **Definición de terminado:** `origin/main` contiene cofres, loot y guardado; un solo comando ejecuta los 34 checks y devuelve exit code; el CI lo corre en cada PR.
- **Resultado jugable:** ninguno. Es infraestructura, y es la fase que más reduce el riesgo total del proyecto.

### Fase 0 — Clarificación (3-5 días)

- **Objetivo:** que la documentación deje de contradecirse y que las decisiones bloqueantes estén tomadas.
- **Sistemas:** diseño, datos, docs.
- **Previos:** Fase −1.
- **Tareas:** B1 (decisión), B2, B4, B5, B6, C1, A6, A7.
- **Riesgos:** B1 (muerte del jugador) es una decisión de diseño de producto, no técnica. Si no se cierra, todo lo demás se construye sobre arena.
- **Definición de terminado:** las 9 contradicciones resueltas; un documento nuevo `docs/player_death_and_progression.md`; `docs/trial_flow.md` existe; `stealth_finish_max_health` es fraccional y hay un test que lo prueba.
- **Resultado jugable:** el backstab deja de ser dominante; el jugador muere y algo pasa.

### Fase 1 — Fundaciones (1-2 semanas)

- **Objetivo:** que los sistemas de los que todo depende sean modificables sin romper el resto.
- **Sistemas:** datos, servicios, reglas.
- **Previos:** Fase 0.
- **Tareas:** C2, C5, D3, E2, E6, F1, F2, F4, F5, F6, F10.
- **Riesgos:** C2 (extraer las tablas de calidad y sinergia a `Resource`) toca el núcleo de 32 dependientes. Hacerlo con la suite verde y en su propia rama.
- **Definición de terminado:** todo el balance de calidad y sets es editable sin abrir un `.gd`; el `InputMap` ya no se reconfigura desde la UI de inventario; los validadores prueban comportamiento; el reset de partida nueva es limpio.
- **Resultado jugable:** el mismo juego, pero tuneable.

### Fase 2 — Vertical Slice y playtest (2-3 semanas) ← **la fase que decide el proyecto**

- **Objetivo:** una experiencia completa de 10 minutos, jugada por al menos 5 personas que no la construyeron.
- **Sistemas:** los del §11.
- **Previos:** Fases −1, 0, 1.
- **Tareas:** ver §11, más G1 (parcial: solo 3 regiones), G2, G3.
- **Riesgos:** **el más alto del proyecto.** El resultado puede ser que intercambiar huesos no genere una decisión interesante. Ese es el propósito de la fase: descubrirlo ahora y no después de otras 20.000 líneas.
- **Definición de terminado:** 5 sesiones grabadas o anotadas, con `docs/vertical_slice_playtest.md` que responda: ¿entendieron matar→cosechar→equipar? ¿Cambiaron de hueso porque quisieron o porque un gate los forzó? ¿Qué hueso se sintió mejor? ¿Cuál se sintió inútil? ¿El combate se sintió justo?
- **Resultado jugable:** **sí** — de spawn a portal sin que nadie explique nada.

### Fase 3 — Core gameplay (según resultado de Fase 2)

- **Objetivo:** completar lo que el playtest demuestre que hace falta.
- **Tareas:** B3 (implementar o borrar durabilidad/mutación/combos, ahora con evidencia), B7, D1, D2, D6, F3, C6.
- **Riesgos:** la tentación de implementar los 20 campos muertos "porque ya están autorados". La decisión debe salir del playtest, no del sunk cost.
- **Definición de terminado:** ninguna feature del juego tiene campos de datos sin consumidor.
- **Resultado jugable:** el slice, pero con las mecánicas que el playtest pidió.

### Fase 4 — Progresión y contenido (3-4 semanas)

- **Objetivo:** llenar las 7 regiones y dar un vector de progresión más allá de la geografía.
- **Tareas:** G1 completo, C3 (catálogo de enemigos a `.tres`), D7, G5, G6.
- **Riesgos:** C3 y D7 son los refactors que hacen barato producir contenido. Hacerlos **antes** de crear los enemigos, no después.
- **Definición de terminado:** añadir un enemigo nuevo = un `.tres` + una escena, sin tocar `enemy.gd` ni `modular_skeleton_rig.gd`.
- **Resultado jugable:** las 7 regiones son distintas y tienen razón de existir.

### Fase 5 — Balance y UX (2-3 semanas)

- **Objetivo:** que los números se sientan bien, no solo que sumen.
- **Tareas:** la lista de §6.3, G4, más los ajustes que salgan de la Fase 2.
- **Riesgos:** si los multiplicadores de calidad (±10%) y los bonos de sinergia (+2%) resultan imperceptibles, el sistema de calidad entero es ruido y hay que decidir si se amplifica o se corta.
- **Definición de terminado:** un jugador puede nombrar la diferencia entre dos builds sin mirar la UI.

### Fase 6 — Robustez (2 semanas)

- **Tareas:** D4, D5, D8, E1, E3, E4, E5, E7, F7-F13, más pruebas headless para head-launch (hoy cero).
- **Definición de terminado:** ningún archivo pasa de 800 líneas; ninguna corrutina puede sobrevivir a la muerte de su dueño; medición real de frame time con 10 enemigos.

### Fase 7 — Escalabilidad de contenido

- **Tareas:** D10, D11, E8, pipelines documentados de "nuevo hueso / nuevo enemigo / nueva región", escenas `.tscn` para la UI en vez de construcción por código.
- **Definición de terminado:** crear contenido sigue una checklist, no una improvisación.

---

## 10. Camino crítico

```
[Repo con respaldo] ──────────────────────► TODO
        │
        ├─► [Runner + CI] ────────────────► cualquier refactor seguro
        │
        └─► [Decisión: qué pasa al morir]
                  │
                  ├─► [Riesgo real en combate] ──► [los builds importan]
                  │            │                          │
                  │            └─► [economía y sinks] ────┤
                  │                                       │
                  └─► [Checkpoint / respawn] ─────────────┤
                                                          ▼
[Capa de datos: .tres + BoneDataCatalog + BoneDatabase]   │
        │                                                 │
        └─► [BoneRulesService] ──► [stats del jugador] ───┤
                  │                                       │
                  ├─► [SynergyRulesService] ──────────────┤
                  ├─► [LootTableService] ──► [cofres] ────┤
                  └─► [BoneInstanceService] ──► [SaveService]
                                                          ▼
[ModularSkeletonRig] ─► [ProceduralAnimator] ─► [attack_impact_reached]
                                                     │
                                                     └─► [daño de backstab]
                                                          ▼
                                              ┌──► VERTICAL SLICE ──► PLAYTEST
[GameEvents] ─► [ArenaGoalManager / trials] ──┘                          │
                                                                         ▼
                                                          [decidir el resto del juego]
```

### 10.1 Dependencias técnicas

1. **Repo con respaldo → todo lo demás.** Sin esto, cualquier refactor es una apuesta.
2. **Runner + CI → cualquier refactor.** Sin ejecución automática, tocar `BoneRulesService` (32 dependientes) es adivinar.
3. **`BoneDefinition`/`.tres` → `BoneDataCatalog` → `BoneDatabase` → `BoneRulesService` → todo consumidor.** La capa de datos es la base real del juego.
4. **`BoneInstanceService` → `SaveService`.** El save no puede existir sin identidad por pieza. Ya está resuelto y bien.
5. **`ProceduralPlayerAnimator.attack_impact_reached` → daño de backstab.** El animador decide cuándo cae el daño. Es un acoplamiento invertido (la presentación gobierna la lógica) y está en el camino crítico del combate.
6. **`ModularSkeletonRig` → animador → cualquier cosa que cambie el cuerpo.** Cerrar `use_split_limbs` (E8) desbloquea codos/rodillas para enemigos y proporciones de perfil por datos.

### 10.2 Dependencias de diseño

1. **Muerte del jugador → riesgo → valor de los builds → todo el pilar del juego.** Es la única dependencia de diseño verdaderamente bloqueante. Si morir no cuesta nada, ningún build es mejor que otro y la fantasía central no se sostiene.
2. **Vocabulario canónico de calidad → capa de datos.** Trivial de decidir, imposible de posponer sin acumular alias.
3. **Durabilidad/mutación/combos → economía y sinks.** Si durabilidad se implementa, aparece el primer sink real del juego y con él una razón para la reparación, la moneda y el inventario limitado. Si se corta, hay que borrar 20 campos y simplificar el modelo.
4. **Definición de trial → diseño de las 7 regiones.** Los trial gates son el mecanismo de gating del mundo, y nadie escribió qué son.

### 10.3 Dependencias de contenido

1. **Enemigos distribuidos por región → vertical slice creíble.** Hoy están en el layout de la isla demo.
2. **`.tres` de enemigos (C3) → producir enemigos es barato.** Hacerlo **antes** de crear los 12 enemigos del plan, no después.
3. **Audio y feedback de daño → cualquier playtest válido.** Sin ellos, los testers medirán frustración de legibilidad, no de diseño.

**La regla que se deriva de todo esto:** no construir nada de la Fase 3 en adelante hasta que la Fase 2 haya producido evidencia. El proyecto ya pagó una vez por saltarse ese gate.

---

## 11. Vertical Slice recomendado

**Nombre:** *Primer Hueso* — de despertar como cabeza a cruzar el primer trial gate.
**Duración objetivo:** 8-12 minutos.
**Escenario:** BonefieldHub → FirstHuntField → ReachRidge. Tres regiones de las siete, las que ya tienen dificultad 1, 2 y 3.

### 11.1 Qué debe incluir

| Categoría | Contenido |
| --- | --- |
| **Apertura** | El jugador despierta como cabeza sola en el hub. Encuentra y equipa el `torso_bone` colocado cerca del spawn |
| **Combate** | Melee con el combo de 3 pasos. **Un solo arquetipo de enemigo** (`normal`) en FirstHuntField, y un segundo (`lizard` **o** `gorilla`, no ambos) en ReachRidge |
| **Cosecha** | Desmembramiento por daño, un limb recogible por enemigo, pickup por hold de interact con la regla de pulsación fresca |
| **Inventario** | Grid con stacks, filtro por slot, panel de detalles con comparación vs equipado, paper-doll con preview 3D |
| **Equipamiento** | Los 6 slots, con la regla torso-primero y la cabeza fija. **Una** familia de sinergia activa (`starter_bones` o `normal_parts`) |
| **Calidad** | La escalera de 5 con su color y multiplicador visible en la UI |
| **Loot** | Dos cofres: `starter_cache` en el hub (sin bloqueo) y `reach_cache` en ReachRidge (bloqueado por trial) |
| **Progresión** | Un trial gate real (el de brazo) que exige tener un brazo equipado, y que abre el cofre de ReachRidge |
| **Muerte** | La regla de B1, cualquiera que sea. **Debe existir y debe costar algo** |
| **Persistencia** | Guardar y cargar: al reabrir el juego, el mundo, el inventario, el equipo y el trial siguen igual |
| **UI/HUD** | Vida, prompt de interacción, checklist de tutorial, objetivo de región |
| **Feedback** | Golpe conectado, enemigo dañado, enemigo muerto, pieza recogida, pieza equipada, cofre abierto, trial completado — con audio placeholder y flash visible |

### 11.2 Qué debe quedar explícitamente FUERA

Esto es la mitad importante. Todas estas cosas **ya están construidas**; la propuesta no es borrarlas, es **sacarlas del alcance de validación** — desactivarlas en el build de playtest o dejarlas fuera del guion.

| Fuera | Por qué |
| --- | --- |
| **Arco y balística** | Es un sistema completo con su propia curva de aprendizaje. Introduce una segunda forma de resolver todo encuentro y contamina la lectura de si el melee y los builds funcionan |
| **Backstab y ejecución sigilosa** | Con C1 arreglado sigue siendo un sistema paralelo. Si está disponible, los testers lo usarán siempre y no verás nada del combate frontal |
| **Head-launch y cabeza desprendida** | El subsistema más grande (~700 líneas), con 5 booleanos de estado y **cero pruebas headless**. Es donde más probable es que un playtest se rompa por un bug en vez de por el diseño |
| **Arm sword (paso 4 del combo)** | Floreo visual. Ruido en la lectura |
| **Presets de build** | Es una herramienta de optimización para un jugador que ya entiende el sistema. En 10 minutos nadie la necesita, y arrastra R6 (5 mundos 3D vivos) |
| **Durabilidad, mutaciones, combos de datos** | No hacen nada. Ocultarlos de la UI hasta que B3 se decida |
| **Las 4 regiones restantes** (QuickrootRun, HeavyRuin, RibfenBonus, ElderMarrowGate) | Contenido sin validar. ElderMarrowGate está declarado como "future high-difficulty zone" |
| **`gorilla` y `lizard` a la vez** | Dos arquetipos nuevos en 10 minutos es demasiado. Uno solo, y que se lea |
| **Filtros de calidad y orden en el inventario** | Optimización para inventarios grandes. En el slice el inventario será pequeño |
| **Ranged de enemigos (flechas, rocas, saliva)** | Añade presión sin que el jugador tenga aún herramientas para responderla |

### 11.3 Qué valida el slice

- **Arquitectura:** que un cambio de balance se pueda hacer en `.tres` y probarse en minutos.
- **Gameplay:** que matar → cosechar → equipar produzca al menos **una decisión genuinamente interesante**.
- **Interacción:** que pickup, cofre y trial se entiendan sin explicación.
- **Progresión:** que el jugador quiera el siguiente hueso.
- **UI:** que el comparador de stats haga que la decisión sea legible.
- **Balance básico:** que un enemigo se sienta justo y que un build se sienta distinto de otro.
- **Persistencia:** que cerrar y reabrir no pierda nada.
- **Experiencia real:** que 5 personas lleguen del spawn al portal sin que nadie les hable.

Ese último punto es la única métrica que importa en esta fase.

---

## 12. Criterios de aceptación

Observables, no ambiguos. Estos son los principales; cada tarea del backlog debería heredar de aquí.

### CA-01 — Repo y verificación

- `git status` en la rama de trabajo devuelve limpio, y `origin/main` contiene `scripts/chest.gd`, `scripts/save_service.gd`, `data/loot_tables/` y `.agents/AGENTS.md`.
- Un solo comando ejecuta los 21 checks headless y los 13 validadores y devuelve exit code 0.
- Un PR con un cambio que rompe cualquier check **no puede fusionarse**.
- *Caso límite:* si Godot CLI no está disponible en el runner, el CI falla ruidosamente en vez de reportar verde.

### CA-02 — Ejecución sigilosa (C1)

- Un enemigo `normal` a 40/40 de vida **no** puede ser ejecutado.
- Un enemigo `normal` por debajo del umbral fraccional definido **sí** puede.
- Un enemigo `gorilla` con `max_health = 70` usa el mismo umbral relativo, no uno absoluto heredado.
- *Error esperado:* intentar ejecutar por encima del umbral produce un ambush (daño ×2), no un fallo silencioso.
- *Prueba:* headless con matriz `health/max_health` × 3 arquetipos.

### CA-03 — Muerte del jugador (B1)

- Al llegar a 0 de vida ocurre un efecto observable y **definido en un documento**.
- El estado post-muerte es determinista: dos muertes idénticas producen el mismo resultado.
- *Persistencia:* si el diseño incluye pérdida, la pérdida se refleja tras guardar y cargar.
- *Interacción:* morir durante una ejecución sigilosa, con el inventario abierto, o a mitad de un head-launch, no deja al jugador bloqueado (hay dos bugs de freeze de ese tipo ya corregidos en el historial — la prueba debe cubrirlos).

### CA-04 — Datos de balance (C2, C3)

- La tabla de calidad puede modificarse **sin editar un `.gd`**, y el cambio se refleja en el juego al recargar.
- Los bonos de un set pueden cambiarse desde un `.tres`.
- Añadir un tipo de hueso de enemigo requiere **un archivo de datos y ninguna edición de código**.
- *Caso límite:* una tabla de calidad cuyas probabilidades no sumen 100 es **rechazada con error visible**, no cacheada con un warning.

### CA-05 — Persistencia

- Guardar, cerrar el juego, reabrir y cargar deja idénticos: inventario, equipamiento, calidad de cada pieza, posición y vida del jugador, cofres abiertos, trials completados y enemigos vivos.
- El contador de trials del panel muestra el número correcto tras cargar (hoy muestra 0/3).
- Una partida nueva **no hereda** ninguna instancia de hueso de la partida anterior.
- *Error esperado:* un save de versión desconocida se rechaza entero y el juego arranca como partida nueva, sin aplicar nada a medias.

### CA-06 — Desacoplamiento (D1, D2, D3)

- La UI de inventario **no contiene** ninguna llamada `player.call("...")` con nombre de método en string.
- La UI de inventario **no accede** a `player.rig` ni a `player.equipment_builds_component`.
- Cambiar el nombre de un método público del jugador produce un **error de compilación**, no un fallo en runtime.
- Instanciar un segundo jugador **no** reconfigura el `InputMap` del proceso.
- Un componente de combate puede reemplazarse sin tocar el inventario ni el rig.

### CA-07 — Reglas y UI

- Ninguna regla de negocio existe en dos implementaciones distintas: hay **una** función que compara dos piezas, **una** que decide si un equipado es válido, **una** que produce el nombre con slot.
- Un equipado rechazado devuelve **un resultado explícito** con motivo; la UI no lo deduce comparando hashes ni lo intercepta de una señal global.
- *Prueba:* headless que equipe una pierna sin torso y verifique que el retorno contiene el motivo.

### CA-08 — Rendimiento

- Con 10 enemigos activos y un hitbox vivo, el frame time se mantiene por debajo del presupuesto de 60 Hz (medición real, no estimación).
- Abrir la pestaña de builds y clicar entre 3 builds **no** destruye ni recrea ningún `SubViewport`.
- `_find_stealth_target` no itera sobre enemigos fuera de `stealth_prompt_scan_range`.
- *Caso límite:* un enemigo cuyo punto de respawn está permanentemente en cámara reaparece de todas formas tras un número acotado de intentos.

### CA-09 — Documentación

- Ninguna de las 9 contradicciones de §2.4 sigue en pie.
- Existe `docs/trial_flow.md` y `docs/player_death_and_progression.md`.
- Ningún campo de `BoneDefinition` está documentado como "para reglas futuras" sin una entrada de backlog asociada.
- Graphify se regeneró después del merge, o se documentó explícitamente que se deja de usar.

### CA-10 — Vertical slice

- Cinco personas que no construyeron el juego llegan del spawn al portal **sin explicación verbal**.
- Al menos tres de ellas cambian de hueso **por decisión propia**, no porque un gate lo exija.
- Cada una puede nombrar, al terminar, qué hueso prefirió y por qué.
- Existe `docs/vertical_slice_playtest.md` con las respuestas.

---

## 13. Tablero de desarrollo

Formato de tablero, ordenado por fase. Estado inicial: todo `Pendiente`. Copiar a un Projects de GitHub o a una hoja de cálculo.

| ID | Fase | Sistema | Tarea | Prio | Dependencias | Riesgo | Estado | Criterio de aceptación |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| A1 | −1 | Repo | Commitear y pushear `feat/loot-chest-scene` | P0 | — | Bajo | Pendiente | CA-01 |
| A2 | −1 | Repo | PR `feat/loot-chest-scene`→`develop`→`main` | P0 | A1 | Medio | Pendiente | CA-01 |
| A4 | −1 | Tooling | Runner único de los 34 checks | P0 | A1 | Bajo | Pendiente | CA-01 |
| A5 | −1 | CI | Workflow con Godot headless en PR | P0 | A4 | Medio | Pendiente | CA-01 |
| C1 | 0 | Combate | `stealth_finish_max_health` fraccional | P0 | A5 | Alto | Pendiente | CA-02 |
| B1 | 0 | Diseño | Definir muerte del jugador | P0 | — | Alto | Pendiente | CA-03 |
| B2 | 0 | Datos | Vocabulario canónico de calidad | P0 | — | Bajo | Pendiente | CA-09 |
| B4 | 0 | Docs | Documentar qué es un trial | P1 | — | Bajo | Pendiente | CA-09 |
| B5 | 0 | Docs | Reconciliar las 9 contradicciones | P1 | B2 | Bajo | Pendiente | CA-09 |
| B6 | 0 | Eventos | Decidir las 4 señales sin oyente | P2 | — | Bajo | Pendiente | CA-09 |
| A6 | 0 | Combate | Test de invariante overlay/cooldown | P1 | A4 | Bajo | Pendiente | CA-01 |
| A7 | 0 | Tooling | Regenerar Graphify o retirarlo | P2 | A2 | Bajo | Pendiente | CA-09 |
| E2 | 1 | Tooling | Validadores que prueben comportamiento | P1 | A4 | Medio | Pendiente | CA-01 |
| C2 | 1 | Datos | Calidad y sinergias a `Resource` | P1 | A5, E2 | Medio | Pendiente | CA-04 |
| C5 | 1 | Combate | Exportar magic numbers de sigilo/feedback | P2 | — | Bajo | Pendiente | CA-04 |
| D3 | 1 | Input | Extraer `ControlSettingsService` | P1 | A5 | Medio | Pendiente | CA-06 |
| E6 | 1 | Datos | Borrar `BoneDataCatalog.DEFINITIONS` | P2 | C2 | Medio | Pendiente | CA-04 |
| F1 | 1 | Combate | Cachear `_body_top_y` del hitbox | P1 | A5 | Bajo | Pendiente | CA-08 |
| F2 | 1 | Combate | Culling en `_find_stealth_target` | P1 | A5 | Bajo | Pendiente | CA-08 |
| F4 | 1 | Enemigos | Acotar `_respawn_after_delay` | P1 | A5 | Bajo | Pendiente | CA-08 |
| F5 | 1 | Combate | Cancelar corrutinas al morir | P1 | B1 | Medio | Pendiente | CA-03 |
| F6 | 1 | Save | Reset de estado estático en `new_game` | P1 | A5 | Medio | Pendiente | CA-05 |
| F10 | 1 | Save | Restaurar `completed_trials` al cargar | P2 | A5 | Bajo | Pendiente | CA-05 |
| VS1 | 2 | Slice | Construir el build de playtest (§11) | P0 | Fase 1 | Alto | Pendiente | CA-10 |
| G1a | 2 | Mundo | Poblar hub, FirstHunt y ReachRidge | P2 | VS1 | Medio | Pendiente | CA-10 |
| G2 | 2 | Feedback | Daño del jugador visible | P2 | VS1 | Bajo | Pendiente | CA-10 |
| G3 | 2 | Audio | 6 sonidos placeholder | P2 | VS1 | Bajo | Pendiente | CA-10 |
| PT1 | 2 | QA | 5 playtests con externos + informe | P0 | VS1, G2, G3 | Alto | Pendiente | CA-10 |
| B3 | 3 | Diseño | Durabilidad/mutación/combos: implementar o borrar | P1 | PT1 | Medio | Pendiente | CA-09 |
| B7 | 3 | Diseño | Decidir sinks y economía | P2 | B3 | Medio | Pendiente | CA-09 |
| D1 | 3 | Rig | Interfaz tipada player↔animador | P1 | A5 | Medio | Pendiente | CA-06 |
| D2 | 3 | UI | Interfaz tipada UI↔player | P1 | A5 | Medio | Pendiente | CA-06 |
| D6 | 3 | UI | Mover lógica de dominio de UI a servicios | P1 | D2 | Medio | Pendiente | CA-07 |
| F3 | 3 | UI | Reutilizar `SubViewport` de builds | P1 | D2 | Medio | Pendiente | CA-08 |
| C6 | 3 | UI | HUD responsive | P2 | — | Bajo | Pendiente | CA-08 |
| C3 | 4 | Datos | Catálogo de enemigos a `.tres` | P1 | C2 | Medio | Pendiente | CA-04 |
| D7 | 4 | Enemigos | Perfiles de enemigo como estrategias | P2 | C3 | Alto | Pendiente | CA-04 |
| C4 | 4 | QA | Eliminar stats duplicados de testing env | P2 | C3 | Medio | Pendiente | CA-04 |
| G1b | 4 | Mundo | Poblar las 4 regiones restantes | P2 | C3 | Medio | Pendiente | CA-10 |
| G5 | 4 | UI | Filtros por rareza y peso | P3 | — | Bajo | Pendiente | — |
| G6 | 4 | Rig | Codos y rodillas para enemigos | P3 | E8 | Alto | Pendiente | — |
| BAL | 5 | Balance | Sesión de balance sobre §6.3 | P2 | PT1 | Medio | Pendiente | CA-10 |
| G4 | 5 | UI | Confirmación visual al equipar | P3 | — | Bajo | Pendiente | — |
| D4 | 6 | Jugador | Extraer combate/ranged/backstab/HUD de `player.gd` | P1 | D1 | Alto | Pendiente | CA-06 |
| D5 | 6 | Jugador | Extraer `PlayerDetachedHeadComponent` | P2 | D4 | Alto | Pendiente | CA-06 |
| D8 | 6 | Enemigos | Factorizar reseteo ×5 y ranged ×3 | P2 | — | Medio | Pendiente | CA-07 |
| HL1 | 6 | Combate | Pruebas headless de head-launch | P1 | D5 | Medio | Pendiente | CA-01 |
| E1 | 6 | Limpieza | Borrar `_rt6.gd` y `node_3d.tscn` | P2 | — | Bajo | Pendiente | — |
| E3 | 6 | Limpieza | Borrar el código muerto verificado | P2 | E2 | Medio | Pendiente | — |
| E4 | 6 | Rig | Borrar o activar `use_rigged_limbs` | P3 | — | Medio | Pendiente | — |
| E5 | 6 | Rig | Sacar `DemoMode` del animador | P3 | — | Bajo | Pendiente | — |
| E7 | 6 | Rig | Apagar `show_socket_markers` | P2 | — | Bajo | Pendiente | — |
| F7-F13 | 6 | Varios | Copias defensivas, RNG, `chest_id`, parentado | P2 | A5 | Medio | Pendiente | CA-05/08 |
| D9 | 7 | Drops | Unificar `bone.gd` y `limb_bone_pickup.gd` | P3 | — | Bajo | Pendiente | CA-07 |
| D10 | 7 | Servicios | Consolidar constantes y vocabularios duplicados | P2 | B2 | Medio | Pendiente | CA-07 |
| D11 | 7 | Datos | Romper el ciclo `BoneDefinition`→servicios | P3 | C2 | Alto | Pendiente | — |
| E8 | 7 | Rig | Cerrar `use_split_limbs` (cortes 2 y 3) | P3 | C3 | Alto | Pendiente | — |
| A3 | 7 | Repo | Podar las 18 ramas muertas | P2 | A2 | Bajo | Pendiente | — |
| UI1 | 7 | UI | Escenas `.tscn` para la UI en vez de código | P4 | D2 | Alto | Pendiente | — |

---

## 14. Preguntas críticas pendientes

No incluyo nada que se pueda resolver leyendo el proyecto. Ordenadas por cuánto bloquean el roadmap.

### Bloqueantes ahora

**Q1. ¿Qué pasa cuando el jugador muere?**
Es la pregunta más importante del proyecto y no tiene respuesta en ninguna parte. Sin ella no hay riesgo, sin riesgo no hay razón para preferir un build, y sin eso el pilar "your body is your build" no se sostiene. Opciones que la arquitectura ya soporta: reaparecer en el hub perdiendo las piezas no equipadas; reaparecer como cabeza sola con el equipo caído en el sitio; cargar el último save; perder solo la pieza que se rompió. Cada una implica un juego distinto.

**Q2. ¿Cuál es la duración objetivo de una sesión y del juego completo?**
No aparece en ningún documento. Determina si 7 regiones son muchas o pocas, si 5 slots dan suficiente combinatoria, y si hace falta progresión más allá de la geografía. El PDF sugería 10-15 minutos para el demo y "4 áreas, 12 enemigos, 12 huesos, 4 jefes" como techo ambicioso para un solo desarrollador — pero eso fue una propuesta, no una decisión.

**Q3. ¿Los ids canónicos de calidad son en inglés o en español?**
Tres documentos se contradicen (C3). El código usa inglés. Es trivial de decidir y bloquea la limpieza de la capa de datos.

**Q4. ¿Durabilidad, mutaciones y combos son mecánicas reales o se cortan?**
Veinte campos por hueso, autorados, validados y documentados, con cero efecto. Si son reales, aparece el primer sink del juego y hay que diseñar reparación y economía. Si no lo son, hay que borrarlos antes de que alguien construya encima. **No decidir es la peor opción**, porque cada mes que pasa se autoran más datos muertos.

**Q5. ¿Qué es un trial y cómo se completa?**
Está implementado, persistido y es el mecanismo de gating de los cofres y del mundo. Nadie escribió qué es. Sin esta respuesta las 7 regiones no se pueden diseñar.

### Bloqueantes en la próxima fase

**Q6. ¿Están dispuestos a hacer el playtest antes de seguir construyendo?**
Esta es una pregunta de proceso, no de producto, y es la que más cambia la trayectoria del proyecto. El plan original la incluía como decision gate y se saltó. Volver a saltarla significa apostar otras 20.000 líneas a que el loop funciona.

**Q7. ¿El proyecto quiere un solo arquetipo de enemigo bien resuelto o tres a medias?**
Hoy hay tres (`normal`, `gorilla`, `lizard`) implementados como `@export` + condicionales esparcidos por 2.353 líneas, y ninguno validado. El coste de hacerlos data-driven (C3) se paga una vez; el coste de mantener tres a mano crece con cada uno.

**Q8. ¿Multiplicadores de calidad de ±10% y sinergias de +2% son perceptibles?**
Nadie lo sabe porque nadie ha jugado. Si no lo son, todo el sistema de calidad es ruido caro. Si lo son, hay que decidir el techo. La respuesta sale del playtest, no de una discusión.

**Q9. ¿Hay límite de inventario?**
`inventory_weight` está calculado y sin consumidor. Sin límite, el inventario solo crece y las decisiones de equipar pierden coste de oportunidad.

### Bloqueantes más adelante

**Q10. ¿Cuál es el papel del `GuideWisp`?**
Existe, está instanciado en `main.tscn`, y no aparece en ninguno de los 14 documentos de flujo. Es la única pieza del juego de la que no hay absolutamente nada escrito.

**Q11. ¿Hay narrativa, o el mundo se explica solo?**
Hoy hay cuatro líneas de arranque y vocabulario sugerente (`ElderMarrowGate`, mutaciones `corrupto`/`maldito`) que existe solo como metadata. Es una decisión de producto que afecta al arte, al audio y al ritmo.

**Q12. ¿Cuál es el objetivo de la isla del demo?**
El panel de tutorial promete mostrarlo. No está definido.

**Q13. ¿Cómo van a dividirse el trabajo ustedes dos?**
Es la pregunta que motivó esta auditoría y merece una respuesta explícita. La forma del proyecto sugiere una división natural que ya existe de facto: la capa de reglas (`*_service.gd`, datos, save, loot) es pura, testeable y modificable sin entender el rig ni la animación — es el mejor punto de entrada para alguien que está subiéndose ahora. La capa de nodos (`player.gd`, `enemy.gd`, el animador) requiere el contexto acumulado de meses. Poner a las dos personas a tocar `player.gd` a la vez es la receta para conflictos de merge en un archivo de 2.017 líneas.

---

## 15. Top 10 acciones siguientes

En orden. Las tres primeras no admiten discusión previa.

| # | Acción | Por qué ahora | Esfuerzo |
| --- | --- | --- | --- |
| **1** | **Commitear y pushear todo lo pendiente de `feat/loot-chest-scene`, incluyendo `.agents/AGENTS.md`** | Cinco semanas de trabajo —cofres, loot, guardado, 6 checks, 2 documentos y las reglas del proyecto— existen en un solo disco. Es el único riesgo del proyecto que puede borrar todo lo demás | 1 hora |
| **2** | **Fusionar `develop` en `main`** y podar las ramas muertas | `main` está a mes y medio del trabajo real; hay 18 ramas locales y nadie sabe cuál es la viva | Medio día |
| **3** | **Escribir el runner único y el workflow de CI que ejecute los 34 checks** | Existe una suite genuinamente buena que nadie ejecuta. Sin ella, cualquier refactor de `BoneRulesService` (32 dependientes) es adivinar | 1-2 días |
| **4** | **Arreglar `stealth_finish_max_health`** para que sea fracción de `max_health` | Un enemigo estándar a vida llena es ejecutable de un golpe. Es el exploit más obvio y hace irrelevante todo el combate frontal, que es donde vive la diferenciación de builds | 1 hora + test |
| **5** | **Sentarse los dos y decidir qué pasa cuando el jugador muere**, y escribirlo en `docs/player_death_and_progression.md` | Sin consecuencia por morir no hay riesgo, sin riesgo ningún build es mejor que otro, y el pilar del juego no se sostiene. Es una conversación de una hora que desbloquea el resto del roadmap | 1 hora de decisión |
| **6** | **Resolver las 9 contradicciones de la documentación**, empezando por el vocabulario de calidad | Hoy la documentación es abundante y no confiable, y esa es una de las razones por las que tú no tienes una vista clara del proyecto | 1-2 días |
| **7** | **Decidir el destino de durabilidad, mutaciones y combos** | Veinte campos por hueso que se autoran, validan y documentan sin producir ninguna experiencia. Cada mes que pasa se acumulan más datos muertos | 1 hora de decisión |
| **8** | **Extraer la tabla de calidad y las reglas de sinergia a `Resource`** | Es todo el balance de progresión del juego viviendo en constantes de GDScript. Sin esto, la Fase 5 de balance es editar código y recompilar por cada ajuste | 3-5 días |
| **9** | **Construir el vertical slice del §11 y jugarlo con 5 personas** | Es el gate que el plan original definía y que el proyecto se saltó. Todo lo que se construya antes de esto es una apuesta sobre si el loop funciona | 2-3 semanas |
| **10** | **Regenerar Graphify, y decidir si vale la pena mantenerlo** | Hoy describe un proyecto que dejó de existir hace mes y medio: no conoce cofres, ni loot, ni guardado. Como referencia de dependencias sirve; como fuente de verdad, `AGENTS.md` ya dice que no | 1 hora + decisión |

---

## Nota de método

Lo que está en este documento se verificó leyendo los archivos. Lo que no pudo verificarse está marcado. Específicamente:

- **No se ejecutó el juego.** No hay Godot disponible en el entorno desde el que se hizo la auditoría. Todas las afirmaciones sobre comportamiento en pantalla —el jitter de cámara, la legibilidad del combate, si los marcadores de socket se ven, si el flash de daño del jugador es invisible— son inferencias del código, no observaciones.
- **No se ejecutó ningún check headless ni validador.** Sus descripciones salen de leer sus fuentes.
- **No se modificó ni un archivo del proyecto**, según la regla que pusiste.
- Las afirmaciones de "cero referencias" y "código muerto" se verificaron con `grep` sobre `scripts/`, `scenes/`, `tools/`, `docs/` y `.github/`, no se supusieron.
- Las cifras de líneas, fan-in y fan-out se contaron, no se estimaron.
