# Milestone 8.32 — Airborne, Landing, and Stance Transitions

## Goal

Complete the fallback soldier's basic movement language so jumps, falls, landings, crouching, and standing carry the same grounded visual quality as the v8.31 directional locomotion pass.

## Delivered

- A short floor probe supplements CharacterBody ground contact for interpolated remote characters.
- Leaving the ground triggers a brief takeoff compression.
- Rising characters tuck and balance differently from descending characters.
- Grounded walk-cycle bob and planting fade while airborne.
- Landing strength follows the existing vertical motion and compresses the torso, legs, knees, and weapon.
- Landing motion blends directly back into forward, reverse, strafe, turn, aim, and reload poses.
- Crouch and stand height now transition through a smoothed stance blend.
- Respawn clears all airborne and stance-transition impulses.

## Compatibility

- Network protocol remains 341.
- No snapshot fields or RPC arguments were added.
- Jump speed, gravity, fall-damage thresholds, movement physics, collision, hitboxes, and weapon handling are unchanged.
- Imported character scenes continue to use their configured animation controller.

## Verification

- Observe local, bot, and remote fallback soldiers jumping and landing.
- Confirm the grounded stride does not continue visibly while airborne.
- Confirm ascending and descending leg poses are visibly different but restrained.
- Confirm harder falls produce stronger landing absorption without altering fall damage.
- Toggle crouch while stationary and moving and confirm body height blends without snapping.
- Confirm aiming, reloading, damage reactions, incapacitation, revival, and respawn remain clean.
