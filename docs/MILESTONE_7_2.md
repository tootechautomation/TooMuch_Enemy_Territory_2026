# Test checklist

1. Confirm v7.2.0 starts without external assets.
2. Add a rigged character with a recognized weapon socket.
3. Add a primary weapon GLB and confirm it attaches to the hand.
4. Switch to the pistol and confirm the weapon model changes.
5. Add an environment GLB with authored StaticBody3D collision.
6. Add a second model without collision and confirm trimesh generation.
7. Confirm fallback geometry hides only after collision succeeds.
8. Check the startup asset report.
9. Confirm bots, scoreboard, tactical map and objectives remain functional.
10. Confirm protocol 341.
