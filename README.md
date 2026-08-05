# Frontline: Objective

## Version 2.3.1 parser correction

This release corrects the `main_node` scope errors introduced in v2.3.0.

Fixed:

- `server_fire()` now declares `main_node` before sending shot effects.
- `_server_bot_fire()` now has only one `main_node` declaration.
- Tactical combat, assists, damage numbers, fall damage, grenade warnings,
  objective direction, kill streaks, and bot skill remain included.

Install the same package on the Linux server and Windows client.

Expected HUD:

```text
Connected: v2.3.1 protocol 231
```
