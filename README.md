FRONTLINE: OBJECTIVE v10.0.1
SERVER-AUTHORITATIVE MAP SELECTION HOTFIX

PROBLEM FIXED
v10.0.0 allowed the server to select Ruined City, but graphical clients built
Operation Black River before they connected. The client therefore remained on
Black River even though the server was running Map 2.

NEW STARTUP ORDER
- Headless/dedicated server parses --map first and builds that map.
- Graphical clients sitting at the connection menu build NO playable world.
- When the client connects, the server sends:
  protocol + build version + active map id
- The client accepts the server map id and constructs that map exactly once.
- The server remains authoritative for map selection.

IMPORTANT
For multiplayer Map 2 testing, ONLY THE SERVER needs:

--map ruined_city

Clients can start normally and connect through the menu. They should print:

Connected: v10.0.1 protocol 343 · map Ruined City

The server should print:

Active map: Ruined City [ruined_city]

BLACK RIVER
No map argument = Operation Black River.

RUINED CITY SERVER EXAMPLE
godot --headless --path /project --server --port 27960 --bots 0 --map ruined_city

or:

godot --headless --path /project --server --port 27960 --bots=0 --map=ruined_city

PRESERVED
- Operation Black River remains unchanged/default
- separate Ruined City assets/map builder
- Jeep / Sherman / Spitfire / Bf 109
- WWII soldier models
- Allied Mk 2 grenade
- Axis grenade behavior
- bots and --bots 0
- current HUD/gameplay systems

Build: 10.0.1
Protocol: 343
