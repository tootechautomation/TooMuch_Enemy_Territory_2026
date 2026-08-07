# Milestone 8.39 — Puddles and Rain-Ground Interaction

## Goal

Make rainfall visibly contact and accumulate on the battlefield instead of ending at airborne streaks and material darkening.

## Puddles

- Ten shallow puddle planes are distributed across both sides of the battlefield.
- Footprints and rotations vary to avoid a repeated tile appearance.
- One shared transparent, low-roughness material controls every puddle.
- Puddle opacity increases from the smoothed v8.38 accumulated wetness value.
- Puddles appear only after meaningful accumulation and recede with the slower drying curve.
- Geometry is visual-only, casts no shadow, and has no collision.

## Rain Impacts

- A capped ground-level particle field emits small upward droplets during rain.
- Velocity, scale, and direction vary within restrained ranges.
- Emission amount follows wetness continuously.
- The Performance quality tier disables the splash system automatically.

## Compatibility

- No movement, collision, navigation, weapon, objective, AI, RPC, or snapshot changes.
- Headless servers do not build puddles or particles.
- Existing wet surfaces, weather, fog, mist, lightning, SSR, SSAO, and volumetric effects remain active according to the selected graphics tier.
- Network protocol remains 341.

## Verification

1. Observe that puddles are absent or nearly invisible during dry intervals.
2. Confirm puddles fade in as sustained rain raises accumulated wetness.
3. Confirm small impact droplets appear near ground level during rain.
4. Walk through every puddle and confirm movement and collision remain unchanged.
5. Select Performance with F6 and confirm rain-impact particles disable.
