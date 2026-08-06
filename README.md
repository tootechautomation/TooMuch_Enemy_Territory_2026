# Frontline: Objective

## Version 8.16.1 — Visual Quality Parser Hotfix

The Godot 4.7 parser hotfix adds explicit types to enum-indexed graphics mode labels and quality-manager collections. All v8.16 scalable-quality behavior remains intact.

The upgraded presentation now includes five runtime graphics modes: Auto, Cinematic, High, Balanced, and Performance. Cinematic remains the default active quality in Auto mode. Auto steps down only after eight sustained seconds below 43 FPS and restores quality only after twenty sustained seconds above 57 FPS, preventing rapid visual oscillation.

F6 cycles modes at any time and displays the active tier. The selection is saved locally. Presets coordinate MSAA, TAA, FXAA, SSAO, SSIL, glow, volumetric fog, directional-shadow range, and expensive atmospheric layers. Gameplay geometry, structural collision, player visibility, objective markers, and combat effects essential to readability are never removed.

Build: v8.16.1
Protocol: 341
