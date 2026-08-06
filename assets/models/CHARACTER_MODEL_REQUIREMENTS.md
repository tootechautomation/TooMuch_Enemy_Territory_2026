# Optional realistic character models

Place licensed rigged models at:

- `allied_soldier.glb`
- `axis_soldier.glb`

Recommended:
- Godot-compatible humanoid skeleton
- 25,000–80,000 triangles per character
- 2K or 4K PBR textures
- Albedo, normal, roughness, and metallic maps
- Animations: idle, walk, run, crouch, fire, reload, death, revive
- Forward direction: -Z
- Feet at Y=0
- Approximate height: 1.75–1.85 meters

The project loads these models only when present. Missing models do not affect
headless server startup.
