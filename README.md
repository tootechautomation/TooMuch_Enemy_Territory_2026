# Frontline: Objective

## Version 7.9.0 Real Asset Integration & Character Rig Adapter

Imported character GLBs are automatically normalized to a human height,
grounded, checked for a skeleton, scanned for animations, assigned a usable
right-hand weapon socket, and given less plastic material response.

Imported buildings and props are grounded, optionally normalized to the target
height configured in `asset_registry.gd`, cleaned up materially, and then sent
through the existing collision-generation and validation pipeline.

Invalid character GLBs no longer hide the procedural soldier. The game rejects
the import and keeps the articulated WWII fallback visible.

Build: v7.9.0
Protocol: 341
