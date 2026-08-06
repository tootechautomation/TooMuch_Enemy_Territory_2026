# Frontline: Objective

## Version 7.7.1 First-Person Weapon Parser Hotfix

The v7.7 stock, handguard and sight additions referenced `receiver_length` and
`barrel_length` after those variables had gone out of scope.

Both dimensions are now declared once in the shared scope of
`_rebuild_first_person_weapon()` and are available to:

- Imported weapon positioning
- Procedural receiver construction
- Buttstock placement
- Handguard placement
- Front sight placement
- Muzzle flash placement

All v7.7 procedural soldier and WWII environment improvements remain enabled.

Compatibility:

- Build: v7.7.1
- Protocol: 341
- Explicit connection-message `+` retained
