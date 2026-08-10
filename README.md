FRONTLINE: OBJECTIVE v17.0.0
BATTLEFIELD OPERATIONS / DYNAMIC TEAM MISSIONS
Network Protocol 359

MAJOR PHASE
- Adds server-authoritative Battlefield Operations above the existing Frontline Director.
- Teams periodically receive short, state-driven missions based on the live battlefield.
- Operations use existing sectors and the Supply Depot; no map geometry or spawn changes.

DYNAMIC OPERATIONS
- FIGHT FOR: resolves a currently contested sector.
- ASSAULT: captures a sector not controlled by the team.
- SECURE: captures the Supply Depot when logistics are not under team control.
- HOLD: maintains control of a frontline sector when the team already owns the field.
- Mission selection is derived from sector/depot state rather than random world placement.

TEAMPLAY / REWARDS
- Successful operations award a restrained +2 team tickets.
- Living teammates physically supporting the operation area receive +7 XP.
- 20m contribution radius prevents passive map-wide XP farming.
- Operations expire after 32 seconds and recur on a controlled cadence.

HUD / NETWORKING
- Active operation is appended to the existing objective compass as OP <mission>.
- Start/completion/expiration use existing team callout presentation.
- Operation state is reliable-RPC synchronized.
- Late joiners receive the currently active operation and remaining duration.
- Server remains authoritative for mission choice, success, XP and ticket rewards.

PRESERVATION / REGRESSION GUARDS
- Environment freeze maintained: no map geometry edits.
- No spawn coordinate or deployment-path changes.
- No vehicle, weapon, grenade, class deployable, objective, or imported asset removal.
- v13 Frontline Director preserved.
- v14 Class Warfare / deployables preserved.
- v15 Squad Command / Tactical Orders preserved.
- v16 Combined Arms / vehicle designations and logistics preserved.
- Bot-disable CLI forms remain supported: --bots 0, --bots=0, --no-bots.

TEST FOCUS
1. Wait ~15 seconds after active play begins for first operations.
2. Confirm each team receives a mission based on current sector state.
3. Complete an ASSAULT/FIGHT FOR operation and verify +2 tickets.
4. Confirm only teammates near the operation receive operation XP.
5. Capture/hold Supply Depot and verify SECURE logic when selected.
6. Let an operation expire and confirm it cleans up without stale HUD state.
7. Join a running match during an operation and verify late-join HUD sync.
8. Regression-test v14 deployables, v15 orders, v16 anti-armor designations.
9. Verify safe initial human deployment remains unchanged.
10. Verify --bots 0 / --bots=0 / --no-bots still disable bots.
