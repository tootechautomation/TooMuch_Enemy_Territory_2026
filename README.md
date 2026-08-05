# Frontline: Objective

## Version 1.2: stance, weapon-view, recoil, and bot fixes

Fixed:

- Pistol slot now rebuilds the first-person model immediately.
- Recoil is visibly stronger and includes weapon kick.
- Crouching lowers the camera, collision capsule, and body.
- HUD shows STANDING or CROUCHED.
- Headless servers default to eight bots.
- `--bots 0` explicitly disables bots.
- Server logs list every spawned bot and final actor count.

## Start server

Eight bots by default:

```bash
flatpak run org.godotengine.Godot --headless --path . --server --port 27960
```

Custom count:

```bash
flatpak run org.godotengine.Godot --headless --path . --server --port 27960 --bots 12
```

No bots:

```bash
flatpak run org.godotengine.Godot --headless --path . --server --port 27960 --bots 0
```

## Controls

WASD move, Shift sprint, C crouch, Space jump, left mouse fire, R reload, X switch weapon, G grenade, hold E interact, Q ability, 1–5 class, Tab scoreboard, F spectate.
