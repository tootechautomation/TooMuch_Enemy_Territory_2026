# Milestone 8.31 — Directional Locomotion and Foot Planting

## Goal

Make bundled fallback soldiers read as grounded infantry rather than articulated figures playing the same gait in every direction.

## Delivered

- Local-space velocity separates forward movement, backpedaling, and strafing.
- Reverse movement uses a shorter, guarded gait instead of visually running forward while moving backward.
- Strafing shifts the stance laterally and balances the torso, head, legs, and weapon toward the movement direction.
- Acceleration pitches the body into movement and braking allows it to settle back naturally.
- Turning creates a restrained anticipatory twist while stationary and moving.
- Alternating knee stabilization strengthens the planted portion of each step and reduces skating.
- All motion channels blend with crouching, aiming, reloading, damage reactions, downed poses, and revive recovery.
- Respawn clears transient motion state.

## Compatibility

- Network protocol remains 341.
- No snapshot fields or RPC arguments were added.
- Movement speed, acceleration, authoritative physics, collision, hitboxes, weapon balance, and class behavior are unchanged.
- Imported character scenes continue to use their configured animation controller. Procedural locomotion fidelity targets the bundled articulated fallback character.

## Verification

- Observe another fallback soldier moving forward, backward, left, and right.
- Confirm backpedaling does not use a full forward-running leg swing.
- Confirm strafing widens and shifts the stance without excessive model roll.
- Start and stop sprinting and confirm the torso briefly leans into acceleration and braking.
- Turn while stationary and confirm the pose anticipates the rotation without twisting unnaturally.
- Confirm crouch, aim, reload, damage, downed, revive, and respawn transitions remain clean.
