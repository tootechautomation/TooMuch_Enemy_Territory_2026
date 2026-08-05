# Frontline: Objective

## Version 1.7.0 class abilities

The five classes now have distinct server-authoritative abilities:

- **Soldier — Combat Resupply:** restores primary reserve ammunition and one grenade.
- **Medic — Healing Burst:** heals all living teammates within 10 meters.
- **Engineer — Field Repair:** restores health and applies three objective interaction ticks when in range.
- **Field Ops — Ammo Pulse:** resupplies nearby teammates within 12 meters.
- **Scout — Recon Pulse:** spots living enemies within 36 meters for eight seconds.

Added:

- Real server cooldown replication
- Ability name and READY/countdown state in the HUD
- World-space `SPOTTED` marker visible to the opposing team
- XP awards for healing, resupply, repair, and recon support
- Ability state reset when changing class

Install the same package on Windows and Linux.

Expected HUD:

```text
Connected: v1.7.0 protocol 170
Class: Scout  XP 0 (Recruit)  Q: Recon Pulse [READY]
```
