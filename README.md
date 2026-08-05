# Frontline: Objective

An original Godot 4 class-based objective shooter prototype. It contains no Wolfenstein game data, maps, branding, characters, sounds, or artwork.

## Version 0.3 highlights

- Server-authoritative movement, firing, damage, reloads, objectives, and respawns
- Sprint and crouch movement
- Modular weapon resources
- Magazine and reserve ammunition
- Timed reloading, weapon spread, damage, range, and rate of fire
- Interpolated remote-player snapshots
- Five classes, spawn waves, match timer, and engineer objective

## Controls

- WASD: move
- Shift: sprint
- C: crouch
- Space: jump
- Mouse: aim
- Left mouse: fire
- R: reload
- E: engineer objective action
- 1–5: choose class
- Escape: release mouse

## Run locally

Install Godot 4.3 or newer.

Host:

```bash
godot --path . --server --port 27960
```

Client:

```bash
godot --path . --connect 127.0.0.1 --port 27960
```

You can also launch the project normally and enter a server IP in the menu.

## Export a Linux server

In Godot:

1. Open `project.godot`.
2. Install export templates if prompted.
3. Create a Linux export preset.
4. Enable **Export as dedicated server**.
5. Export as `frontline_server.x86_64`.

Run:

```bash
chmod +x frontline_server.x86_64
./frontline_server.x86_64 --headless --server --port 27960
```

Open UDP port 27960 in the VPS firewall.

## Ubuntu VPS example

```bash
sudo ufw allow 27960/udp
sudo mkdir -p /opt/frontline
sudo cp frontline_server.x86_64 /opt/frontline/
sudo chmod +x /opt/frontline/frontline_server.x86_64
sudo cp deploy/frontline.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now frontline
sudo systemctl status frontline
```

Edit the service file if your executable has a different name.

## Important architecture note

This first prototype uses client-authoritative movement to keep the code easy to understand. Before public deployment, movement, shooting, cooldowns, and objective interactions should be validated server-side and protected with rate limits.

## Recommended next milestones

1. Server-authoritative movement and lag compensation
2. Spawn waves and spawn selection
3. Revive, ammo packs, med packs, and class abilities
4. Constructible and dynamite objectives
5. Match timer, campaign XP, scoreboard, and map rotation
6. Original character, weapon, audio, UI, and map assets

## Version 0.2 authoritative prototype

The server now controls movement, hit detection, health, deaths, objective damage, and wave respawns. Clients submit input and render replicated state. This is a foundation for further prediction and lag compensation, not a finished anti-cheat implementation.

Validate the project on a Linux machine with either a native or Flatpak Godot installation:

```bash
./tools/validate_project.sh
```

Run the VPS server:

```bash
flatpak run org.godotengine.Godot --headless --path . --server --port 27960
```
