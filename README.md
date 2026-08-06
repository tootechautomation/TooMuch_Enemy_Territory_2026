# Frontline: Objective

## Version 4.5.0 High-Fidelity WWII Environment Pass

### High-resolution materials
- Added 1024px limestone-block PBR set.
- Added 1024px slate-roof PBR set.
- Added 1024px damaged-plaster PBR set.
- Added 1024px compacted-gravel PBR set.
- Each set includes albedo, normal, and roughness maps.

### New modular assets
- Detailed stone church with tower, windows, buttresses, roof, and cross.
- Large rail warehouse with loading dock and structural supports.
- WWII field artillery piece.
- Reusable crate-and-barrel clusters.

### Environment upgrade
- Added church landmark to the village.
- Added detailed warehouse to the rail yard.
- Added field guns and prop clusters throughout the map.
- Added high-resolution gravel road and rail-yard overlays.
- Enabled SSAO, SSIL, and color adjustment when supported by the installed Godot build.
- Improved sunlight, contact depth, contrast, and muted wartime color grading.

### First-person presentation
- Added subtle camera inertia to the imported weapon and arms.
- Mouse movement now produces small delayed weapon motion.
- Existing recoil, muzzle smoke, shell ejection, ADS, sprint lowering, and weapon bob remain.

### Compatibility
- Build: v4.5.0
- Protocol: 341
- Explicit connection-message `+` retained.
- All visual assets remain optional for the headless server.

Expected status: `Connected: v4.5.0 protocol 341`
