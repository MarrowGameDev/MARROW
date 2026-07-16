# Roadmap Tecnico 1-165

Fecha base: 2026-07-15

Este archivo es la fuente auditable del roadmap tecnico. Los estados son
conservadores: un objetivo no se marca como cumplido si solo existe metadata,
documentacion o una prueba estatica sin integracion/runtime cuando el objetivo
requiere gameplay.

Estados usados:

- No iniciado.
- Preparado.
- Parcial.
- Integrado.
- Validacion pendiente.
- Validado estaticamente.
- Validado manualmente.
- Bloqueado.
- Obsoleto por implementacion existente.

## Tabla

| N | Sistema | Objetivo | Estado actual | Evidencia / pendiente |
| --- | --- | --- | --- | --- |
| 1 | Repo | Mantener trabajo fuera de `main` mediante ramas de hito. | Parcial | Branch policy documentada; requiere PR de este hito. |
| 2 | Repo | Mantener commits pequenos y reversibles dentro de cada rama. | Parcial | Commits anteriores pequenos; seguir auditando por PR. |
| 3 | Repo | Evitar force-push y reescritura de historial. | Preparado | Politica en goal y docs; sin evidencia de force-push local. |
| 4 | Repo | Crear preflight de commits reproducible. | Integrado | `docs/repo_stability_and_graphify.md`. |
| 5 | Repo | Definir politica de line endings. | Integrado | `.gitattributes`. |
| 6 | Repo | Evitar commits accidentales de `.import`. | Preparado | Politica documentada; requiere disciplina en PRs. |
| 7 | Repo | Definir politica de caches. | Integrado | `.gitignore` y politica Graphify. |
| 8 | Repo | Definir politica Graphify para ramas feature. | Integrado | Workflow limitado y politica documentada. |
| 9 | Arquitectura | Confirmar componentes de inventario existentes. | Preparado | `PlayerInventoryComponent` documentado; requiere auditoria puntual por rama. |
| 10 | Arquitectura | Confirmar componentes de equipamiento existentes. | Preparado | `PlayerEquipmentComponent` documentado; requiere auditoria puntual. |
| 11 | Arquitectura | Confirmar componentes de stats existentes. | Preparado | `PlayerStatsComponent` documentado; requiere auditoria puntual. |
| 12 | Arquitectura | Evitar duplicar reglas entre UI y gameplay. | Parcial | Politica documentada; validacion continua pendiente. |
| 13 | Arquitectura | Usar servicios compartidos para reglas de slots. | Parcial | `EquipmentRulesService` existe; canon de seis slots pendiente. |
| 14 | Arquitectura | Usar catalogo de huesos como fuente de datos. | Parcial | `BoneDataCatalog` existe; migracion incompleta. |
| 15 | Arquitectura | Mantener `Player` como orquestador. | Parcial | Estado documentado; hotspots siguen grandes. |
| 16 | Arquitectura | Documentar arquitectura por flujos. | Integrado | `docs/flow_index.md` y docs de flujo. |
| 17 | QA | Probar inventario con checklist manual. | Preparado | Checklist existe; ejecucion runtime pendiente. |
| 18 | QA | Probar combate con checklist manual. | Preparado | Checklist existe; ejecucion runtime pendiente. |
| 19 | QA | Probar camara y movimiento con checklist manual. | Preparado | Checklist existe; ejecucion runtime pendiente. |
| 20 | QA | Probar rig y preview con checklist manual. | Preparado | Checklist existe; ejecucion runtime pendiente. |
| 21 | Docs | Mantener docs de inventario actualizadas. | Parcial | `docs/inventory_flow.md`; actualizar por cada hito. |
| 22 | Docs | Mantener docs de equipamiento actualizadas. | Parcial | `docs/equipment_flow.md`; seis slots pendiente. |
| 23 | Docs | Mantener docs de combate actualizadas. | Parcial | `docs/combat_flow.md`; backstab runtime pendiente. |
| 24 | Docs | Mantener docs de camara actualizadas. | Parcial | `docs/camera_flow.md`; jitter runtime pendiente. |
| 25 | Docs | Mantener docs de drops actualizadas. | Parcial | `docs/drops_flow.md`; drops side-aware pendiente. |
| 26 | Docs | Mantener docs de tutorial actualizadas. | Parcial | `docs/tutorial_flow.md`. |
| 27 | Docs | Mantener estado actual del sistema. | Parcial | `docs/current_system_status.md`; revisar tras hitos. |
| 28 | Docs | Mantener mapa de arquitectura. | Parcial | Graphify versionado; politica actualizada. |
| 29 | Datos | Definir ids estables de huesos. | Parcial | Resources existentes; auditoria de ids pendiente. |
| 30 | Datos | Definir nombres visibles. | Parcial | Resources existentes; glosario UI pendiente. |
| 31 | Datos | Definir rarezas. | Integrado | Documentado en historial y `BoneDefinition`. |
| 32 | Datos | Definir mutaciones. | Integrado | Documentado en historial y `BoneDefinition`. |
| 33 | Datos | Definir peso. | Integrado | Metadata existe; formula activa pendiente. |
| 34 | Datos | Definir stats base. | Parcial | Metadata existe; comparador pendiente. |
| 35 | Datos | Definir sets y sinergias. | Parcial | Metadata pasiva; reglas activas pendientes. |
| 36 | Datos | Definir ataque y combo. | Parcial | Metadata pasiva; combate avanzado pendiente. |
| 37 | Datos | Definir modificadores porcentuales de calidad. | Parcial | Metadata existe; consumo automatico pendiente. |
| 38 | Datos | Definir calidades. | Integrado | Documentado en `docs/bone_data_structure.md`. |
| 39 | Datos | Definir rarezas y mutaciones en docs. | Integrado | Documentacion existente. |
| 40 | Datos | Documentar estructura de datos de huesos. | Integrado | `docs/bone_data_structure.md`. |
| 41 | Inventario | Stacks visuales reales. | Parcial | Contador `xN` integrado; runtime pendiente. |
| 42 | Inventario | Tiles con cantidad y drag and drop. | Parcial | `ui_bone_item.gd` y validador; runtime pendiente. |
| 43 | Inventario | Comparador de stats. | No iniciado | Pendiente en `feat/inventory-equipment-ux-core`. |
| 44 | Inventario | Mostrar subidas y bajadas de stats. | No iniciado | Pendiente. |
| 45 | Inventario | Filtro por slot. | No iniciado | Pendiente. |
| 46 | Inventario | Filtro por rareza. | No iniciado | Pendiente. |
| 47 | Inventario | Filtro por peso. | No iniciado | Pendiente. |
| 48 | Inventario | Filtro por dano. | No iniciado | Pendiente. |
| 49 | Inventario | Filtro por defensa. | No iniciado | Pendiente. |
| 50 | Inventario | Ordenar por nuevo. | No iniciado | Pendiente. |
| 51 | Inventario | Ordenar por rareza o calidad. | No iniciado | Pendiente. |
| 52 | Inventario | Ordenar por slot. | No iniciado | Pendiente. |
| 53 | Inventario | Ordenar por poder. | No iniciado | Pendiente. |
| 54 | Inventario | Ordenar por nombre. | No iniciado | Pendiente. |
| 55 | Inventario | Tooltip con color por calidad. | No iniciado | Pendiente. |
| 56 | Inventario | Tooltip con resumen. | No iniciado | Pendiente. |
| 57 | Inventario | Feedback de slot valido. | No iniciado | Pendiente. |
| 58 | Inventario | Feedback de slot invalido. | No iniciado | Pendiente. |
| 59 | Inventario | Confirmacion o animacion al equipar. | No iniciado | Pendiente. |
| 60 | Builds | Guardar builds de equipamiento. | No iniciado | Pendiente. |
| 61 | Builds | Cambiar builds de equipamiento. | No iniciado | Pendiente. |
| 62 | Builds | Validar builds disponibles. | No iniciado | Pendiente. |
| 63 | Stats | Formula determinista de stats. | Parcial | `PlayerStatsComponent` existe; ampliar reglas. |
| 64 | Stats | Comparacion contra pieza equipada. | No iniciado | Pendiente. |
| 65 | Stats | Balance inicial de calidad. | Parcial | Metadata existe; balance activo pendiente. |
| 66 | Stats | Balance inicial de peso. | Parcial | Metadata existe; consumo activo pendiente. |
| 67 | Stats | Defensa en calculo final. | No iniciado | Pendiente. |
| 68 | Stats | Movilidad en calculo final. | Parcial | Stats actuales; auditoria pendiente. |
| 69 | Stats | Stamina en calculo final. | No iniciado | Pendiente. |
| 70 | Durabilidad | Durabilidad de huesos. | No iniciado | Pendiente. |
| 71 | Durabilidad | Estado roto o agrietado. | No iniciado | Pendiente. |
| 72 | Durabilidad | Reparacion de huesos. | No iniciado | Pendiente. |
| 73 | Sinergias | Bonus de set completos. | No iniciado | Pendiente. |
| 74 | Sinergias | Bonus de set parciales. | No iniciado | Pendiente. |
| 75 | Sinergias | Efectos negativos y mutaciones. | No iniciado | Pendiente. |
| 76 | Backstab | Validar frente bloqueado. | Validado estaticamente | `validate_backstab_geometry.py`; runtime pendiente. |
| 77 | Backstab | Validar laterales bloqueados. | Validado estaticamente | `validate_backstab_geometry.py`; runtime pendiente. |
| 78 | Backstab | Validar detras permitido. | Validado estaticamente | `validate_backstab_geometry.py`; runtime pendiente. |
| 79 | Backstab | Validar enemigos rotados. | Validado estaticamente | `validate_backstab_geometry.py`; runtime pendiente. |
| 80 | Backstab | Confirmar forward logico y visual. | Preparado | Requiere Godot/manual. |
| 81 | Backstab | Centralizar regla compartida. | No iniciado | Pendiente si se demuestra duplicacion. |
| 82 | Backstab | Ajustar distancia valida. | No iniciado | Pendiente de reproduccion. |
| 83 | Backstab | Ajustar umbral angular. | No iniciado | Pendiente de reproduccion. |
| 84 | Backstab | Prevenir doble dano. | No iniciado | Pendiente. |
| 85 | Backstab | Cooldown o ventana de ejecucion. | No iniciado | Pendiente. |
| 86 | Backstab | Animacion base de ejecucion. | No iniciado | Pendiente runtime. |
| 87 | Backstab | Reaccion del enemigo. | No iniciado | Pendiente runtime. |
| 88 | Backstab | Sincronizar momento de impacto. | No iniciado | Pendiente runtime. |
| 89 | Backstab | Restaurar control tras ejecucion. | No iniciado | Pendiente runtime. |
| 90 | Backstab | Fallback para enemigos incompatibles. | No iniciado | Pendiente. |
| 91 | Backstab | Documentar flujo final. | Preparado | Docs existen; actualizar tras fix. |
| 92 | Cuerpo jugador | Contrato de dano corporal. | No iniciado | Pendiente. |
| 93 | Cuerpo jugador | Perdida de partes. | No iniciado | Pendiente. |
| 94 | Cuerpo jugador | Partes permitidas. | No iniciado | Pendiente. |
| 95 | Cuerpo jugador | Penalizaciones por parte perdida. | No iniciado | Pendiente. |
| 96 | Cuerpo jugador | Recuperacion de partes. | No iniciado | Pendiente. |
| 97 | Cuerpo jugador | Tiempo de recogida. | No iniciado | Pendiente. |
| 98 | Cuerpo jugador | Feedback visual de perdida. | No iniciado | Pendiente. |
| 99 | Cuerpo jugador | Feedback sonoro de perdida. | No iniciado | Pendiente. |
| 100 | Cuerpo jugador | Integracion con inventario. | No iniciado | Pendiente. |
| 101 | Cuerpo jugador | Integracion con equipamiento. | No iniciado | Pendiente. |
| 102 | Cuerpo jugador | Integracion con animacion. | No iniciado | Pendiente. |
| 103 | Cuerpo jugador | Compatibilidad con slots corporales. | No iniciado | Pendiente de seis slots. |
| 104 | Cuerpo jugador | Compatibilidad con camara. | No iniciado | Pendiente. |
| 105 | Cuerpo jugador | Validacion de recuperacion. | No iniciado | Pendiente. |
| 106 | Enemigos | Variante rapida. | Parcial | Enemigos existentes; catalogacion pendiente. |
| 107 | Enemigos | Variante tanque. | Parcial | Enemigos existentes; catalogacion pendiente. |
| 108 | Enemigos | Variante crawler. | Parcial | Crawling documentado; runtime pendiente. |
| 109 | Enemigos | Variante lanzadora. | Parcial | Ranged/gorilla/lizard existen; auditoria pendiente. |
| 110 | Enemigos | Minijefes. | No iniciado | Pendiente. |
| 111 | Enemigos | Estado corporal enemigo. | Parcial | Limb detachment existe; consolidar reglas. |
| 112 | Enemigos | Perdida de brazos. | Parcial | Existe en drops/limbs; validar side-aware. |
| 113 | Enemigos | Perdida de piernas. | Parcial | Existe en drops/limbs; validar side-aware. |
| 114 | Enemigos | Perdida de torso. | Parcial | Existe parcialmente; validar. |
| 115 | Enemigos | Partes recuperables. | Parcial | Documentado; runtime pendiente. |
| 116 | Enemigos | Alertas grupales. | Parcial | Estado actual documentado; validar. |
| 117 | Enemigos | Ruido. | Parcial | Documentado en combate; validar. |
| 118 | Enemigos | Reaccion a muerte. | Parcial | Drops/eventos existentes; validar. |
| 119 | Enemigos | Drop inteligente. | Parcial | Servicios existentes; ampliar. |
| 120 | Enemigos | Claridad visual del drop. | Parcial | Pendiente UX. |
| 121 | Drops | Preservar slot canonico del drop. | Parcial | Slots legacy; seis slots pendiente. |
| 122 | Drops | Preservar lado de origen cuando aplique. | No iniciado | Pendiente. |
| 123 | Camara | Reproducir jitter. | Preparado | Validador diagnostico; runtime pendiente. |
| 124 | Camara | Aislar camara habilitada/deshabilitada. | No iniciado | Pendiente runtime. |
| 125 | Camara | Aislar rig procedural. | No iniciado | Pendiente runtime. |
| 126 | Camara | Comparar `_process` y `_physics_process`. | Preparado | Validador advierte hipotesis. |
| 127 | Camara | Corregir causa demostrada del jitter. | No iniciado | Pendiente causa. |
| 128 | Camara | Sensibilidad configurable. | No iniciado | Pendiente. |
| 129 | Camara | Invertir eje Y. | No iniciado | Pendiente. |
| 130 | Camara | Persistencia de controles. | No iniciado | Pendiente. |
| 131 | Camara | Modo crawler. | No iniciado | Pendiente. |
| 132 | Camara | Modo combate. | No iniciado | Pendiente. |
| 133 | Camara | Lock-on. | No iniciado | Pendiente. |
| 134 | Animacion | Animaciones por equipamiento. | No iniciado | Pendiente. |
| 135 | Animacion | Animacion de pickup. | No iniciado | Pendiente. |
| 136 | Animacion | Animacion de crawlers. | Parcial | Rig tiene estados; validar. |
| 137 | Animacion | Feedback sonoro. | No iniciado | Pendiente. |
| 138 | Animacion | Feedback visual. | Parcial | Algunos flashes existen; consolidar. |
| 139 | Animacion | Transiciones de ataque. | Parcial | Combo visual existe; validar. |
| 140 | Animacion | Transiciones de dano. | Parcial | Enemigos tienen feedback; validar. |
| 141 | Animacion | Transiciones de muerte. | Parcial | Enemigos tienen muerte/drops; validar. |
| 142 | Progresion | Arbol de mejoras. | No iniciado | Pendiente. |
| 143 | Progresion | NPC. | No iniciado | Pendiente. |
| 144 | Progresion | Mesa de ensamblaje. | No iniciado | Pendiente. |
| 145 | Mundo | Zonas por salto. | No iniciado | Pendiente. |
| 146 | Mundo | Zonas por escalada. | No iniciado | Pendiente. |
| 147 | Mundo | Zonas por alas. | No iniciado | Pendiente. |
| 148 | Mundo | Zonas por fuerza. | No iniciado | Pendiente. |
| 149 | Mundo | Pruebas por brazos. | Parcial | Trial gates existen; validar y ampliar. |
| 150 | Mundo | Pruebas por piernas. | Parcial | Trial gates existen; validar y ampliar. |
| 151 | Mundo | Pruebas por torso. | Parcial | Trial gates existen; validar y ampliar. |
| 152 | Mundo | Pruebas por cabeza. | Parcial | Trial gates existen; validar y ampliar. |
| 153 | Objetivos | ArenaGoalManager narrativo. | Parcial | Manager existe; ampliar narrativa. |
| 154 | Objetivos | Misiones. | Parcial | Tutorial/checklist existe; sistema formal pendiente. |
| 155 | Objetivos | Tutoriales. | Parcial | Tutorial flow existe; validar runtime. |
| 156 | Objetivos | Recompensas de arenas. | Parcial | Arena flow existe; validar. |
| 157 | Objetivos | Salida/portal de objetivo. | Parcial | Exit portal existe; validar. |
| 158 | Objetivos | Registro de progreso de demo. | Parcial | ArenaGoalManager; persistencia pendiente. |
| 159 | Mantenimiento | Actualizar docs por cambio funcional. | Parcial | Politica existe; aplicar por PR. |
| 160 | Mantenimiento | Ejecutar validadores por rama. | Parcial | Validadores existen; checklist por PR. |
| 161 | Mantenimiento | Revisar caches por rama. | Preparado | Politica documentada. |
| 162 | Mantenimiento | Revisar conflictos por rama. | Preparado | Preflight documentado. |
| 163 | Mantenimiento | Mantener commits pequenos. | Preparado | Politica documentada. |
| 164 | Mantenimiento | Registrar decisiones arquitectonicas. | Preparado | Docs de flujo y politica. |
| 165 | Mantenimiento | Refrescar roadmap tras grupos de ramas integradas. | Preparado | Este archivo y `roadmap_progress.md`; automatizacion pendiente. |
