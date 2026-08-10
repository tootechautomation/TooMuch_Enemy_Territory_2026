FRONTLINE: OBJECTIVE v9.26.0
WEAPON HANDLING + RELOAD/SWAP RELIABILITY

DIRECT WEAPON KEYS
1 = primary slot
2 = secondary slot

These are handled in the direct input path so focused UI Controls are less
likely to swallow weapon selection during normal gameplay.

QUICK SWITCH
The existing weapon_switch action (Q in the current control scheme) now
prefers the actual previously equipped weapon instead of blindly advancing
through the slot array.

This matters if more weapon slots are added later.

RESPONSIVE LOCAL PRESENTATION
Weapon models switch immediately on the local client while the server remains
authoritative and confirms/corrects the selected slot.

A short 110 ms debounce prevents duplicate key repeats/RPC spam.

RELOAD CANCELLATION
Changing weapons cancels reload safely.

Firing during a tactical reload:
- if the magazine still contains rounds, the reload is cancelled and fire is
  allowed
- if the magazine is empty, the reload cannot be bypassed

No ammunition is granted/lost because ammo state is stored before switching.

EMPTY-MAG AUTO RELOAD
If the server receives a fire request with:
- magazine = 0
- reserve > 0

it starts the normal reload automatically.

This avoids repeated dry-fire requests when the player is already trying to
continue firing.

RELOAD AUDIO
Reload audio now only begins when a reload is actually possible.
Weapon switching or firing-to-cancel also stops the local reload audio.

VEHICLES
Infantry weapon switching is ignored while seated in a vehicle.

PERFORMANCE
No new rendering.
No new physics.
No continuous RPCs.
Only tiny input-state/debounce logic.

PRESERVED
- v9.25 TAB scoreboard priority
- v9.24 bot combat intelligence
- revive/team awareness
- spatial audio
- effect budgets
- spawn safety
- destructible environment
- all vehicles/aircraft
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.26.0
Protocol: 341
