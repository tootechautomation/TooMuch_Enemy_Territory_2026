# Frontline: Objective

Original Godot 4 multiplayer objective-shooter prototype.

## Version 0.9: weapon loadouts and hit confirmation

Added:

- Service Rifle primary weapon
- Service Pistol sidearm
- Separate magazine and reserve ammunition for each weapon
- Server-authoritative weapon switching
- Press **X** to switch between primary and sidearm
- Weapon-dependent first-person blockout models
- Brief hit-confirmation marker when a shot damages an enemy
- Updated HUD showing the active weapon slot

No Wolfenstein code, assets, branding, maps, characters, or audio are included.

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
