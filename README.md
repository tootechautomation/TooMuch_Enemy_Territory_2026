# Frontline: Objective

## Version 3.4.2 inactive multiplayer guard

This release fixes the debugger flood seen when running the project in the
Godot editor before hosting or connecting.

### Fixed

- Server logic now checks for an active multiplayer peer before calling
  `multiplayer.is_server()`.
- Automatic emplacements remain dormant during offline editor preview.
- Main round processing remains dormant until hosting or connecting.
- Smoke, grenades, sensor beacons, supply packs, constructibles and
  destructible cover use the same safe multiplayer guard.
- Offline preview displays a clear connection status instead of producing
  thousands of debugger errors.
- All v3.4 skins, textures, sprites and gameplay features remain included.

Expected online status:

```text
Connected: v3.4.2 protocol 342
```

Expected before connecting:

```text
Offline preview — host or connect to begin
```
