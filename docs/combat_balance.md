# Balance de combate y economía de stats

Este documento fija la escala de la vertical slice. La fuente de verdad del
cálculo sigue siendo `BoneRulesService`.

## Decisión

| Modelo | Ventaja | Riesgo | Decisión |
| --- | --- | --- | --- |
| A: escala pequeña | Migración mínima | Redondeo dominante y poco margen | Descartado |
| B: base 10 uniforme | Daño granular | Salud estrecha para tanques y élites | Viable |
| C: híbrida amplia | Daño base 10, salud por bandas, movimiento y alcance en metros | Exige revisar umbrales absolutos | Elegido |

El modelo C permite pasos ofensivos de +1 a +3 sin que una pieza duplique el
daño. Los bonos viejos no se multiplicaron por diez.

## Baseline y escala nueva

| Sistema | Antes | Ahora | Objetivo |
| --- | ---: | ---: | --- |
| Daño melee base | 1 | 10 | Ajustes granulares |
| Vida jugador | 1 | 50 | 5 impactos estándar |
| Arco / Finger Bone | 1 / 1 | 8 / 6 | Ranged útil sin reemplazar melee |
| Enemigo normal: vida / daño | 3 / 1 | 40 / 10 | 4 golpes para matar, 5 para morir |
| Flecha enemiga | 1 | 8 | Menor que contacto |
| Gorilla: vida / daño mínimos | 5 / 2 | 70 / 14 | Encuentro resistente |
| Roca Gorilla / saliva Lizard | 1 / 1 | 12 / 8 | Presión ranged diferenciada |
| Multiplicador de vida Lizard | 85% | 80% | Movilidad a cambio de vida |
| Curación por recuperación | 1 | 8 | Útil sin restaurar por completo |
| Umbral de ejecución | 3 | 40 | Conserva la ejecución del enemigo normal |

Backstab conserva su regla: ejecución bajo el umbral y daño de emboscada fuera
de él. La pérdida de miembros ya escala con `max_health`.

## Presupuesto de piezas

| Pieza o familia | Bonos planos nuevos | Porcentajes propios | Rol |
| --- | --- | --- | --- |
| Arm Bone | +0.35 alcance, +2 vida | 0 | Starter alcance |
| Leg Bone | +0.45 velocidad, +2 vida | 0 | Starter movilidad |
| Torso / Training | +10 vida / 0 | 0 | Starter defensa / referencia |
| Heavy Bone | -0.8 velocidad, +2 daño, +18 vida | +4% daño, -3% velocidad, +4% vida, +10% peso | Bruiser |
| Rib Bone | +0.35 velocidad, +0.25 alcance, +10 vida | +2% daño/velocidad/vida/peso | Híbrido |
| Normal arms / legs / body | +0.45 alcance y +1 daño / +0.35 velocidad y +2 vida / +12 vida | 0 | Equilibrado |
| Gorilla arms | +0.25 alcance, +3 daño, +2 vida | +2% daño por brazo | Fuerza |
| Gorilla legs / body | -0.15 velocidad y +4 vida / +1 daño y +20 vida | -2% velocidad por pierna / +2% vida y +5% peso | Masa/tanque |
| Lizard arms / legs | +0.15 velocidad y +0.55 alcance / +0.8 velocidad | 0 / +3% velocidad por pierna | Reposición |
| Lizard body | +0.35 velocidad, +8 vida | -2% vida, -4% peso | Ligereza |

Los campos `quality_*_percent` de piezas generadas aún mezclan en su nombre
modificadores de especie y calidad. Se limitaron a las partes que expresan el
rol para evitar double dipping; renombrarlos queda como deuda cosmética.

## Calidad, sets y peso

Calidades: Frail 0.90, Worn 0.95, Normal 1.00, Strong 1.05 y Pristine 1.10.
La calidad escala sólo bonos planos positivos. Los costes negativos se
conservan, por lo que Pristine no empeora la lentitud de Heavy.

Los tiers son exclusivos. Gorilla 4 piezas usa +6% daño/-3% velocidad.
Matching Arms (+2% daño), Matching Legs (+0.15 velocidad/+2% peso) y
High-Quality Assembly (+2% daño/vida/peso) siguen siendo incentivos menores.

El peso libre pasa de 3 a 6, la penalización de 6% a 4% por unidad excedida y
el techo de 30% a 25%. Un set estándar no paga carga; Gorilla y Heavy sí.

## Matriz contractual

Resultado real de `tools/headless_balance_matrix_check.gd`:

| Build | Daño | Vida | Velocidad | Alcance | Peso | Penalización | Golpes para matar 40 HP | Golpes para morir a 10 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Sin equipo | 10 | 50 | 6.00 | 2.00 | 0.00 | 0% | 4 | 5 |
| Starter | 10 | 68 | 7.05 | 2.90 | 5.51 | 0% | 4 | 7 |
| Enemy Parts | 12 | 69 | 6.70 | 3.05 | 5.60 | 0% | 4 | 7 |
| Gorilla | 19 | 84 | 4.83 | 2.50 | 8.22 | 9% | 3 | 9 |
| Lizard | 10 | 55 | 9.16 | 3.10 | 4.55 | 0% | 4 | 6 |
| Heavy | 15 | 78 | 5.63 | 3.05 | 6.40 | 2% | 3 | 8 |
| Hybrid | 14 | 65 | 8.19 | 3.05 | 5.70 | 0% | 3 | 7 |

La matriz demuestra diferenciación matemática, no feel. Cooldowns, evasión,
grupos, geometría y legibilidad todavía requieren playtest.

## Compatibilidad y validación

Las instancias guardan `bone_id` y `quality_id`, no stats ni multiplicadores.
Las builds guardan instance ids y recalculan con el servicio central. No hace
falta migración de save ni cambiar anatomía, slots o inventario.

```text
godot --headless --path . --script tools/headless_balance_matrix_check.gd
python -B tools/validate_bone_quality.py
python -B tools/validate_bone_stat_formulas.py
python -B tools/validate_synergy_rules.py
python -B tools/validate_bone_data.py
```
