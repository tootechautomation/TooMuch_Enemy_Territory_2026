# Frontline: Objective

## Version 3.8.0 Match Flow & Progression

### Session progression
- XP and rank now persist between rounds during the current server session.
- Added Major rank at 600 XP.
- The HUD displays current rank and progress toward the next rank.
- Each rank grants +2 maximum health and +8 reserve ammunition.
- Bonuses remain server-authoritative.

### Expanded combat statistics
- Added assist tracking.
- Added objective-score tracking.
- Added round XP separate from total session XP.
- Objective score is earned from revives, fortification, rally deployment,
  artillery, bridge work, command-post actions, and supply-depot actions.

### Round awards
The end-of-round screen now calculates:
- MVP
- Top Fragger
- Support award
- Objective Specialist
- Survivor

### Scoreboard
The scoreboard now includes:
- Kills
- Deaths
- Assists
- Objective score
- Round XP
- Total XP
- Rank
- Human/bot status
- Command-post and supply-depot ownership

### Match flow
- Per-round combat statistics reset between rounds.
- Session XP and rank remain.
- Network protocol remains 341.
- The connection error string retains explicit `+` concatenation.

Expected status: `Connected: v3.8.0 protocol 341`
