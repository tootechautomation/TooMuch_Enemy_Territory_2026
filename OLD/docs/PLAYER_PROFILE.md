# Persistent Player Profile

The client stores settings at:

```text
user://frontline_profile.cfg
```

The exact operating-system location is managed by Godot. The profile follows
the game installation/user account and is sent to every compatible server when
the connection protocol is verified.

Saved fields:

- Player name
- Preferred team
- Preferred class
- Mouse sensitivity
- Field of view
- HUD scale
- Master volume
- Effects volume
- Music volume
- Last server address
- Last server port

Controls:

- `F8`: open Player Profile & Settings
- `Escape`: close the profile panel
- Connection screen: edit the name before joining

Names are restricted to 2–20 safe characters. Servers resolve exact duplicate
names by adding a numeric suffix.
