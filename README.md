FRONTLINE: OBJECTIVE v8.93.0
OBJECTIVE AWARENESS + MATCH-FLOW HUD

NEW CLIENT HUD
A compact upper-left objective panel now provides:
- current/next objective
- contested-state emphasis
- capture progress where available
- Allied vs Axis ticket status where available
- spawn-wave countdown
- short objective/event banner when the visible objective state changes

OBJECTIVE PRIORITY
The HUD prioritizes contested objectives first, then unresolved Command Post /
Supply Depot captures, then falls back to holding captured ground and reducing
enemy tickets.

SPAWN WAVE
If the game exposes an authoritative spawn-wave remaining value, the HUD uses
it. Otherwise the display derives an approximate countdown from the existing
10-second wave cadence. This is presentation only and does not drive spawning.

PERFORMANCE
- refresh interval is approximately 0.15 seconds, not every rendered frame
- no new 3D geometry
- no new dynamic lights
- no new network RPC traffic
- Low/Laptop keeps the HUD but slightly reduces opacity

PRESERVED
- v8.92 remote-player presentation LOD
- v8.91 memory scaling
- v8.90 CPU/frame pacing
- v8.89 GPU presets
- F8 Low/Balanced/High system
- active-weapon-only death drops
- same-weapon ammo scavenging
- cross-faction weapon swaps
- contextual pickup HUD
- resupply stations
- casualty persistence
- shell casing / weapon handling feedback
- working Axis P38 orientation
- Mouse2 shoulder zoom
- persistent crosshair
- collision / objectives / server authority / networking

Build: 8.93.0
Network protocol: 341
