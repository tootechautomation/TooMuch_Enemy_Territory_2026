# Test checklist

1. Fully restart the client and VPS.
2. Confirm main.gd parses without the ExternalLODController type error.
3. Confirm the game starts with no external GLB assets installed.
4. Press F10 and verify the external-asset overlay opens.
5. Confirm the console reports fallback asset availability.
6. Add an optional environment GLB and verify LOD registration.
7. Move away from the model and verify far-distance shadow reduction.
8. Confirm bots, scoreboard, tactical map and objectives remain functional.
9. Confirm build v7.3.1 protocol 341.
