# Milestone 8.23 — Viewmodel Camera Clearance and Obstruction

Version 8.23 fixes the first-person sleeve and weapon hierarchy being animated toward the camera origin. The weapon rebuild path now initializes both its base position and base rotation before presentation animation begins.

## Camera-safe composition

- Shorter pistol and long-gun arm reaches keep sleeve capsules outside the camera near plane.
- Hands, cuffs, fingers, thumbs, and class wrist equipment are repositioned along the revised arms.
- A final animated Z limit protects the view during recoil, sprinting, aiming, reloads, and landing inertia.
- High and low field-of-view settings receive restrained spacing adjustments without altering aim behavior.

## Obstruction response

A local camera ray detects nearby solid world geometry. As clearance closes, the viewmodel lowers, retracts, and rotates into a compact ready position rather than visually passing through the wall. The probe is presentation-only and does not affect collision, weapon traces, hit detection, damage, or server authority.

## Compatibility

All v8.22 mechanical-part and magazine animations remain supported for bundled and imported weapons. Gameplay balance, networking, and protocol 341 are unchanged.
