# Frontline: Objective

## Version 1.2.4 snapshot-routing fix

This build fixes repeated errors such as:

```text
Node not found: Main/<player-id>
Invalid packet received. Requested node was not found.
```

High-frequency player snapshots no longer originate from temporary player-node RPC paths. They now travel through the permanent `/Main` node. If a snapshot arrives before its reliable spawn packet, it is safely discarded and the next snapshot is applied.

Install this exact package on both the Linux server and Windows client.

Expected HUD:

```text
Connected: v1.2.4 protocol 124
```
