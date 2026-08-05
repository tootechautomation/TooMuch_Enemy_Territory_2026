# Frontline: Objective

## Version 1.4.3 remote-sender command fix

The server no longer trusts or depends on a player ID supplied by the client.

For every gameplay RPC, the server now:

1. Reads `multiplayer.get_remote_sender_id()`.
2. Finds the player belonging to that connection.
3. Dispatches movement, firing, reload, grenade, menu, class, and interaction commands to that player.

The client also uses `multiplayer.get_unique_id()` when constructing requests.

The HUD includes an input acknowledgement counter:

```text
Connected: v1.4.3 protocol 143 · input ack 1234
```

The number should increase continuously after deployment. Install the same package on Windows and Linux.
