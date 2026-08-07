# Frontline: Objective

## Version 8.38.0 — Dynamic Wet-Surface Weather Response

Rain now changes the battlefield materials instead of existing only as particles and audio. Roads, masonry, roofs, concrete, rubble, rails, crates, fortifications, and exposed props progressively darken and become smoother as the weather front intensifies, then dry slowly after rain passes. The response is derived from the existing deterministic weather intensity and updates at a restrained interval.

The system duplicates presentation materials locally before changing them, excludes players, weapons, markers, particles, water, and transparent/unshaded surfaces, and adds no collision or gameplay state. Existing SSR, SSAO, fog, volumetrics, quality scaling, and weather behavior remain intact.

## Previous Phase — 8.37.0 Imported Character Military Presentation

The working animated humanoid placeholder now reads more clearly at gameplay distance. Imported characters normalize to a slightly stronger 1.88 m soldier height, while the bundled neutral suit receives distinct Allied olive-drab or opposing field-gray treatment. Metallic response and source emission are removed from recognized uniform surfaces, roughness is raised to cloth-like levels, and normal response is restrained for a less plastic or alien appearance.

User-supplied Allied and Axis models remain higher-priority and continue through the same normalization and material-safety pipeline. A Godot-tested CC0 male base was evaluated but not bundled as the active replacement because it has no embedded animations and would leave combatants frozen in a T-pose.

## Previous Phase — 8.36.2 Duplicate Fallback Body Visibility Hotfix

Validated imported characters now exclusively own the remote third-person body. The recurring snapshot visibility update no longer turns the procedural barrel-shaped soldier back on over the imported rig. The old body is displayed only when no imported character passed validation.

## Previous Phase — 8.36.1 Imported Humanoid Activation Hotfix

The bundled humanoid is now preloaded as the guaranteed character fallback, and imported-scene traversal includes Godot's complete internal GLB hierarchy. This fixes the case where the valid CesiumMan mesh and skeleton were present but rejected because their imported nodes were not owned directly by the instantiated root, leaving the procedural soldier visible.

## Previous Phase — 8.36.0 Real Rigged Humanoid Character Replacement

The default third-person character is now a genuine textured, skinned, animated human mesh instead of the articulated primitive fallback. The bundled CesiumMan GLB is normalized automatically to the existing 1.82 m character scale, grounded, validated through the external-character pipeline, and used for both teams with the established team identity, HUD, hitboxes, collision, weapons, and gameplay unchanged.

CesiumMan is a compact neutral placeholder rather than the final WWII soldier. It is included under CC BY 4.0 with the required Cesium attribution and trademark notice in `assets/models/cc_by/cesium_man/LICENSE_AND_SOURCE.md`. User-supplied Allied or Axis models remain supported and will take priority when placed in the existing external-character slots.

The character's single authored animation is now accepted as a safe presentation fallback when an imported rig does not use the project's standard animation names. Network protocol remains 341.

## Previous Phase — 8.35.0 CC0 Building and Uniform Material Upgrade

The project now bundles two redistributable 1K PBR materials downloaded from ambientCG under CC0. Bricks097 replaces the temporary procedural brick surface with photographed, damaged industrial red masonry across the WWII material library, asset-based village buildings, townhouses, warehouses, and generated brick surfaces. Color, OpenGL normal, and roughness maps give the walls real mortar variation, chipped faces, and physically readable surface response.

Fabric083 replaces the fallback uniform color texture with a woven cloth material across articulated soldiers, legacy fallback bodies, and first-person sleeves. The material retains Allied olive-drab and opposing field-gray tinting while adding a restrained weave normal and measured roughness. Class accents and team identification remain unchanged.

Only the required color, NormalGL, and roughness maps are included; Blender, USD, MaterialX, displacement, DirectX-normal, and preview files were excluded. Source URLs, download date, CC0 terms, and original archive SHA-256 values are recorded in `assets/cc0/ambientcg/LICENSE_AND_SOURCES.md`. Imported character, weapon, and building assets still take priority; gameplay, collision, hitboxes, networking, and protocol 341 are unchanged.

## Previous Phase — 8.34.0 Third-Person Reload Mechanics and Editor-State Recovery

Fallback world weapons now perform a staged reload instead of moving only the arms and entire gun as one rigid piece. Each class-specific magazine or Soldier drum leaves its seated position, travels with the support-hand phase, returns to the weapon, and settles before the bolt handle cycles. The support arm follows the same normalized reload timeline, keeping the hand motion and weapon hardware synchronized.

Reload progress is presentation-only and derived from the existing replicated reload flag plus each weapon's existing reload duration. No snapshot fields or RPC arguments were added. Interruptions, weapon switches, respawns, and completed reloads return the magazine and bolt to their authored positions.

This build also documents and provides recoverable reset tools for Godot's editor-side `TextEdit` gutter warning. Frontline: Objective contains no `TextEdit`, `CodeEdit`, or gutter API use; the warning is caused by stale local `.godot` script-editor state when a replacement is extracted over an existing folder. The tools back up that local state rather than deleting project files. Imported-animation priority, reload timing, ammunition transfer, gameplay, networking, and protocol 341 are unchanged.

## Previous Phase — 8.33.0 Third-Person Aim Tracking and Firing Recoil

Fallback soldiers now follow the replicated vertical look direction with coordinated head, torso, shoulder, and weapon pitch. Looking uphill, down from elevated cover, or across uneven terrain therefore changes the full firing silhouette instead of moving only the invisible gameplay ray or camera head node.

Aim-to-hip transitions now blend through the support arm, firing arm, torso, and weapon rather than switching between two hard poses. Remote firing uses the existing shot-effect origin to identify the shooter locally, briefly shoulder the weapon, and apply visible recoil through the weapon, arms, torso, and head. Repeated automatic fire accumulates within a restrained cap and settles quickly.

No arguments were added to the unreliable shot-effect RPC, and no snapshot fields were added. Imported characters retain their animation-controller priority; aim mechanics, recoil values, spread, damage, fire rate, networking, and protocol 341 are unchanged.

## Previous Phase — 8.32.0 Airborne, Landing, and Stance Transitions

Fallback soldiers now visibly prepare for takeoff, hold a readable airborne silhouette, and absorb their landing instead of continuing the grounded walk cycle in midair. Ascending and descending motion produce different leg balance, knee bend, torso pitch, and weapon response, while landing strength scales with the existing vertical movement state.

Ground contact for remote characters is resolved with a short presentation-only floor probe combined with their interpolated velocity. This allows multiplayer jumps and falls to animate without adding snapshot data. Locomotion bob fades while airborne, stride planting resumes after contact, and landing compression flows back into the v8.31 directional gait.

Crouching and standing now blend the full body-height and joint pose rather than snapping between two offsets. Imported characters retain their animation-controller priority; jump velocity, gravity, fall damage, movement, collision, networking, and protocol 341 are unchanged.

## Previous Phase — 8.31.0 Directional Locomotion and Foot Planting

Fallback soldiers now move according to their actual direction instead of playing one forward gait for every velocity. Forward movement, backpedaling, and lateral strafing drive separate leg direction, stance width, torso balance, and weapon stabilization. Backpedaling uses a shorter guarded stride, while strafing shifts the hips and legs laterally without turning the entire pose into an exaggerated lean.

Acceleration and braking now influence upper-body pitch, and body turns produce a restrained anticipatory twist through the torso, head, legs, and held weapon. Alternating knee stabilization reduces the skating appearance at planted points of the stride, with smoother blending through idle, crouch, aim, reload, damage reaction, incapacitation, and revive recovery states.

The motion data is derived locally from existing velocity and body rotation. Imported characters retain their animation-controller priority; movement speed, acceleration, collision, hitboxes, weapon handling, networking, and protocol 341 are unchanged.

## Previous Phase — 8.30.0 Character Hit Reactions and Revive Recovery

Fallback soldiers now react visibly when taking damage instead of continuing through fire without physical feedback. Snapshot health changes drive a short presentation-only torso flinch, head recoil, arm displacement, and weapon deflection, with restrained side variation so repeated hits do not look mechanically identical.

Entering the downed state now accelerates into a weighted left- or right-side collapse rather than using the same slow fall every time. Revived soldiers rise through a brief guarded recovery pose before returning to normal locomotion, aim, crouch, and reload animation. These transitions use existing replicated health, alive, and downed state; no RPC arguments or network fields were added.

Imported characters retain their own animation controller and remain the preferred visual path. Damage, hitboxes, collision, weapon balance, revive rules, headless server behavior, networking, and protocol 341 are unchanged.

## Previous Phase — 8.29.0 Class-Specific World Weapons and Remote Fire

The class-specific weapon work now extends beyond the local first-person view. Fallback soldiers carry distinct Support LMG, SMG, carbine, service-rifle, and scoped-rifle silhouettes with profile-specific receivers, barrels, magazines, fore-ends, stocks, slings, sights, bipods, and muzzle sockets.

Third-person pose fidelity is now the sole owner of fallback joint and weapon transforms. This removes competing animation writers, fixes weapons drifting toward the torso origin, and keeps both hands connected during ready movement, aiming, crouching, and reload poses. Gunmetal material response now covers magazines, shrouds, bipods, handles, and butt plates as well as the receiver and barrel.

The existing unreliable shot-effects RPC now adds a brief world-space muzzle flash, unshadowed light, and smoke near remote shooters. Its arguments and network behavior are unchanged, local first-person fire avoids the duplicate world flash, and headless servers remain excluded. Imported character and weapon scenes still take priority; hitboxes, gameplay, networking, and protocol 341 are unchanged.

## Previous Phase — 8.28.0 Audible Adaptive Score and Battlefield Mix

The adaptive soundtrack is now deliberately audible instead of sitting beneath several layers of attenuation. Calm, Tension, and Assault stems have been loudness-normalized to a consistent average level, preventing the score from becoming quieter as combat intensity rises. The director uses a stronger but still restrained mix range controlled by the existing Music slider.

All three synchronized stems receive a short fade-in and are checked once per second for interrupted playback. If an audio player stops after a device transition or other interruption, it resumes at the active stem position. High-intensity combat applies only a small music duck so gunfire and objective effects remain readable without effectively muting the soundtrack.

Battlefield ambience now uses a dedicated Ambience bus derived from the Effects slider rather than sharing the Music bus. New profiles default to 75% Music volume; existing saved settings remain respected. Objectives, combat, bots, classes, headless server behavior, networking, and protocol 341 are unchanged.

## Previous Phase — 8.27.0 Spatial Firing Effects and Weapon Heat

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

Build: v8.29.0
Protocol: 341
