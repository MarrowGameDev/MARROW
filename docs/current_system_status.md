# MARROW Current System Status

This document records the current gameplay architecture before the next larger
refactor pass.

## Inventory

- `PlayerInventoryUI` owns inventory presentation, tabs, item tiles, details,
  settings, paper doll slots, and the character preview.
- `PlayerInventoryComponent` owns collected inventory state.
- `PlayerEquipmentComponent` owns equipped state.
- `Player` remains the gameplay orchestrator and exposes stable methods for UI,
  pickups, gates, and tests.
- Equipped copies are filtered out of the carried item grid, while duplicate
  bone ids can remain as separate inventory copies.
- The character preview is rendered in an isolated `SubViewport` world with its
  own small room backdrop, so the preview clone stays outside the playable
  world and can be framed independently.

## Combat

- `Player` owns attack input, bow input, stealth finish input, attack cooldowns,
  damage, and attack hitbox spawning.
- `AttackHitbox` applies direct melee damage to enemies it overlaps.
- Stealth finishes are validated by the enemy using distance and the player's
  position behind the enemy facing direction.

## Camera

- `PlayerCameraController` owns third-person orbit, mouse capture, zoom, camera
  collision, and aim ray helpers.
- `Player` delegates mouse capture/release to the camera controller when
  inventory opens or closes.
- Player movement is camera-relative.

## Enemies

- `Enemy` owns AI state, vision/search, contact attacks, ranged attacks, gorilla
  rock throws, limb detachment, crawling, respawn, and bone recovery.
- Enemies can recover detached parts after a safe delay.
- Enemy labels and drops use slot-aware bone names.
- Lizard wall climb uses normal collision and upward climb velocity instead of
  direct position movement through walls.

## Bone Data

- `BoneDataCatalog` is now the clean authoring source for hand-authored bones.
- `BoneDatabase` remains the compatibility layer that normalizes catalog data
  into the flat fields current systems expect.
- Gameplay consumers should still use `BoneRulesService`, `EquipmentRulesService`
  or `BoneDatabase`, not `BoneDataCatalog` directly.

## Testing

- `scenes/testing_environment.tscn` is the unified sandbox for camera, enemies,
  movement, animation, rig, drops, and equipment checks.
- `scenes/main_menu.tscn` exposes both the playable demo and testing
  environment.

## Rig

- `ModularSkeletonRig` creates sockets and visual equipment parts.
- `ProceduralPlayerAnimator` animates sockets from resolved movement velocity and
  equipped bone data.
- Crawl mode lowers the body and uses stronger arm pulls with tucked legs.

## Documentation Boundary

All future functional changes should update the relevant flow file listed in
`docs/flow_index.md`.
