# Milestone 8.24 — Proportional Viewmodel Grip Composition

Version 8.24 replaces the oversized first-person arm presentation with a lower-screen, weapon-focused composition.

## Proportion pass

- Sleeve and glove radii are reduced together so wrists transition cleanly into the hands.
- Four smaller fingers and a separate thumb retain the v8.21 hand structure without dominating the screen.
- Class wrist equipment is scaled to the new arm dimensions and seated directly on the sleeve.
- Higher radial segmentation keeps reduced procedural geometry smooth rather than visibly faceted.

## Grip composition

Pistol and long-gun arms now begin below and outside the sight picture. Their inward yaw converges the hands toward their respective grip zones, while forward placement prevents near-camera magnification. The bundled fallback grip and buttstock are slimmer and the complete rig is positioned farther from the camera.

## Compatibility

The change is client-side presentation only. Imported first-person weapon support, mechanical part animation, recoil, reload timing, ammo, damage, movement, hit detection, server authority, networking, and protocol 341 remain unchanged.
