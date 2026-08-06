# Frontline: Objective

## Version 5.0.0 Visual Identity & Battlefield Detail

### Compass correction
- Replaced the imported compass-frame texture with a native Godot Control.
- The circular compass is drawn at runtime and cannot crop off-screen.
- Uses top-right anchoring rather than fixed screen coordinates.
- Compass ticks rotate relative to player heading.
- Objective bearing is displayed as a gold diamond.
- Team affiliation appears as a colored inner arc.
- Radar markers are clamped inside the circular map boundary.

### Objective guidance
- Added a centered objective direction arrow.
- Arrow points left, right, or forward.
- Existing objective distance and heading remain visible.

### Battlefield detail
- Added wooden roadside and perimeter fences.
- Added telegraph poles and ceramic insulators.
- Added shell craters throughout contested areas.
- Added village, rail-depot, and fort direction signs.
- All new dressing is graphical-client safe and headless compatible.

### First-person presentation
- Reduced imported rifle and pistol visual scale.
- Shifted the primary weapon slightly right and down.
- Weapon now blocks less of the center view.
- Existing arms, recoil, sway, smoke, shell ejection, and ADS remain.

### Compatibility
- Build: v5.0.0
- Protocol: 341
- Explicit connection-message `+` retained.

Expected status: `Connected: v5.0.0 protocol 341`
