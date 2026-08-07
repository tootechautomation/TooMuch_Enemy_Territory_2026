# Milestone 8.37 — Imported Character Military Presentation

## Goal

Improve the battlefield readability of the working animated humanoid without reintroducing the procedural barrel body or replacing it with an unanimated T-pose model.

## Character Presentation

- Imported humanoids normalize to 1.88 meters for a stronger soldier-scale silhouette.
- The bundled neutral suit is recognized as a uniform surface by mesh and material identity.
- Allied characters receive olive-drab treatment.
- Opposing characters receive field-gray treatment.
- Embedded source texture detail remains visible beneath the team treatment.
- Uniform metallic and emissive response is disabled.
- Roughness and normal response are constrained toward matte cloth rather than plastic or spacesuit material.

## Asset Evaluation

The CC0 3D Male Base Mesh published by Orange Juice Games and maintained for Godot by BoQsc was evaluated. It provides a more conventional male outline and full armature, but its current GLB has no embedded animations. It remains a useful future retargeting base, not an immediate replacement for an animated combat character.

Sources:

- https://godotengine.org/asset-library/asset/3690
- https://github.com/BoQsc/Godot-3D-Male-Base-Mesh

## Compatibility

- Custom Allied and Axis models retain priority over the bundled placeholder.
- The procedural soldier remains an import-failure fallback only.
- Hitboxes, collision, weapons, objectives, classes, bots, networking, and protocol 341 are unchanged.

## Verification

1. Confirm remote characters remain single-body imported humanoids.
2. Compare both teams and confirm olive-drab versus field-gray distinction.
3. Confirm the embedded suit texture remains visible without metallic or emissive shine.
4. Confirm characters stand at a consistent human gameplay scale.
