FRONTLINE: OBJECTIVE v9.04.0
MULTI-SEAT VEHICLES + TURRET CONTROL + VEHICLE RESPAWN

MULTI-SEAT
JEEP:
- first player enters DRIVER seat
- second player can enter GUNNER seat
- gunner uses A/D to traverse weapon
- Mouse1 fires mounted MG

TANK:
- first player enters DRIVER seat
- second player can enter GUNNER seat
- driver controls hull movement
- gunner controls turret yaw independently with A/D
- Mouse1 fires cannon

AIRCRAFT:
- remains single-seat
- driver controls aircraft and guns
- dedicated center gunsight added

VEHICLE ENTRY PROMPTS
Now identify available seat:
E · ENTER JEEP · DRIVER
E · ENTER JEEP · GUNNER
E · ENTER TANK · DRIVER
E · ENTER TANK · GUNNER

VEHICLE HUD
Shows:
- vehicle type
- DRIVER / GUNNER seat
- HP
- speed
- seat-specific controls

VEHICLE RESPAWN
Destroyed vehicles now respawn automatically after 20 seconds at their
original staging position with:
- full health
- no occupants
- zero velocity
- original orientation
- reset turret
- restored visual state

PERFORMANCE
- still uses simplified CharacterBody3D vehicle motion
- turret is transform-only, no rigid-body turret physics
- ray-based weapons retained
- vehicle snapshots remain lightweight

PRESERVED
- real Willys/Sherman/Spitfire/Bf109 models
- tank cannon / aircraft guns
- vehicle destruction effects
- seat lock / safe exit
- first-person weapon hidden while in vehicles
- F6/F8 quality controls
- --bots 0 / --bots=0 / --no-bots
- laptop performance system

Build 9.04.0
Protocol 341
