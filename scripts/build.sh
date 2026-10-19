#!/bin/zsh
# Builds or tests the app, one build at a time across every checkout and
# worktree on this machine, so parallel agents don't bog it down.
#
#   scripts/build.sh ios         build the iOS app for the simulator
#   scripts/build.sh test-ios    run the tests on the iOS test simulator
#   scripts/build.sh mac         build the Mac app
#   scripts/build.sh test-mac    run the tests on this Mac (no simulator)
#
# Set SIMULATOR to a simulator name or udid for test-ios (default:
# Catalog-laneb-iPhone, a dedicated test simulator). Products land in
# .build/DerivedData inside this checkout.
set -euo pipefail

root=${0:A:h:h}
action=${1:-ios}
derived="$root/.build/DerivedData"
lock=/tmp/swiftui-for-humans-build.lock

# Take the machine-wide lock. A lock left by a process that no longer
# exists is stale and gets cleared.
until mkdir "$lock" 2>/dev/null; do
    owner=$(cat "$lock/pid" 2>/dev/null || true)
    if [[ -n $owner ]] && ! kill -0 "$owner" 2>/dev/null; then
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

common=(-project SwiftUIForHumans.xcodeproj -derivedDataPath "$derived" -jobs 4 ARCHS=arm64)

case $action in
    ios)
        xcodebuild "${common[@]}" -scheme "SwiftUI for Humans" \
            -destination 'generic/platform=iOS Simulator' build -quiet
        echo "$derived/Build/Products/Debug-iphonesimulator/SwiftUI for Humans.app"
        ;;
    test-ios)
        simulator=${SIMULATOR:-Catalog-laneb-iPhone}
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
        echo "usage: scripts/build.sh ios|test-ios|mac|test-mac" >&2
        exit 64
        ;;
esac
