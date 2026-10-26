# Agent-only sources

Hand-written content for the agent pack that doesn't come from the app's pages. The generator copies it into the skills, the primer, and the website.

| File | What it is |
|---|---|
| `corrections.yaml` | Outdated SwiftUI → current SwiftUI, with why, minimum OS, a lint regex, and examples. Feeds the primer, the skills' top rules, the linter, and `topics/deprecated-apis.md`. |
| `topics/*.md` | Agent-only topics: `liquid-glass`, `whats-new-26`, `whats-new-27`, `deprecated-apis` (generated), `review-checklist`, `hig-decisions`. Terse, imperative, at most about 1,500 tokens each. |
| `check-swift.sh`, `check_swift.py` | The linter shipped inside the review skill. Reads `corrections.yaml` plus built-in HIG checks. Python 3 standard library only. |
| `make_deprecated_topic.py` | Regenerates `topics/deprecated-apis.md` from `corrections.yaml`. |
| `snippet_check.py` | Writes every `example_new` and topic code block into temporary `_SnippetCheck` files so the app builds them. |

## After editing

```sh
agent/src/check-swift.sh --self-test          # every rule flags its example_old, passes its example_new and the topic snippets
python3 agent/src/make_deprecated_topic.py    # refresh the generated topic (use --check in CI)
python3 agent/src/snippet_check.py write      # then build both editions:
scripts/build.sh ios && scripts/build.sh mac
python3 agent/src/snippet_check.py clean      # always, before committing
```

Check new URLs with `curl -sI` (they must return 200, and `.md` links must return markdown). In topic code fences, `swift ios` or `swift macos` limits a block to one platform, and `swift nocompile` skips it.

## Writing rules

- Verify every API against the installed SDK's `.swiftinterface` and Apple's `.md` docs, including availability and deprecation.
- Our own words; link Apple's `.md` pages for depth instead of copying them.
- Only what models get wrong or don't know yet. No beginner explanations.
- Code in `example_new` and topics must be complete declarations, deprecation-free, and pass the linter.
