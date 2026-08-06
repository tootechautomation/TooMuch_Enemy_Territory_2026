# Frontline: Objective

## Version 5.1.0 Combat Readability & Map Atmosphere

### Combat readability
- Long tracers now render only their final nine-meter segment.
- Reduced tracer opacity and impact-orb size.
- Added short-lived first-person muzzle lighting.
- Reduced crosshair and objective-arrow dominance.
- Headshots retain audio and medal feedback without oversized center text.

### Battlefield atmosphere
- Added four wooden road barricades.
- Added three burning barrels with particles and local lighting.
- Added three distant smoke columns.
- Added warm objective-zone lighting.
- Existing fog, dust, rubble, craters, fences, poles, signs, and vehicles remain.

### Visual balance
- Fire and smoke are graphical-client only.
- Headless servers do not construct the new particles or lights.
- New atmosphere is positioned away from primary spawn sightlines.
- Combat effects are intentionally shorter and less obstructive.

### Compatibility
- Build: v5.1.0
- Protocol: 341
- Explicit connection-message `+` retained.

Expected status: `Connected: v5.1.0 protocol 341`
