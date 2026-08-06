# Frontline: Objective

## Version 5.9.1 Squad Movement & Tactical Map Hotfix

### Bot movement fix
`SquadCoordinator.squad_id()` returned the result of `/` from a function typed
as `int`. Godot 4 division returns a float, which could interrupt every bot AI
tick.

Fixed:
```gdscript
return int(posmod(peer_id, 8) / SQUAD_SIZE)
```

The formation row calculation is also explicitly converted to int.

Additional safeguards:
- Formation roles are clamped to 0-3.
- Near-zero support goals are ignored.
- A stationary escort no longer freezes the squad away from the objective.
- Target-claim counts reset every 0.9 seconds.

### Tactical map control fix
Both the tactical map and class menu were bound to M.

New controls:
- `M`: spawn/team/class menu
- `K`: tactical map
- `Escape`: close tactical map or deployed spawn menu

The map and spawn menu now dismiss one another. Respawning and deploying also
force the tactical map closed.

### Compatibility
- Build: v5.9.1
- Protocol: 341
- Explicit connection-message `+` retained.
- All v5.9 squad coordination features remain.

Expected status: `Connected: v5.9.1 protocol 341`
