# Frontline: Objective

## Version 8.6.0 Forward+ PBR Battlefield Upgrade

The desktop renderer now defaults to Forward+ so the existing SSAO, SSIL,
screen-space reflections, volumetric fog, glow, and modern shadow pipeline are
actually rendered. Four-times MSAA, screen-space antialiasing, soft directional
shadows, and restrained cinematic color grading are enabled by default.

The material library now uses the included albedo, normal, and roughness maps
for brick, damaged plaster, concrete, limestone, wood, rusted metal,
cobblestone, mud, gravel, and slate. Box-shaped sandbags and rubble have been
replaced by rounded bags and irregular stones. Mobile still uses the GL
Compatibility fallback. All v8.5 combat audio and protocol compatibility remain.

Build: v8.6.0
Protocol: 341
