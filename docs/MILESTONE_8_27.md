# Milestone 8.27 — Spatial Firing Effects and Weapon Heat

Version 8.27 aligns first-person firing effects with the class-specific weapon rigs introduced in v8.25 and the ADS composition introduced in v8.26.

## Muzzle resolution

Imported first-person rigs are searched for `MuzzleSocket`, `Muzzle`, `BarrelEnd`, `muzzle`, and `barrel_end` nodes. When no imported socket exists, pistol and all five primary class profiles use explicit fallback barrel endpoints matched to their geometry.

## Flash and light

Weapon profiles receive different spatial flash radii. Each shot varies flash scale and rotation while a short unshadowed muzzle light uses the same barrel endpoint. The former screen-centered 2D flash is no longer shown.

## Heat-responsive smoke

Each local shot adds profile-specific visual heat. Heat cools slowly during a burst and faster after firing stops. Hot weapons generate a second smoke layer with increased size, opacity, drift, and lifetime. Heat is presentation-only and does not create jams, spread changes, or damage changes.

## Casing presentation

Pistols, standard long guns, and the Support LMG use different casing dimensions. Ejection direction and rotation vary within controlled ranges so automatic fire no longer produces identical overlapping brass.

## Compatibility

All new state and effects are local presentation. Headless servers remain excluded, imported models retain priority, and weapon timing, recoil, spread, ammo, damage, hit detection, networking, and protocol 341 are unchanged.
