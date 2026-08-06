# Frontline: Objective

## Version 7.3.1 External LOD Parser Hotfix

### Fixed parser error

Version 7.3.0 declared:

```gdscript
var external_lod_controller: ExternalLODController
```

Godot could parse `main.gd` before the external script's `class_name` was
registered, producing:

```text
Could not find type "ExternalLODController" in the current scope.
```

The controller is now stored as a standard `Node` and instantiated through the
already preloaded script resource:

```gdscript
var external_lod_controller: Node

var controller_instance: Node = (
    ExternalLODControllerScript.new()
)
```

Method calls use `has_method()` and `call()`, removing the cross-script parser
dependency while retaining the complete LOD behavior.

### Included v7.3 features

- Character and environment asset validation
- Runtime distance-based LOD
- Far-distance shadow and GI reduction
- F10 external-asset status overlay
- Safe procedural fallback replacement
- Imported collision validation

### Compatibility

- Build: v7.3.1
- Protocol: 341
- Explicit connection-message `+` retained
- No external assets are required for startup

Expected status: `Connected: v7.3.1 protocol 341`
