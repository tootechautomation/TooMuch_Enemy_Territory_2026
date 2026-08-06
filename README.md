# Frontline: Objective

## Version 8.0.0 Authoritative Structure Collision & Wall Audit

Open buildings now create every visible wall directly under the building's
rotated root as a matching `StaticBody3D` with an exact local `BoxShape3D`.
This removes the world-space/reparent transform mismatch that could leave red
brick walls visually present but physically passable.

After the full graphical map is built, a deferred collision audit scans visible
structural meshes. Unprotected walls and buildings receive trimesh collision,
with a mesh-local box fallback only when trimesh generation fails.

Decorative grime, scorch marks, particles, foliage, weapons, characters, and
street debris are excluded.

The headless VPS continues to use authoritative procedural collision bodies.

Build: v8.0.0
Protocol: 341
