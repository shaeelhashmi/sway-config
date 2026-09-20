#!/bin/bash
dir="$HOME/Videos"
base="${1:-record}"
mkdir -p "$dir"

# Pick the first free number: record1.mp4, record2.mp4, ...
n=1
while [ -e "$dir/$base$n.mp4" ]; do
    n=$((n + 1))
done
FILE="$dir/$base$n.mp4"

# Select region; abort quietly if cancelled
geometry=$(slurp) || exit 1

wf-recorder -g "$geometry" -f "$FILE" &
REC_PID=$!

# "Recording started" notification with a Stop button (never auto-expires)
NOTIF_ID=$(gdbus call --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.Notify \
  "screen-recorder" 0 "media-record" \
  "Screen recording started" "Saving to $FILE" \
  "['stop', 'Stop Recording']" \
  '{"urgency": <byte 1>}' \
  0 2>/dev/null \
  | grep -oP "uint32 \K[0-9]+")

# Watch for the Stop button click in the background
watch_notification() {
    gdbus monitor --session \
      --dest org.freedesktop.Notifications \
      --object-path /org/freedesktop/Notifications 2>/dev/null \
      | while IFS= read -r line; do
          if echo "$line" | grep -q "ActionInvoked.*$NOTIF_ID"; then
              kill -INT "$REC_PID" 2>/dev/null
              break
          fi
          if echo "$line" | grep -q "NotificationClosed.*$NOTIF_ID"; then
              break
          fi
      done
}
watch_notification &
MON_PID=$!

# Block until the recording ends (button, keybinding, or Ctrl+C)
wait "$REC_PID"

# Clean up the watcher and close the "started" notification
pkill -P "$MON_PID" 2>/dev/null
kill "$MON_PID" 2>/dev/null
gdbus call --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.CloseNotification \
  "$NOTIF_ID" >/dev/null 2>&1

notify-send -a screen-recorder "Screen recording saved" "$FILE"