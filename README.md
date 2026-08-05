# Frontline: Objective

## Version 3.4.3 connection recovery

This release fixes the gray-screen and failed-connection regression.

### Fixed

- Restored the original networking lifecycle from v3.4.1.
- Kept network protocol 341 for compatibility with an existing v3.4.1 server.
- The connection menu is no longer hidden when Join is clicked.
- The menu hides only after a successful connection.
- Failed connections restore the menu and re-enable the Join button.
- Server disconnects also restore the connection menu.
- Failed peers are closed and cleared before retrying.
- Offline guards are limited to autonomous world entities.
- Main connection callbacks and protocol verification are no longer guarded out.
- Emplacements, smoke and sensor beacons remain dormant in offline preview.

Expected client build:

```text
v3.4.3
```

Expected compatible protocol:

```text
341
```

This client can connect to a server running v3.4.1 protocol 341, but updating
both client and server with this package is recommended.
