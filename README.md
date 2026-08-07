FRONTLINE: OBJECTIVE v8.83.0
ACTIVE-WEAPON DROP + MATCHING-WEAPON AMMO SCAVENGE

DEATH DROP RULE
Only the weapon physically active/in the player's hands at the moment of death
is dropped.

Examples:
- Axis dies while holding MP40 -> MP40 drops.
- Axis dies while holding P38 -> P38 drops.
- Allied dies while holding Thompson -> Thompson drops.
- Allied dies while holding TT -> TT drops.

The inactive weapon does NOT appear on the ground.

AMMO
A small separate ammo pouch still drops to represent carried magazines.

MATCHING WEAPON INTERACTION
If you interact with a dropped weapon that you already own in that same slot,
the dropped gun is treated as an ammunition source instead of replacing your
identical weapon.

Example:
- You already carry an MP40.
- Another MP40 is on the ground.
- INTERACT transfers that dropped MP40's magazine + reserve ammunition into
  your MP40 reserve, capped at your normal reserve maximum.
- The dropped MP40 disappears only if ammunition was actually transferred.

If the dropped weapon is different, the existing swap behavior remains:
- primary replaces primary
- pistol replaces pistol

PICKUP POLISH
- clearer "TAKE / SCAVENGE" prompt
- subtle ground marker under dropped equipment
- 55-second cleanup remains

PRESERVED
- Axis P38 orientation
- Allied TT / Thompson / MP40 rendering
- cross-faction weapon rendering
- Mouse2 shoulder zoom
- persistent crosshair
- collision / objectives / networking
- v8.81 performance/LOD work

Build: 8.83.0
Network protocol: 341
