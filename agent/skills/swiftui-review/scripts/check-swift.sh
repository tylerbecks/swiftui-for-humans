#!/bin/sh
# Lints Swift files for outdated SwiftUI APIs and HIG smells, using the rules in
# corrections.yaml. Needs only python3. Run with --help for options.
#
#   check-swift.sh Sources/            path:line: id — message (exit 1 on findings)
#   check-swift.sh --json Sources/     the same as JSON
#   check-swift.sh --self-test         every rule against its own examples
exec python3 "$(dirname "$0")/check_swift.py" "$@"
