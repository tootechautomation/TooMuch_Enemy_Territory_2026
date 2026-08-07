# Frontline: Objective

## Version 8.27.0 — Spatial Firing Effects and Weapon Heat

First-person firing effects now originate at the actual weapon muzzle instead of a stale shared coordinate. Each fallback weapon class uses a barrel endpoint matched to its current geometry, while imported models can provide `MuzzleSocket`, `Muzzle`, `BarrelEnd`, or common lowercase socket names for automatic alignment.

Flash size varies by pistol, SMG, carbine, rifle, scoped rifle, and Support LMG profile, with restrained random scale and rotation on each shot. Muzzle lighting follows the same resolved endpoint. The old screen-centered 2D flash is disabled so firing reads as part of the weapon rather than a HUD overlay.

Repeated fire now builds presentation-only weapon heat. Higher heat produces denser, larger, longer-lived smoke layers that rise and drift independently before cooling naturally. Casings use pistol, standard long-gun, or heavier LMG proportions with randomized ejection paths and spin. Fire rate, recoil values, spread, damage, hit detection, ammo, server authority, networking, and protocol 341 are unchanged.

## Previous Phase — 8.26.0 Class-Specific Aim-Down-Sights Composition

Right-click aiming now shoulders each weapon into a deliberate class-specific sight position instead of applying one generic forward nudge. The Support LMG, SMG, carbine, service rifle, scoped rifle, and pistol use separate hip distances and centered aim positions matched to their receiver and sight geometry.

The animation controller is now the sole owner of first-person weapon placement. This removes the previous conflict in which the aim-view update and animation update pulled the weapon toward different targets every frame. Firing feedback remains anchored to the aimed pose, the standard and ET-style crosshairs clear during ADS, and the Scout retains its dedicated scope overlay.

ADS movement bob, landing inertia, camera-turn inertia, and visible recoil are damped for a steadier sight picture, with subtle breathing motion retained so the weapon does not appear frozen. These are presentation changes only: authoritative spread multipliers, recoil values, fire rates, damage, movement penalties, networking, and protocol 341 are unchanged.

## Previous Phase — 8.25.0 Class-Specific First-Person Weapon Rigs

The bundled first-person fallback weapons now read as five distinct class weapons rather than one generic receiver with multiple magazines stacked underneath it. The Soldier carries a single drum-fed Support LMG silhouette with a jacketed barrel, rear sight, carry handle, and compact folded bipod. Medic, Engineer, Field Ops, and Scout weapons receive their own magazine proportions and fore-end or sight details.

Long-gun hand placement is now driven by the actual grip zones: the firing hand terminates at the rear grip while the support hand reaches the fore-end. The oversized rectangular stock has been replaced by a smaller layered wood body, raised comb, and metal butt plate, and the full long-gun rig sits farther from the camera for a clearer ET-style lower-right presentation.

Imported GLB/FBX first-person weapons still take priority whenever installed. The v8.24 proportional arms, v8.23 camera protections, v8.22 mechanical animations, weapon timing, recoil, ammo, damage, movement, server authority, networking, and protocol 341 remain unchanged.

## Previous Phase — 8.24.0 Proportional Viewmodel Grip Composition

First-person weapons now use a deliberately lower, smaller, weapon-focused composition. Both forearms begin outside the central sight picture and angle inward toward the pistol or long-gun grip area. Sleeves, cuffs, gloves, fingers, thumbs, and class wrist equipment have been resized as one coherent set instead of appearing as camera-adjacent primitive shapes.

The full viewmodel sits farther from the camera, while fallback grips and buttstocks use slimmer silhouettes. Watches, the Medic sleeve band, Engineer cuff, Field Ops push-to-talk control, and Scout compass are seated directly against the support sleeve, eliminating the floating circular accessory that previously blocked the crosshair.

The v8.23 camera-origin initialization fix, near-plane clamp, wall-aware lowering, and FOV spacing remain active. The v8.22 mechanical weapon animations also remain intact, with weapon timing, ammo, recoil values, damage, collision, movement, server authority, networking, and protocol 341 unchanged.

## Previous Phase — 8.23.0 Viewmodel Camera Clearance and Obstruction

The first-person viewmodel now maintains a safe, readable composition at all times. The animation base position is initialized when each weapon is rebuilt, preventing the entire weapon-and-arm hierarchy from being pulled to the camera origin. Pistol and long-gun sleeves have also been shortened and repositioned so cuffs, hands, fingers, thumbs, and class wrist details remain beyond the near plane instead of appearing as an oversized peg across the screen.

Recoil, sprinting, aiming, reloads, landing inertia, and weapon mechanics now share a final camera-clearance clamp. A short local obstruction probe lowers and rotates the weapon near walls, reducing geometry penetration while leaving collision and authoritative gameplay untouched. Viewmodel spacing responds conservatively to field of view, and first-person geometry no longer casts distracting self-shadows.

The v8.22 slide, bolt, charging-handle, magazine, and support-hand animations remain intact. Weapon timing, recoil values, ammo, damage, movement, class balance, server authority, networking, and protocol 341 are unchanged.

## Previous Phase — 8.22.0 First-Person Mechanical Animation Fidelity

First-person weapons now visibly operate instead of moving only as one rigid object. Pistol slides, rifle bolts, charging handles, magazines, drum magazines, and the support arm respond to firing and reload state. Magazine removal, hand travel, reinsertion, and the final bolt action are timed as presentation layers over the existing authoritative reload duration.

Movement presentation also gains restrained landing inertia and reduced weapon bob while aiming. Sprint lowering, recoil, muzzle effects, shell ejection, reload audio, and the v8.21 textured arms remain intact.

The player's first-person body now matches the upgraded third-person soldier. Sleeves use the high-resolution Allied olive-drab or opposing field-gray wool textures; hands use team-appropriate rough leather gloves with four articulated-looking fingers, a separate thumb, and a dimensional cuff instead of the earlier three-finger skin-colored capsules.

Each class also carries a small first-person identifier on the support wrist: Soldier watch, Medic sleeve band, Engineer reinforced cuff, Field Ops push-to-talk control, or Scout compass. Both imported and bundled first-person weapons now receive the same arm treatment, so installing a better rifle model no longer makes the player's arms disappear.

The articulated fallback soldiers now use the v8.19 high-resolution wool textures directly, with neutral albedo response and heavier cloth roughness. Their class identity is also visible in the model itself: Soldiers carry bandoliers, grenades, and bayonet scabbards; Medics carry layered canvas medical packs, dressing pouches, and a dimensional armband; Engineers carry tool rolls, a wrench, wire spool, and cap tins; Field Ops carry a detailed radio, control panel, dials, antenna, and handset; Scouts carry binoculars, a map case, helmet scrim, and a scoped weapon.

All equipment is attached to the existing articulated joints, so locomotion, aiming, crouching, reloading, incapacitation, and team skin changes continue to move as one coherent character. The pass remains visual-only and does not alter hitboxes, collision, weapon balance, class abilities, or networking.

This hotfix makes external-asset reporting type-aware. Boolean availability entries continue to display `READY` or `fallback`, while the new selected-path entries display the actual imported resource path or `fallback`. This removes the invalid attempt to convert character path strings with Godot's Boolean constructor.

The bundled fallback soldiers now use original high-resolution olive-drab and field-gray wool albedo skins instead of the earlier schematic blue/red textures. The material response is non-metallic, highly rough cloth with no artificial uniform glow; class accents, friendly markers, and the v8.17 team HUD continue to provide clear gameplay identification.

The external-character registry now auto-detects GLB, FBX, and Blender exports prepared from Modular Military 2-style packages. One assembled, rigged character can be supplied for each team, automatically normalized to human scale, grounded, validated, connected to the animation controller, attached to weapon sockets, and given restrained cloth-only team treatment. Existing generic `allied_soldier.glb` and `axis_soldier.glb` slots remain fully compatible.

The free Modular Military 2 download is documented as an Unreal Engine evaluation build rather than bundled into the project: it contains only cooked Windows demo content and no editable Godot-importable character source. The project remains ready for the licensed full pack's FBX, GLB, or Blender exports without redistributing proprietary source assets.

The battlefield now carries substantially more dimensional detail instead of relying on broad, block-like surfaces. Rail-yard routes gain full sleeper, spike, ballast, rail-head, and rust-web assemblies. Roads show paired vehicle ruts and period repair seams. Village windows gain recessed panes, cross-mullions, hardware, and aged glass, while fortifications gain layered embrasures, armored shutters, and visible fasteners.

Period direction signs and rounded rubble clusters strengthen location identity and environmental storytelling. New dressing is client-side, distance-faded, non-colliding, and omitted on headless servers. Existing imported-model overrides remain supported, so redistributable or privately purchased art can continue replacing bundled fallback assets later.

This hotfix renames a reserved Godot keyword that was inadvertently used as a local variable and function parameter in the v8.17 team-identity feature. The full team panel, edge accents, deployment announcements, friendly identifiers, and prior gameplay systems are preserved.

The local player’s allegiance is now unmistakable. A persistent team-colored panel identifies ATTACKERS or DEFENDERS, the selected class, the current attack/defend order, and the associated blue/red team color. Thin peripheral accents reinforce allegiance without covering the center view. Deployment and team changes trigger a short explicit attacker/defender announcement with role verbs.

Friendly world nameplates now include a diamond identifier and remain visible at longer depth-tested ranges. Class labels also remain readable farther away. Enemy players receive no new marker or visibility advantage.

All additions are client-side presentation. Team assignment, uniforms, objectives, spotting, server authority, networking, and protocol 341 remain unchanged.

Build: v8.27.0
Protocol: 341
