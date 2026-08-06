# Changelog

## 8.19.1
- Made the external asset report formatter type-aware for Boolean availability and String path entries
- Fixed the `Nonexistent 'bool' constructor` runtime failure when character source paths are empty or populated
- Preserved v8.19 skins, modular import candidates, fallback behavior, networking, and protocol 341

## 8.19.0
- Replaced schematic fallback uniform maps with original high-resolution Allied olive-drab and opposing field-gray wool textures
- Removed artificial uniform glow and broad blue/red material tinting for more natural cloth response
- Added automatic GLB, FBX, and Blender candidate discovery for Modular Military 2-style team exports
- Added cloth-surface recognition and restrained team-aware imported-material treatment
- Extended external asset reporting with the selected character source paths
- Documented the cooked UE4 demo limitation and the safe licensed-source import workflow
- Preserved procedural fallbacks, generic external character slots, animation control, weapon sockets, gameplay, networking, and protocol 341

## 8.18.0
- Added detailed railway sleepers, spikes, ballast beds, rail heads, and rusted rail webs
- Added layered vehicle ruts and period road-repair seams to break up flat road surfaces
- Added recessed village glazing, dimensional mullions, door hardware, and aged glass response
- Added fort embrasure lips, armored shutters, fasteners, and layered material response
- Added dimensional period wayfinding and rounded mixed-material rubble clusters
- Added distance fading and headless exclusions for the new client-side dressing
- Preserved collision, navigation, imported-asset overrides, gameplay, networking, and protocol 341

## 8.17.1
- Renamed reserved `class_name` locals and parameters in the player and team-identity HUD scripts
- Fixed the associated Godot parser failures without changing team readability behavior
- Preserved all v8.17 features, networking compatibility, and protocol 341

## 8.17.0
- Added a persistent ATTACKERS or DEFENDERS panel with class, current order, and explicit team color
- Added restrained blue or red screen-edge accents
- Added clear deployment and team-change role announcements
- Added friendly-only diamond identifiers and extended depth-tested friendly label ranges
- Protected custom team borders from generic interface restyling
- Preserved team assignment, enemy spotting rules, gameplay, networking, previous milestones, and protocol 341


## 8.16.1
- Added explicit String typing for graphics mode and active-tier status text
- Added explicit typed arrays and local variable annotations throughout the quality manager
- Fixed Godot 4.7 parser inference failures at visual_quality_manager.gd lines 214-215
- Preserved all v8.16 quality modes, F6 cycling, auto-scaling behavior, and protocol 341


## 8.16.0
- Added Auto, Cinematic, High, Balanced, and Performance graphics modes
- Added F6 mode cycling, active-tier display, and local persistence
- Added conservative sustained-FPS adaptation and gradual quality recovery
- Coordinated antialiasing, SSAO, SSIL, glow, volumetric fog, shadows, and optional atmosphere
- Restricted visibility changes to named optional atmospheric effects only
- Preserved gameplay geometry, state-driven visibility, networking, previous milestones, and protocol 341


## 8.15.0
- Added peripheral damage response and restrained chromatic separation
- Added suppression and heavy-fire desaturation, grain, edge pressure, and mild softening
- Added pulsing low-health tunnel vision and incapacitated-state treatment
- Added a short peripheral recovery cue when health increases
- Kept the center sight picture clear and the overlay mouse-transparent
- Used existing replicated state only; preserved gameplay, networking, prior milestones, and protocol 341


## 8.14.0
- Added cohesive steel, canvas, and brass styling across HUD and menus
- Added clear button states, readable fields, and role-aware progress bars
- Added consistent title hierarchy, label shadows, spacing, and panel treatment
- Added a restrained edge vignette and low-opacity animated film grain
- Added discovery styling for controls created later in multiplayer sessions
- Preserved HUD information, inputs, responsive layout, gameplay, networking, and protocol 341


## 8.13.0
- Added three independently moving procedural overcast layers
- Added bounded wind-driven rain and wet-ground mist
- Added gradual weather modulation of fog, ambient light, sun energy, and color temperature
- Added original looping rain ambience through the SFX bus
- Added restrained deterministic distant-lightning flashes during heavy weather
- Preserved visibility, gameplay, networking, prior atmosphere progression, and protocol 341


## 8.12.0
- Added ten visible bridge-construction stages tied to engineer progress
- Added a detailed command-post field table, radio, controls, antenna, and map board
- Added a canvas supply canopy, detailed crates, poles, bands, and artillery stores
- Added a wired dynamite bundle, bunker hardware, and state-colored sector flags
- Kept all additions client-side and non-colliding
- Preserved objective logic, interaction radii, navigation, networking, previous milestones, and protocol 341


## 8.11.0
- Added an original synchronized calm, tension, and assault battlefield score
- Added smooth objective-driven intensity crossfades
- Raised score pressure for armed dynamite, contested control points, damaged objectives, overtime, and final-minute play
- Routed all score stems through the existing Music bus and profile volume control
- Lowered ambience slightly so the musical score remains clearly audible
- Preserved headless behavior, gameplay, networking, previous milestones, and protocol 341


## 8.10.0
- Rebound fallback animation to the articulated v8.7 shoulder, hip, knee, torso, head, and weapon joints
- Added speed-scaled locomotion, torso counter-motion, knee articulation, and equipment-aware posing
- Added supported aiming, crouched combat, asymmetric reload, idle breathing, and subtle look motion
- Added grounded incapacitated poses with clean recovery on respawn
- Preserved external rig animation, physics, hitboxes, combat timing, networking, and protocol 341


## 8.9.0
- Added detailed magazines, triggers, ejection ports, controls, barrel hardware, and sling fittings to fallback first-person weapons
- Added a detailed fallback pistol slide, chamber, sights, magazine, grip panels, and controls
- Added class-specific LMG, SMG, carbine, field-ops, and marksman weapon details
- Added a lowered and rolled first-person reload pose with subtle hand-work movement
- Preserved imported weapon overrides, combat balance, networking, earlier milestones, and protocol 341


## 8.8.0
- Added layered period facades with recessed doors, windows, stone bases, lintels, and sills
- Added iron balconies, warm street lamps, chimneys, and stronger roof silhouettes
- Added deterministic battle-damage rubble clusters around village and rail approaches
- Added reflective puddles and repaired road seams to break up broad flat surfaces
- Kept all new dressing non-blocking and disabled it on headless servers
- Preserved v8.7 soldier fidelity, Forward+ PBR, spatial audio, combat effects, and protocol 341


## 8.7.0
- Improved bundled Allied and Axis fallback soldier silhouettes
- Added team-specific helmet geometry, facial ears, and neck protection
- Added webbing straps, breast pockets, buttons, buckle, and layered equipment
- Replaced box-shaped boots and backpacks with rounded geometry
- Added rifle handguard, bolt handle, trigger guard, and canvas sling details
- Restricted uniform textures to cloth instead of skin, leather, wood, and metal
- Added distinct metallic response for helmets, rifle parts, and belt hardware
- Raised battlefield ambience from -24 dB to -15 dB and enabled seamless looping
- Preserved automatic external rigged-character and weapon replacement support
- Preserved all v8.6 Forward+ PBR rendering improvements
- Preserved protocol 341 and explicit connection-string `+`

## 8.6.0
- Upgraded the desktop renderer from GL Compatibility to Forward+
- Enabled 4x MSAA, screen-space antialiasing, and soft directional shadows
- Enabled screen-space reflections and cinematic contrast/color grading
- Connected existing albedo, normal, and roughness maps to the material library
- Added true PBR surfaces for ten battlefield material categories
- Replaced box-shaped sandbags with rounded capsule geometry
- Replaced box rubble with low-poly irregular stone geometry
- Preserved the GL Compatibility renderer as the mobile fallback
- Preserved all v8.5 spatial combat audio and functional audio buses
- Preserved protocol 341 and explicit connection-string `+`

## 8.5.0
- Added positional surface-impact audio for every replicated bullet hit
- Added distinct metal, wood, brick, concrete, stone, ground, and flesh profiles
- Added randomized pitch variation to reduce repetitive combat sound
- Cached synthesized impact streams instead of generating audio per shot
- Added a bounded 28-player impact-audio pool for sustained firefights
- Created functional SFX and Music buses for the existing profile sliders
- Routed weapons, reloads, footsteps, hit confirms, grenades, and explosions to SFX
- Routed battlefield ambience to Music
- Preserved all v8.4 persistent decals and directional impact effects
- Preserved protocol 341 and explicit connection-string `+`

## 8.4.0
- Made impact decals independent of short-lived particle roots
- Extended bullet-hole visibility to the intended bounded lifetime
- Cached procedural impact textures to remove per-shot texture regeneration
- Added randomized radial fracture detail to bullet-hole decals
- Directed debris away from struck surfaces instead of always upward
- Added emissive ricochet streaks for metal impacts
- Preserved v8.3.2 world-root compatibility
- Preserved protocol 341 and explicit connection-string `+`

## 8.3.2
- Changed combat impact world_root parameter from Node3D to Node
- Added safe Node3D world-context discovery
- Added explicit Dictionary typing for the surface ray result
- Fixed runtime argument-type failure from main.gd
- Preserved all v8.3 combat effects
- Preserved protocol 341 and explicit connection-string `+`
