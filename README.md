# Frontline: Objective

## Version 8.10.0 — Articulated Soldier Motion

The upgraded fallback soldiers now receive animation through their actual articulated joint hierarchy. Locomotion drives shoulder, hip, and knee joints; aiming establishes a supported weapon pose; crouching lowers the stance with bent knees; reloading uses asymmetric hand-work; idle soldiers breathe and scan subtly; and incapacitated soldiers settle into a grounded pose.

This phase repairs the legacy animation binding that still searched for obsolete `ArmL`, `ArmR`, `LegL`, and `LegR` node names after the v8.7 soldier rebuild. External rigged characters retain their own imported AnimationPlayer/AnimationTree pipeline and are not altered.

Movement physics, collision shapes, weapon timing, damage, server authority, replication, and protocol 341 remain unchanged.

Build: v8.10.0
Protocol: 341
