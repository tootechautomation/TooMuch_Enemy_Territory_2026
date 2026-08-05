# Frontline: Objective

An original Godot 4 class-based objective shooter prototype. It contains no Wolfenstein code, game data, maps, branding, characters, audio, or artwork.

## Version 0.5 — Teamplay milestone

- Server-authoritative movement, shooting, damage, reloads, objectives, and respawns
- Downed state with a 15-second bleedout window
- Medic revive interaction
- Deployable health and ammunition packs
- Engineer-planted objective charge with an 8-second fuse
- Scoreboard with team, kills, deaths, and player state
- Five-entry event/kill feed
- Procedural first-person service-rifle blockout
- Four original procedural team uniform skins
- Sprint, crouch, class abilities, spawn waves, match timer, and remote interpolation

## Controls

- WASD: move
- Shift: sprint
- C: crouch
- Space: jump
- Mouse: aim
- Left mouse: fire
- R: reload
- E: revive as Medic or arm the objective as attacking Engineer
- Q: class ability / deploy support pack
- 1–5: choose class
- Tab: scoreboard
- Escape: release mouse

## Class abilities

- Soldier: personal ammunition reserve
- Medic: deploy health pack; revive downed teammates with E
- Engineer: field repair; arm the objective charge with E
- Field Ops: deploy ammunition pack
- Scout: light personal recovery

## Run a VPS server

```bash
flatpak run org.godotengine.Godot --headless --path . --server --port 27960
```

Open UDP port 27960. The Windows client should run locally and connect to the VPS public IP.

## Validate

```bash
./tools/validate_project.sh
```

## Status

This is a playable engineering prototype, not a production-ready public release. It still needs client prediction, lag compensation, proper animations, audio, menus, spawn selection, anti-cheat hardening, map content, and broader playtesting.
