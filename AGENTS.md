Rules for AI coding agents (and people) working on Mutabiq.

## Before you start
- Read docs/plan.md for scope and docs/decisions.md for the reasons behind it. Don't reopen a decision in code: if one seems wrong, ask.

## Branches, commits and PRs
- Follow CONTRIBUTING.md: branch `<type>/<issue>-<description>`, `Closes #<issue>` in the PR, squash merge.
- PR titles look like `feat(cleaning): add the SQL cleaning function`. The title becomes the commit on `main`.
- Commit in small steps, one behavior each with its tests, so the history shows what changed and why. Generated files and lockfiles go in the commit that causes them.
- No AI attribution in commits or PRs: no `Co-Authored-By` lines for Claude, Codex or any other tool, and no "Generated with" footer. Instead, start the PR description with "Co-developed with AI assistance."

## Scope
- Build only what the issue's "Done when" asks. If something else seems needed, ask first.
- Nothing for future issues: no empty modules, unused parameters, settings or abstractions "for later".
- Use library defaults. Change a setting only when you can say why.

## Libraries
- Before writing code that uses a language feature or library, check its docs with Context7 instead of relying on memory. Our versions may be newer than what you know: see pyproject.toml.
- The core has no dependencies. Anything else is an optional extra (decision 12).

## Data
- Catalog, alias and test data come only from text we wrote or from CC0 sources (decision 10). Never copy from Wiktionary, Open Food Facts or other non-CC0 sources.
- Never add real search logs or users' data (decision 11).

## Tests
- Test our behavior, not the libraries'. Postgres and the standard library test themselves.
- A few tests that each protect something real beat many small ones.

## Docs
- Short and plain. Decisions go in docs/decisions.md, in the same style as existing entries.
- Never write inline comments, use docstrings.

## Before a PR
- Run the checks in README.md.
