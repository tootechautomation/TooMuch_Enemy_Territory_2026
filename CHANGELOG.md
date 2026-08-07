# Changelog

## 8.31.0
- Added locally derived forward, backward, strafe, turn, and acceleration motion channels
- Added shorter reverse-direction steps and guarded upper-body balance while backpedaling
- Added lateral hip, leg, torso, head, and weapon response during strafing
- Added acceleration lean and braking recovery without changing movement physics
- Added restrained turn anticipation through the torso, head, legs, and held weapon
- Added alternating knee stabilization at stride plant points to reduce visible foot skating
- Reset transient locomotion state on respawn to prevent stale pose impulses
- Preserved imported-animation priority, v8.30 combat reactions, gameplay, networking, and protocol 341

## 8.30.0
- Added visible fallback-character flinches driven by existing replicated health changes
- Added torso, head, arm, and held-weapon displacement scaled by hit severity
- Added restrained left/right variation so repeated impacts remain readable without looking identical
- Upgraded the downed transition with faster impact response and two-sided collapse poses
- Added a brief guarded recovery motion after revival before normal locomotion resumes
- Reset presentation impulses safely on respawn and excluded headless display mode
- Preserved imported-animation priority, hitboxes, gameplay, RPC signatures, networking, and protocol 341

## 8.29.0
- Made ThirdPersonPoseFidelity the sole owner of fallback character joint and weapon transforms
- Fixed world weapons lerping toward the torso origin instead of their chest-ready base position
- Kept both hands connected to the weapon during idle movement, aiming, crouching, and reload presentation
- Added distinct third-person Support LMG, SMG, carbine, service-rifle, and scoped-rifle silhouettes
- Added class-specific receiver, barrel, magazine, fore-end, optic, stock, sling, bipod, and muzzle-socket proportions
- Expanded world-weapon material recognition for magazines, shrouds, bipods, handles, and butt plates
- Added brief world-space muzzle flash, light, and smoke to the existing shot-effect RPC without changing its arguments
- Preserved imported-character and weapon priority, hitboxes, gameplay, headless isolation, networking, and protocol 341

## 8.28.0
- Loudness-normalized the Calm, Tension, and Assault score stems to a consistent average level
- Raised the adaptive director's usable score range while retaining Music-bus volume control
- Added a short score fade-in and automatic synchronized restart checks for stopped audio players
- Added restrained high-intensity music ducking so gunfire stays readable without making the score disappear
- Moved battlefield ambience from the Music bus to a dedicated Ambience bus derived from effects volume
- Raised the new-profile default Music volume from 65% to 75% while preserving existing saved settings
- Added explicit adaptive-score startup reporting and safe initialization failure handling
- Preserved objectives, combat, bots, classes, headless isolation, networking, and protocol 341

## 8.27.0
- Replaced stale fixed muzzle-effect coordinates with class-specific fallback barrel endpoints
- Added imported-model muzzle socket discovery for MuzzleSocket, Muzzle, BarrelEnd, and common lowercase variants
- Added weapon-specific flash sizes with randomized spatial flash scale and rotation per shot
- Added visible weapon heat accumulation and cooling that controls muzzle-smoke density, size, opacity, rise, and lifetime
- Added pistol, standard long-gun, and Support LMG casing sizes with randomized ejection arcs and spin
- Anchored muzzle lighting to the resolved barrel endpoint and scaled its energy and range by weapon profile and heat
- Retired the screen-centered 2D muzzle flash in favor of the spatial first-person effect
- Preserved firing mechanics, recoil values, damage, hit detection, imported asset priority, networking, and protocol 341

## 8.26.0
- Made first-person animation the single owner of weapon placement, removing the frame-by-frame conflict with the older aim-view position writer
- Added class-specific hip positions and centered ADS positions for the Support LMG, SMG, carbine, service rifle, scoped rifle, and pistol
- Added faster shouldering transitions and restrained breathing motion while aiming
- Reduced ADS recoil presentation, movement bob, landing inertia, and camera-turn inertia without changing authoritative recoil or spread values
- Kept firing feedback anchored to the active aimed position instead of snapping briefly back to the hip pose
- Hid the standard and ET-style crosshairs during iron-sight aiming while retaining the Scout scope overlay
- Preserved v8.25 class weapon rigs, imported-model priority, gameplay balance, networking, and protocol 341

## 8.25.0
- Removed the generic long-gun box magazine and floor plate that were stacked beneath every class-specific weapon
- Rebuilt the Soldier Support LMG as one drum-fed silhouette with a barrel jacket, rear sight, carry handle, and compact folded bipod
- Added distinct SMG, carbine, service-rifle, and scoped-rifle magazine and fore-end treatments for the remaining classes
- Moved the long-gun support hand onto the fore-end and the firing hand onto the rear grip instead of leaving either hand detached or buried
- Replaced the oversized single-box stock with a smaller layered wood body, comb, and metal butt plate
- Bound pistol, SMG, carbine, and rifle magazine base plates to the existing staged reload movement
- Increased long-gun camera distance while preserving the v8.24 proportional limbs and all camera-clearance safeguards
- Preserved imported weapon priority, mechanical animation, weapon balance, gameplay, networking, and protocol 341

## 8.24.0
- Rebuilt first-person arm composition around proportional lower-screen silhouettes instead of camera-adjacent capsules
- Reduced sleeve, cuff, glove, finger, thumb, and class wrist-equipment dimensions while increasing mesh roundness
- Angled both forearms inward from lower outer origins so the hands converge naturally on pistol and long-gun grip areas
- Seated watches, Medic bands, reinforced cuffs, push-to-talk controls, and compasses directly on the support sleeve
- Moved complete pistol and long-gun rigs farther from the camera and reduced fallback grip and buttstock bulk
- Preserved the v8.23 camera-origin correction, near-plane protection, wall response, v8.22 mechanics, gameplay, networking, and protocol 341

## 8.23.0
- Fixed the first-person weapon animation target initializing at the camera origin, which pulled the sleeve and weapon into the player's face
- Re-composed pistol and long-gun arms with shorter camera-safe sleeves, hands, cuffs, fingers, thumbs, and class wrist details
- Added a hard near-plane clearance limit across recoil, sprinting, aiming, reloads, landing inertia, and mechanical-part animation
- Added wall-aware weapon lowering so the viewmodel tucks down naturally near solid geometry instead of clipping through it
- Added restrained FOV-aware viewmodel spacing and disabled first-person shadow casting to prevent oversized self-shadows
- Preserved v8.22 mechanical animations, weapon timing, recoil, damage, movement, class balance, networking, and protocol 341

## 8.22.0
- Added visible pistol-slide, rifle-bolt, and charging-handle cycling during fire and reload
- Added staged magazine removal, handling, and reinsertion for pistol, box, SMG, carbine, and drum magazines
- Added synchronized support-arm motion and final reload bolt manipulation
- Added restrained landing inertia based on the player's previous vertical velocity
- Reduced movement bob while aiming for a steadier sight picture
- Preserved authoritative reload duration, fire rate, recoil values, movement, damage, networking, and protocol 341

## 8.21.0
- Applied the v8.19 high-resolution wool skins to visible first-person sleeves
- Replaced skin-colored three-finger hands with rough leather gloves, four fingers, separate thumbs, and cuffs
- Added first-person Soldier watch, Medic sleeve band, Engineer reinforced cuff, Field Ops push-to-talk control, and Scout wrist compass
- Ensured imported first-person weapon scenes retain the complete arm and hand presentation
- Centralized pistol and long-gun arm construction for consistent future asset replacement
- Preserved weapon timing, recoil, aiming, reload behavior, class balance, networking, and protocol 341

## 8.20.0
- Connected the articulated fallback soldiers directly to the v8.19 high-resolution wool uniform skins
- Added Soldier bandolier, grenades, and bayonet-scabbard silhouette details
- Added layered Medic canvas pack, flap, dimensional armband, cross, and dressing pouches
- Added Engineer tool roll, flap, wrench, wire spool, and demolition cap tins
- Added Field Ops radio control panel, dials, antenna, and handset
- Added Scout binoculars, map case, helmet scrim, and scoped-rifle detail
- Improved uniform albedo neutrality and cloth roughness on articulated character parts
- Preserved imported-character priority, fallback animation, hitboxes, gameplay, networking, and protocol 341

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
