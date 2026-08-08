FRONTLINE: OBJECTIVE v8.85.0
CASUALTY PERSISTENCE + BATTLEFIELD AFTERMATH

NEW
When a player is fully eliminated:
- the live player node still hides as before
- a temporary casualty silhouette remains at the death location
- the casualty keeps the dead player's team coloration
- body orientation follows the player's final facing direction
- a damp/disturbed ground patch appears underneath
- the active dropped weapon is positioned beside the casualty
- the loose-ammo pouch is positioned on the opposite side

CLEANUP
- casualty visuals persist for 28 seconds
- dropped weapons/ammo still use their existing 55-second cleanup
- casualty geometry fades at long range to control visual cost

IMPORTANT
The casualty is VISUAL ONLY:
- no collision
- no blocking movement
- no hitbox
- no revive target
- no gameplay advantage/disadvantage

PRESERVED
- only ACTIVE weapon drops
- same-weapon ammo scavenging
- primary/secondary cross-faction swapping
- resupply stations from v8.84
- pickup interaction priority
- Axis P38 orientation
- Mouse2 shoulder zoom
- persistent crosshair
- collision / objectives / networking
- all existing visual/performance systems

Build: 8.85.0
Network protocol: 341
