FRONTLINE: OBJECTIVE v10.1.0
MAP IDENTITY + MAP-AWARE HUD + RUINED CITY BOT ROUTES

Operation Black River remains the default and its geometry is unchanged.

RUINED CITY is now presented as:
OPERATION ASHEN STREETS

ATTACK:
Open the central crossing, seize the command post, and demolish the eastern
pillbox.

DEFEND:
Hold the central streets, deny the command post, and protect the eastern
pillbox.

MAP-AWARE PRESENTATION
- TAB scoreboard shows active operation and location
- objective marker uses map-specific language
- contextual E prompts use map-specific language
- status bar says CROSSING/PILLBOX on Ruined City
- tactical map is unique per map
- a 5.2-second mission banner appears after map load
- server console prints operation/mission details

BOT FIX
Ruined City bots now have their own four-route waypoint set per team instead
of following Black River coordinates.

Ruined City forward-spawn sector priority now uses:
West Ruins / Central Square / Pillbox Ridge.

MAP SELECTION
Server:
--map ruined_city

Clients still receive the server-selected map automatically.

UNCHANGED
- Black River map detail
- Ruined City geometry/setpieces
- Jeep / Sherman / Spitfire / Bf 109
- WWII character models
- Allied Mk 2 grenade
- Axis grenade path
- weapons/textures
- collision/destruction
- TAB priority behavior
- contextual E mechanics
- --bots 0 / --bots=0 / --no-bots

Build: 10.1.0
Protocol: 344
