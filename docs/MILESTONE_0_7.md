# Milestone 0.7 test plan

## Server

```bash
flatpak run org.godotengine.Godot --headless --path . --server --port 27960 --bots 8
```

## Expected behavior

- Eight bots spawn across both teams.
- Engineer bots travel toward the current objective.
- Medic bots prioritize downed teammates.
- Other bots seek the nearest visible enemy.
- The bridge progresses without repeated manual key presses.
- A completed round restarts after ten seconds.
- Kills and deaths reset between rounds; XP remains for the server session.

## Known limitations

- Direct steering can make bots catch on geometry.
- No pathfinding or avoidance yet.
- Bot aim is intentionally simple.
- Bot names and difficulty are not configurable yet.
