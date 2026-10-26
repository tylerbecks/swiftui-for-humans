---
name: commit
description:
  Generate conventional commit messages with emojis. Use when creating git
  commits.
allowed-tools:
  - Bash(git add:*)
  - Bash(git status:*)
  - Bash(git commit:*)
  - Bash(git diff:*)
  - Bash(git log:*)
argument-hint: '[optional message hint]'
---

# Create Commit

Branch commits are working notes. Every PR is squash-merged, and `main` gets the PR title and
description, never these messages. They are read by the pr and babysit skills, Codex, and the next
agent on the branch, so keep them accurate and short.

If the user provided a hint, use it: **$ARGUMENTS**

## Context (gathered automatically)

If a line below is empty or still shows its command, run that command yourself.

- Working tree status: !`git status --porcelain`
- Staged files: !`git diff --cached --stat`
- Staged diff: !`git diff --cached`
- Recent commits: !`git log --oneline -5`

## Stage

If nothing is staged, stage the files that belong to this change by name, never with `git add -A`;
ask when unrelated work is mixed in. Describe everything staged, including work from earlier
sessions, not just your own edits. Never stage a leftover `_SnippetCheck.swift`.

## Message

Title: `EMOJI TYPE: summary`, from this closed set. Do not substitute other emojis or types.

- 🚀 feat: New feature
- 🐛 fix: Bug fix
- 📚 docs: Documentation
- 🛠️ refactor: Code change (no new feature/fix)
- ⚡ perf: Performance improvement
- 🧪 test: Tests
- 🧹 chore: Build/clean up

A new page or section is `🚀 feat`; correcting a page's wrong guidance or a snippet that misleads is
`🐛 fix`. Use `TYPE!:` when the change renames or removes a page id (saved selections and checklist
progress are keyed by it) or a launch flag that scripts rely on; adding them is not breaking. Start
the summary lowercase when natural, with no trailing period, short enough to read in
`git log --oneline`.

Add a body only when the title can't carry the reason: what was wrong or missing, and why this
approach, in a sentence or two. Take the reason from the user's words or the hint; if you don't have
one, leave the body out rather than invent it. No test results, file lists, or session story. Do not
hard-wrap: each paragraph is one physical line.

## Commit

Run `git commit -F -` with a single-quoted heredoc so the message reaches git exactly. Add no
`Co-authored-by` trailer or other AI attribution.

If a hook fails, the commit did not happen: fix the cause, re-stage, and commit again. Never
`--amend` to recover, and never bypass a hook with `--no-verify`.

## Examples

```text
🐛 fix: keep the glass toolbar legible over bright scenery
```

```text
🚀 feat: a Mac page for menu bar extras

Covers MenuBarExtra in both window and menu styles, since the HIG treats them differently and most samples only show the menu.
```
