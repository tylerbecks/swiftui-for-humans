#!/bin/zsh
# Agent hook, shared by Claude Code (.claude/settings.json) and Codex
# (.codex/hooks.json). Before an agent ends its turn, it checks what the
# agent changed:
#
#   scripts/agent-hook.sh stop
#
# - no _SnippetCheck.swift is left behind
# - project.yml changes come with the regenerated Xcode project
# - new docsURL and higURL links return 200
# - each edition whose sources changed still builds (scripts/build.sh)
#
# Exit 0 is silent; exit 2 hands stderr back to the agent.
set -uo pipefail

root=${0:A:h:h}
cd "$root"
max_lines=40

if [[ ${1:-} != stop ]]; then
    echo "Unknown mode \"${1:-}\". Use stop." >&2
    exit 2
fi

# Uncommitted paths, including deleted and untracked ones.
changed=(${(f)"$(git diff HEAD --name-only; git ls-files --others --exclude-standard)"})
(( ${#changed} )) || exit 0

failures=()
fail() { failures+=("## $1"$'\n'"$2") }

snippets=(${(f)"$(git ls-files --cached --others --exclude-standard '*_SnippetCheck.swift')"})
for f in $snippets; do
    [[ -e $f ]] && fail "leftover snippet check" "Delete $f: it breaks the unique-file-name rule."
done

if (( ${changed[(Ie)project.yml]} )) && ! (( ${changed[(Ie)SwiftUIForHumans.xcodeproj/project.pbxproj]} )); then
    fail "xcodegen" "project.yml changed but SwiftUIForHumans.xcodeproj didn't: run xcodegen generate."
fi

# Links on lines this change added, in tracked diffs and new files.
added=$(git diff HEAD -U0 -- '*.swift' | grep '^+[^+]'
        for f in $changed; do
            [[ $f == *.swift && -f $f ]] && ! git ls-files --error-unmatch "$f" &>/dev/null && cat "$f"
        done)
urls=(${(u)${(f)"$(grep -oE '(docsURL|higURL): *"https?://[^"]+"' <<< "$added" | grep -oE 'https?://[^"]+')"}})
bad=()
for url in $urls; do
    code=$(curl -sI -o /dev/null -w '%{http_code}' --max-time 10 "$url")
    # 000 means no answer (offline or sandboxed), which says nothing about the link.
    [[ $code == 200 || $code == 000 ]] || bad+=("$code $url")
done
(( ${#bad} )) && fail "links" "These must return 200 (curl -sI):"$'\n'"${(F)bad}"

# Shared code and resources go into both editions.
editions=()
for f in $changed; do
    case $f in
        SwiftUIForHumans/iOS/*) editions+=(ios) ;;
        SwiftUIForHumans/macOS/*) editions+=(mac) ;;
        SwiftUIForHumans/*|project.yml) editions+=(ios mac) ;;
    esac
done
editions=(${(u)editions})

# Skip the build when the sources haven't changed since the last one passed,
# so a turn that only talks doesn't rebuild.
built_marker=$(git rev-parse --git-path agent-hook-built)
fingerprint=$( { git diff HEAD --binary -- SwiftUIForHumans project.yml
                 git ls-files --others --exclude-standard -z -- SwiftUIForHumans | xargs -0 cat 2>/dev/null
               } | shasum | cut -d' ' -f1)
if (( ${#editions} )) && [[ $(cat "$built_marker" 2>/dev/null) != "$fingerprint" ]]; then
    build_ok=1
    for edition in $editions; do
        if ! out=$(scripts/build.sh "$edition" 2>&1); then
            build_ok=0
            errors=$(grep -E 'error:' <<< "$out" | sort -u | head -n $max_lines)
            fail "$edition build" "${errors:-$(tail -n $max_lines <<< "$out")}"
        fi
    done
    (( build_ok )) && echo "$fingerprint" > "$built_marker"
fi

# Loop guard (Claude's stop_hook_active would also skip the re-check after a
# real fix, and Codex may not send it): block again only while the failures
# change; the same ones twice end the turn.
last=$(git rev-parse --git-path agent-hook-stop)
now=${(F)failures}
if (( ${#failures} )) && [[ ! -f $last || $(<$last) != "$now" ]]; then
    print -r -- "$now" > "$last"
    print -r -- "Checks failed on your changes; fix them before finishing:"$'\n'"$now" >&2
    exit 2
fi
rm -f "$last"
exit 0
