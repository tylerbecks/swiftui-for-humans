#!/bin/zsh
# Opens the built Mac app with launch flags, saves a picture of its window,
# and quits it. The Mac's version of screenshotting a dedicated test
# simulator. Needs a Debug build (the snapshot flag is debug-only).
#
#   scripts/mac-shot.sh <output.png> [light|dark] [launch flags…]
#   scripts/mac-shot.sh /tmp/toggle.png dark -open toggle -showControls
#
# Build first with `scripts/build.sh mac`. Set APP to use another build,
# SIZE to change the window size (default 1180x820), and SETTLE to wait
# longer before the shot (default 3 seconds).
#
# The app draws its own window (see LaunchSnapshot.swift), so this needs no
# Screen Recording permission. The window does appear on screen briefly.
set -euo pipefail

root=${0:A:h:h}
app=${APP:-"$root/.build/DerivedData/Build/Products/Debug/SwiftUI for Humans.app"}
output=${1:?usage: mac-shot.sh <output.png> [light|dark] [flags…]}
appearance=${2:-light}
shift $(( $# >= 2 ? 2 : 1 ))

log=$(mktemp)
trap 'rm -f "$log"' EXIT
# Run the executable directly, so its standard output comes back here.
"$app/Contents/MacOS/SwiftUI for Humans" \
    -appearance "$appearance" -ApplePersistenceIgnoreState YES \
    -snapshot -windowSize "${SIZE:-1180x820}" -snapshotDelay "${SETTLE:-3}" "$@" \
    > "$log" 2>/dev/null &
pid=$!
# Give up after 30 seconds.
for _ in {1..60}; do
    kill -0 $pid 2>/dev/null || break
    sleep 0.5
done
kill $pid 2>/dev/null || true

if ! grep -q '^END SNAPSHOT' "$log"; then
    echo "No snapshot was saved." >&2
    exit 1
fi
sed -n '/^BEGIN SNAPSHOT$/,/^END SNAPSHOT$/p' "$log" | sed '1d;$d' | base64 -D > "$output"
echo "$output"
