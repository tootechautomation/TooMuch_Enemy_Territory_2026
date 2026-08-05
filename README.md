# Frontline: Objective

## Version 2.4.1 gray-screen recovery

Fixed the v2.4.0 startup regression.

- Camera, HUD, and deployment menu initialize before radar/audio.
- Local Camera3D is explicitly activated.
- Radar/audio initialize later through a deferred optional path.
- Missing or not-yet-imported WAV files cannot stop the player `_ready()` method.
- Audio is loaded with runtime existence and type checks.
- Radar validates network dictionaries and node methods before reading them.
- Grenade and explosion audio are also failure-safe.

All v2.4 radar and audio features remain included.

Expected status: `Connected: v2.4.1 protocol 241`
