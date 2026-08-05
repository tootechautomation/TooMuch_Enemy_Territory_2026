# Frontline: Objective

## Version 1.2.2 synchronized networking build

This build addresses the case where local visual effects work but all server-authoritative controls fail.

Godot requires matching RPC declarations on the client and server. Install this exact package on:

1. The Linux VPS server.
2. The Windows development/client copy.

The new protocol handshake displays:

```text
Connected: v1.2.2 protocol 122
```

in the HUD. A mismatched client/server pair displays an explicit version mismatch.

## Required deployment order

Stop and update the VPS first, then replace the Windows project with the same archive.

## Server

```bash
flatpak run org.godotengine.Godot --headless --path . --server --port 27960
```

## Expected server log

```text
Frontline Objective v1.2.2 protocol 122 listening on UDP 27960
Peer <id> verified: client v1.2.2 protocol 122
```

Only after the peer is verified will the server accept movement, firing, jumping, grenades, reloads, classes, abilities, and interactions.
