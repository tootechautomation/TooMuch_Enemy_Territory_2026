FRONTLINE: OBJECTIVE v10.4.0 — SOLID CITY / COLLISION MAJOR PASS
Protocol 348

Primary fix
-----------
Ruined City imported GLB scenery is no longer visual-only ghost geometry.
Substantial architecture now receives static trimesh collision generated from
its actual imported mesh. Players should collide with buildings, ruins,
bunkers, wreck-sized geometry, structural walls and other major scenery.

Safety/performance rules
------------------------
- Existing authored gray-wall collision remains untouched.
- Ground/terrain/roads/floors are excluded from generated GLB collision.
- Glass/windows/foliage/fire/smoke/decals/water are excluded.
- Tiny rubble and clutter are excluded to reduce snagging.
- Collision generation is capped per imported setpiece.
- Existing spawn points, objectives, vehicles, weapons and map logic remain.

Test focus
----------
1. Walk directly into the large imported buildings/ruins.
2. Test the pillbox exterior.
3. Check spawn areas for trapping.
4. Test doorways/open passages; report any invisible blockage with screenshot.
5. Test vehicles around the new solid scenery.
