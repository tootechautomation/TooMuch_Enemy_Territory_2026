# Milestone 8.26 — Class-Specific Aim-Down-Sights Composition

Version 8.26 gives the bundled and imported first-person weapons one stable presentation path for both hip fire and aiming.

## Unified placement

The first-person animation update now owns weapon position and rotation. The aim-view update controls camera FOV, scope overlay, and reticle visibility only, eliminating competing transforms during the same frame.

## Weapon handling profiles

- Support LMG: heavier lower-right hip position and centered rear-sight shoulder position.
- Medic SMG: closer compact hip position and faster centered sight presentation.
- Engineer carbine: intermediate compact-rifle spacing.
- Field Ops rifle: full-length service-rifle spacing.
- Scout rifle: long receiver spacing aligned with the existing scope.
- Pistol: independent one-handed/two-handed sight position.

## Presentation fidelity

ADS uses faster position and rotation convergence, reduced movement bob, reduced landing response, reduced camera inertia, and subtle breathing. Firing feedback starts from the current ADS position, preventing a one-frame hip-position snap. Both standard crosshairs are hidden while aiming; the Scout scope overlay remains supported.

## Compatibility

Imported first-person scenes retain priority. Authoritative accuracy, recoil, fire rate, damage, movement penalties, server behavior, networking, and protocol 341 are unchanged.
