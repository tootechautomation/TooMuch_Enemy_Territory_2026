# Frontline: Objective

An original Godot 4 class-based objective-shooter prototype. No Wolfenstein game data, maps, branding, characters, audio, or artwork are included.

## Version 0.7: bots, held interactions, and round flow

New features:

- Server-side bots for local and VPS testing
- Bots select all five classes
- Engineer bots build, arm, and defuse objectives
- Medic bots seek and revive downed teammates
- Combat bots locate and fire at enemies
- Hold **E** for construction, arming, defusing, and reviving
- Automatic ten-second round restart
- Round objectives, players, scores, and spawn state reset cleanly

## Start a dedicated server with bots

```bash
flatpak run org.godotengine.Godot \
  --headless \
  --path . \
  --server \
  --port 27960 \
  --bots 8
```

The bot count is clamped between 0 and 16.

## Controls

- WASD: move
- Shift: sprint
- C: crouch
- Space: jump
- Mouse: aim
- Left mouse: fire
- R: reload
- Hold E: revive, construct, arm, or defuse
- Q: class ability / supply pack
- 1–5: select class
- Tab: scoreboard
- Escape: release mouse

## Mission

1. Attacking Engineers construct the bridge.
2. Attackers cross the river.
3. Attacking Engineers arm the bunker charge.
4. Defending Engineers may defuse it.
5. Attackers win on detonation; defenders win on time.

## Validate

```bash
./tools/validate_project.sh
```

## Alpha limitations

The bots use direct steering rather than a navigation mesh. Advanced prediction, reconciliation, lag compensation, polished animation, audio, final models, anti-cheat, and public-server hardening remain future work.
