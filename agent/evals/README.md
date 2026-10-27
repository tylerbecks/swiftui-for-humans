# Agent evals

These evals measure whether a coding agent writes better SwiftUI with our skills than without them. The agent gets a real task in a throwaway Xcode project, and the harness scores what it wrote: does it build, does it use deprecated APIs, does it pass the task's checks, and how does an LLM judge rate it against the HIG.

This is phase 1 of the agent plan. No competitor publishes evals, so the numbers are worth publishing on their own.

## Results

Run `2026-10-v3`, October 2026: 23 tasks, 2 repeats, 6 setups, 276 jobs. Opus is Claude Code's default model (`claude-opus-5-5` in every job); Sonnet is pinned to `claude-sonnet-5-5`. The judge is `claude-sonnet-5-5`. Raw results stay in `results/` (gitignored); this is the summary.

| Setup | Builds | Deprecated-API hits | Checks | Judge criteria | Judge overall /10 | Tokens in (avg) | Agent time (avg) |
|---|---|---|---|---|---|---|---|
| Opus, no skills | 46/46 | 0 | 100% | 96% | 8.3 | 105k | 1.7m |
| Opus + skills + primer (`ours`) | 45/46 | 0 | 100% | 98% | 8.6 | 205k | 1.8m |
| Opus + skills (`ours-no-primer`) | 46/46 | 0 | 100% | 98% | 8.7 | 191k | 1.9m |
| Sonnet, no skills | 46/46 | 4 (`tabItem`, one task) | 98% | 88% | 7.2 | 85k | 1.3m |
| Sonnet + skills + primer | 46/46 | 0 | 100% | 97% | 8.4 | 218k | 1.8m |
| Sonnet + skills | 45/46 | 0 | 100% | 94% | 7.9 | 143k | 1.3m |

Per task, with the judge's overall score averaged over both repeats and compared with the same model's baseline (95% intervals from bootstrapping over the 23 tasks):

| Comparison | Mean change | 95% interval | Tasks better / worse / same |
|---|---|---|---|
| Sonnet + skills + primer vs. Sonnet | +1.2 | +0.65 to +1.83 | 16 / 2 / 5 |
| Sonnet + skills vs. Sonnet | +0.7 | 0.00 to +1.33 | 12 / 4 / 7 |
| Opus + skills + primer vs. Opus | +0.3 | −0.04 to +0.70 | 7 / 1 / 15 |
| Opus + skills vs. Opus | +0.4 | +0.09 to +0.72 | 8 / 2 / 13 |
| Sonnet + skills + primer vs. Opus, no skills | +0.1 | −0.26 to +0.48 | 8 / 7 / 8 |

What it shows:

- **The pack lifts Sonnet to about where Opus starts.** With the skills and primer, Sonnet's judge score went from 7.2 to 8.4, level with Opus on its own (8.3). The biggest gains were App Review and HIG judgment: without the pack, Sonnet never offered in-app account deletion when asked for an account screen before submission (judge 4/16 criteria, 16/16 with it), and put more than one prominent button on the checkout screen (10/16, then 16/16).
- **Opus barely needs it.** Opus already avoids deprecated APIs and passes nearly every check, so the pack adds a small gain (+0.3 to +0.4), mostly in detail the judge looks for (card styling, accessibility labels and touch targets, settings layout, previews), and the interval for `ours` touches zero.
- **The primer matters more for Sonnet.** Sonnet with the skills but no primer scored 7.9; with the primer, 8.4. Both setups opened the skills in nearly every job (44–46 of 46). The difference is that the primer tells the agent to run the skills' linter before finishing, and agents with it did (Sonnet 39 of 46 jobs, Opus 45), while agents without it almost never did (Sonnet 0, Opus 6). Sonnet without the primer also scored below its own baseline on the 6 Liquid Glass jobs (6.3 vs. 8.2), including one job that never built after a denied command (see Limits); that's too few jobs to read much into.
- **Deprecated APIs are mostly a solved problem for current models.** The only deprecated-API hits were Sonnet without the pack using `tabItem` on the Mac settings task. Every other job, in every setup, used current APIs, so that column no longer separates the setups; the judge's design and App Review criteria do.
- **It costs context.** The skill setups read about twice as many input tokens, and took about the same time.

### Limits

- **Two repeats.** Repeat-to-repeat spread for a setup's average was up to 0.4 points (Sonnet + skills: 8.1 then 7.7), so differences under about half a point are noise. The intervals above are over tasks, not repeats.
- **The judge is Sonnet**, the same model family as the Sonnet setups and one of the agents it grades. It sees only the diff, not the running app, and scores against a short rubric per task. It's consistent but not a person.
- **23 tasks, written by us**, aimed at what the pack covers. They don't measure general coding ability, and a pack written for these topics should do well on them.
- **The harness still denies some commands.** Claude Code's sandbox auto-approves most shell commands but still asks about some (a `cd` to an absolute path, a parenthesized subshell, `cat > "$f" <<EOF`, `xargs sh -c`), and with no one to ask it denies them and tells the agent not to retry. About one job in five hit one denial, spread evenly across setups (7–15 jobs each). Agents usually switched to the file tools and kept building, but in 10 of 276 jobs the agent never built again, and both build failures in the run came from those: Opus `ours` (1) and Sonnet + skills (1).
- **Two checks were fixed after the run** and recomputed on the saved projects (checks only; builds and judge scores unchanged). `checkout-one-prominent` counted a `.glassProminent` button with its iOS 18 `.borderedProminent` fallback as two buttons, and `glass-mini-player` missed `glassEffect(` called without a leading dot inside a `View` extension. Both had failed agents whose code was right.
- **Apple's skills, SwiftUI Pro, and swiftui-expert-skill weren't run.** Their setups are ready (see Setups); a comparison with them is the next run.
- **Earlier runs aren't reported.** They used a shell allowlist that skewed against the skill setups (see How the agents run).

## What's here

| Path | What it is |
|---|---|
| `tasks/*.yaml` | 23 tasks: a prompt, a platform, regex checks, and judge rubric items |
| `setups.yaml` | Named setups to compare: an agent plus optional skills and primer |
| `judge-prompt.md` | The fixed prompt for the LLM judge |
| `template/` | The starting app: iOS and macOS targets, generated by XcodeGen |
| `evals.py` | The runner, scorer, and report (Python standard library only) |
| `minyaml.py` | A small YAML-subset parser, so nothing needs installing |
| `results/` | Run output (gitignored) |
| `vendor/` | Third-party skills to compare against (gitignored) |

### Tasks

| Category | Tasks | What they catch |
|---|---|---|
| `deprecated-api` | list-detail-navigation, observable-cart, search-onchange, previews, styled-card, adaptive-grid, async-load | NavigationView, ObservableObject, one-parameter onChange, PreviewProvider, foregroundColor, cornerRadius, UIScreen.main, DispatchQueue.main |
| `liquid-glass` | glass-map-controls, glass-onboarding-buttons, glass-mini-player | iOS 26 APIs (glassEffect, .glass button styles, tabViewBottomAccessory) with an `#available` fallback |
| `hig` | delete-confirmation, edit-sheet, settings-screen, checkout-one-prominent, dynamic-type-weather, podcast-player-controls, contacts-sheet-vs-push, adaptive-tabs | Destructive confirmation, one prominent button, sheet vs. push, Dynamic Type, accessibility labels, 44pt targets, tab bar vs. sidebar |
| `mac` | mac-settings, mac-menu-commands, mac-toolbar | Settings scene, menu commands, toolbar and sidebar idioms |
| `app-review` | request-review, account-deletion | requestReview timing, in-app account deletion (5.1.1(v)) |

Prompts are written the way a person would ask, without hints. The template's deployment target is iOS 18 / macOS 15, so iOS 26 APIs without an `#available` check fail to build. The template also uses the Swift settings of a new Xcode 26+ project (main-actor default isolation, `MemberImportVisibility`), so, for example, an `ObservableObject` without `import Combine` fails to build just as it would in a fresh project.

## Requirements

- Xcode 27 and `xcodegen` (`brew install xcodegen`)
- `claude` (Claude Code), signed in. The judge also uses it.
- `codex`, signed in, for the Codex setups
- Python 3.9 or later. No packages.

## Commands

Run everything from the repo root.

```sh
# Check every task and setup parses, and see which setups are ready
python3 agent/evals/evals.py list

# Test the harness itself: agent command lines and scoring (no agents, builds, or cost)
python3 agent/evals/evals.py self-test

# Print the agent commands without running anything
python3 agent/evals/evals.py run --setup claude-baseline --task previews --dry-run

# Run one task once
python3 agent/evals/evals.py run --setup claude-baseline --task previews

# Compare setups on every task, three times each, with the judge
python3 agent/evals/evals.py run --setup claude-baseline --setup ours \
    --repeats 3 --judge --run-id 2026-11-ours-vs-baseline

# Only some tasks
python3 agent/evals/evals.py run --setup claude-baseline --category liquid-glass --platform ios

# Print the latest run's table (also saved as report.md in the run folder)
python3 agent/evals/evals.py report
python3 agent/evals/evals.py report 2026-11-ours-vs-baseline

# Rebuild and rescore a run's saved projects after changing checks or linter rules
python3 agent/evals/evals.py score 2026-11-ours-vs-baseline [--judge]
```

A run with an existing `--run-id` skips jobs that already have a `result.json`, so an interrupted run resumes where it stopped. Pass `--force` to redo them. `--keep` leaves the temp projects in place for inspection. `--timeout` caps each agent run (20 minutes by default).

## Setups

A setup is `{agent, skills_dir, primer}` plus an optional `model` and `extra_args` (extra CLI arguments, placed after the harness's options and before the prompt). For each run, the harness:

1. copies `template/` into a new temp directory, outside the repo so none of this repo's instructions leak in
2. copies each skill folder into the project's `.claude/skills/` and `.agents/skills/`
3. appends the primer to the project's `AGENTS.md` and `CLAUDE.md` (Claude Code reads only `CLAUDE.md` when both exist, and Codex reads `AGENTS.md`, so each agent sees it once)
4. runs `xcodegen generate` and commits the starting state to a fresh git repo, so the diff shows only the agent's work
5. runs the agent, then scores the result

`claude-baseline` and `codex-baseline` work as is, and so do ours:

- **Ours** read the generated `agent/skills/` (`scripts/agent-build.py`). `ours` adds the always-on primer, `agent/primer/AGENTS.snippet.md`, the way the install page recommends; `ours-no-primer` leaves it out, to measure what the primer adds; `codex-ours-primer` is `ours` on Codex.

The rest need files that aren't in the repo:

- **Apple's Xcode 27 skills** (`claude-apple`): export them with `xcrun agent skills export` into `agent/evals/vendor/apple-xcode27/`.
- **Paul Hudson's [SwiftUI Pro](https://github.com/twostraws/SwiftUI-Agent-Skill)** (`claude-hudson`) and **Antoine van der Lee's [swiftui-expert-skill](https://github.com/AvdLee/SwiftUI-Agent-Skill)** (`claude-vanderlee`), both MIT licensed: clone each and copy its skill folder into `agent/evals/vendor/swiftui-pro/` and `agent/evals/vendor/swiftui-expert-skill/`.

`skills_dir` can be one skill (a folder with `SKILL.md`) or a folder of skills.

### How the agents run

**Claude Code** runs as `claude -p --output-format stream-json --verbose` in the temp project, with:

- `--settings` turning on Claude Code's [sandbox](https://code.claude.com/docs/en/sandboxing): every shell command runs under the macOS sandbox, which auto-approves it but confines writes to the temp project and blocks the network. `allowUnsandboxedCommands: false` stops it retrying outside, and `failIfUnavailable: true` stops the run rather than going unsandboxed.
- `--permission-mode acceptEdits` and `--permission-prompts none`: file edits inside the project are accepted, and anything else that would need a person is denied.
- `--tools Bash,Edit,Read,Write,Glob,Grep,Skill,WebFetch,Task`, with WebFetch allowed on `developer.apple.com` only.

The first version used a shell allowlist (`./build.sh`, `ls`, `cat`, and so on) instead of the sandbox. It skewed the results: Claude Code splits a compound command like `./build.sh ios 2>&1 | tail -5; echo "exit $?"` and denies the whole thing if any part isn't listed, then denies every later approval in that session. Agents that chain commands, the skill setups most (they also run the skills' linter), lost their build checks and handed back code they never compiled. In one run, Opus with our skills and no primer saw its own build in 29 of 46 jobs, against 46 of 46 for the baseline, and every build failure in that run was an agent that couldn't build. Those runs aren't reported.
- `--setting-sources project --strict-mcp-config`: the user's settings, plugins, hooks, MCP servers, and `~/.claude/CLAUDE.md` are left out, so every setup starts the same. (Checked: with these flags, the init event lists no user skills, plugins, or MCP servers.) Claude Code's built-in skills are still there, in every setup.

**Codex** runs as `codex exec --json --sandbox workspace-write --ignore-user-config --ephemeral` in the temp project. The Codex path hasn't been run yet; see Known gaps.

Both agents can run `./build.sh ios` or `./build.sh mac` in the project to check their work, as a person would in Xcode. `xcodebuild` can't run inside either agent's sandbox (it needs CoreSimulator and writes outside the project), so `build.sh` hands the request to a broker thread in the harness: it drops a file in `.build/requests/`, the harness builds outside the sandbox behind the same machine-wide lock as `scripts/build.sh`, and `build.sh` prints the output and exits with the build's status. `result.json` records how many builds each agent ran (`agent_run.builds`).

## Scoring

Every run records:

| Metric | How |
|---|---|
| Builds | A clean `xcodebuild build` of the task's platform (`-jobs 4 ARCHS=arm64`, fresh DerivedData), inside the machine-wide lock at `/tmp/swiftui-for-humans-build.lock` that `scripts/build.sh` uses |
| Deprecated-API hits | Findings from the skills' own linter, `agent/src/check-swift.sh --json --min-severity warning --target "iOS 18.0"` (or `"macOS 15.0"`, the template's targets), on the agent's Swift files. It ignores comments and strings, counts only the corrections in `agent/src/corrections.yaml` (not its HIG checks or info-level judgment calls), and skips a correction whose replacement needs a newer OS than the target. **This is the main deprecation measure**: Xcode 27's SwiftUI soft-deprecates NavigationView, foregroundColor, cornerRadius, and the like (`deprecated: 100000`, "in a future version"), which never produces a compiler warning, and 26.0 deprecations such as `Text + Text` warn only with a 26+ deployment target |
| Deprecation warnings | Unique compiler warnings in the agent's Swift files that mention "deprecated". Only catches hard deprecations, such as `UIApplication.shared.windows` |
| Checks | The task's `require` (must match), `forbid` (must not match), and `max` (at most N matches) regexes |
| Judge (optional, `--judge`) | `claude -p` with no tools, the fixed `judge-prompt.md`, four general criteria plus the task's rubric, and the diff. Records criteria passed and an overall 0–10 grade |
| Tokens and cost | From the agent's JSON events: Claude reports tokens and cost (summed over every result event, since a session that waits on a background command emits several), Codex reports tokens only |
| Time | Agent wall-clock time |

Each run's folder (`results/<run>/<setup>/<task>/r<n>/`) holds `result.json`, the agent's raw output, `changes.diff`, `build.log`, `judge.json`, and `project/`, a copy of the agent's project that `score` can rebuild.

The judge defaults to the `sonnet` alias. Aliases move to newer models over time, so pass `--judge-model` with a full model name when results need to stay comparable across months; `result.json` records the model that answered.

## Task format

```yaml
id: edit-sheet                  # must match the file name
title: Edit form with Cancel and Save
platform: ios                   # ios | macos
category: hig                   # deprecated-api | liquid-glass | hig | mac | app-review
prompt: >
  What the agent is asked, in a person's words. No hints.
checks:
  require:                      # each must match somewhere
    - label: Presents the editor as a sheet
      pattern: '\.sheet\('
  forbid:                       # none may match
    - label: No presentationMode
      pattern: '\bpresentationMode\b'
  max:                          # at most `count` matches
    - label: At most one prominent button style
      pattern: '\.borderedProminent\b'
      count: 1
rubric:                         # extra criteria for the judge
  - Cancel discards edits because the form edits a draft copy.
```

Patterns are Python regular expressions in single quotes. Keep files inside the YAML subset `minyaml.py` reads (block maps and lists, `|` and `>` blocks, quoted strings, flat `[a, b]` lists); `evals.py list` fails loudly on anything else.

## Cost and time

The published run (276 jobs) took just under two hours, with one `run` process per setup in parallel. Agents averaged 1.3–1.9 minutes a job, and the scoring build and judge about a minute more. Claude Code reported $60 for the agents at API prices (Opus setups $10–16 each for 46 jobs, Sonnet $4–8), plus about $0.03 a job for the judge. On a Claude subscription, as here, that counts against usage limits instead of billing. If a job hits a usage or rate limit, the run discards it, exits with code 4, and resumes from there with the same `--run-id`.

| Run | Jobs | Time | Cost at API prices |
|---|---|---|---|
| One setup, all tasks, 1 repeat | 23 | 45–60 minutes | $2–8 |
| Six setups, 2 repeats, six processes (the published run) | 276 | about 2 hours | about $70, judge included |

Builds take turns on the machine-wide lock, so builds from other worktrees add straight to agent time. In the smoke test, a simple task took 10.7 minutes while parallel agents were building, and 43 seconds when nothing else was.

## Smoke test

Run on October 26, 2026 with Claude Code 2.1.308 (Opus 5.5), Xcode 27.1, and the Sonnet 5.5 judge: `claude-baseline` on two tasks, one repeat each.

| Task | Build | Deprecated-API hits | Checks | Judge | Agent time | Cost |
|---|---|---|---|---|---|---|
| list-detail-navigation | ok | 0 | 2/2 | 7/7 criteria, 9/10 | 43 s | $0.13 + $0.03 judge |
| mac-settings | ok | 0 | 1/1 | 7/8 criteria, 8/10 | 50 s | $0.17 + $0.04 judge |

On mac-settings, the judge failed the accessibility criterion because the agent applied the font-size slider with `.font(.system(size:))`, a fixed size that ignores Dynamic Type. That's the kind of judgment the skills should fix. Two tasks prove the harness works, not that baseline Claude is good: these are two of the easiest tasks.

The smoke test turned up three harness bugs, all fixed:

- A user's `diff.external` (difftastic here) replaced the unified diff the judge reads.
- When an agent runs its build in the background, Claude Code emits one result per segment, so tokens were undercounted. The harness now reads `stream-json` and sums them.
- `run` didn't save `report.md`.

Running `score --judge` on the saved projects reproduced the same grades.

## Known gaps

- **Codex hasn't been run.** The command is built (see `--dry-run`) and its JSONL usage parsing follows the documented `turn.completed` events, but nothing has exercised it. Its `workspace-write` sandbox would block `xcodebuild`, but the build broker should cover that, since `build.sh` only writes inside the project. Try one task first.
- **Codex isolation is partial.** `--ignore-user-config` skips `~/.codex/config.toml`, but a global `~/.codex/AGENTS.md` still loads.
- **Some shell commands are still denied.** About one job in five, Claude Code asks about a command the sandbox would have contained, and with no one to answer it denies it and tells the agent not to retry (see Results, Limits). Running with `--permission-mode bypassPermissions`, keeping the sandbox on and adding deny rules for `Edit` and `Write` outside the temp project, would remove these. It wasn't tried in the published run.
- **Regex checks are blunt.** They see code, not behavior. The judge covers intent, and `score` makes it cheap to refine patterns and rescore saved runs.
- **One job at a time per process.** Run one `run` process per setup with the same `--run-id` to go faster (the published runs used six); builds still take turns on the lock.
