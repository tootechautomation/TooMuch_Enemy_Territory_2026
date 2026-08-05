# Frontline: Objective

## Version 1.4.1 deployment-menu correction

Fixed:

- The deployment menu no longer disappears on the first live snapshot.
- The menu cannot close until the first Deploy action.
- M is polled directly every frame and reliably reopens the menu.
- The M input action is stored inside Godot's `[input]` section.
- Team is now included in replicated player snapshots.
- Client HUD receives the authoritative team and class from the server.
- The menu displays the currently selected team and class before deployment.

Install the exact same package on both Windows and Linux.

Expected HUD:

```text
Connected: v1.4.1 protocol 141
```
