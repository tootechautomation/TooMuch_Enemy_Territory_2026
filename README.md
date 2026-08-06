# Frontline: Objective

## Version 4.6.0 First-Person & HUD Overhaul

### True first-person presentation
- The local player's helmet, head, torso, legs, backpack, and class accent are hidden.
- Only the imported weapon, sleeves, hands, and arms remain visible.
- Other players and bots still render their complete third-person character.
- Local body hiding is reapplied after snapshots, respawns, class changes, and every local frame.

### Original ET-inspired HUD
The HUD has been rebuilt into a compact WWII objective-shooter layout:
- Center-top match timer, tickets, and current objective.
- Bottom-left team, class, health, stamina, stance, rank, and XP.
- Bottom-right weapon, magazine, reserve ammunition, grenades, and smoke.
- Center-bottom life state, sector control, and class ability.
- Circular-style centered crosshair.
- Existing kill feed, objective progress, damage feedback, radar, and scope systems remain.

### TAB results screen
- Large framed results panel.
- Separate Attackers and Defenders sections.
- Class, kills, deaths, assists, objective score, XP, and rank.
- Current objective, tickets, sector control, round awards, build, and protocol.
- The normal combat HUD hides while TAB is held.

### Compatibility
- Build: v4.6.0
- Protocol: 341
- Explicit connection-message `+` retained.
- Existing combat, bots, objectives, destruction, assets, and networking remain.

Expected status: `Connected: v4.6.0 protocol 341`
