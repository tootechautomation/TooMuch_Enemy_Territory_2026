# Frontline: Objective

Original Godot 4 multiplayer objective-shooter prototype.

## Version 1.0: grenades and explosion damage

Added:

- Server-authoritative fragmentation grenades
- Two grenades per life
- Press **G** to throw
- Three-second fuse
- Ballistic movement and simple world bouncing
- Distance-scaled explosion damage
- Friendly-fire protection for grenade damage
- Replicated grenade movement for clients
- Brief procedural explosion flash
- Automatic grenade cleanup when a round resets
- Active grenade inventory in the HUD

No Wolfenstein source code, proprietary game data, maps, characters, branding, audio, or artwork are included.

## Dedicated server

```bash
flatpak run org.godotengine.Godot \
  --headless \
  --path . \
  --server \
  --port 27960 \
  --bots 8
```

## Controls

- WASD: move
- Shift: sprint
- C: crouch
- Space: jump
- Mouse: aim
- Left mouse: fire
- R: reload
- X: switch rifle/pistol
- G: throw grenade
- Hold E: revive, construct, arm, or defuse
- Q: class ability
- 1–5: select class
- Tab: scoreboard
- F while dead: cycle teammate cameras
- Escape: release mouse

## Validate

```bash
./tools/validate_project.sh
```
