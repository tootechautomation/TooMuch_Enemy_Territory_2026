#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-$(pwd)}"
cd "$PROJECT_DIR"

# Imported assets are platform/cache-specific. Never copy a stale .godot cache
# between Windows and Linux.
rm -rf .godot

flatpak run org.godotengine.Godot   --headless   --path .   --editor   --quit-after 10
