# Milestone 8.29 — Class-Specific World Weapons and Remote Fire

Version 8.29 brings the first-person class identity pass into third-person battlefield presentation.

## Unified pose ownership

The fallback character builder no longer animates joints in its own process loop. `ThirdPersonPoseFidelity` owns ready, moving, aimed, crouched, reload, and incapacitated transforms, preventing process and physics updates from fighting over the same nodes.

Weapons now retain their chest-ready base transform instead of lerping to the torso origin. Both arms use profile-aware ready offsets and remain connected to the rear grip and fore-end while moving.

## Class weapon silhouettes

- Soldier: drum-fed Support LMG, barrel jacket, carry handle, and folded bipod.
- Medic: compact SMG receiver, stick magazine, and barrel shroud.
- Engineer: carbine magazine and wood fore-end.
- Field Ops: service-rifle magazine and grenade sight.
- Scout: long rifle geometry with compact magazine and scope.

Each fallback weapon includes a muzzle socket for future attachment compatibility. Metal material classification includes receivers, barrels, magazines, shrouds, bipods, handles, sights, triggers, and butt plates.

## Remote firing presentation

The existing shot-effect RPC spawns a short world-space flash, light, and smoke plume near remote muzzle position. The local shooter is detected and excluded from the duplicate world flash because the first-person v8.27 effect already handles it.

## Compatibility

Imported character and weapon scenes retain priority. The RPC signature, hitboxes, collision, weapon balance, gameplay, headless behavior, networking, and protocol 341 are unchanged.
