# Frontline: Objective

An original, open-source prototype inspired by classic class-based objective shooters.

This project contains no Wolfenstein code, names, maps, characters, sounds, or art.

## Current prototype

- Godot 4 client and headless dedicated server
- ENet UDP multiplayer
- Automatic team assignment
- First-person movement and shooting
- Five selectable classes
- Engineer-only destructible objective
- Health, ammo, respawning, HUD, and win announcement
- Procedurally assembled gray-box map; no external assets required

## Controls

- WASD: move
- Mouse: aim
- Left mouse: fire
- Space: jump
- E: damage the objective while playing Engineer on the attacking team
- 1–5: select class
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
