# Frontline: Objective

## Version 1.2.6 gameplay RPC fix

This build fixes the state where snapshots and the HUD work, but movement, shooting, jumping, reloading, and grenades do not.

Cause: the server accepted the client connection but rejected every gameplay RPC through an overly strict protocol-verification gate.

Fix:

- Gameplay RPCs now require the correct remote sender ID.
- The handshake remains available for version diagnostics.
- The handshake is no longer a second hard gate on every input packet.
- Server logs the first accepted gameplay input from each player.

Install this exact package on both server and client.

Expected HUD:

```text
Connected: v1.2.6 protocol 126
```

Expected server log after the client enters the match:

```text
Accepted gameplay input from peer <id> (Player<id>)
```
