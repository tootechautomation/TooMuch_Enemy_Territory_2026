# External Asset Integration

The game now supports real GLB assets without making them mandatory.

## Character slots

```text
assets/external/characters/allied_soldier.glb
assets/external/characters/axis_soldier.glb
```

Models should face `-Z`, have feet near `Y=0`, and be approximately 1.8 meters
tall. The loader searches for common animation names such as idle, walk, run,
crouch, reload, and death.

## Environment slots

```text
assets/external/environment/village_house_a.glb
assets/external/environment/village_house_b.glb
assets/external/environment/ruined_house.glb
assets/external/environment/warehouse.glb
assets/external/environment/chainlink_fence.glb
assets/external/props/military_crate.glb
```

After placing files, delete `.godot`, run the editor import once, then restart
the game.

## Licenses

CC0 assets can be bundled with the project.

CGTrader assets must be checked individually. Under the standard Royalty Free
license, the model may be incorporated into a game, but the raw downloaded
asset must not be redistributed as a standalone retrievable file. Keep those
files out of public source archives unless the individual license clearly
permits redistribution.
