# Frontline: Objective

## Version 7.7.2 Weapon Dimension Syntax Hotfix

Version 7.7.1 accidentally produced invalid statements such as:

```gdscript
receiver_length = float = 0.62
barrel_length = float = 0.34
```

The first-person weapon function now uses clean shared defaults:

```gdscript
var is_pistol: bool = current_weapon_index == 1
var receiver_length: float = 0.72
var barrel_length: float = 0.55
```

The pistol branch then uses ordinary assignments:

```gdscript
if is_pistol:
    receiver_length = 0.34
    barrel_length = 0.28
```

All v7.7 realism improvements remain enabled.

Compatibility:

- Build: v7.7.2
- Protocol: 341
- Explicit connection-message `+` retained
