# Godot Scene Map

## scenes/attack_hitbox.tscn

### Attached Scripts
- `scripts/attack_hitbox.gd`

### Instanced Scenes
- none

### Nodes
- `AttackHitbox`
- `CollisionShape3D`
- `Visual`

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

## scenes/enemy.tscn

### Attached Scripts
- `scripts/enemy.gd`
- `scripts/rig/modular_skeleton_rig.gd`
- `scripts/rig/procedural_enemy_animator.gd`

### Instanced Scenes
- none

### Nodes
- `Enemy`
- `MeshInstance3D`
- `CollisionShape3D`
- `VisualRoot`
- `ModularSkeletonRig`
- `ProceduralAnimator`
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

## scenes/player.tscn

### Attached Scripts
- `scripts/player.gd`
- `scripts/rig/modular_skeleton_rig.gd`
- `scripts/rig/procedural_player_animator.gd`
- `scripts/player_camera_controller.gd`

### Instanced Scenes
- none

### Nodes
- `Player`
- `MeshInstance3D`
- `CollisionShape3D`
- `VisualRoot`
- `ModularSkeletonRig`
- `ProceduralAnimator`
- `SocketArmRight`
- `SocketArmLeft`
- `SocketLegs`
- `SocketBody`
- `CameraPivot`
- `SpringArm3D`
- `Camera3D`

## scenes/rig_test.tscn

### Attached Scripts
- `scripts/rig/rig_test_player.gd`
- `scripts/rig/modular_skeleton_rig.gd`
- `scripts/rig/procedural_player_animator.gd`

### Instanced Scenes
- `assets/skeleton_model.glb`
- `assets/skeleton_rigged.glb`

### Nodes
- `RigTest`
- `WorldEnvironment`
- `DirectionalLight3D`
- `Ground`
- `GroundMesh`
- `GroundCollision`
- `Ramp`
- `RampMesh`
- `RampCollision`
- `RigTestPlayer`
- `CollisionShape3D`
- `CameraPivot`
- `Camera3D`
- `VisualRoot`
- `ModularSkeletonRig`
- `ProceduralAnimator`

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

