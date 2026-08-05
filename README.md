# Frontline: Objective

An original Godot 4 multiplayer objective-shooter prototype inspired by classic class-based games. It contains no Wolfenstein code, maps, branding, models, textures, sounds, or other proprietary game data.

## Version 0.4

- ENet dedicated server for up to 32 players
- Server-authoritative movement, combat, reloads, class actions, and objective damage
- Sprinting, crouching, jumping, hitscan rifle, spread, magazines, and reserve ammunition
- Five classes: Soldier, Medic, Engineer, Field Ops, and Scout
- Ten-second team respawn waves and ten-minute objective matches
- Four original procedural uniform skins, selected deterministically per player
- Headless Linux VPS operation

## Controls

- WASD: move
- Mouse: look
- Left mouse: fire
- R: reload
- Shift: sprint
- C: crouch
- Space: jump
- E: engineer objective action
- Q: class ability
- 1–5: choose class
- Escape: release mouse

## Class abilities

- Soldier: personal ammunition resupply
- Medic: heals nearby living teammates
- Engineer: repairs personal armor/health and performs objective work
- Field Ops: resupplies ammunition for nearby teammates
- Scout: light field recovery

## Run a server

```bash
flatpak run org.godotengine.Godot --headless --path . --server --port 27960
```

## Run a Windows client from source

Install Godot 4.7, clone this repository, open `project.godot`, and press F6/F5. Enter the VPS public IP in the connection menu.

## Validate

```bash
./tools/validate_project.sh
```

## Current limitations

This is an early playable prototype. The character skins are original procedural blockout uniforms, not final animated production models. It does not yet include reviving downed players, planted dynamite, constructible objectives, audio, bots, client prediction, lag compensation, or a full server browser.
