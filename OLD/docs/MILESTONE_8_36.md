# Milestone 8.36 — Real Rigged Humanoid Character Replacement

## Goal

Replace the visibly primitive fallback soldier silhouette with an actual human character while retaining the open-source project's clean external-asset upgrade path.

## Bundled Character

CesiumMan is a textured, skinned, animated humanoid distributed by the Khronos glTF Sample Assets repository. The GLB contains one mesh, one skin, a complete articulated skeleton, and one authored animation. Its compact size makes it suitable as an immediately usable placeholder while a purpose-built WWII character is selected later.

## Integration

- The same bundled GLB is shared by both teams instead of duplicating binary data.
- The real-asset adapter normalizes the model to 1.82 meters and grounds it at the player origin.
- The external-model path hides the primitive `Body` and `CharacterVisual` only after skeleton and height validation succeeds.
- The bundled skeleton's right-hand joint is recognized as an equipment socket fallback.
- A single nonstandard authored animation is played when no conventional idle, walk, or run clip name exists.
- Existing external Allied and Axis slots remain available for later purpose-built replacements.

## License and Provenance

The model is Copyright 2017 Cesium and distributed under CC BY 4.0 International with trademark limitations. Full attribution, source, checksum, and a no-endorsement statement are included beside the model.

## Compatibility

- Character collision and hitboxes remain on the existing player controller.
- Combat, classes, objectives, weapons, bot logic, and spawn behavior are unchanged.
- Headless servers do not instantiate display-only character models.
- Network protocol remains 341.

## Verification

1. Start a local match with bots and confirm remote players use a recognizable human silhouette.
2. Confirm the model is grounded and approximately human height.
3. Confirm team HUD, nameplates, class identity, health, weapons, and objective markers remain visible.
4. Confirm the primitive fallback stays hidden only when the GLB imports successfully.
5. Remove the bundled GLB temporarily and confirm the previous fallback still loads safely.
