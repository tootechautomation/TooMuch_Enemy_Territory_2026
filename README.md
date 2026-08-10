FRONTLINE: OBJECTIVE v9.16.0
FIRST-PERSON ARMS/HANDS + WEAPON PRESENTATION POLISH

FIRST-PERSON ARMS FALLBACK
The procedural fallback has been rebuilt with:
- cleaner forearm/sleeve proportions
- cuffs
- structured palms
- knuckle blocks
- four low-poly fingers per hand
- thumbs
- reduced segment counts for performance

TEAM SLEEVES
Allied:
- muted olive-drab sleeve

Axis:
- muted field-grey sleeve

Team materials refresh when the weapon/team presentation refreshes.

DYNAMIC ARM POSES
The procedural hands now respond to:
- primary vs pistol slot
- ADS
- sprinting
- reload state
- walking/running
- suppression

ADS:
hands pull inward toward the weapon.

SPRINT:
arms lower/tuck with the weapon.

RELOAD:
support hand moves toward the magazine/breech region.

MOVEMENT:
small independent arm sway reduces the floating/glued-to-camera appearance.

SUPPRESSION:
tiny visual-only tremor. No accuracy manipulation.

PERFORMANCE
This remains a fallback rig made from simple MeshInstance3D primitives.
- no Skeleton3D
- no skinning
- no animation tree
- no imported high-poly arms
- no shadows
- reduced mesh radial segments

If a real first-person arm/hand rig is later imported, the fallback detects it
and does not stack itself on top.

PRESERVED
- v9.15 HUD/objective performance pass
- v9.14 infantry combat feedback
- v9.13.2 tracer fixes
- destructible streets
- all vehicle/aircraft systems
- real vehicle GLBs
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.16.0
Protocol: 341
