# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bombyboi is a 2D Bomberman clone built with Godot 4.5 using GDScript. The game features grid-based movement on a 64x64 pixel tile system.

### Game Modes
- **Hot seat multiplayer** - Multiple players on the same keyboard
- **Single player** - Play against AI opponents

## Running the Game

Open the project in Godot 4.5 from the `bombyboi/` directory, or run from command line:
```bash
cd bombyboi && godot --path . project.godot
```

## Architecture

- **Main scene**: `map.tscn` - Contains the Map node with two TileMapLayers:
  - `Terrain` - Static tile-based terrain using `Art/Basic_Tiles.png`
  - `Players` - TileMapLayer that holds player scenes as tiles

- **Player**: `player.tscn` + `player.gd` - A CharacterBody2D that moves in grid-aligned steps
  - Uses `playermap_path` and `terrainmap_path` references to access the TileMapLayers
  - Movement converts between world position and map coordinates via `local_to_map`/`map_to_local`

## Input Actions

Player 1 controls are mapped to WASD:
- `p1_move_up` - W
- `p1_move_down` - S
- `p1_move_left` - A
- `p1_move_right` - D
