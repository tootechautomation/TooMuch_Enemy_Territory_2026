# Milestone 8.21 — First-Person Arms and Handling Fidelity

Version 8.21 brings the visible first-person body up to the same material and class-readability standard as the v8.20 articulated world character.

## Arms and hands

- Sleeves use the bundled v8.19 Allied olive-drab or opposing field-gray wool albedo.
- Cloth uses neutral color response, high roughness, and zero metallic response.
- Hands are now represented by rough leather gloves instead of exposed capsule-colored skin.
- Each hand has four fingers, a separate angled thumb, and a dimensional leather cuff.
- Pistol and long-gun poses share a centralized arm builder, reducing visual drift between loadouts.

## First-person class cues

- **Soldier:** compact wristwatch.
- **Medic:** light medical sleeve band.
- **Engineer:** reinforced work cuff.
- **Field Ops:** wrist-mounted push-to-talk control.
- **Scout:** metallic-rim wrist compass.

These details sit on the support wrist and remain restrained enough not to obstruct the sight picture.

## Imported weapon compatibility

Previously, successfully loaded first-person weapon scenes returned before procedural arms were created. v8.21 builds the same arms after either imported or fallback weapon construction, keeping the player's body visible when later licensed weapon assets are installed.

## Compatibility

The pass is presentation-only. Fire rate, spread, recoil values, aim FOV, reload duration, muzzle effects, weapon switching, damage, authoritative simulation, networking, and protocol 341 remain unchanged.
