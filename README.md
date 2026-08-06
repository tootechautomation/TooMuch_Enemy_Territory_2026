# Frontline: Objective

## Version 5.7.0 Combat AI & Objective Behavior

### Class-aware bot tactics
Bots now select goals according to their class and the active objective stage.

- Soldiers pressure contested objective lanes.
- Medics prioritize downed teammates, then wounded teammates.
- Engineers continue to prioritize bridge, bunker, and construction actions.
- Field Ops move toward nearby teammate clusters and support lanes.
- Scouts hold longer-range anchors and avoid standing directly on objectives.

### Suppression reaction
Bots record the attacker position when damaged. While suppressed, they request
a validated lateral cover position away from the threat instead of continuing
to run straight forward.

### Combat spacing
- Scouts prefer approximately 24-meter engagement spacing.
- Field Ops prefer approximately 13 meters.
- Other classes retain close assault spacing.
- Scouts briefly hold position after firing.
- Low-health medics may disengage instead of continuing to shoot.

### Objective anchors
Added stage-specific tactical anchors for:
- Bridge attack and defense
- Northern, central, southern, and sewer approaches
- Rail yard and bunker attack
- Bunker perimeter defense

Squad-role IDs distribute bots across different anchors.

### Respawn reliability
Bot threat memory, hold states, and route state are cleared after respawn.

### Compatibility
- Build: v5.7.0
- Protocol: 341
- Explicit connection-message `+` retained.
- v5.6.1 cache-independent startup and surface-aware footsteps remain.

Expected status: `Connected: v5.7.0 protocol 341`
