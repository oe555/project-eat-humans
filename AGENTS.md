# Project Eat Humans - Agent Notes

## Project Overview

This is a Godot 4.6 top-down 2D pixel-art game prototype. The premise is that the player belongs to an alien race traveling by spaceship to find humans to eat and resources to use.

The current playable state is early prototype: a ship can fly around a generated space scene with a home planet and procedurally spawned planets.

## Entry Point

- Main project file: `project.godot`
- Main scene: `Scenes/main_scene.tscn`
- Main scene root script: `Scripts/World/planet_scene.gd`

`Scenes/main_scene.tscn` currently contains:

- `SpaceBackground`: layered pixel-art parallax background
- `HomePlanet`: home planet `Area2D`
- `Player`: player spaceship `CharacterBody2D`
- Root `Node2D` using `planet_scene.gd`

## Controls And Player Movement

Input actions are defined in `project.godot`:

- `rotate_clockwise`: `D` / right arrow
- `rotate_counterclockwise`: `A` / left arrow
- `accelerate`: `W` / up arrow
- `break`: `S` / down arrow

Player movement lives in `Scripts/player.gd`.

The ship uses rotation plus thrust movement, closer to an Asteroids-style drift model than direct top-down movement:

- Rotate left/right.
- Accelerate in the ship's facing direction.
- Brake toward zero velocity.
- Decay velocity slowly when not accelerating.
- Clamp velocity to `thrust_max`.

Note: `player.gd` currently prints velocity every physics tick, which is useful only for debugging and will spam output.

## Core Gameplay Scenes

- `Scenes/player.tscn`
  - `CharacterBody2D`
  - `CollisionShape2D`
  - `Sprite2D` using `Assets/Art/spaceship.png`
  - `Camera2D`
  - In group `player`

- `Scenes/home_planet.tscn`
  - `Area2D`
  - `CollisionShape2D`
  - `Sprite2D` using `Assets/Art/home_planet_new.png`
  - Script: `Scripts/home_planet.gd`
  - Currently prints when a player body enters.

- `Scenes/planet.tscn`
  - `Area2D`
  - `CollisionShape2D`
  - `Sprite2D`
  - Script: `Scripts/World/planet.gd`
  - Currently uses `Assets/Art/placeholderspaceship.png` as its texture, so generated planets may look like placeholder ships until art is swapped.

- `Scenes/space_background.tscn`
  - Layered `Parallax2D` background using 640x360 pixel-art textures.

## World Generation

World generation is signal-driven.

`Scripts/World/planet_scene.gd`:

- Defines `PLANET_COUNT = 20`.
- On `_ready()`, calculates the viewport rect.
- Emits `SignalBus.world_generation_requested` with the rect, count, and current scene/root as the spawn parent.

`Scripts/Core/planet_manager.gd`:

- Autoload singleton.
- Connects to `SignalBus.world_generation_requested`.
- Calls `generate_planets(rect, count, parent)`.
- Clears previous spawned planets.
- Randomly places planets with:
  - radius range: `MIN_RADIUS = 12.0` to `MAX_RADIUS = 32.0`
  - placement buffer: `PLACEMENT_BUFFER = 12.0`
  - max attempts per planet: `MAX_PLACEMENT_ATTEMPTS = 30`
- Stores generated `PlanetData` resources in `planets`.
- Instantiates `Scenes/planet.tscn` for each placed planet.
- Emits:
  - `SignalBus.planet_spawned`
  - `SignalBus.world_generated`
  - `SignalBus.planets_cleared`

`Scripts/World/planet.gd`:

- `class_name Planet`
- Expects a `PlanetData`.
- Sets its position from `PlanetData.position`.
- Duplicates and resizes its circle collision shape based on `PlanetData.radius`.
- Scales its sprite based on texture width and planet radius.

`Scripts/World/planet_data.gd`:

- `class_name PlanetData`
- Resource with:
  - `position: Vector2`
  - `radius: float`

## Autoloads

The following autoloads are registered in `project.godot`:

- `SignalBus`: `Scripts/Core/signal_bus.gd`
- `AchievementManager`: `Scripts/Core/achievement_manager.gd`
- `AudioPlayer`: `Scripts/Core/audio_player.gd`
- `ConfigurationManager`: `Scripts/Core/configuration_manager.gd`
- `Enums`: `Scripts/Core/enums.gd`
- `LocalizationManager`: `Scripts/Core/localization_manager.gd`
- `PlanetManager`: `Scripts/Core/planet_manager.gd`
- `Randomizer`: `Scripts/Core/randomizer.gd`
- `SaveManager`: `Scripts/Core/save_manager.gd`
- `SceneManager`: `Scripts/Core/scene_manager.gd`

## Singleton Responsibilities

- `SignalBus`
  - Central hub for project-wide signals.
  - Currently includes planet/world generation signals.

- `PlanetManager`
  - Owns procedural planet placement and spawning.

- `Randomizer`
  - Owns a shared `RandomNumberGenerator`.
  - Provides seed setting by string hash.

- `SaveManager`
  - JSON save/load scaffold using `user://save_data.json`.
  - `default_data` is currently empty.

- `ConfigurationManager`
  - Settings scaffold using `user://settings.cfg`.

- `SceneManager`
  - Thin helper around `change_scene_to_file`.

- `AudioPlayer`
  - SFX and music scaffold with pooled `AudioStreamPlayer`s.
  - Currently references audio paths under `Assets/Audio`, but that directory does not appear to exist yet.

- `LocalizationManager`
  - CSV localization scaffold.
  - Expects `Assets/Localization/localization.csv`, which does not appear to exist yet.

- `AchievementManager`
  - Achievement scaffold with placeholder `ACH_EXAMPLE`.
  - Contains TODO notes around Steam integration.

- `Enums`
  - Placeholder global enum scaffold.

## Assets

Main art:

- `Assets/Art/spaceship.png`: 32x32 player ship
- `Assets/Art/placeholderspaceship.png`: 32x32 placeholder
- `Assets/Art/home_planet.png`: 50x50
- `Assets/Art/home_planet_new.png`: 50x50

Resource icons:

- `Assets/Art/Resources/resource_gold.png`: 16x16
- `Assets/Art/Resources/resource_human_1.png`: 16x16
- `Assets/Art/Resources/resource_human_2.png`: 16x16
- `Assets/Art/Resources/resource_human_3.png`: 16x16
- `Assets/Art/Resources/resource_human_4.png`: 16x16

Backgrounds:

- `Assets/Art/parallax_background/empty_space_new.png`: 640x360
- `Assets/Art/parallax_background/stars_new.png`: 640x360
- `Assets/Art/parallax_background/background_planets_new.png`: 640x360

Older/non-new variants also exist in the same folders.

## Rendering And Pixel-Art Settings

`project.godot` is configured for pixel-art style:

- Viewport: 640x360
- Stretch mode: `canvas_items`
- Stretch scale mode: `integer`
- Default texture filter: nearest/no filtering
- 2D transform snapping enabled
- 2D vertex snapping enabled
- Renderer: GL compatibility

## Known Rough Edges

- `Scenes/planet.tscn` uses the spaceship placeholder texture as planet art.
- `Scripts/player.gd` prints velocity every physics frame.
- `Scripts/home_planet.gd` only prints on player entry.
- Audio paths in `AudioPlayer` point to missing `Assets/Audio` files.
- Localization path points to missing `Assets/Localization/localization.csv`.
- `SaveManager.default_data` is empty.
- `Scenes/planet_scene.tscn` appears to be an older/test scene separate from the active `Scenes/main_scene.tscn`.
- `Scenes/temp.tscn` is an empty `Control` scene.

## Git/Workspace Notes

At the time these notes were written, the worktree already had modifications in:

- `project.godot`
- `Scenes/main_scene.tscn`

Treat existing modifications as user work unless the user explicitly asks to revert or overwrite them.

## Validation Notes

The Godot CLI was not available on the shell path when checked with:

```sh
godot --version
```

So terminal-based scene validation was not performed.

## Suggested Next Development Steps

Good next increments would be:

- Replace generated planet placeholder art with real planet sprites or generated variations.
- Remove or gate debug `print()` calls.
- Define player inventory/resources: humans, gold, ship fuel, cargo, etc.
- Make planets interactable: scan, land, harvest, raid, or collect resources.
- Give `HomePlanet` an actual deposit/upgrade loop.
- Add UI for cargo/resources.
- Extend `PlanetData` with resource contents, danger, population, and depletion state.
- Decide whether planet generation should happen only in the starting viewport or across a larger world area.
- Add save data defaults once the main game loop exists.
