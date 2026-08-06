# Frontline: Objective

## Version 7.4.0 Persistent Player Profile & Cross-Server Settings

### Custom player names
The connection screen now includes a player-name field. The server validates
the name and synchronizes it to scoreboards, kill feeds, HUD labels and other
clients.

The generated `Player########` name remains only as a brief connection
fallback until the verified profile arrives.

### Persistent settings
Profiles are stored locally in:

```text
user://frontline_profile.cfg
```

The same profile is used automatically across compatible servers.

Saved:
- Player name
- Preferred team and class
- Mouse sensitivity
- Field of view
- HUD scale
- Master, effects and music volume
- Last server IP and port

### Settings panel
Press `F8` before joining or during play to open the settings panel. Changes
apply immediately and are saved for future sessions.

### Server safety
Player names are sanitized to 2–20 characters. Exact duplicate names receive a
numeric suffix. Clients cannot rename another peer because the server uses the
actual RPC sender ID.

### Compatibility
- Build: v7.4.0
- Protocol: 341
- Explicit connection-message `+` retained
- Existing servers require the matching v7.4 client build

Expected status: `Connected: v7.4.0 protocol 341`
