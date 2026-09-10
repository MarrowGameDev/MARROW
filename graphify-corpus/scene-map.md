# Godot Scene Map

## scenes/_ch.tscn

### Attached Scripts
- `scripts/_ch.gd`

### Instanced Scenes
- none

### Nodes
- `CH`

## scenes/attack_hitbox.tscn

### Attached Scripts
- `scripts/attack_hitbox.gd`

### Instanced Scenes
- none

### Nodes
- `AttackHitbox`
- `CollisionShape3D`
- `Visual`

## scenes/beach_cliff_test.tscn

### Attached Scripts
- `scripts/terrain/beach_cliff_terrain.gd`

### Instanced Scenes
- none

### Nodes
- `BeachCliffTest`
- `WorldEnvironment`
- `Sun`
- `Terrain`
- `Camera3D`

## scenes/bone.tscn

### Attached Scripts
- `scripts/bone.gd`

### Instanced Scenes
- none

### Nodes
- `BonePickup`
- `MeshInstance3D`
- `PickupMarker`
- `PromptLabel`
- `CollisionShape3D`

## scenes/bone_trial_gate.tscn

### Attached Scripts
- `scripts/bone_trial_gate.gd`

### Instanced Scenes
- none

### Nodes
- `BoneTrialGate`
- `GateMesh`
- `CollisionShape3D`
- `GateLabel`

## scenes/crab.tscn

### Attached Scripts
- `scripts/crab_scuttle.gd`

### Instanced Scenes
- `assets/crab_walk.fbx`

### Nodes
- `Crab`
- `CollisionShape3D`
- `Model`

## scenes/creature_walk_test.tscn

### Attached Scripts
- `scripts/creature_walk_test.gd`
- `scripts/rig/creature_walker.gd`

### Instanced Scenes
- none

### Nodes
- `CreatureWalkTest`
- `Crab`
- `Col`
- `VisualRoot`
- `CreatureWalker`

## scenes/dummy_testing_environment.tscn

### Attached Scripts
- `scripts/testing_environment.gd`

### Instanced Scenes
- none

### Nodes
- `DummyTestingEnvironment`
- `EnemySpawnPoints`
- `DummySpawn`

## scenes/enemy.tscn

### Attached Scripts
- `scripts/enemy.gd`
- `scripts/rig/modular_skeleton_rig.gd`
- `scripts/rig/animated_character.gd`

### Instanced Scenes
- none

### Nodes
- `Enemy`
- `MeshInstance3D`
- `CollisionShape3D`
- `VisualRoot`
- `ModularSkeletonRig`
- `AnimatedCharacter`
- `VisionMesh`
- `HealthLabel`

## scenes/equipped_bone.tscn

### Attached Scripts
- none

### Instanced Scenes
- none

### Nodes
- `EquippedBone`
- `BoneMesh`
- `JointMesh`

## scenes/exit_portal.tscn

### Attached Scripts
- `scripts/exit_portal.gd`

### Instanced Scenes
- none

### Nodes
- `ExitPortal`
- `PortalMesh`
- `CollisionShape3D`
- `PortalLabel`

## scenes/guide_wisp.tscn

### Attached Scripts
- `scripts/guide_wisp.gd`

### Instanced Scenes
- none

### Nodes
- `GuideWisp`
- `Orb`
- `Label3D`

## scenes/head_only_test.tscn

### Attached Scripts
- `scripts/creature_walk_test.gd`
- `scripts/head_only_controller.gd`
- `scripts/head_only_enemy.gd`
- `scripts/player_health.gd`

### Instanced Scenes
- none

### Nodes
- `HeadOnlyTest`
- `Crab`
- `Col`
- `VisualRoot`
- `HeadOnlyController`
- `Enemy`
- `Enemy2`
- `Enemy3`

## scenes/head_torso_test.tscn

### Attached Scripts
- `scripts/head_torso_test.gd`
- `scripts/head_only_controller.gd`

### Instanced Scenes
- none

### Nodes
- `HeadTorsoTest`
- `Body`
- `Col`
- `VisualRoot`
- `HeadTorso`

## scenes/heavy_crab_enemy.tscn

### Attached Scripts
- `scripts/heavy_crab_enemy.gd`

### Instanced Scenes
- none

### Nodes
- `HeavyCrab`
- `Col`

## scenes/heavy_crab_test.tscn

### Attached Scripts
- `scripts/heavy_crab_test.gd`

### Instanced Scenes
- none

### Nodes
- `HeavyCrabTest`

## scenes/main.tscn

### Attached Scripts
- `scripts/arena_goal_manager.gd`
- `scripts/world_map_manager.gd`
- `scripts/tutorial_island_builder.gd`

### Instanced Scenes
- `scenes/player.tscn`
- `scenes/enemy.tscn`
- `scenes/bone_trial_gate.tscn`
- `scenes/exit_portal.tscn`
- `scenes/open_world_stage.tscn`
- `scenes/guide_wisp.tscn`
- `scenes/palm_tree_1.tscn`
- `scenes/palm_tree_2.tscn`
- `scenes/palm_tree_3.tscn`
- `scenes/crab.tscn`
- `scenes/rock.tscn`
- `assets/whale_skeleton.glb`

### Nodes
- `Main`
- `WorldEnvironment`
- `DirectionalLight3D`
- `Ground`
- `MeshInstance3D`
- `CollisionShape3D`
- `Player`
- `GuideWisp`
- `ArenaGoalManager`
- `WorldMapManager`
- `DemoIslandBuilder`
- `OpenWorldStages`
- `BonefieldHub`
- `FirstHuntField`
- `ReachRidge`
- `QuickrootRun`
- `HeavyRuin`
- `RibfenBonus`
- `ElderMarrowGate`
- `SightTestWalls`
- `CenterHideWall`
- `LeftHideWall`
- `RightHideWall`
- `EnemyCenter`
- `EnemyLeft`
- `EnemyRight`
- `ArmTrialGate`
- `LegTrialGate`
- `HeavyTrialGate`
- `EnemyBonus`
- `ExitPortal`
- `Palms`
- `Palm1`
- `Palm2`
- `Palm3`
- `Palm4`
- `Palm5`
- `Palm6`
- `Crabs`
- `Crab1`
- `Crab2`
- `Crab3`
- `Crab4`
- `Crab5`
- `Rocks`
- `Rock1`
- `Rock2`
- `Rock3`
- `Rock4`
- `Rock5`
- `Rock6`
- `Rock7`
- `Rock8`
- `Rock9`
- `Rock10`
- `Rock11`
- `Rock12`
- `Rock13`
- `Rock14`
- `Rock15`
- `Rock16`
- `Rock17`
- `Rock18`
- `Rock19`
- `Rock20`
- `BeachWhale`

## scenes/main_menu.tscn

### Attached Scripts
- `scripts/main_menu.gd`

### Instanced Scenes
- none

### Nodes
- `MainMenu`

## scenes/open_world_stage.tscn

### Attached Scripts
- `scripts/open_world_stage.gd`

### Instanced Scenes
- none

### Nodes
- `OpenWorldStage`
- `StageBody`
- `StageMesh`
- `StageCollision`
- `StageTrigger`
- `StageTriggerShape`
- `StageLabel`

## scenes/palm_tree_1.tscn

### Attached Scripts
- none

### Instanced Scenes
- `assets/palm_tree_1.glb`

### Nodes
- `PalmTree1`
- `Mesh`
- `TrunkCollision`

## scenes/palm_tree_2.tscn

### Attached Scripts
- none

### Instanced Scenes
- `assets/palm_tree_2.glb`

### Nodes
- `PalmTree2`
- `Mesh`
- `TrunkCollision`

## scenes/palm_tree_3.tscn

### Attached Scripts
- none

### Instanced Scenes
- `assets/palm_tree_3.glb`

### Nodes
- `PalmTree3`
- `Mesh`
- `TrunkCollision`

## scenes/player.tscn

### Attached Scripts
- `scripts/player.gd`
- `scripts/rig/modular_skeleton_rig.gd`
- `scripts/rig/animated_character.gd`
- `scripts/player_camera_controller.gd`
- `scripts/tuning_menu_ui.gd`

### Instanced Scenes
- `assets/skull.glb`

### Nodes
- `Player`
- `MeshInstance3D`
- `CollisionShape3D`
- `VisualRoot`
- `ModularSkeletonRig`
- `AnimatedCharacter`
- `SocketArmRight`
- `SocketArmLeft`
- `SocketLegs`
- `SocketBody`
- `CameraPivot`
- `SpringArm3D`
- `Camera3D`
- `TuningMenuUI`

## scenes/rock.tscn

### Attached Scripts
- `scripts/rock.gd`

### Instanced Scenes
- none

### Nodes
- `Rock`

## scenes/testing_environment.tscn

### Attached Scripts
- `scripts/testing_environment.gd`

### Instanced Scenes
- none

### Nodes
- `TestingEnvironment`
- `EnemySpawnPoints`
- `NormalSpawn`
- `GorillaSpawn`
- `LizardSpawn`
- `RangedSpawn`
- `DummySpawn`

