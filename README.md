# Frontline: Objective

An original Godot 4 class-based objective-shooter prototype. It contains no Wolfenstein game data, maps, branding, characters, sounds, or artwork.

## Version 0.6: campaign objectives and progression

This milestone turns the single target into a small two-stage assault mission:

1. Attacking Engineers construct a bridge by using **E** at the yellow build site.
2. After construction, attackers cross the river and arm a charge at the bunker.
3. Defending Engineers can defuse an armed charge by repeatedly using **E** near it.
4. The attackers win when the bunker charge detonates; defenders win when time expires.

Also included:

- Objective XP and five ranks
- XP awards for eliminations, revives, construction, arming, and defusing
- Expanded scoreboard with XP and rank
- Mission-stage HUD
- Original procedural bridge, river, bunker, uniforms, supply packs, and weapon blockouts
- Server-authoritative movement, combat, objectives, revives, and wave respawns

## Controls

- WASD: move
- Shift: sprint
- C: crouch
- Space: jump
- Mouse: aim
- Left mouse: fire
- R: reload
- E: revive, build, arm, or defuse
- Q: class ability / deploy supply pack
- 1–5: select class
- Tab: scoreboard
- Escape: release mouse

## Run the dedicated server

```bash
flatpak run org.godotengine.Godot --headless --path . --server --port 27960
```

## Connect a Windows client

Open `project.godot` in Godot 4.7, run the project, and enter the public IP address of the VPS.

Open UDP port 27960 on the VPS and at the hosting provider firewall.

## Validate

```bash
./tools/validate_project.sh
```

## Status

This remains an alpha prototype. It needs client prediction/reconciliation, lag compensation, animations, audio, polished models, bots, map rotation, and security hardening before public hosting.
