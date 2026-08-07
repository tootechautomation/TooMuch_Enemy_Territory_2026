# Milestone 8.10 — Articulated Soldier Motion

- Rebound fallback animation to the v8.7 articulated shoulder, hip, knee, torso, head, and weapon joints.
- Added speed-scaled walking and sprinting with knee articulation and torso counter-motion.
- Added supported aiming, crouched combat, asymmetric reload, breathing, and subtle idle-look poses.
- Added grounded incapacitated posing without modifying gameplay collision or revive logic.
- Limited the pose layer to `ArticulatedSoldier`; imported rigged characters keep their existing animation pipeline.
- Preserved v8.9 first-person weapon fidelity, v8.8 environment detail, v8.7 soldier art, Forward+ PBR, spatial audio, persistent effects, and protocol 341.
