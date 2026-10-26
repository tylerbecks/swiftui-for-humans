#!/bin/zsh
# Builds the app:  ./build.sh ios   or   ./build.sh mac
# Builds wait their turn behind a machine-wide lock shared with other builds.
set -euo pipefail
cd "${0:A:h}"
lock=/tmp/swiftui-for-humans-build.lock
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

[[ -d EvalApp.xcodeproj ]] || xcodegen generate --quiet
common=(-project EvalApp.xcodeproj -derivedDataPath .build/DerivedData
        -jobs 4 ARCHS=arm64 CODE_SIGNING_ALLOWED=NO)
case ${1:-ios} in
    ios) xcodebuild "${common[@]}" -scheme EvalApp-iOS \
             -destination 'generic/platform=iOS Simulator' build -quiet ;;
    mac) xcodebuild "${common[@]}" -scheme EvalApp-macOS \
             -destination 'platform=macOS,arch=arm64' build -quiet ;;
    *) echo "usage: ./build.sh ios|mac" >&2; exit 64 ;;
esac
echo "Build succeeded."
