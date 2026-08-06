# Frontline: Objective

## Version 8.13.0 — Dynamic Battlefield Weather

The battlefield now transitions through moving overcast fronts, wind-driven rain, low wet-ground mist, shifting fog and sunlight, synchronized rain ambience, and restrained distant lightning. Weather changes gradually using deterministic layered cycles, preserving visibility while preventing the map from feeling frozen or artificially static.

Rain and mist use bounded particle fields. Cloud layers do not cast expensive dynamic shadows, lightning does not cast shadows, and all weather construction is skipped on headless servers. Weather is visual and atmospheric only; it does not alter movement, weapon handling, accuracy, objectives, AI, or networking.

Build: v8.13.0
Protocol: 341
