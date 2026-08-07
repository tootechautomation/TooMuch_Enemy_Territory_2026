# Milestone 8.38 — Dynamic Wet-Surface Weather Response

## Goal

Connect the existing rain, cloud, mist, lightning, fog, and audio systems to the physical appearance of the battlefield.

## Wetness Model

- Existing deterministic weather intensity drives a smoothed wetness value.
- Surfaces wet faster than they dry.
- Wet materials darken by up to 18 percent.
- Roughness moves toward a restrained wet range rather than a mirror finish.
- Existing normal maps, albedo textures, metallic values, and authored geometry remain intact.
- Existing screen-space reflections make wet highlights visible on supported quality tiers.

## Surface Selection

The pass recognizes exposed ground, roads, lanes, cobblestone, gravel, mud, rubble, brick, walls, buildings, roofs, plaster, concrete, rails, trains, crates, barrels, cover, fences, towers, trenches, platforms, sandbags, vehicles, and artillery.

Characters, weapons, markers, beacons, spawn zones, particles, clouds, mist, rain geometry, river/water surfaces, transparent materials, and unshaded materials are explicitly excluded.

## Performance and Compatibility

- Eligible materials are collected once after world construction.
- Each material is duplicated before adjustment.
- Updates run at 10 Hz rather than every rendered frame.
- Headless servers do not build the system.
- Weather timing, collision, objectives, bots, weapons, networking, and protocol 341 are unchanged.

## Verification

1. Observe dry roads and masonry during a low-intensity weather interval.
2. Wait for rain intensity to increase and confirm surfaces gradually darken.
3. Confirm wet highlights remain restrained rather than mirror-like.
4. Confirm characters, weapons, objective markers, and river materials are unchanged.
5. Confirm surfaces dry more slowly when the rain front passes.
