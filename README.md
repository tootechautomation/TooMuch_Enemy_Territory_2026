Frontline: Objective v18.0.0 — Battlefield Persistence / Fortification & Attrition
Network Protocol: 360

MAJOR PHASE
- Adds server-authoritative sector fortification/resilience to the existing Frontline Director and sector warfare systems.
- Friendly sectors gradually fortify while held and uncontested.
- Active contesting rapidly strips fortification, making sustained attacks matter.
- Fortified owned sectors resist enemy capture speed by up to 32%; neutral territory is never slowed.
- Captured/neutralized sectors reset fortification, creating a vulnerable consolidation/counterattack window.
- Engineers using the existing Fortify action near a friendly frontline sector add an immediate resilience boost while retaining barricade repair behavior.
- Sector world markers show FORT percentage once defenses become meaningful.
- Fortification state is synchronized through the existing sector-state RPC and resets cleanly between rounds.

PRESERVATION a/ SAFETY
- No map geometry or environment redesign.
- No spawn coordinate or initial human deployment changes.
- No new invisible/visible collision boxes.
- No new persistent scene-node population.
- Existing v13 Frontline Director, v14 class deployables, v15 squad orders, v16 combined arms, and v17 dynamic operations remain layered in place.
- Existing bot-disable CLI forms remain supported: --bots 0, --bots=0, --no-bots.

TEST FOCUS
1. Capture a sector and observe fortification build while uncontested.
2. Contest a fortified sector and confirm FORT decays quickly.
3. Compare capture time against a freshly captured vs well-fortified enemy sector.
4. Use Engineer Fortify near a friendly sector and confirm resilience increases.
5. Capture/neutralize a sector and confirm its fortification resets.
6. Verify sector state/markers on remote clients and late joins.
7. Regression-test v14 deployables, v15 orders, v16 vehicle logistics/designations, v17 operations, safe initial spawning, bots, objectives, and vehicles.
