# Milestone 8.18 — Battlefield Surface and Prop Fidelity

Version 8.18 replaces another layer of visibly basic world dressing with detailed, dimensional fallback art while keeping the open-source project self-contained.

## Visual upgrades

- Three rail-yard lines now include graded ballast, creosote sleepers, individual spikes, steel rail heads, and rusted web layers.
- North and south road approaches now show wheel wear and irregular repair work rather than uninterrupted flat strips.
- Village facades receive recessed translucent panes, wooden cross-mullions, and period door hardware.
- Fort positions receive layered concrete embrasures, armored shutters, and visible bolts.
- Location-specific wooden direction signs improve environmental identity without replacing objective HUD information.
- Rounded stone and brick debris reduces reliance on box-shaped clutter.

## Compatibility and performance

All additions are presentation-only `MeshInstance3D` or `Label3D` nodes. They do not add collision, change navigation, alter objective interaction radii, or affect authoritative state. Detail nodes use distance fading and are not built by headless servers. Protocol 341 remains unchanged.

The existing external-asset adapter remains authoritative. Properly licensed imported character, weapon, vehicle, and structure models can still replace fallback art without modifying this pass.
