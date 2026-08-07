# Milestone 8.20 — Class Equipment and Soldier Silhouette Fidelity

Version 8.20 turns the five gameplay classes into visibly different battlefield roles while improving the material quality of the animated fallback soldier.

## Shared character upgrade

- The articulated soldier now uses `uniform_allied_wool_v819.png` or `uniform_axis_fieldgray_v819.png` directly.
- Uniform textures render with a neutral albedo multiplier instead of being darkened by the older procedural skin colors.
- Tunics, sleeves, forearms, trousers, and collars use a higher cloth roughness response.
- Existing team helmets, webbing, pockets, buttons, buckles, packs, canteens, tools, boots, faces, and weapon geometry remain intact.

## Class silhouettes

- **Soldier:** ammunition bandolier, paired grenades, and bayonet scabbard.
- **Medic:** larger layered canvas medical pack, closure flap, field-dressing pouches, and a dimensional light armband with dark-red cross geometry.
- **Engineer:** rear tool roll, closure flap, visible wrench, wire spool, and demolition cap tins.
- **Field Ops:** enlarged radio pack, separate control face, three dials, long antenna, and chest-mounted handset.
- **Scout:** paired binocular tubes, leather map case, helmet scrim, and rifle scope.

## Compatibility

The added parts are visual child meshes on the existing articulated rig. They create no collision shapes and do not change damage volumes, weapon behavior, movement, abilities, navigation, authoritative state, or network data. External rigged character assets still take priority and hide the complete fallback model only after validation succeeds. Protocol 341 remains unchanged.
