# Frontline: Objective

## Version 4.9.0 Presentation & Character Clarity

### End-of-round presentation
- Replaced overlapping victory labels with one reusable announcement banner.
- Rebuilt the round-results screen as a centered, dimmed overlay.
- The normal HUD, compass, kill feed, and TAB scoreboard hide during results.
- TAB can no longer open a second scoreboard over the final results.
- Added a clean live round-restart countdown.
- Reduced the final results content to fit the available viewport.

### World-label cleanup
- Teammate names, class labels, revive markers, and spotted markers scale with
  world distance.
- Reduced label font and outline sizes.
- Reduced teammate-name visibility to close combat distances.
- Reduced class-label and spotted-enemy ranges.
- Enabled normal depth testing for spotted markers.

### Scoreboard improvements
- Narrower framed panel.
- Smaller, more readable typography.
- Better fit at 1280x720 while retaining responsive HUD scaling.
- Separate Attackers and Defenders sections remain.

### Character clarity
- Third-person materials use more subdued, rough WWII uniform surfaces.
- Existing team colors and class accents remain readable without appearing
  fluorescent.
- Existing locomotion, crouch, gear movement, and first-person body hiding remain.

### Compatibility
- Build: v4.9.0
- Protocol: 341
- Explicit connection-message `+` retained.

Expected status: `Connected: v4.9.0 protocol 341`
