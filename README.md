# Frontline: Objective

## Version 1.4.4 authoritative snapshot fix

The input acknowledgement proved commands reached the VPS. This build fixes the server-to-client state return path.

Changes:

- `main.gd` now broadcasts every player snapshot centrally at 20 Hz.
- Player nodes no longer attempt to originate their own snapshot RPCs.
- Movement, ammunition, reload state, grenade inventory, team, class, health, and position all use one authoritative broadcast.
- Fire and grenade origins are now calculated on the server from the player's Head node.
- Client-supplied camera position is no longer used as a rejection condition.
- HUD displays authoritative position and ammo beside the input acknowledgement.

Expected:

```text
Connected: v1.4.4 protocol 144 · input ack 1234 · pos -8.2,1.5 · ammo 27
```

Pressing WASD should change `pos`. Shooting should reduce `ammo`.
