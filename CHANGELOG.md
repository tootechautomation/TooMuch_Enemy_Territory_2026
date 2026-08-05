# Changelog

## 0.5.0

- Added downed and bleedout states.
- Added Medic reviving.
- Added deployable health and ammunition packs.
- Added Engineer objective charge and fuse timer.
- Added replicated kill/event feed.
- Added live scoreboard.
- Added procedural first-person rifle blockout.
- Replicated kills, deaths, and downed state.

## 0.3.0 — Movement and weapon framework

- Added modular `WeaponDefinition` resources.
- Added magazine ammo, reserve ammo, timed reloads, rate of fire, range, damage, spread, and recoil metadata.
- Added sprinting and crouching.
- Added interpolation for remote player snapshots.
- Kept movement, firing, damage, reloads, objectives, and respawns server-authoritative.
- Expanded the HUD with weapon and reload state.

## 0.2.0 — Authoritative multiplayer foundation

- Server-authoritative movement and combat.
- Spawn waves, match timer, replicated match state, and validation workflow.

## 0.4.0 - Classes and original uniforms

- Added original procedural attacker and defender character uniforms.
- Added four bundled skin palettes with no external or Wolfenstein assets.
- Added Q class abilities with server-side cooldown validation.
- Medic heals nearby teammates; Field Ops resupplies ammunition.
- Soldier self-resupplies; Engineer repairs armor/health; Scout receives a light recovery ability.
- Added class-ability cooldown to the HUD.
