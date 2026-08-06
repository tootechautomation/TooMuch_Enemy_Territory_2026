# Frontline: Objective

## Version 8.19.0 — Character Skin and Modular Import Bridge

The bundled fallback soldiers now use original high-resolution olive-drab and field-gray wool albedo skins instead of the earlier schematic blue/red textures. The material response is non-metallic, highly rough cloth with no artificial uniform glow; class accents, friendly markers, and the v8.17 team HUD continue to provide clear gameplay identification.

The external-character registry now auto-detects GLB, FBX, and Blender exports prepared from Modular Military 2-style packages. One assembled, rigged character can be supplied for each team, automatically normalized to human scale, grounded, validated, connected to the animation controller, attached to weapon sockets, and given restrained cloth-only team treatment. Existing generic `allied_soldier.glb` and `axis_soldier.glb` slots remain fully compatible.

The free Modular Military 2 download is documented as an Unreal Engine evaluation build rather than bundled into the project: it contains only cooked Windows demo content and no editable Godot-importable character source. The project remains ready for the licensed full pack's FBX, GLB, or Blender exports without redistributing proprietary source assets.

The battlefield now carries substantially more dimensional detail instead of relying on broad, block-like surfaces. Rail-yard routes gain full sleeper, spike, ballast, rail-head, and rust-web assemblies. Roads show paired vehicle ruts and period repair seams. Village windows gain recessed panes, cross-mullions, hardware, and aged glass, while fortifications gain layered embrasures, armored shutters, and visible fasteners.

Period direction signs and rounded rubble clusters strengthen location identity and environmental storytelling. New dressing is client-side, distance-faded, non-colliding, and omitted on headless servers. Existing imported-model overrides remain supported, so redistributable or privately purchased art can continue replacing bundled fallback assets later.

This hotfix renames a reserved Godot keyword that was inadvertently used as a local variable and function parameter in the v8.17 team-identity feature. The full team panel, edge accents, deployment announcements, friendly identifiers, and prior gameplay systems are preserved.

The local player’s allegiance is now unmistakable. A persistent team-colored panel identifies ATTACKERS or DEFENDERS, the selected class, the current attack/defend order, and the associated blue/red team color. Thin peripheral accents reinforce allegiance without covering the center view. Deployment and team changes trigger a short explicit attacker/defender announcement with role verbs.

Friendly world nameplates now include a diamond identifier and remain visible at longer depth-tested ranges. Class labels also remain readable farther away. Enemy players receive no new marker or visibility advantage.

All additions are client-side presentation. Team assignment, uniforms, objectives, spotting, server authority, networking, and protocol 341 remain unchanged.

Build: v8.19.0
Protocol: 341
