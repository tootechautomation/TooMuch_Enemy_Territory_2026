# Frontline: Objective

## Version 8.3.0 Combat Effects, Surface Impacts & Destruction Polish

Bullet impacts now inspect the nearby collider and select an effect for metal,
wood, brick, concrete, stone, ground, or player hits.

Effects include:

- impact decals,
- sparks,
- masonry chips,
- wood splinters,
- concrete dust,
- dirt puffs,
- short impact lights,
- restrained player-hit particles.

Explosion polish includes a rapidly expanding fireball, flash light, smoke,
dirt, fragments, and a ground scorch mark.

The effect manager limits active roots and decals and cleans temporary effects
automatically. All combat effects remain client-side and are skipped on the
headless VPS.

Build: v8.3.0
Protocol: 341
