#!/usr/bin/env bash
set -euo pipefail

GODOT_CMD=(godot)
if command -v flatpak >/dev/null 2>&1 && flatpak info org.godotengine.Godot >/dev/null 2>&1; then
  GODOT_CMD=(flatpak run org.godotengine.Godot)
fi

"${GODOT_CMD[@]}" --headless --path "$(cd "$(dirname "$0")/.." && pwd)" --editor --quit-after 3
