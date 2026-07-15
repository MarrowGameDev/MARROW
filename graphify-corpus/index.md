# Marrow Graphify Corpus

This generated corpus translates the Godot project into Markdown that Graphify can map reliably.
It is derived from source files and should be rebuilt before Graphify runs.

## Included Source
- GDScript files: 38
- Godot scenes: 14
- Documentation files: 14
- Project/root files: 3

## Generated Maps
- `architecture.py`: synthetic Python AST map used by Graphify code-only extraction.
- `gdscript-api.md`: classes, functions, signals, exports, dependencies, input actions, and GameEvents usage.
- `scene-map.md`: scenes, node names, and attached scripts.
- `dependency-map.md`: inferred relationships between scripts and scenes.
- `system-map.md`: project systems grouped by gameplay responsibility.
- `source-docs.md`: source documentation included in the graph.
