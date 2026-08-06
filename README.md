# Frontline: Objective

## Version 8.2.0 Server Structural Asset Authority & Alley Detail

### Root collision fix
The townhouse, ruined-townhouse, church, warehouse, and bunker scenes are now
loaded before the graphical/headless split in `_ready()`.

Previously the client displayed the townhouses while a remote headless server
had `null` structure scenes. The VPS therefore had no matching wall meshes from
which to generate collision.

The server and client now instantiate the same structural scenes and generate
collision directly from those meshes.

### Missing asset protection
When a required townhouse model is genuinely unavailable, the server creates a
thin, doorway-aware perimeter shell. It does not create a broad solid building
box and does not cover the intended doorway.

The console reports both asset availability and any fallback use.

### Movement safeguards
The existing server capsule motion sweep remains. A three-height forward wall
probe now checks ankle, chest, and head height before movement, reducing
tunneling through thin or imperfect trimesh walls.

### Ongoing visual improvements
The village alley receives:

- metal drainpipes,
- overhead utility cables,
- aged wall posters,
- masonry wall caps,
- wooden crates,
- metal bins.

These are visual-only and do not add invisible collision.

Build: v8.2.0
Protocol: 341
