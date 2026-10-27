#!/bin/zsh
# Builds the app:  ./build.sh ios   or   ./build.sh mac
# The eval harness runs the build outside the agent's sandbox (xcodebuild needs
# system services the sandbox blocks) and hands back its output and exit code.
# Builds wait their turn behind a machine-wide lock shared with other builds.
set -euo pipefail
cd "${0:A:h}"
platform=${1:-ios}
case $platform in
    ios|mac) ;;
    *) echo "usage: ./build.sh ios|mac" >&2; exit 64 ;;
esac
dir=.build/requests
if [[ ! -f $dir/broker ]]; then
    echo "build.sh: no build service is running (the eval harness provides one)" >&2
    exit 69
fi
id=$$-$RANDOM
print -r -- $platform > $dir/$id.tmp
mv $dir/$id.tmp $dir/$id.req
until [[ -f $dir/$id.done ]]; do sleep 1; done
cat $dir/$id.out
code=$(<$dir/$id.done)
rm -f $dir/$id.*
exit $code
