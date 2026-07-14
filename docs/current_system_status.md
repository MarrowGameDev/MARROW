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
- The inventory preview uses the same body progression visibility as the player:
  fixed head first, torso required, limbs visible only after recovery/equip.

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

- Full schema reference lives in `docs/bone_data_structure.md`.
- `BoneDefinition` is the Godot `Resource` type for one hand-authored bone.
- Initial hand-authored bones now live as `.tres` assets in `data/bones/`.
- `BoneDataCatalog` loads `.tres` Resources first and uses its in-code
  dictionaries only as temporary fallback during gradual migration.
- `BoneDatabase` remains the compatibility layer that normalizes catalog data
  into the flat fields current systems expect.
- `BoneDatabase.BONES` is still populated for legacy direct reads, and
  `BoneDatabase.reset_cache()`/`reload_from_catalog()` refresh the cache.
- Bone quality fields describe part quality/condition and balancing metadata;
  they are intentionally separate from loot rarity.
- Canonical quality ids are `chatarra`, `fragil`, `comun`, `fuerte` and
  `legendario`; UI can localize display text separately.
- Quality percentage modifiers are stored as passive metadata for damage, speed,
  health, drop and weight tuning; no automatic formula consumes them yet.
- Canonical rarity ids are `comun`, `corrupto`, `maldito`, `especial` and
  `legendario`; canonical mutation families are empty, `corrupto`, `maldito`,
  `especial` and `hibrido`.
- Bone attack/combo fields are present as passive metadata for future combat
  chains; current attacks still come from the existing player/enemy combat code.
- Bone weight fields now distinguish animation weight, physical weight,
  equipment load and inventory weight while keeping legacy `weight`.
- Bone set/synergy fields are present as passive metadata; no automatic set
  bonuses are active yet.
- Gameplay consumers should still use `BoneRulesService`, `EquipmentRulesService`
  or `BoneDatabase`, not `BoneDefinition` or `BoneDataCatalog` directly.

## Testing

- `scenes/testing_environment.tscn` is the unified sandbox for camera, enemies,
  movement, animation, rig, drops, and equipment checks.
- `scenes/main_menu.tscn` exposes both the playable demo and testing
  environment.

## Tutorial

- `ArenaGoalManager` owns the demo help panel and now shows a live controls
  tutorial checklist.
- The checklist reads current bindings through `DropPickupRulesService`, so it
  follows control remaps instead of hardcoded key text.
- Tutorial progress listens to direct input plus `GameEvents` for pickup,
  inventory open, and equip events.

## Rig

- `ModularSkeletonRig` creates sockets and visual equipment parts.
- `ProceduralPlayerAnimator` animates sockets from resolved movement velocity and
  equipped bone data.
- Crawl mode lowers the body and uses stronger arm pulls with tucked legs.
- Attack animation now supports a simple three-step combo overlay: right strike,
  left strike, and two-arm finisher. It is visual only.
- Player body progression mode hides unrecovered body parts. Head-only movement
  uses a simple hop/roll pose until the torso is equipped.

## Documentation Boundary

All future functional changes should update the relevant flow file listed in
`docs/flow_index.md`.
