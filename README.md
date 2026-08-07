FRONTLINE: OBJECTIVE v8.82.0
DEATH DROPS + CROSS-FACTION WEAPON PICKUPS

NEW GAMEPLAY SYSTEM
When a player is fully eliminated they now drop:
1. their primary weapon
2. their secondary pistol
3. a separate ammunition pouch

INTERACTION
Use the existing INTERACT action near a dropped item.

WEAPON SWAPS
- taking a primary replaces slot 0
- taking a pistol replaces slot 1
- the picked weapon automatically becomes equipped
- weapon pickup preserves remaining magazine/reserve ammunition
- dropped equipment expires after 55 seconds

CROSS-FACTION EXAMPLES
Allied player can kill Axis and pick up:
- MP40 to replace Thompson/current primary
- P38 to replace TT/current pistol

Axis player can kill Allied and pick up:
- Thompson to replace MP40/current primary
- TT pistol to replace P38/current pistol

IMPORTANT TECHNICAL CHANGE
Weapon appearance is no longer assumed to equal player faction.
Each inventory slot now stores its own weapon-origin team:
    weapon_slot_teams

So an Allied character can remain Allied while physically carrying/rendering
an Axis MP40/P38, including first-person and third-person external models.

RESPAWN
Respawning restores the player's normal faction/class loadout and ammunition.

AMMO
The separate ammo pouch adds reserve ammunition to the currently equipped
weapon, capped by that weapon's normal reserve maximum.

PRESERVED
- working Axis P38 orientation
- Allied TT correction
- Mouse2 shoulder zoom
- persistent crosshair
- all v8.81 performance/LOD work
- collision / objectives / networking architecture

Build: 8.82.0
Network protocol: 341
