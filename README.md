Frontline: Objective v22.2.1 — ASSET REGISTRY COMPATIBILITY HOTFIX
Network Protocol 364

FIX
- Corrects the parser error:
  Static function "grenade_scene()" not found in base "res://scripts/assets/asset_registry.gd".
- v22.2 weapon restoration accidentally replaced the long-running asset registry with a
  weapon-only subset. v22.2.1 restores the complete registry API surface currently called
  by main.gd, grenade.gd and player.gd.
- Restored registry methods:
  weapon_scene, grenade_scene, available_character, character_config,
  environment_scene, environment_config, availability_report.
- Allied MK2 grenade remains physically packaged.
- Axis grenade registry checks established Model 24 candidate paths and safely returns null
  to the existing fallback if the complete base project supplies it elsewhere.
- MP40 and P38 mappings/assets from v22.2 are retained.
- Network Protocol remains 364.

VALIDATION
- Scanned every ExternalAssetRegistryScript method call in all packaged GDScript.
- Confirmed every called registry method now has a static function definition.
- Confirmed MP40, P38 and MK2 packaged assets exist.
- ZIP CRC/integrity test performed.
