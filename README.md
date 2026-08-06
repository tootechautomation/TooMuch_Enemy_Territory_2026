# Frontline: Objective

## Version 8.15.0 — Cinematic Combat Feedback

Combat now produces restrained modern screen-space feedback driven entirely by existing replicated player state. Damage creates a brief peripheral red response and light chromatic separation. Suppression and sustained heavy fire introduce controlled desaturation, fine noise, and pressure at the screen edge. Low health adds a pulsing tunnel effect, incapacitation deepens desaturation and peripheral darkness, and healing creates a short recovery cue.

The crosshair and center sight picture remain clear. Effects interpolate smoothly, ignore mouse input, run only for the local graphical player, and do not add network fields or alter damage, weapon handling, accuracy, movement, healing, revive rules, or server authority.

Build: v8.15.0
Protocol: 341
