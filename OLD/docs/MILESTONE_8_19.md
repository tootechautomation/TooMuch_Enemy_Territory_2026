# Milestone 8.19 — Character Skin and Modular Import Bridge

Version 8.19 improves the bundled soldier presentation immediately and prepares the project for a later licensed modular-character purchase.

## Bundled character skins

- Allied fallback uniforms now use an original 1254×1254 olive-drab wool weave albedo.
- Opposing fallback uniforms now use an original 1254×1254 field-gray wool weave albedo.
- Both maps are project-owned, historically inspired, logo-free textures generated specifically for Frontline: Objective.
- Cloth now renders with high roughness, zero metallic response, and no artificial emission.
- Team HUD, edge accents, friendly-only identifiers, and class accents remain unchanged for gameplay clarity.

## Modular character bridge

The registry retains the original `allied_soldier.glb` and `axis_soldier.glb` slots and adds automatic discovery for:

```text
modular_military_2_allied.glb
modular_military_2_allied.fbx
modular_military_2_allied.blend
modular_military_2_axis.glb
modular_military_2_axis.fbx
modular_military_2_axis.blend
```

Each file should contain one assembled and rigged character. GLB with embedded textures and animations is preferred. Existing scale normalization, ground alignment, skeleton validation, animation-state mapping, weapon-socket lookup, LOD registration, and fallback protection remain active.

Imported materials identified as clothing receive a restrained olive or field-gray color correction and cloth roughness floor. Skin, weapons, metal, leather, and unrelated equipment materials are not deliberately recolored.

## Demo archive finding

The free `Modular military 2 - Demo.zip` is a cooked Unreal Engine 4 Windows evaluation build. Its archive contains executables and a packaged `.pak`, not reusable FBX, GLB, Blender, or standalone texture source. Cooked demo content is therefore not extracted or redistributed in the open-source project. The bridge targets exports from a properly licensed source package.

## Compatibility

The new textures and imported-character processing are client-side presentation only. Character collision, hitboxes, weapons, authoritative simulation, networking, and protocol 341 are unchanged.
