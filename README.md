# Frontline: Objective

An original Godot 4 class-based objective-shooter prototype. It contains no Wolfenstein game data, maps, branding, characters, audio, or artwork.

## Version 0.8: stable bots and spectating

This release replaces the affected project files completely and fixes the v0.7 bot startup, reload, firing, and round-restart failures.

### Added

- Death spectating of living teammates
- Press **F** while dead to cycle teammates
- Respawn-wave status in the HUD
- Hold-to-interact construction, reviving, arming, and defusing
- Reliable automatic round restart
- Correct `--bots N` command-line parsing and spawning
- Correct bot weapon range, fire interval, damage, and reload behavior

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
- Hold E: revive, construct, arm, or defuse
- Q: class ability
- 1–5: select class
- Tab: scoreboard
- F while dead: cycle spectator target
- Escape: release mouse

## Validate

```bash
./tools/validate_project.sh
```

This is still an alpha prototype. Navigation meshes, prediction, lag compensation, animation, audio, final assets, and public-server hardening remain future work.
