FRONTLINE: OBJECTIVE v9.10.2
DRIVABLE VEHICLE PARSER HOTFIX

SCREENSHOT ERROR
main.gd:
Could not resolve/preload:
res://scripts/gameplay/drivable_vehicle.gd

ROOT CAUSE
The v9.10.1 finite-transform patch accidentally produced this invalid line:

    target_pitch = _finite_float(pitch, 0.0)_value

The function parameter is named pitch_value.

CORRECTED
    target_pitch = _finite_float(pitch_value, 0.0)

This parser error prevented drivable_vehicle.gd from loading, which then caused
main.gd's preload to fail.

PRESERVED
- v9.10.1 NaN/infinite transform protection
- network transform validation
- destructible streets
- brick/sandbag/wood/concrete cover
- tank bunker support
- anti-vehicle grenades
- vehicle service zones
- aircraft handling
- multi-seat vehicle system
- real Willys/Sherman/Spitfire/Bf109 models
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.10.2
Protocol: 341
