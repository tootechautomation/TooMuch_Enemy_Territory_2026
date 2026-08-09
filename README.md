FRONTLINE: OBJECTIVE v9.03.1 HOTFIX

FIXED:
- player.gd parser error at the vehicle exit path.
- Replaced obsolete/nonexistent:
    _refresh_first_person_weapon_visual()
  with the actual current weapon rebuild method:
    _rebuild_first_person_weapon()

WHY:
v9.03.0 restored the first-person weapon after exiting a vehicle using
an older function name that no longer exists in the current player.gd.

RESULT:
- Project should parse past player.gd line ~2728.
- Entering a vehicle still hides gun/arms.
- Exiting a vehicle restores and rebuilds the current first-person weapon.
- First-person arm pose is refreshed immediately afterward.
- Vehicle combat/HUD/destruction changes from v9.03.0 are retained.
- --bots 0 support remains retained.
