# Frontline: Objective

## Version 7.7.3 Duplicate Weapon Block Removal

The stock, handguard, and sight block had been inserted into the imported GLB
helper. That helper does not declare the procedural dimensions or materials,
which caused `receiver_length` scope errors near the beginning of player.gd.

The imported helper now performs only:
- GLB instantiation
- Imported material processing
- Imported muzzle-flash setup

The procedural rebuild function now owns:
- Receiver and barrel dimensions
- Metal and wood materials
- Buttstock
- Handguard
- Rear sight
- Front sight
- First-person arms
- Procedural muzzle flash

Build: v7.7.3
Protocol: 341
