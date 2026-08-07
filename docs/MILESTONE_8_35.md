# Milestone 8.35 — CC0 Building and Uniform Material Upgrade

## Goal

Replace more of the generated fallback appearance with freely redistributable real-world PBR surfaces while preserving the project's later paid-asset upgrade path.

## Selected Assets

### ambientCG Bricks097

- 1K JPG material
- Damaged, dirty, old industrial red brick
- Color, NormalGL, and Roughness maps included
- Applied to brick buildings, townhouses, warehouses, village structures, and generated brick surfaces

### ambientCG Fabric083

- 1K JPG material
- Woven gray patterned cloth
- Color, NormalGL, and Roughness maps included
- Applied to fallback soldier uniforms and first-person sleeves
- Multiplied by team-specific olive-drab or field-gray tint

## License

Both assets are Creative Commons CC0. The bundled source record preserves asset URLs, original archive names, download date, and SHA-256 hashes. No attribution is required, but provenance remains documented for maintainers.

## Integration

- The WWII material library prioritizes Bricks097 for the brick category.
- Asset-based village construction loads Bricks097 directly for brick materials.
- Generated brick and townhouse materials use the downloaded color and roughness maps.
- Articulated fallback uniforms load Fabric083 with OpenGL normal and roughness response.
- Legacy fallback bodies and first-person sleeves receive the same material and team tint.
- Existing original textures remain available as compatibility fallbacks.
- Imported scenes and their authored materials remain preferred.

## Compatibility

- Network protocol remains 341.
- No RPC, snapshot, collision, hitbox, gameplay, or class-balance changes were made.
- Headless servers do not load display-only PBR textures.

## Verification

- Inspect damaged brick buildings at oblique light angles and confirm mortar and chipped-face normal response.
- Confirm brick roughness remains matte without plastic highlights.
- Compare Allied and opposing fallback soldiers and confirm clear olive/field-gray separation.
- Inspect first-person sleeves and confirm the weave remains subtle rather than oversized.
- Confirm class accents, nameplates, HUD identity, and imported models remain unchanged.
