# Frontline: Objective

## Version 7.7.0 Procedural Realism & WWII Environment Pass

### Articulated fallback soldiers
The procedural fallback character is no longer a single capsule or rigid stack
of boxes. It now has:

- Separate torso, head, shoulders, elbows, hips and knees
- Human proportions and a clearer silhouette
- Helmet, chin straps, webbing, belt, pouches and backpack
- Class-specific medic, engineer, radio and scout equipment
- A recognizable WWII-style fallback rifle
- Walk, run, crouch, aiming and downed movement

Real rigged GLBs still override the procedural character automatically.

### First-person weapon
The fallback first-person weapon now has darker blued metal, wooden furniture,
a buttstock, handguard and front/rear sights. Existing visible sleeves, hands
and fingers remain.

### Environment detail
A new WWII detail pass adds:

- Two-row sandbag positions
- Supply crates and metal barrels
- Rubble fields
- Windows and damaged shutters
- Blackout-style street lamps
- Extra visual breakup around major routes

These are decorative and do not replace authoritative gameplay collision.

### External asset path
The project includes:

```text
assets/external/REALISTIC_ASSET_SOURCES.json
```

It lists the CC0 sources and the existing prepared GLB slots.

### Compatibility
- Build: v7.7.0
- Protocol: 341
- Explicit connection-message `+` retained
- Headless server skips all decorative visual generation
- Existing progression, profile and external-asset systems retained

Expected status: `Connected: v7.7.0 protocol 341`
