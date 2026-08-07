# Milestone 8.33 — Third-Person Aim Tracking and Firing Recoil

## Goal

Make the bundled fallback soldier's weapon handling match the direction and timing of actual combat instead of presenting a mostly fixed ready pose.

## Delivered

- Existing replicated head pitch now drives a coordinated vertical look through the head, torso, shoulders, and fallback weapon.
- A partial look contribution remains in the ready pose, while active aiming applies the full alignment.
- Hip-to-aim and aim-to-hip transitions blend instead of snapping.
- Existing shot origins resolve the closest firing player locally.
- Firing briefly holds the weapon in a shouldered pose for remote readability.
- Each shot adds capped presentation-only recoil to the weapon, arms, torso, and head.
- Automatic fire can build visible motion without destabilizing the pose.
- Respawn clears aim and recoil impulses.

## Compatibility

- Network protocol remains 341.
- No snapshot fields or RPC arguments were added.
- Authoritative aim, spread, recoil, damage, range, fire rate, ammunition, and hit detection are unchanged.
- Imported character scenes continue to use their configured animation controller.

## Verification

- Observe fallback soldiers aiming above and below level ground.
- Confirm the head, torso, arms, and weapon follow the same vertical direction without extreme bending.
- Toggle aim and confirm the weapon shoulders and lowers smoothly.
- Observe semi-automatic and automatic remote fire and confirm visible recoil returns quickly.
- Confirm local first-person muzzle effects are not duplicated in the world view.
- Confirm locomotion, jumping, landing, crouching, reloading, damage, downed, revive, and respawn poses remain clean.
