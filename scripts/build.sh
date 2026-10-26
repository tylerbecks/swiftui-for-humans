#!/bin/zsh
# Builds or tests the app, one build at a time across every checkout and
# worktree on this machine, so parallel agents don't bog it down.
#
#   scripts/build.sh ios         build the iOS app for the simulator
#   scripts/build.sh test-ios    run the tests on the iOS test simulator
#   scripts/build.sh mac         build the Mac app
#   scripts/build.sh test-mac    run the tests on this Mac (no simulator)
#
# Set SIMULATOR to a simulator name or udid for test-ios. Without it, the
# tests run on Catalog-laneb-iPhone (a dedicated test simulator) if this
# Mac has one, and otherwise on the first available iPhone simulator.
# Products land in .build/DerivedData inside this checkout.
#
# Anything after the action is passed to xcodebuild as extra build settings.
# CI uses this to build without a signing certificate:
#   scripts/build.sh test-mac CODE_SIGNING_ALLOWED=NO
set -euo pipefail

root=${0:A:h:h}
action=${1:-ios}
(( $# )) && shift
extra=("$@")
derived="$root/.build/DerivedData"
lock=/tmp/swiftui-for-humans-build.lock

# Take the machine-wide lock. A lock left by a process that no longer
# exists is stale and gets cleared, and so is one that never got its pid
# (killed between mkdir and writing it) once it's a few seconds old.
until mkdir "$lock" 2>/dev/null; do
    owner=$(cat "$lock/pid" 2>/dev/null || true)
    created=$(stat -f %m "$lock" 2>/dev/null || date +%s)
    if { [[ -n $owner ]] && ! kill -0 "$owner" 2>/dev/null; } ||
       { [[ -z $owner ]] && (( $(date +%s) - created > 10 )); }; then
        rm -rf "$lock"
        continue
    fi
    echo "Waiting for another build (pid ${owner:-?})…" >&2
    sleep 5
done
echo $$ > "$lock/pid"
trap 'rm -rf "$lock"' EXIT

cd "$root"
[[ -d SwiftUIForHumans.xcodeproj ]] || xcodegen generate --quiet

common=(-project SwiftUIForHumans.xcodeproj -derivedDataPath "$derived" -jobs 4 ARCHS=arm64 "${extra[@]}")

case $action in
    ios)
        xcodebuild "${common[@]}" -scheme "SwiftUI for Humans" \
            -destination 'generic/platform=iOS Simulator' build -quiet
        echo "$derived/Build/Products/Debug-iphonesimulator/SwiftUI for Humans.app"
        ;;
    test-ios)
        available=$(xcrun simctl list devices available)
        if [[ -n ${SIMULATOR:-} ]]; then
            simulator=$SIMULATOR
        elif grep -q "Catalog-laneb-iPhone (" <<< "$available"; then
            simulator=Catalog-laneb-iPhone
        else
            simulator=$(grep -m1 -E '^ +iPhone' <<< "$available" | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')
        fi
        if [[ -z $simulator ]]; then
            echo "No iPhone simulator found. Create one in Xcode, or set SIMULATOR." >&2
            exit 1
        fi
        [[ $simulator == *-*-*-*-* ]] && key=id || key=name
        xcodebuild "${common[@]}" -scheme "SwiftUI for Humans" \
            -destination "platform=iOS Simulator,$key=$simulator" test -quiet
        ;;
    mac)
        xcodebuild "${common[@]}" -scheme "SwiftUI for Humans (Mac)" \
            -destination 'platform=macOS,arch=arm64' build -quiet
        echo "$derived/Build/Products/Debug/SwiftUI for Humans.app"
        ;;
    test-mac)
        xcodebuild "${common[@]}" -scheme "SwiftUI for Humans (Mac)" \
            -destination 'platform=macOS,arch=arm64' test -quiet
        ;;
    *)
        echo "usage: scripts/build.sh ios|test-ios|mac|test-mac [SETTING=value ...]" >&2
        exit 64
        ;;
esac
