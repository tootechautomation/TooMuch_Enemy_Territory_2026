Frontline: Objective v22.2.0 — AXIS WEAPON ASSET RESTORATION
Network Protocol 364

RESTORED FROM USER-SUPPLIED ORIGINAL ASSETS
- Axis primary: MP40 FBX + PBR texture set physically embedded.
- Axis sidearm: Walther P38 FBX + PBR texture set physically embedded.
- Added/overrode scripts/assets/asset_registry.gd so Axis slot 0 resolves MP40 and
  Axis slot 1 resolves P38 directly from packaged resources.
- Existing first-person real-asset adaptation remains responsible for scale/orientation.
- Explicit warnings now exist for missing MP40 AND missing P38 resources instead of silent
  generic fallback.
- Cross-team pickup visual ownership logic remains intact.
- Network Protocol remains 364: asset restoration only.
- v20 movement, v21 class/combat, v22 fireteams, maps, spawns, vehicles and objectives unchanged.

IMPORTANT
This is still an overlay package. Apply it on top of the same complete project/base used
for v22.1. The new registry file intentionally replaces the missing/older registry mapping.

TEST
1. Defenders/Axis Medic/Soldier/Engineer/Field Ops: primary visually resolves MP40.
2. Switch to pistol: visually resolves Walther P38.
3. Respawn/change Axis class and verify both persist.
4. Join Allies and verify Allied mappings from the base project remain available.
5. Pick up cross-team primary/pistol and verify source-team weapon visuals follow pickup.
6. Check first-person muzzle direction/scale. Report a screenshot if either imported asset
   needs a final pose-only adjustment; do not replace the model.
