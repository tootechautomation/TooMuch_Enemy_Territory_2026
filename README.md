# Frontline: Objective

## Version 4.2.0 Asset-Based Visual Foundation

This release begins the transition from primitive placeholder graphics to an
asset-based WWII visual pipeline.

### PBR materials
Included original generated texture sets:
- Cobblestone
- Red brick
- Weathered plaster
- Dark wood
- Brushed gunmetal
- Rubble and damaged ground

Each set includes albedo, normal, and roughness maps. Godot materials use
world-space triplanar mapping, reducing visible stretching on modular geometry.

### Modular 3D assets
Included original GLB models:
- Intact European townhouse
- Ruined European townhouse
- Rubble pile
- Sandbag emplacement
- First-person service rifle with arms and hands
- First-person service pistol with arms and hands

### Village visual pass
- Added four imported multi-story townhouses.
- Added imported rubble and sandbag scenes.
- Added PBR cobblestone streets and fort courtyard.
- Added gameplay collision volumes independently of the visual models.
- Existing procedural geometry remains as a compatibility fallback.

### First-person presentation
- Rifle and pistol now use imported GLB visual rigs when available.
- Both rigs include sleeves, forearms, hands, fingers, detailed receivers,
  stocks, barrels, sights, and support-hand placement.
- Existing recoil, weapon bob, sprint lowering, ADS, switching, ammunition,
  and muzzle flash remain connected to the imported rig.
- The old procedural weapon remains as a fallback if Godot has not imported
  the GLB files yet.

### Headless server safety
- The VPS never preloads GLB or PNG visual assets.
- All optional scenes and textures load only on graphical clients.
- Gameplay collision is generated separately from visual scenes.
- Protocol remains 341.

Expected status: `Connected: v4.2.0 protocol 341`
