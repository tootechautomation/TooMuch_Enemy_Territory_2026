FRONTLINE: OBJECTIVE v9.03.2

BATTLEFIELD EFFECTS MANAGER HOTFIX

FIXED
Godot parser error:
Identifier "battlefield_effects_manager" not declared in the current scope.

CAUSE
v9.03 added the BattlefieldEffectsManager preload and initialization code,
but the class-level variable declaration was missing from main.gd.

ADDED
var battlefield_effects_manager: Node3D

VERIFIED IN SOURCE
- BattlefieldEffectsManagerScript preload exists.
- manager is instantiated during client visual initialization.
- manager is added as a child.
- initialize(self, visual_quality_manager) call exists.
- vehicle weapon impact/explosion calls retain access to the manager.

PRESERVED
- v9.03 vehicle cannon / aircraft guns
- vehicle HUD
- vehicle damage/destruction
- explosion/fire effects
- actual Willys/Sherman/Spitfire/Bf109 models
- E vehicle entry/exit and seat lock
- spawn fixes
- F6/F8 quality controls
- --bots 0 / --bots=0 / --no-bots

Build: 9.03.2
Protocol: 341
