# Changelog

## 8.1.0
- Replaced broad townhouse proxies with exact scene-mesh trimesh collision
- Instantiated structural townhouse scenes on the headless server
- Removed manually positioned gray plaster collision proxies
- Disabled broad AABB fallback collision in the wall auditor
- Added server capsule motion sweep against thin walls
- Added architectural windows, shutters, foundations, roof trim, gutters,
  masonry damage, soot, and curbs
- Preserved protocol 341 and explicit connection-string `+`
