FRONTLINE: OBJECTIVE v9.17.0
FIRST-PERSON VISIBILITY FIX + GAMEPLAY SCREENSHOT RESPONSE

WHY THIS PHASE
The v9.16 gameplay screenshots showed the procedural arm fallback obscuring
large portions of the screen:
- large white rounded geometry could cover the center view
- black/oval arm geometry could sit beside/over the weapon
- nearby vehicle marker text overlapped compass/objective information

FIRST-PERSON ARM SAFETY REDESIGN
The long capsule-based forearms from v9.16 have been removed.

New fallback:
- compact palm geometry
- three low-poly grip fingers per hand
- thumb
- small cuff
- optional SHORT box-style forearm sleeve

LOW/LAPTOP
- hands only
- short forearm sleeves hidden entirely
- no long arm primitive can cross the camera

BALANCED/HIGH
- compact hands
- short sleeves behind the hands
- no long capsules

HARD VIEW SAFETY
- entire fallback root scaled to 72%
- hand positions are clamped to safe lower-screen ranges
- ADS motion cannot pull hands toward the center sight picture
- sprint moves hands farther down
- reload movement stays below the crosshair
- vehicle/cinema modes force fallback visibility off

TACTICAL MARKER CLEANUP
Nearby vehicle markers have moved from y=115 to y=205 so they no longer sit
inside the heading/objective strip.

Far markers are also shortened to symbol + distance.

PERFORMANCE
The new fallback is cheaper than v9.16:
- fewer finger segments
- no long capsule forearms
- Low/Laptop hides sleeve geometry
- no shadows
- no skeleton/skin/animation tree

PRESERVED
- v9.15 HUD throttling/objective cleanup
- v9.14 infantry combat feedback
- v9.13.2 tracer fixes
- battlefield atmosphere
- destructible streets
- all vehicle/aircraft systems
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.17.0
Protocol: 341
