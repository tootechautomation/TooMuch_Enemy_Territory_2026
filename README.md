# Frontline: Objective

## Version 7.4.1 Player Profile Parser Hotfix

The v7.4.0 profile panel used `class_name` as a loop variable. `class_name` is
a reserved GDScript keyword, so `main.gd` failed to parse.

Fixed implementation:

```gdscript
var profile_class_names: Array[String] = [
    "Soldier",
    "Medic",
    "Engineer",
    "Field Ops",
    "Scout"
]
for profile_class_name in profile_class_names:
    profile_class_option.add_item(profile_class_name)
```

All v7.4 profile features remain:
- Custom persistent player name
- Cross-server local profile
- Preferred team and class
- Mouse sensitivity
- Field of view
- HUD scale
- Audio settings
- Last server address and port
- F8 profile/settings panel

Build: v7.4.1
Protocol: 341
