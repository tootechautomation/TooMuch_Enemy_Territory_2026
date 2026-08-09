FRONTLINE: OBJECTIVE v9.03.3
VEHICLE COMBAT WORLD-SPACE HOTFIX

FIXED
Godot error:
Function "get_world_3d()" not found in base self.

CAUSE
main.gd extends Node rather than Node3D.
The new vehicle weapon raycast attempted:
    get_world_3d().direct_space_state

FIX
The firing vehicle is a Node3D, so the raycast now obtains its World3D:
    var vehicle_world: World3D = vehicle.get_world_3d()
    var hit := vehicle_world.direct_space_state.intersect_ray(query)

ALSO HARDENED
- vehicle hit detection no longer depends on the DrivableVehicle class name
  being globally resolvable in main.gd.
- vehicle targets are detected by server_apply_damage + vehicle_id capability.
- vehicle-hit handling is evaluated before generic server_take_damage handling,
  preventing the wrong damage path from swallowing vehicle hits.

PRESERVED
- tank cannon
- aircraft machine guns
- vehicle HUD
- vehicle destruction / fire / explosion effects
- real Willys / Sherman / Spitfire / Bf109 GLBs
- seat lock and E enter/exit
- weapon hidden while driving
- F6/F8 presentation controls
- --bots 0 / --bots=0 / --no-bots

Build: 9.03.3
Protocol: 341
