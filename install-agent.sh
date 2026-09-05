#!/usr/bin/env bash
# Install the agent that drains the write queue.
#
# There is no launchd trigger for "the screen was unlocked", so the agent simply
# runs on an interval and on any change to the queue directory. While the screen
# is locked `flush` costs one ioreg call and exits, so a minute is cheap; the
# queue drains within a minute of the Mac becoming usable again.
set -euo pipefail
LABEL="systems.focused.foodnoms-flush"
BIN="${1:-$HOME/.local/bin/foodnoms}"
PENDING="${FOODNOMS_SPOOL:-$HOME/.local/state/foodnoms/queue}/pending"
LOG="$HOME/Library/Logs/foodnoms-flush.log"
DST="$HOME/Library/LaunchAgents/$LABEL.plist"
SRC="$(cd "$(dirname "$0")" && pwd)/$LABEL.plist"

[ -x "$BIN" ] || { echo "not executable: $BIN — run ./install.sh first"; exit 1; }
mkdir -p "$PENDING" "$(dirname "$LOG")" "$(dirname "$DST")"

sed -e "s|__FOODNOMS__|$BIN|" -e "s|__PENDING__|$PENDING|" -e "s|__LOG__|$LOG|" \
    "$SRC" > "$DST"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$DST"
launchctl enable "gui/$(id -u)/$LABEL"
echo "loaded $LABEL"
echo "log: $LOG"
