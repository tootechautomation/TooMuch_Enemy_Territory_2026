#!/usr/bin/env bash
set -euo pipefail

BINARY="${1:-frontline_server.x86_64}"
INSTALL_DIR="/opt/frontline"
SERVICE_USER="frontline"

if [[ ! -f "$BINARY" ]]; then
  echo "Missing server binary: $BINARY"
  exit 1
fi

sudo useradd --system --home "$INSTALL_DIR" --shell /usr/sbin/nologin "$SERVICE_USER" 2>/dev/null || true
sudo mkdir -p "$INSTALL_DIR"
sudo cp "$BINARY" "$INSTALL_DIR/frontline_server.x86_64"
sudo chmod 0755 "$INSTALL_DIR/frontline_server.x86_64"
sudo chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR"
sudo cp "$(dirname "$0")/frontline.service" /etc/systemd/system/frontline.service
sudo ufw allow 27960/udp || true
sudo systemctl daemon-reload
sudo systemctl enable --now frontline
sudo systemctl status frontline --no-pager
