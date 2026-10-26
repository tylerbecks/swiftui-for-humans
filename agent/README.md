# SwiftUI for Humans for agents

The app's pages, rewritten for AI coding agents: four [Agent Skills](https://agentskills.io), an always-on primer, a SwiftUI linter, and plugin wrappers for Claude Code and Codex. Install instructions are in the [main README](../README.md#for-ai-agents).

Agents pay for every token they read, and anything they already know is wasted. So the pack keeps what models get wrong or don't know yet: deprecated APIs they still write, iOS and macOS 26–27 APIs newer than their training, the HIG as decision rules, and exact App Review rules. It drops explanations written for people. It links Apple's docs (add `.md` to any developer.apple.com URL) instead of copying them.

## What's here

| Path | What it is | Edit it? |
|---|---|---|
| `skills/<skill>/SKILL.md` | Each skill's description, workflow, top rules, and topic index | Generated |
| `skills/<skill>/references/<id>.md` | One topic per page id, iOS and macOS merged | Generated |
| `skills/swiftui-review/scripts/` | The linter (`check_swift.py`, `check-swift.sh`, `corrections.yaml`) | Generated (copied from `src/`) |
| `primer/AGENTS.snippet.md` | The always-on snippet for AGENTS.md / CLAUDE.md, at most 8 KB | Generated |
| `src/` | Everything hand-written: skill intros, agent-only topics, overlays, corrections, the linter | **Yes** |
| `.claude-plugin/plugin.json`, `commands/`, `agents/` | The Claude Code plugin: the skills plus `/swiftui-review` and the `hig-reviewer` subagent | Yes |
| `.codex-plugin/plugin.json` | The Codex plugin manifest (skills only) | Yes |
| `plugins/swiftui-lint-hook/` | The opt-in Claude Code plugin that lints each edited `.swift` file | Yes, except `scripts/check_swift.py` and `corrections.yaml` (generated copies) |
| `build/` | The catalog export, `ios.json` and `macos.json` (gitignored) | No |

The marketplaces that point at these live at the repo root: `.claude-plugin/marketplace.json` for Claude Code and `.agents/plugins/marketplace.json` for Codex. `npx skills add` finds `agent/skills/` on its own, since it's one of the folders the skills CLI searches.

## Pipeline

```
App pages (Swift) ── scripts/export-catalog.sh ──▶ agent/build/{ios,macos}.json
agent/src/ (skills, topics, overlays, corrections.yaml, linter) ──┐
                                                                  ▼
                                          scripts/agent-build.py ──▶ agent/skills/, agent/primer/
```

1. **Export.** `scripts/export-catalog.sh` renders every page offscreen in the tests and writes its text to `agent/build/` (see AGENTS.md, "Catalog export").
2. **Generate.** `scripts/agent-build.py` merges both editions with `agent/src/` and rewrites the generated files. Same input, same bytes.
3. **Check.** `scripts/agent-build.py --check` exits 1 when the output is stale, a budget is over, or an id doesn't resolve. Add `--check-urls` to HEAD every Apple link (they must all return 200).

After changing a page, `agent/src/`, or the generator:

```sh
scripts/export-catalog.sh             # only when app pages changed
scripts/agent-build.py
scripts/agent-build.py --check
agent/src/check-swift.sh --self-test   # after editing corrections.yaml or the linter
```

Commit the regenerated `agent/skills/` and `agent/primer/`. They're the product people install, straight from `main`.

## How a topic is built

Each page id becomes one file in the skill for its tab: Build → `swiftui-build`, Design → `apple-design`, Ship → `app-store-ship`. A page in both editions becomes one file with an **On macOS** section that holds only what the Mac page adds or says differently. Mac-only pages get their own file with `platforms: [macOS]`.

| Section | From |
|---|---|
| Frontmatter | id, title, platforms (editions), availability, docs and HIG links as `.md`, reviewed |
| Summary, Also called | `summary`, the first 10 `aliases` |
| Use when / Don't use when | `about` (sentences that send people to another page become "Don't use when"), plus overlays |
| Default code | The Usage block |
| Rules | Guidelines (title and detail; the Do / Don't captions label previews, so they're left out) |
| Pitfalls | "Good to know" notes, and standalone asides on component pages |
| Guide | The prose, checklists, steps, and facts of Concept and Reference pages. Component pages drop their prose |
| Key APIs | `api` |
| Variants | Each ExampleCard: title, caption, code, and aside |
| Related | `related` ids, linked inside the skill, or named with their skill when they live in another |

**Budgets.** A topic is at most 1,500 tokens (characters / 4), and gets a Contents list past 100 lines. When a topic is over, the generator drops, in order: the Mac guide prose, Key API details (names stay), the aliases, and then the last variant of whichever platform has more variant text, until it fits. Dropped variants are named at the end of the file with Apple's docs link. Each SKILL.md description is at most 1,024 characters (plain YAML, no `: ` or ` #`), each SKILL.md body at most 300 lines, and the primer at most 8 KB.

**Agent-only topics** (`src/topics/<id>.md`) are copied as they are into every skill their `skills:` frontmatter names. One with the same id as a page replaces that page (`liquid-glass` does). Mentions of another topic's file are pointed at its skill when it lives in a different one.

**Overlays** (`src/overlays/<id>.md`) add agent-only sections to a page's topic. See "Agent overlays" in [docs/content-guide.md](../docs/content-guide.md).

**Skill intros** (`src/skills/<skill>.md`) hold the frontmatter, workflow, and top rules. `{{index}}` becomes the topic index and `{{corrections}}` the top corrections from `corrections.yaml`.

## Known gaps

- Text a page draws with plain `Text` or its own views, rather than the shared reporting views, isn't exported (for example, the rejection guide's list of guidelines).
- 40-odd topics leave some variants out to stay under budget. The file names them.
- The pack isn't on any skills directory yet, and the evals (`agent/evals/`, if present) haven't been re-run against it.
