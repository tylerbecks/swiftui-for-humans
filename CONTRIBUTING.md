# Contributing

Thanks for helping. Changes reach `main` only through pull requests.

1. Fork the repository, or create a branch if you have access.
2. Make your change. For page content, follow [docs/content-guide.md](docs/content-guide.md) and [docs/building-pages.md](docs/building-pages.md); the rules in [AGENTS.md](AGENTS.md) apply to people too.
3. Run the tests: `scripts/build.sh test-ios` and `scripts/build.sh test-mac`.
4. Open a pull request against `main`.

## What happens next

- **CI must pass.** A first-time contributor's run starts after the maintainer approves it. Every pull request runs these checks:
  - `test-ios` and `test-mac` test both apps, export each edition's page text to `agent/build/`, and build every Swift snippet in `agent/src` into the app.
  - `agent-pack` regenerates the agent pack from that export and fails if the committed copy is stale. If it fails, run `scripts/export-catalog.sh` and `scripts/agent-build.py`, and commit the result. It also runs `agent/src/check-swift.sh --self-test` and `python3 agent/src/make_deprecated_topic.py --check`.
  - `mcp` typechecks and tests the MCP server (`cd mcp && npm ci && npm run typecheck && npm test`).
- **The maintainer reviews every pull request** before it merges.
- **Keep pull requests small**, one change each, so they're quick to review.

## Commit messages

Use conventional commits with an emoji prefix:

- 🚀 feat: new features
- 🐛 fix: bug fixes
- 📚 docs: documentation changes
- 🛠️ refactor: code refactoring
- ⚡ perf: performance improvements
- 🧪 test: adding or updating tests
- 🧹 chore: maintenance tasks

For example: `🐛 fix: Slider label clipping on iPad`.

## Security problems

Don't open a public issue. See [SECURITY.md](SECURITY.md).
