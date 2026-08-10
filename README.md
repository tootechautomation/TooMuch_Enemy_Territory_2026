FRONTLINE: OBJECTIVE v12.1.0
MAJOR UPDATE — SPAWN RECOVERY / DEPLOYMENT STABILITY

PRIMARY FIX
The inherited spawn table was still using old map-edge coordinates around
x +/-50 to +/-58 even though the current authored team deployment zones are
centered around x +/-15. That could spawn a player inside a building, ruin,
roof volume, or boxed architectural space.

CHANGES
- Re-authored both teams' primary spawn arrays inside the actual deployment zones.
- Human players now prioritize safe base deployment on join.
- Tactical rally / sector forward spawns no longer hijack a human's initial spawn.
- Bots retain tactical forward-spawn behavior.
- Emergency spawn now uses the known team deployment zone.
- Removed the extra +0.35m respawn lift after spawn validation.
- Existing spawn capsule validation remains active.
- Existing manual unstuck/recovery system remains active.
- v12 objective warfare and squad intelligence preserved.
- No map geometry, building, ruin, vehicle, weapon, or environment rewrite.

Build 12.1.0
Protocol 354
