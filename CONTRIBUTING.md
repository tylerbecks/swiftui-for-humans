# Contributing

Thanks for helping. Changes reach `main` only through pull requests.

1. Fork the repository, or create a branch if you have access.
2. Make your change. For page content, follow [docs/content-guide.md](docs/content-guide.md) and [docs/building-pages.md](docs/building-pages.md); the rules in [AGENTS.md](AGENTS.md) apply to people too.
3. Run the tests: `scripts/build.sh test-ios` and `scripts/build.sh test-mac`.
4. Open a pull request against `main`.

## What happens next

- **CI must pass.** Every pull request builds and tests both apps. A first-time contributor's run starts after the maintainer approves it.
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
