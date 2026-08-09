FRONTLINE: OBJECTIVE v8.96.0
HUD ALIGNMENT + F6/TAB INPUT HARDENING + LOW-COST VISUAL CLARITY

FIX 1 — BOTTOM HUD ALIGNMENT
The lower HUD was visually crowded against the bottom edge.

v8.96:
- health and ammo cards now share a cleaner baseline
- both side cards are slightly shorter
- Bunker Damage label/bar moved upward
- center status row moved upward
- more breathing room between objective bar / status / screen edge
- existing resolution-safe 1280x720 scaling remains intact

FIX 2 — TAB SCOREBOARD
TAB was previously handled only in _unhandled_input().
Godot Control focus can consume Tab before _unhandled_input receives it.

v8.96 now handles TAB in raw _input():
- focused UI cannot steal it during gameplay
- press/hold TAB = scoreboard
- release TAB = close scoreboard
- scoreboard remains accessible even in cinema HUD mode

FIX 3 — F6 CINEMA MODE
F6 is restored as a dedicated raw-key cinema-HUD toggle:
- F6 hides normal combat HUD
- F6 again restores it
- works even if a Control currently owns keyboard focus
- match-flow objective panel is suppressed
- reinforcement panel is suppressed
- quality/F8 indicator is suppressed
- kill feed/radar/combat panels are suppressed
- TAB scoreboard remains available
- F6 state does NOT alter gameplay or graphics quality

VISUAL QUALITY — NO EXTRA FPS COST
The Low/Laptop screenshot was visually washed out because regular fog density
remained fairly strong even after volumetric fog was disabled.

v8.96 adds LowCostVisualClarity:
LOW:
- regular fog density reduced substantially
- slightly stronger contrast
- slightly richer saturation
- darker/cooler fog light instead of washed-out white haze

BALANCED:
- moderate fog
- modest contrast/readability improvement

HIGH:
- preserves the cinematic atmosphere while avoiding unnecessary white wash

This adds:
- no meshes
- no lights
- no particles
- no extra shadow casters
- no new network traffic

WHY THE GAME STILL DOES NOT FULLY MATCH CONCEPT ART
The remaining gap is increasingly ASSET-BOUND rather than code-bound:
- higher-quality modular WWII buildings
- cobblestone/road PBR sets
- better rubble/prop libraries
- skeletal first-person arm animations
- more character skins/uniforms
- authored level geometry instead of procedural block structures

The engine/code now has the scalability and asset hooks needed to use those
without abandoning laptop compatibility.

YOU DO NOT NEED A DIFFERENT AI MODEL TO CONTINUE
The next meaningful visual jump will come from supplying/choosing better game
assets and then integrating/optimizing them, not changing coding assistants.

PRESERVED
- structural collision guard
- first-person arm/hand fallback
- menu-aware objective HUD
- reinforcement display
- objective progress sanity
- active-weapon-only drops
- same-weapon ammo scavenging
- cross-faction weapon swaps
- resupply
- casualty persistence
- contextual pickup HUD
- shell casing feedback
- F8 Low/Balanced/High
- remote-player LOD
- memory/CPU/GPU scalability
- working Axis P38 orientation
- Mouse2 zoom + persistent normal-game crosshair
- server authority / objectives / networking

Build: 8.96.0
Network protocol: 341
