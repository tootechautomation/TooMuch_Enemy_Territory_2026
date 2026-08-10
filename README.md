Frontline: Objective v9.18.1

Fixes the v9.18 environment pass preload/parser failure shown in Godot.

The new environment cohesion script has been rewritten conservatively to avoid
the parser/type-inference patterns that prevented Godot from resolving the
preloaded script.

Preserved:
- v9.18 environment/street detail concept
- v9.17 first-person visibility fixes
- vehicles and aircraft
- F6/F8
- --bots 0 / --bots=0 / --no-bots
- protocol 341

Build 9.18.1
