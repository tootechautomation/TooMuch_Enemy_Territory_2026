Frontline: Objective v22.2.2 — MP40 FIRST-PERSON ORIENTATION HOTFIX
Network Protocol 364

FIX
- Keeps the correct user-supplied MP40 model and textures from v22.2.
- Corrects the MP40 first-person pose so the barrel points forward instead of the
  model rendering sideways across the screen.
- The supplied MP40 mesh is authored lengthwise along local +X; Frontline expects a
  camera-forward -Z weapon axis. v22.2.2 applies a specific +90 degree Y-axis correction.
- Applies the same axis correction to the external/third-person MP40 weapon presentation.
- P38 mapping and pose logic are unchanged.
- No movement, class, fireteam, map, environment, spawn, vehicle, objective, damage,
  recoil, or weapon-stat changes.
- Network Protocol remains 364.

TEST
1. Join Defenders/Axis and equip primary.
2. MP40 should now point directly forward rather than horizontally across the screen.
3. Fire, reload, zoom, move and jump to verify the corrected pose remains stable.
4. Switch to P38 and verify it is unaffected.
5. Verify remote Axis characters also carry the MP40 in a forward-aligned orientation.
