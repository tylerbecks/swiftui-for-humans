#!/bin/zsh
# Exports every page's text as JSON, one file per edition:
#
#   scripts/export-catalog.sh          agent/build/ios.json and macos.json
#   scripts/export-catalog.sh ios      only the iOS edition
#   scripts/export-catalog.sh mac      only the Mac edition
#   scripts/export-catalog.sh mac-results
#                                      copy macos.json out of the newest Mac
#                                      test results, without running the tests
#                                      (CI's fallback after its own test-mac)
#
# It runs each edition's tests through scripts/build.sh (so it waits its
# turn for the build lock) with SFH_EXPORT_DIR set, which makes
# ExportCatalogTests write `<edition>.json`. xcodebuild hands its
# TEST_RUNNER_<NAME> variables to the tests as <NAME>.
#
# The Mac app is sandboxed, so its tests can't write to agent/build/.
# They attach macos.json to the test results instead, and this script
# copies it out with xcresulttool. Needs jq.
set -euo pipefail

root=${0:A:h:h}
out="$root/agent/build"
which=${1:-all}
mkdir -p "$out"

export_ios() {
    rm -f "$out/ios.json"
    TEST_RUNNER_SFH_EXPORT_DIR="$out" "$root/scripts/build.sh" test-ios
    [[ -s $out/ios.json ]] || { echo "The iOS tests didn't write $out/ios.json." >&2; exit 1; }
}

export_mac() {
    rm -f "$out/macos.json"
    TEST_RUNNER_SFH_EXPORT_DIR="$out" "$root/scripts/build.sh" test-mac
    [[ -s $out/macos.json ]] || copy_mac_attachment
}

# Sandboxed: the file is attached to the newest Mac test results.
copy_mac_attachment() {
    local results=( "$root/.build/DerivedData/Logs/Test/"*"(Mac)"*.xcresult(Nom[1]) )
    [[ -n ${results[1]:-} ]] || { echo "No Mac test results found." >&2; exit 1; }
    local attachments
    attachments=$(mktemp -d)
    xcrun xcresulttool export attachments --path "$results[1]" --output-path "$attachments" \
        --test-id "ExportCatalogTests/everyPageExportsItsText()" > /dev/null
    local file
    file=$(jq -r '[.[].attachments[] | select(.suggestedHumanReadableName | startswith("macos"))][0].exportedFileName // empty' "$attachments/manifest.json")
    [[ -n $file ]] || { echo "The Mac tests didn't attach macos.json." >&2; exit 1; }
    cp "$attachments/$file" "$out/macos.json"
    rm -rf "$attachments"
}

case $which in
    all) export_ios; export_mac ;;
    ios) export_ios ;;
    mac) export_mac ;;
    mac-results) copy_mac_attachment ;;
    *)
        echo "usage: scripts/export-catalog.sh [ios|mac|mac-results]" >&2
        exit 64
        ;;
esac

for file in "$out"/ios.json "$out"/macos.json; do
    [[ -f $file ]] || continue
    echo "$file: $(jq '.pages | length' "$file") pages, $(du -h "$file" | cut -f1 | tr -d ' ')"
done
