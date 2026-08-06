#!/usr/bin/env python3
from pathlib import Path
import json

root = Path(__file__).resolve().parents[1]
manifest_path = root / "assets/external/asset_manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

print("Frontline external asset verification")
print("=" * 40)

missing = []
for relative, details in manifest["slots"].items():
    path = root / "assets/external" / relative
    status = "FOUND" if path.exists() else "MISSING"
    print(f"{status:7} {relative} — {details['purpose']}")
    if details.get("required") and not path.exists():
        missing.append(relative)

print()
if missing:
    print("Required assets missing:")
    for item in missing:
        print(f"  - {item}")
    raise SystemExit(1)

print("All required asset slots are satisfied.")
print("Optional missing assets will use procedural fallbacks.")
