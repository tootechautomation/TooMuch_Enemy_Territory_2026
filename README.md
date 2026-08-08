FRONTLINE: OBJECTIVE v8.87.0
CONTEXTUAL PICKUP HUD + SCAVENGING FEEDBACK

NEW CONTEXTUAL WORLD PROMPTS
Dropped weapons now describe exactly what INTERACT will do for the local player.

Examples:
- Already carrying MP40:
  [INTERACT] SCAVENGE MP40 AMMO +42

- Allied player carrying Thompson sees dropped MP40:
  [INTERACT] SWAP PRIMARY → MP40

- Axis player carrying P38 sees dropped TT:
  [INTERACT] SWAP SECONDARY → TT PISTOL

- Ammo pouch:
  [INTERACT] TAKE AMMO +30

The prompt updates from the LOCAL player's actual inventory and therefore works
correctly with cross-faction weapon pickups.

LOCAL FEEDBACK
After a successful pickup the HUD now reports:
- which slot changed
- the equipped weapon
- current magazine/reserve values

Matching-weapon scavenging reports:
- PRIMARY/SECONDARY
- ammo added
- resulting reserve

PERFORMANCE
Context prompts refresh at a lightweight ~0.18 second interval rather than
performing inventory checks every rendered frame.

PRESERVED
- only ACTIVE weapon drops
- matching weapon = ammo scavenging
- different weapon = primary/secondary swap
- world weapon presentation from v8.86
- casualty persistence
- resupply stations
- working Axis P38 orientation
- Mouse2 shoulder zoom
- persistent crosshair
- collision / objectives / networking
- all environment/performance systems

Build: 8.87.0
Network protocol: 341
