FRONTLINE: OBJECTIVE v8.89.0
LAPTOP / INTEGRATED-GRAPHICS COMPATIBILITY PHASE

PERFORMANCE REVIEW FINDING
Previous builds still called _apply_high_visual_quality() at startup. That
forced expensive settings before the quality manager initialized:
- 4x MSAA
- TAA
- SSAO
- glow
- full particle/light/shadow budgets

v8.89 removes that forced startup High mode.

QUALITY PRESETS
F8 cycles:
LOW / LAPTOP -> BALANCED -> HIGH

The setting persists between launches.

LOW / LAPTOP
Designed for integrated graphics / non-gaming machines:
- 72% internal 3D render scale
- FXAA
- no MSAA
- no TAA
- SSAO off
- SSIL off
- glow off
- volumetric fog off
- particle density ~28%
- secondary dust/ember/rain-interaction particles disabled
- only ~2 shadow-casting dynamic lights
- aggressive microdetail draw distance
- microdetail shadows disabled
- environmental cloth/rain interaction pass disabled
- shell casing budget reduced to 4

BALANCED (NEW DEFAULT)
Designed for ordinary modern laptops:
- 88% internal render scale
- 2x MSAA + FXAA
- TAA off
- moderate SSAO
- SSIL off
- moderate glow
- volumetric fog off
- particle density ~58%
- about 7 shadow-casting dynamic lights
- reduced microdetail shadow/distance cost
- shell casing budget 8

HIGH
Keeps the approved full presentation:
- 100% render scale
- 4x MSAA + FXAA + TAA
- full SSAO / SSIL
- glow
- volumetric fog
- full particle counts
- original light/shadow state
- full visual detail ranges
- shell casing budget 14

OTHER COMPATIBILITY WORK
- major structures and gameplay collision are never removed by Low mode
- smoke needed for gameplay visibility remains active
- quality changes do not affect server/network simulation
- pickups, weapon swaps, resupply and casualties remain gameplay-identical
- original render state is cached so switching back to High restores it
- settings are property-checked where Godot versions may differ

CONTROL
F8 = Cycle Video Quality
Upper-left indicator shows current mode.

RECOMMENDED TARGETS
LOW: integrated Intel/AMD graphics, older laptops, office-class PCs
BALANCED: modern laptop iGPU / entry-level discrete graphics
HIGH: gaming laptop / gaming desktop

PRESERVED
- all v8.88 weapon handling feedback
- contextual pickup HUD
- active-weapon-only drops
- ammo scavenging
- cross-faction weapon swaps
- resupply stations
- casualty persistence
- working Axis P38 orientation
- Mouse2 zoom and persistent crosshair
- collision / objectives / networking

Build: 8.89.0
Network protocol: 341
