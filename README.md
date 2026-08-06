# Frontline: Objective

## Version 6.0.0 Bot Locomotion, Direct Input & WWII Character Upgrade

### Bot locomotion reset
Squad orders and shared enemy information remain, but moving escort formations
no longer control bot locomotion.

Bots now:
- Follow stable team route waypoints
- Switch directly to the objective within 20 meters
- Ignore shared enemies beyond 48 meters
- Smoothly rotate toward goals instead of repeatedly using `look_at`
- Stop route advancement at the final waypoint instead of wrapping backward

This removes the circular formation chasing that caused stationary spinning.

### Direct keyboard controls
The player now reads the physical keys directly in `_unhandled_input`:

- Tab: hold scoreboard
- K: toggle tactical map
- M: spawn/team/class menu
- Escape: close overlays

Input Map actions remain as controller/remapping fallbacks.

### WWII character upgrade
Procedural third-person soldiers now include:
- Neck, collar, and facial nose shape
- Separate forearms and lower legs
- Tunic skirt
- Defined shoulders
- Cross-body web straps
- Canteen and entrenching tool
- Rougher cloth materials
- Existing helmet, pack, belt, pouches, gloves, boots, and class gear

### Optional rigged model slots
The client checks for these optional files:

- `res://assets/models/allied_soldier.glb`
- `res://assets/models/axis_soldier.glb`

They are loaded only at runtime after Godot imports them. They are not
parse-time preloads and cannot break headless startup.

For best results, future models should be rigged humanoid GLBs with idle, walk,
run, crouch, fire, reload, death, and revive animations.

### Compatibility
- Build: v6.0.0
- Protocol: 341
- Explicit connection-message `+` retained
- Cache-independent VPS startup retained

Expected status: `Connected: v6.0.0 protocol 341`
