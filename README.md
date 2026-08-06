# Frontline: Objective

## Version 5.9.0 Squad Coordination & Combat Orders

### Persistent squads
Bots are grouped into four-member squads. Each squad has:
- Stable squad membership derived from peer ID
- A living squad leader
- Shared enemy contacts
- Shared attack or defense orders
- Formation offsets around the leader or engineer

### Class coordination
- Soldiers escort engineers and squad leaders.
- Medics stay closer to engineers and wounded teammates.
- Field Ops hold wider support spacing.
- Engineers remain free to interact directly with objectives.
- Scouts retain their independent long-range anchors.

### Shared enemy contacts
When one bot sees an enemy, the contact is shared with its squad for 2.8
seconds. Target scoring penalizes enemies already claimed by many bots, which
reduces the tendency for every bot to chase one target.

### Combat orders
Orders update with the match state:
- Build and secure bridge
- Hold bridge approaches
- Capture command post
- Protect dynamite
- Defuse dynamite
- Breach bunker
- Defend bunker

The local HUD now displays the active team order beside the available routes.

### Compatibility
- Build: v5.9.0
- Protocol: 341
- Explicit connection-message `+` retained
- v5.8 tactical-director refactor retained
- Cache-independent VPS startup retained

Expected status: `Connected: v5.9.0 protocol 341`
