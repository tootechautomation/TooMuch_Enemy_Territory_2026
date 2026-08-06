# Frontline: Objective

## Version 8.1.0 Exact Scene Collision & Urban Realism

The four village townhouses now instantiate on both client and headless server.
Collision is generated directly from each visible mesh with
`create_trimesh_collision()`, so rotated walls, recesses, and openings remain
aligned with the rendered scene.

The broad townhouse solid proxies and hand-positioned gray plaster wall proxies
have been removed. The structural auditor no longer creates broad AABB box
fallbacks, eliminating the primary source of invisible walls.

Server movement now uses a short capsule motion sweep before `move_and_slide()`
to reduce thin-wall tunneling during sprinting or low frame-rate spikes.

The visual pass adds window glass, shutters, stone lintels and sills,
foundations, cornices, gutters, exposed-brick damage, soot, and stone curbs.

Build: v8.1.0
Protocol: 341
