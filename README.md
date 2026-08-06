# Frontline: Objective

## Version 3.7.1 Tactical Operations declaration fix

Fixed the parser errors introduced in v3.7.0:

- Declared `rally_cooldown_until_ms`.
- Declared `mission_banner`.
- Preserved the explicit `+` in the connection failure message.
- Preserved all supply-depot, rally-point, tactical AI, and mission-banner
  features.
- Preserved network protocol 341.

Expected status:

```text
Connected: v3.7.1 protocol 341
```
