FRONTLINE: OBJECTIVE v8.92.0
REMOTE PLAYER LOD + MULTIPLAYER PRESENTATION OPTIMIZATION

WHY THIS PHASE
Remote players could still render third-person weapons, small gear, labels and
dynamic shadows at near-player detail regardless of distance.

v8.92 introduces client-only remote-player presentation LOD.

IMPORTANT
LIVE PLAYERS THEMSELVES ARE NEVER REMOVED.
This does not hide enemies or alter gameplay visibility/hit detection.

LOW / LAPTOP
- detailed third-person weapon presentation ~38m
- small gear/attachments ~18m
- player labels ~18m
- remote weapon shadows reduced aggressively
- main character dynamic shadows reduced beyond ~22m

BALANCED
- detailed weapon presentation ~55m
- small gear/attachments ~28m
- labels ~28m
- main-character shadows reduced beyond ~38m

HIGH
- detailed weapon presentation retained to ~78m
- gear/labels remain visible farther out
- original body shadows retained through normal combat ranges

LOCAL PLAYER SAFETY
The local player is excluded from remote-player LOD so first-person viewmodel
quality, weapon orientation and HUD presentation stay intact.

NETWORK/GAMEPLAY SAFETY
NOT CHANGED:
- player replication
- hitboxes/collision
- movement/aiming
- weapon fire rate
- hit registration
- team identity
- objective logic
- server authority
- bot gameplay simulation

UPDATE COST
The presentation check runs about every 0.35 seconds rather than every frame.

PERFORMANCE STACK
v8.89 GPU quality tiers
v8.90 CPU/frame pacing
v8.91 memory/world detail scaling
v8.92 remote-player presentation scaling

F8 still cycles LOW / BALANCED / HIGH.

PRESERVED
- weapon pickup/scavenging rules
- resupply stations
- casualty persistence
- contextual pickup HUD
- working Axis P38 orientation
- Mouse2 zoom + persistent crosshair
- collision/objective/network systems

Build: 8.92.0
Network protocol: 341
