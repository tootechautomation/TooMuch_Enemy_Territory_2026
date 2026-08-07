# Milestone 8.36.2 — Duplicate Fallback Body Visibility Hotfix

## Problem

The v8.36.1 model importer successfully activated the bundled rig, but the regular player-visibility refresh still treated every remote player as a fallback character. Each replicated snapshot turned `Body` and `CharacterVisual` back on after the importer had hidden them. This overlaid the old barrel torso, helmet, equipment, arms, legs, and feet on the imported human.

## Correction

- `external_model_loaded` now remains the authoritative visual-mode switch.
- A validated imported character keeps both legacy fallback roots hidden during every visibility refresh.
- The procedural character returns only if imported-scene instantiation or validation fails.
- Imported-model state is cleared before rebuilding, preventing stale success state after a later load failure.

## Compatibility

- Local first-person body hiding is unchanged.
- Nameplates, team identity, class accents, and spotted/revive markers remain available.
- Collision, hitboxes, weapons, objectives, classes, bots, RPCs, snapshots, and protocol 341 are unchanged.

## Expected Result

Remote players and bots display one character body. The barrel-shaped procedural soldier must not be visible when the imported humanoid is active.
