# Test checklist

1. Restart VPS and client and confirm build v7.0.0 protocol 341.
2. Walk into all four wooden fences; they must block movement.
3. Walk into each red-brick fallback townhouse; it must block movement.
4. Run `python3 tools/verify_external_assets.py`.
5. Add one optional environment GLB and reimport the project.
6. Confirm the external model appears without breaking the server.
7. Add a rigged test character to the Allied slot.
8. Confirm the procedural body hides for that character.
9. Confirm idle, walk, and run animation detection where names match.
10. Confirm bots, scoreboard, tactical map, combat, and objectives remain.
