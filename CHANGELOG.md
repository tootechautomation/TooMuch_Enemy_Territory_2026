# Changelog

## 5.8.0
- Fixed invalid `get_world_3d()` call from Node-based main.gd
- Added `scripts/ai/tactical_director.gd`
- Moved tactical anchors and cover evaluation out of main.gd
- Added line-of-sight cover scoring
- Added short cover-goal caching for suppressed bots
- Preserved protocol 341 and explicit connection-string `+`
