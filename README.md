FRONTLINE: OBJECTIVE v9.20.0
SPAWN SAFETY + ANTI-STUCK RECOVERY

EXISTING SPAWN VALIDATION PRESERVED
The project already had a strong server-side spawn candidate validator:
- floor raycast
- slope validation
- player capsule overlap test
- separation from living players
- enemy staging exclusion
- rally-point validation

v9.20 builds on that system rather than replacing it.

MANUAL UNSTUCK
On foot:
U = request safe position recovery.

Server rules:
- player must be alive
- cannot be downed
- cannot be inside a vehicle
- must be nearly stationary
- 15 second cooldown
- server chooses the destination

The server searches:
1. current position
2. four nearby 1.5m offsets
3. four nearby 2.5m offsets
4. diagonal nearby offsets
5. normal validated team spawn as final fallback

Every candidate uses the existing authoritative spawn validator.

AUTOMATIC BELOW-MAP RECOVERY
If a living on-foot player:
- falls below Y = -8
- or somehow receives a non-finite position

the server automatically invokes the same recovery system.

RECOVERY SAFETY
After recovery:
- velocity resets
- interpolation target resets
- collision is re-enabled
- input vector resets
- short spawn protection refreshes
- client receives the authoritative recovery position

ANTI-ABUSE
Manual U cannot be used while moving faster than 2.5 m/s and has a 15 second
server cooldown.

VEHICLES
Vehicle occupants are intentionally excluded. Vehicle exit/ejection already
uses the dedicated safe-exit system from earlier builds.

PRESERVED
- v9.19 visibility/lighting/route readability
- v9.18.1 parser-safe environment pass
- v9.17 first-person visibility fixes
- HUD/combat feedback
- destructible streets
- all vehicle/aircraft systems
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.20.0
Protocol: 341
