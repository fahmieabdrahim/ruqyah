#!/bin/bash
set -euo pipefail

APP_DIR="$HOME/.local/share/ruqyah"
AGENT_DIR="$HOME/Library/LaunchAgents"
SCRIPT_URL="https://raw.githubusercontent.com/fahmieabdrahim/ruqyah/main/ruqyah.sh"
PLIST="$AGENT_DIR/com.fahmie.ruqyah.plist"
LABEL="com.fahmie.ruqyah"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Ruqyah hanya menyokong macOS."
  exit 1
fi

command -v curl >/dev/null || { echo "curl tidak ditemui."; exit 1; }
command -v afplay >/dev/null || { echo "afplay tidak ditemui."; exit 1; }

mkdir -p "$APP_DIR" "$AGENT_DIR"
echo "Memasang pemain Ruqyah..."
curl -fsSL "$SCRIPT_URL" -o "$APP_DIR/ruqyah.sh"
chmod 700 "$APP_DIR/ruqyah.sh"

cat > "$PLIST" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$APP_DIR/ruqyah.sh</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>14</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>$HOME/Library/Logs/Ruqyah.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/Ruqyah-error.log</string>
</dict>
</plist>
PLIST_EOF

plutil -lint "$PLIST" >/dev/null
launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo
echo "Ruqyah berjaya dipasang."
echo "Auto-play: semasa log masuk dan setiap hari pada 2:00 petang."
echo "Log: $HOME/Library/Logs/Ruqyah.log"
echo "Pemain akan bermula selepas pemasangan."
