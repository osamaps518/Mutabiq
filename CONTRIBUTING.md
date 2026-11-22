# Contributing

How we work on Mutabiq. [docs/plan.md](docs/plan.md) says what we're building and in which milestone.

## Setup

Coming once there's code to run.

## Finding work

1. Pick an issue in the **current milestone**. Later milestones aren't ready yet.
2. Comment on the issue before you start, so nobody else does the same work.
3. If you have to stop, leave a comment saying where you got to.

## Writing issues

Use **New issue** and pick a template:

- **Search miss:** a search that didn't find what it should, or found something wrong.
- **Alias suggestion:** words that mean the same thing, for an alias pack.
- **Bug report:** something that's broken.

An issue is ready when someone who wasn't part of the discussion could pick it up and know when it's done.

## Data

Catalog and alias entries must be text you wrote yourself or come from a CC0 source, because we publish them as CC0 ([decision 10](docs/decisions.md#10-licences-mit-for-code-cc0-for-data)). Never copy from Wiktionary, Open Food Facts or other sources with conditions. Never include real search logs or anyone's personal data.

## Branches

`main` only changes through pull requests. Branch off an up-to-date `main`:

```bash
git switch main
git pull
git switch -c feat/12-sql-cleaning
```

Name branches `<type>/<issue-number>-<short-description>`:

| Type | For |
|---|---|
| `feat` | new functionality |
| `fix` | bug fixes |
| `docs` | documentation only |
| `chore` | setup, tooling, dependencies |

## Pull requests

1. Keep PRs small: one issue per PR.
2. In the description, write **`Closes #12`** (with your issue number). Merging the PR then closes the issue.
3. Explain *what* changed and *why*.
4. The PR title becomes the commit on `main`, so write it like `feat(cleaning): add the SQL cleaning function`.
5. A maintainer reviews it and merges with **Squash and merge**.

When reviewing, ask about anything you don't understand. That's part of the review, not a waste of the author's time.

## Decisions

Big technical choices (a library, a change to the cleaning rules, a new dependency) go in [docs/decisions.md](docs/decisions.md) with the reasoning, in the same PR that introduces them.
