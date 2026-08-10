# First Game

A small 2D platformer built with Godot 4.4, targeting desktop and mobile.

## Requirements

- [Godot Engine 4.4](https://godotengine.org/download) or later (Mobile renderer)

## Running the project

1. Open Godot and choose **Import**, then select `project.godot` in this repository.
2. Press **F5** (or the Play button) to run the main scene.

## Controls

| Action | Keyboard         |
|--------|------------------|
| Move   | A / D or ← / →   |
| Jump   | Space or W       |
| Attack | Ctrl or Enter *(input action exists but isn't wired up to gameplay yet)* |

On mobile/touch platforms, on-screen controls (`scenes/mobile_controls.tscn`) provide the same actions.

## Project structure

- `scenes/` — game scenes (player, enemies, levels, pickups, hazards)
- `scripts/` — GDScript sources
- `resources/` — shared resources (tileset, etc.)
- `assets/` — art and sprite sheets
- `android/` — Android export template config (build output is git-ignored)

## Notes

Some bundled art in `assets/` comes from third-party packs; check each pack's included `READ ME.txt`/license file before reusing or redistributing it outside this project.
