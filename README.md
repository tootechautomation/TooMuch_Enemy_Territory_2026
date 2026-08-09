FRONTLINE: OBJECTIVE v8.97.0
TEAM REINFORCEMENT WAVES + DEAD-PLAYER RESPAWN FLOW

IMPORTANT DISCOVERY
The game already had real 10-second reinforcement waves. The problem was that
it used ONE GLOBAL TIMER.

The Command Post reinforcement bonus was therefore shortening the wave for BOTH
teams whenever either side controlled the post.

v8.97 corrects the existing gameplay instead of adding a duplicate system.

TEAM-SPECIFIC WAVES
- Allies/Attackers have their own reinforcement timer
- Axis/Defenders have their own reinforcement timer
- a team respawns only when ITS timer reaches zero
- each team uses its own ticket count
- spawn validation / forward spawns remain unchanged

COMMAND POST BONUS
SPAWN_WAVE_SECONDS remains 10 seconds.

The existing FORWARD_SPAWN_WAVE_BONUS is now applied only to the Command Post
owner:
- team without CP: normal 10 second reinforcement cycle
- team controlling CP: 8 second cycle
- minimum remains protected at 5 seconds

This makes the Command Post materially useful without accidentally buffing the
enemy team too.

NETWORK COMPATIBILITY
A new lightweight unreliable reinforcement-state RPC synchronizes:
- attacker_spawn_wave_remaining
- defender_spawn_wave_remaining

The legacy spawn_wave_remaining variable remains for older HUD/status code and
is populated with the LOCAL player's team timer on clients.

DEAD-PLAYER HUD
When fully eliminated, the local player now gets a compact center panel:

WAITING FOR REINFORCEMENTS · Xs
M CLASS / TEAM · TAB SCOREBOARD

It disappears automatically on respawn.

RESPAWN SAFETY
server_respawn now explicitly:
- re-enables the player's collision shape
- restores player visibility
- retains existing spawn protection
- restores normal class loadout/ammunition

PRESERVED
- v8.96 TAB raw-input scoreboard fix
- v8.96 F6 cinema toggle
- bottom HUD alignment
- LowCostVisualClarity
- structural collision guard
- first-person hands/arms fallback
- menu-aware HUD
- objective sanity/clamping
- active-weapon-only death drops
- same-weapon ammo scavenging
- cross-faction weapon swaps
- resupply
- casualty persistence
- performance scalability stack
- working Axis P38
- Mouse2 zoom + crosshair
- server authority / objective logic

Build: 8.97.0
Network protocol: 341
