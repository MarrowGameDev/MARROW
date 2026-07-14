# Marrow Open-World Map Layout Notes

## Current Goal

The map is now arranged as a grey-box open world with named stage regions and difficulty bands. It should feel closer to a Mario/Zelda overworld: a safe hub, nearby starter zones, side paths, and harder regions farther out.

## Mesh-Swap Rule

Each map region is an instance of:

`scenes/open_world_stage.tscn`

Inside that scene, the important node is:

`OpenWorldStage/StageBody/StageMesh`

To change a stage's physical layout/art later:

1. Open the stage instance or inherited scene in Godot.
2. Replace the mesh on `StageMesh`.
3. Keep the node name `StageMesh`.
4. Keep the sibling `StageCollision`.

At runtime, `scripts/open_world_stage.gd` copies `StageMesh.mesh` into `StageCollision.shape`, so the playable surface follows the mesh.

## Metadata

The stage script has exported fields for:

- `stage_id`
- `stage_name`
- `difficulty`
- `recommended_bone`
- `description`
- `stage_color`
- `trigger_size`

Those are not terrain geometry. They are labels and progression metadata. The terrain/art itself should stay concentrated in `StageMesh`.

## Current Regions

- `BonefieldHub`: Difficulty 1, safe center.
  - Starter `torso_bone` pickup sits near player spawn so the opening order is
    head first, then torso, then extremities.
- `FirstHuntField`: Difficulty 2, starter enemies and first bones.
- `ReachRidge`: Difficulty 3, Arm Bone / reach-focused area.
- `QuickrootRun`: Difficulty 4, Leg Bone / speed-focused area.
- `HeavyRuin`: Difficulty 5, Heavy Bone / power-focused area.
- `RibfenBonus`: Difficulty 4, optional side-stage for Rib Bone.
- `ElderMarrowGate`: Difficulty 7, future high-difficulty zone.

## Next Coder Step

Once the layout feels readable, move enemies/trials into the matching stage regions and add stage-specific spawn points. Do not create real art yet; first confirm the overworld route makes players naturally understand where each bone matters.
