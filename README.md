# Frontline: Objective

## Version 4.1.0 WWII Urban Frontline

This release moves the visual language closer to an original World War II
objective shooter while retaining original maps, code, and assets.

### Larger battlefield
- Map boundaries expanded to approximately 124 x 104 meters.
- Added far-west and far-east outskirts.
- Added a larger cobblestone village square.
- Added a paved/cobbled fort courtyard.
- Added multi-story apartment blocks, barracks, rail offices, damaged roofs,
  windows, floors, and interior firing positions.
- Added street lamps and sandbag defenses.

### WWII-style ground and architecture
- Procedural cobblestone streets use individually varied stone blocks.
- Fort and urban areas use concrete, masonry, dark roofs, and window recesses.
- Village and rail sectors now read as occupied European urban spaces.
- All geometry is generated with Godot primitives, so the Linux server remains
  independent of imported visual assets.

### First-person body
- Added visible right and left sleeves.
- Added rounded forearms, hands, and finger shapes.
- Hands reposition for pistol and primary weapon profiles.
- Sleeve color reflects the selected team.
- Existing weapon switching, recoil, sway, sprint lowering, and ADS remain.

### TAB results
- TAB shows the expanded scoreboard and current match results.
- Added current objective, sector control, and round-award preview.
- Existing K/D/A, objective score, round XP, total XP, rank, and player type
  remain visible.

### Compatibility
- Build: v4.1.0
- Protocol: 341
- Explicit connection-message `+` retained.

Expected status: `Connected: v4.1.0 protocol 341`
