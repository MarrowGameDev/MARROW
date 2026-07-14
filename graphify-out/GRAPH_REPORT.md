# Graph Report - MARROW  (2026-07-14)

## Corpus Check
- 8 files · ~47,644 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 73 nodes · 75 edges · 8 communities (7 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `4d2fb402`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Community 0
- Community 1
- Community 2
- Community 3
- Community 4
- Community 5
- MARROW Current System Status
- AGENTS.md

## God Nodes (most connected - your core abstractions)
1. `Marrow Project Graph Map` - 14 edges
2. `MARROW Current System Status` - 7 edges
3. `SimplePdf` - 6 edges
4. `Godot Signal Guidelines` - 6 edges
5. `Marrow Open-World Map Layout Notes` - 6 edges
6. `Marrow — Modular Rig / Procedural Animation notes` - 6 edges
7. `main()` - 5 edges
8. `build_pages()` - 4 edges
9. `escape_pdf_text()` - 2 edges
10. `wrap_paragraph()` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (8 total, 1 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.29
Nodes (6): Godot Signal Guidelines, Keep Emitters Decoupled, Pass Useful Data, Prefer Event Names, Signal Up, Call Down, Use `GameEvents` Sparingly

### Community 1 - "Community 1"
Cohesion: 0.29
Nodes (6): Current Goal, Current Regions, Marrow Open-World Map Layout Notes, Mesh-Swap Rule, Metadata, Next Coder Step

### Community 2 - "Community 2"
Cohesion: 0.29
Nodes (6): Architecture (animate sockets, not meshes), How to test, Known limitations / TODO, Marrow — Modular Rig / Procedural Animation notes, Phase E/F tuning (exports on ProceduralAnimator), Tuning variables (exports on ProceduralAnimator)

### Community 3 - "Community 3"
Cohesion: 0.32
Nodes (7): Path, add_footer(), build_pages(), escape_pdf_text(), main(), SimplePdf, wrap_paragraph()

### Community 4 - "Community 4"
Cohesion: 0.13
Nodes (14): Arena Goals, BoneDatabase, Enemy and Combat, GameEvents, Generated World, Guidance Docs, Inventory UI, Marrow Project Graph Map (+6 more)

### Community 6 - "MARROW Current System Status"
Cohesion: 0.25
Nodes (7): Camera, Combat, Enemies, Inventory, MARROW Current System Status, Next Refactor Boundary, Rig

### Community 7 - "AGENTS.md"
Cohesion: 0.13
Nodes (13): Camara Y Controles, Combate, Enemigos Y Feel, Criterios Para Aceptar Un Cambio, Datos Y Resources, Documentacion, Escenas De Prueba Y Validacion, Estructura Esperada, Git Y Cambios (+5 more)

## Knowledge Gaps
- **48 isolated node(s):** `Principios Del Proyecto`, `Estructura Esperada`, `Reglas De Arquitectura`, `Godot Y GDScript`, `Datos Y Resources` (+43 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What connects `Principios Del Proyecto`, `Estructura Esperada`, `Reglas De Arquitectura` to the rest of the system?**
  _48 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 4` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `AGENTS.md` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._