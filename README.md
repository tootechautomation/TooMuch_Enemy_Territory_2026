FRONTLINE: OBJECTIVE v9.13.1 HOTFIX

Fixes player.gd parser error near line 1749 introduced by v9.13.0 tracer integration.
The tracer call had accidentally been inserted between an if statement and its required indented body.

The corrected flow is:
1. Resolve shot/hit.
2. Broadcast combat tracer when supported.
3. Broadcast existing show_shot_effect when supported.

No gameplay systems were intentionally removed.
Protocol remains 341.
