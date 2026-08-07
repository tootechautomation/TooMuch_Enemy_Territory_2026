# Milestone 8.30 — Character Hit Reactions and Revive Recovery

## Goal

Make infantry combat read through the character model by adding physical impact and recovery feedback to the bundled fallback soldiers, while preserving authoritative gameplay and imported-model compatibility.

## Delivered

- Health decreases trigger a short severity-scaled flinch across the torso, head, arms, and held weapon.
- Impact side varies deterministically, avoiding synchronized or continuously one-sided reactions.
- Downed soldiers collapse more decisively and can fall toward either side.
- Revived soldiers pass through a brief lowered, guarded recovery pose before returning to the existing animation state.
- Remote reactions are inferred from the existing snapshots; server-side bots and players use the same presentation state.
- Respawn clears all transient reaction state.
- Headless servers skip display-only reaction registration.

## Compatibility

- Network protocol remains 341.
- No snapshot fields, RPC arguments, damage values, hitboxes, collision shapes, revive rules, or weapon behavior changed.
- Imported character scenes retain their animation-controller priority. The procedural reaction pass targets the bundled articulated fallback character.

## Verification

- Confirm a standing fallback soldier visibly flinches when health decreases.
- Confirm consecutive hits can displace the pose toward either side.
- Confirm a player entering the downed state collapses without geometry jumping to the camera.
- Confirm revival produces a short recovery motion and then returns cleanly to locomotion and aiming.
- Confirm respawn begins from the neutral pose.
- Confirm imported animated characters continue to use their configured animations.
