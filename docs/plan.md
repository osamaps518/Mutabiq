# Plan

What Mutabiq is, what goes in each version, and the milestones. This file changes as work moves. The reasons behind each choice are in [decisions.md](decisions.md), and the measurements are in [findings.md](findings.md).

## What Mutabiq is

A library that makes Arabic search work in an app's own database. It has:

- **Cleaning rules:** a written spec that turns different spellings of the same word into one form (مقلوبة, مَقْلُوبَة and مقلوبه all become مقلوبه).
- **Two implementations of the rules:** Python and PostgreSQL SQL, tested to give the same output.
- **A search pattern for Postgres:** columns, indexes and queries that are fast and find the right rows.
- **Alias packs:** words that mean the same thing but are spelled differently (رز and أرز, بندورة and طماطم). Food comes first.
- **`mutabiq doctor`:** checks a database and says exactly what to fix.
- **`mutabiq bench`:** measures search quality and speed on labelled queries, for any search setup.

Anyone can use it. Nothing about food or about one app is in the code: domains live in data files, and each app sets its own options. GHBot is the first user. GHBot depends on Mutabiq, never the other way around, and GHBot's own tasks live in GHBot's issues.

## The problem

Arabic is written many ways for the same word:

- with or without diacritics, different alef forms (أرز, إرز, آرز, ارز), ة or ه, ى or ي
- Arabic-Indic or Persian digits, and Persian letters typed on Persian keyboards
- invisible characters and letter shapes pasted from PDFs
- dialect words: رز for أرز, بندورة for طماطم

Apps fix this by hand, each in its own way. Three traps make it worse:

1. If each writer cleans text in app code, one that forgets breaks search silently.
2. In a database with the wrong locale, Postgres's fuzzy search ignores Arabic letters without any error.
3. Fuzzy search can't connect رز to أرز, and "contains" search also returns كرز (cherry).

## Prior art

Lucene and Elasticsearch ([ArabicNormalizer](https://lucene.apache.org/core/9_12_0/analysis/common/org/apache/lucene/analysis/ar/ArabicNormalizer.html)), [CAMeL Tools](https://camel-tools.readthedocs.io/en/latest/api/utils/normalize.html) and PyArabic apply similar cleaning rules. Mutabiq's difference is identical Python and SQL behavior, a tested Postgres search pattern, the doctor, and the measuring tool.

## Versions

**0.x:** releases while the rules can still change.

**1.0:** the cleaning rules are frozen as v1.

| In 1.0 | Later |
|---|---|
| Cleaning spec, Python and Postgres SQL | **1.1:** mining aliases from search logs, once real logs exist |
| Search pattern: stored column, ال-free word column, short-query tiers, ranking, aliases | **1.1:** Wikidata and reviewed LLM suggestions as alias sources |
| `mutabiq doctor` and `mutabiq sql` (install) | **1.1:** Django integration, demo video, 500k-row test, tested-hosts table |
| `mutabiq bench` with three adapters | **2:** SQLite port, more domain packs, Arabizi |
| SQLAlchemy/Alembic recipe | **2:** comparing with Meilisearch or embeddings |
| Food alias pack | **2:** a light stemmer, only if the numbers show a need |
| Live demo, article on the locale trap | Never: a compiled Postgres extension |

## Milestones

Milestones are goal-based, with no time estimates.

### M0: Repo and rules

- Repo setup: uv, Ruff, pytest, CI on Postgres 15–18, `AGENTS.md` adapted to Mutabiq.
- First draft of the cleaning rules, to adjust against real queries before 1.0.
- Start the open demo catalog and the labelled queries (some kept aside for final grading).

**Done when:** CI runs on all four Postgres versions, the rules draft is written, and labelling has started.

### M1: Cleaning in Python and SQL

- `spec/v1.md` and a shared file of test cases (input → expected output) that every implementation must pass.
- Python and SQL implementations.
- Tests: same output from both, cleaning twice equals cleaning once, character counts in the SQL.
- PyPI 0.1 with the Python cleaning function.

**Done when:** both implementations pass the shared cases on every Postgres version. GHBot #58 can use the SQL.

### M2: Measuring tool

- Adapter interface: query in, ranked IDs out.
- Three adapters: plain fuzzy search, Mutabiq cleaning, cleaning plus a small alias set.
- Numbers: Recall@k, MRR, share of wrong results, latency. Tuning queries and grading queries kept separate.
- Plan check on a large table only.
- JSON and Markdown reports.

**Done when:** one command prints a results table for all three adapters.

### M3: Search pattern

- Stored column over several name fields, and a word column with ال removed. Both are built from the original fields.
- Ranking with `ORDER BY`. The app's own filter (for example "my foods") applies before the top-k cut.
- Short-query tiers, alias table with query-time expansion, CSV loader.
- Safe queries: `%` and `_` escaped, thresholds set per transaction.
- Defined behavior for several words, empty names and aliases inside a phrase.
- Every choice backed by M2 numbers.

**Done when:** the pattern beats the plain adapters in the M2 table and has a written install recipe.

### M4: Doctor, install, first real release

- `mutabiq sql` to install, and a tested upgrade path (Postgres 17+ and 15/16).
- `mutabiq doctor`.
- `docs/locale-trap.md` and the first article.
- PyPI 0.2 with SQL included.

**Done when:** a fresh database goes from nothing to working search with `mutabiq sql` and passes `mutabiq doctor`, and a broken-locale database fails it with the fix printed.

### M5: Integrations and 1.0

- SQLAlchemy/Alembic recipe.
- Food alias pack, about 100–300 groups, CC0.
- Live demo: plain vs Mutabiq results side by side, on the open catalog.
- Rules frozen as v1, release 1.0.

**Done when:** 1.0 is on PyPI with the demo link and the results table in the README.
