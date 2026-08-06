# Frontline: Objective

## Version 8.17.1 — Team Identity Parser Hotfix

This hotfix renames a reserved Godot keyword that was inadvertently used as a local variable and function parameter in the v8.17 team-identity feature. The full team panel, edge accents, deployment announcements, friendly identifiers, and prior gameplay systems are preserved.

The local player’s allegiance is now unmistakable. A persistent team-colored panel identifies ATTACKERS or DEFENDERS, the selected class, the current attack/defend order, and the associated blue/red team color. Thin peripheral accents reinforce allegiance without covering the center view. Deployment and team changes trigger a short explicit attacker/defender announcement with role verbs.

Friendly world nameplates now include a diamond identifier and remain visible at longer depth-tested ranges. Class labels also remain readable farther away. Enemy players receive no new marker or visibility advantage.

All additions are client-side presentation. Team assignment, uniforms, objectives, spotting, server authority, networking, and protocol 341 remain unchanged.

Build: v8.17.1
Protocol: 341
