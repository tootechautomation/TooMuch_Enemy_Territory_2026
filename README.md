FRONTLINE: OBJECTIVE v9.14.0
INFANTRY COMBAT FEEL + DAMAGE FEEDBACK + EFFECT SCALING

This phase improves systems already present in the infantry controller rather
than adding another expensive subsystem.

HIT FEEDBACK
- standard hit marker remains a clear X
- headshot now gets a larger distinct star marker
- headshot visibility lasts slightly longer
- hit marker presentation resets safely after timeout

DIRECTIONAL DAMAGE
Existing FRONT / REAR / LEFT / RIGHT indicators now scale with damage severity:
- larger arrow for heavier damage
- stronger opacity/color response
- existing direction calculation remains unchanged

SUPPRESSION
Existing suppression overlay now pulses subtly with remaining suppression time.
First-person weapon presentation receives a very small visual-only tremor while
suppressed.

IMPORTANT:
Suppression tremor does NOT alter authoritative bullet direction. This is visual
feedback rather than hidden accuracy manipulation.

QUALITY-SCALED FIRST-PERSON EFFECTS
LOW/LAPTOP
- no per-shot dynamic muzzle light
- no local casing mesh
- one short muzzle-smoke layer

BALANCED
- muzzle light enabled
- shorter-lived casing effect
- one smoke layer

HIGH
- full existing casing duration
- second hot-weapon smoke layer where appropriate

This reduces short-lived nodes and lights on low-end hardware during automatic
fire.

PRESERVED
- v9.13.2 tracer scope fix
- tracers / impact FX / battlefield smoke and fire
- v9.12 camera collision / safe exits
- destructible streets
- all vehicle/aircraft systems
- real vehicle GLBs
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.14.0
Protocol: 341
