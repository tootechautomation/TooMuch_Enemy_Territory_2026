# Milestone 8.22 — First-Person Mechanical Animation Fidelity

Version 8.22 makes the first-person weapon assembly visibly respond to its mechanical state while retaining the existing server-authoritative combat timings.

## Mechanical motion

- Pistol slides reciprocate during a shot and at the end of a reload.
- Rifle bolt carriers and charging handles cycle during the same mechanical windows.
- Pistol, generic box, SMG, carbine, and LMG drum magazines use a three-stage remove, hold, and insert path.
- The support arm follows a curved reload path instead of remaining fixed to the weapon.
- Animation works through recursive named-part lookup and safely becomes a no-op when an imported model does not expose a recognized part.

## Movement handling

- Landing produces a short bounded weapon dip based on the previous vertical velocity.
- The landing response decays smoothly rather than moving the camera itself.
- Aimed movement retains only 28 percent of normal walking bob, improving sight stability.
- Existing sprint lowering, idle breathing, camera inertia, recoil impulse, muzzle flash, smoke, light, and shell ejection remain layered together.

## Compatibility

The animation progress is client-side and derives from existing reload, muzzle-flash, movement, stamina, and aim state. It does not change reload duration, ammunition transfer, fire cadence, recoil calculation, movement speed, jump physics, damage, authoritative state, network payloads, or protocol 341.
