# Test checklist

1. Confirm combat_effects_manager.gd parses without line 252 errors.
2. Confirm no Variant inference error appears near effect-root cleanup.
3. Fire repeatedly into walls and confirm decal cleanup still works.
4. Trigger explosions and confirm effect-root cleanup still works.
5. Confirm no unbounded effect accumulation.
6. Confirm v8.3.1 protocol 341.
