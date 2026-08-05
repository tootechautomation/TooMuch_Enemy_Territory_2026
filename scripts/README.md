# Frontline: Objective

## Version 1.3.0 permanent command routing

All client gameplay commands now travel through the permanent `/Main` node:

- Movement and jumping
- Firing
- Reloading
- Grenades
- Weapon switching
- Interactions
- Class abilities
- Class selection

The server validates that the RPC sender ID matches the requested player ID, then dispatches the command locally to that player object.

This removes dependence on temporary `/Main/<player-id>` RPC paths.

Install this exact package on both the Linux VPS and Windows client.

Expected HUD:

```text
Connected: v1.3.0 protocol 130
```

Expected VPS log after input begins:

```text
Accepted gameplay input from peer <id> (Player<id>)
```
