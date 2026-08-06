# Milestone 8.19.1 — External Asset Report Hotfix

The v8.19 availability report introduced two path-valued entries alongside its existing Boolean entries. The formatter previously attempted Boolean conversion for every value, which is invalid for Godot String values.

The report now formats values according to their actual type:

- Boolean values display `READY` or `fallback`.
- String values display the selected resource path, or `fallback` when empty.
- Other non-null diagnostic values display their normal string representation.

Character loading, generated uniform textures, modular import selection, gameplay, networking, and protocol 341 are unchanged.
