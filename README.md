# Frontline: Objective

## Version 4.7.0 Character Animation & HUD Polish

### Third-person animation
- Added synchronized arm and leg stride animation.
- Added speed-dependent walk and sprint motion.
- Added crouch lowering and body bob.
- Added subtle backpack, head, helmet, and class-gear movement.
- Remote players and bots now have clearer locomotion instead of sliding.

### Circular field compass
- Replaced the square text radar frame with an original circular compass.
- Added cardinal directions and compass ticks.
- Moved the radar to the upper-right corner.
- Existing teammate, spotted enemy, grenade, and objective markers remain.
- Added live heading and objective distance below the primary objective panel.

### HUD polish
- Repositioned and restyled the kill feed.
- Added shadowed HUD typography.
- Improved TAB scoreboard readability.
- Retained the compact health, stamina, rank, weapon, ammunition, and objective layout.
- The local third-person body remains hidden in first person.

### Compatibility
- Build: v4.7.0
- Protocol: 341
- Explicit connection-message `+` retained.
- Existing objectives, destruction, bots, assets, and networking remain.

Expected status: `Connected: v4.7.0 protocol 341`
