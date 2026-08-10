# CGTrader Asset Setup — Frontline: Objective v8.40.0

The game is wired for the requested models but this archive does not redistribute CGTrader downloads. Download each free package from its source page, extract the model and textures, and rename/copy one supported model file into the paths below. Godot will import FBX/GLB/OBJ and accompanying textures.

## Allied / Blue

- Primary: M1A1 Thompson SMG — https://www.cgtrader.com/free-3d-models/military/gun/m1a1-thompson-smg-low-poly
  - `assets/external/weapons/m1a1_thompson.glb` OR `.fbx` OR `.obj`
- Pistol: TT Pistol — https://www.cgtrader.com/free-3d-models/military/gun/tt-pistol-low-poly-pbr-7d35b808-25c7-44ae-8e97-dc3d95f8ba5b
  - `assets/external/weapons/tt_pistol.glb` OR `.fbx` OR `.obj`
- Character: Private Military Contractor — https://www.cgtrader.com/free-3d-models/military/military-character/private-military-contractor-8cb4b6a2-1d89-45be-b328-7f29ad58f653
  - `assets/external/characters/private_military_contractor.glb` OR `.fbx` OR `.obj`

## Axis / Red

- Primary: MP40 — https://www.cgtrader.com/free-3d-models/military/gun/mp-40-ww2-submachine-gun-pbr-game-ready-low-poly
  - `assets/external/weapons/mp40.glb` OR `.fbx` OR `.obj`
- Pistol: Walther P38 — https://www.cgtrader.com/free-3d-models/military/gun/walther-p38-low-poly-pbr
  - `assets/external/weapons/walther_p38.glb` OR `.fbx` OR `.obj`
- Grenade: German Model 24 — https://www.cgtrader.com/free-3d-models/military/other/german-handgrenade-model-24
  - `assets/external/weapons/model24_grenade.glb` OR `.fbx` OR `.obj`
- Character: Survival Character — https://www.cgtrader.com/free-3d-models/character/man/survival-character
  - `assets/external/characters/survival_character.glb` OR `.fbx` OR `.obj`

## Notes

- Keep texture folders beside the imported model where practical.
- GLB is preferred when you convert the downloaded FBX because it usually preserves Godot PBR materials more predictably.
- Character models must contain a Skeleton3D after import to replace the animated bundled character. If a downloaded OBJ is static, the game will reject it as a character and keep the animated fallback.
- Missing assets never prevent the game from running.
