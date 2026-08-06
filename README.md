# Frontline: Objective

## Version 3.9.0 Operation Black River & Visual Upgrade

This release introduces a substantially larger original battlefield inspired
by the multi-sector objective pacing of classic team-based objective shooters.
It does not copy proprietary Enemy Territory layouts or assets.

### Operation Black River
- Approximate playable footprint expanded to 92 x 76 meters.
- Original central bridge/objective chain remains functional.
- Added western ruined-village sector.
- Added eastern rail-yard sector with rail cars and firing lanes.
- Added southeastern fortified bunker compound.
- Added northern and southern cross roads.
- Added elevated flank ramps and two new watchtowers.
- Added additional river sections, roads, trees, ruins, and outer terrain.
- Expanded boundaries support longer-range combat and squad movement.

### Modernized characters
- Replaced major rectangular body parts with capsules and cylinders.
- Added rounded torsos, pelvis, arms, legs, boots, gloves, and helmets.
- Added helmet rim, pouches, backpack, and belt detail.
- Added class-specific medical, engineer, radio, and scout gear.
- Increased mesh radial segments for smoother silhouettes.
- Improved material roughness and subtle metallic response.

### Smoother motion
- Increased snapshot interpolation responsiveness.
- Replaced linear interpolation with exponential smoothing.
- Added smoothed remote velocity estimation.
- Remote players now animate based on interpolated movement.
- Reduced exaggerated character rocking.
- Added subtler stride, vertical motion, and rotational sway.

### Lighting and atmosphere
- Added a procedural sky.
- Added filmic tone mapping.
- Added light battlefield fog.
- Increased ambient and directional-light quality.
- Extended directional shadow range for the larger map.

### Compatibility
- Build: v3.9.0
- Network protocol: 341
- Explicit `+` connection-string concatenation retained.

Expected status: `Connected: v3.9.0 protocol 341`
