FRONTLINE: OBJECTIVE v9.27.3
WWII SOLDIER CHARACTER-ONLY TEST

BASELINE
Built directly from stable v9.27.2.

ONLY NEW CONTENT
Allied:
assets/external/characters/ww2_allied_soldier.glb

Axis:
assets/external/characters/ww2_german_wehrmacht_soldier.glb

NO v9.28 ENVIRONMENT CONTENT
- no city ruins
- no low-poly city
- no pillbox
- no Vairogs prop
- no map expansion
- no map/objective/collision placement changes

CHARACTER BEHAVIOR
The supplied character GLBs do not contain a usable authored animation rig in
the imported asset metadata. The existing external character system therefore
uses a very small transform-only motion fallback:
- slight walk/run bob
- slight movement lean
- crouch lowering

If a future rigged soldier GLB is supplied, the existing authored-animation
path automatically takes priority.

The existing procedural/fallback character remains available if either real
model cannot load or validate.

Build: 9.27.3
Protocol: 341
