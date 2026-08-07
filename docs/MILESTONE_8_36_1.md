# Milestone 8.36.1 — Imported Humanoid Activation Hotfix

## Problem

The v8.36 GLB contains a real mesh, skin, skeleton, and animation, but the game could still show the procedural soldier. Imported GLB descendants are not guaranteed to be owned directly by the instantiated scene root. The adapter's owned-only hierarchy searches could therefore calculate empty bounds and zero skeletons, reject the model, and intentionally retain the fallback.

## Correction

- Character bounds, meshes, skeletons, animations, materials, sockets, and geometry configuration now traverse all imported descendants regardless of scene ownership.
- The bundled GLB is preloaded and returned as the guaranteed final character source if ordinary path discovery does not produce a scene.
- Custom Allied and Axis external-model candidates remain ahead of the bundled placeholder.
- The procedural soldier remains available only when a custom model and the bundled model both fail validation.

## Compatibility

- No collision, hitbox, weapon, movement, objective, bot, class, RPC, or snapshot changes.
- Headless display isolation remains intact.
- Network protocol remains 341.

## Expected Result

Remote players and bots should now display the imported skinned human model rather than the capsule-and-cloth procedural character. The local player's body remains hidden in first person by design.
