Frontline: Objective v22.1.0 — AXIS MP40 RESTORATION HOTFIX
Network Protocol 364 (compatible with v22)

- Fixes regression where an Axis/Defender primary could retain/fall back to the generic
  service-rifle visual instead of resolving the registered MP40.
- Native class/team loadout rebuild now explicitly restores weapon visual ownership to
  the player's current team.
- External weapon visual cache is forcibly refreshed after class/team loadout rebuild.
- Axis primary resolution remains tied to the existing external asset registry; no
  replacement MP40 model or new environment asset was introduced.
- Battlefield cross-team weapon pickups remain supported and can still intentionally
  retain the picked weapon's source-team visual.
- v20 movement, v21 class/combat rhythm, v22 fireteams, maps, spawns, vehicles,
  objectives and environment are unchanged.

TEST:
1. Join Defenders/Axis as Medic: primary should visually be MP40.
2. Respawn and change Axis classes: primary should remain MP40 visual.
3. Join Allies: primary should remain Thompson visual.
4. Pick up an enemy primary and verify cross-team weapon visual still follows the pickup.
5. Drop/repick weapons and verify visuals refresh correctly.
