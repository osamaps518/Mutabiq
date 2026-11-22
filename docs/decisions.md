# Decisions

Every technical decision on Mutabiq and the reasoning behind it.
Each entry records what we chose, what else we considered, and what we accept as a trade-off.
When a decision changes, mark the old one as **Superseded** and add a new entry instead of editing history.

Status values: **Accepted**, **Provisional** (we'll revisit after a set point), **Deferred** (not decided yet, on purpose), **Superseded**.

---

## 1. Name: Mutabiq

**Status:** Accepted, 2026-11-21

Mutabiq (مطابق) means "matching". It describes the job: making different spellings match. It was free on PyPI, npm and GitHub. `pg_arabic` was dropped because most of the project doesn't depend on Postgres. Other names were too generic (bahth), taken (tatabuq, rasm), or clashed with known Arabic projects (qarib, nuqta).

---

## 2. A library inside the app's database, not a hosted service

**Status:** Accepted, 2026-11-21

Search has to run in the app's own database, next to its rows, so Mutabiq is SQL that apps install plus a Python package. A hosted API would need every app to send its data elsewhere. The only hosted part is the demo.

---

## 3. Generic, with settings

**Status:** Accepted, 2026-11-21

Nothing about one domain or one app is in the code. Food lives only in data files (alias packs, test catalog). Filters such as "only this user's foods" are passed in by the app.

- **Set freely, per query:** alias packs, thresholds, fields searched, ranking, filters.
- **Set once at install:** cleaning options, as named profiles in the function name. Stored columns depend on the exact output, so changing them means rebuilding the column.

---

## 4. Plain SQL, no compiled extension

**Status:** Accepted, 2026-11-21

Hosted Postgres such as Azure Flexible Server only allows extensions from its own list. A Rust or C extension would never run there. Mutabiq uses plain SQL functions and `pg_trgm`, which is on those lists.

---

## 5. Stored generated column, not an expression index

**Status:** Accepted, 2026-11-21

The cleaned text is saved in a `STORED` generated column with a trigram index. On 50,400 rows a query took 1.5 ms this way, against 14.1 ms with an index on the expression, because Postgres re-runs the cleaning on every candidate row. Postgres 18 makes generated columns virtual by default, and virtual columns can't be indexed, so we always write `STORED`. Trade-off: the column takes disk space.

---

## 6. Versioned functions, 0.x until the rules freeze

**Status:** Accepted, 2026-11-21

Functions carry their rules version (`ar_norm_v1`). Changing the rules creates `ar_norm_v2`, never an edit, because stored columns depend on the exact output. Until 1.0 the rules can change and releases are 0.x, so we can adjust them against real queries first.

---

## 7. Cleaning rules

**Status:** Provisional, 2026-11-21. Revisit against labelled queries before 1.0.

In order: Unicode NFKC; A–Z to a–z, then `lower()`; delete diacritics, Quranic marks and small letters (U+064B–U+065F, U+0670, U+06D6–U+06ED), tatweel and invisible characters; zero-width space becomes a space; أ إ آ ٱ → ا; ة → ه; ى → ي; ئ → ي; Persian ی → ي and ک → ك; Arabic-Indic and Persian digits → 0–9; collapse whitespace.

- **A–Z mapped explicitly:** `lower()` follows the database's locale, and a Turkish locale turns `I` into `ı`. One line removes that risk for every install.
- **Zero-width space becomes a space:** deleting it would glue two words together.
- **ء and ؤ kept:** mapping ؤ → و wouldn't help, because مسؤول and مسئول would still differ (مسوول vs مسيول). An alias covers that pair if needed.
- **Python and SQL match** for Arabic and ASCII. For other scripts, `lower()` can differ by locale, and we document that.

---

## 8. Aliases are vocabulary, applied at query time

**Status:** Accepted, 2026-11-21

رز and أرز are different words for the same thing. Stemmers don't fix this: one maps كرز (cherry) to رز. So we keep alias lists and expand the query with them. Expanding the query, not the stored column, means updating a list never forces a rebuild.

- Default entry: a group of equal words. One-way entries are allowed for words that aren't true synonyms.
- Format: CSV, so contributors can edit it without tools and diffs stay readable.
- An app's own per-row names (like GHBot's `other_names`) are searched as data, separate from the lists.

---

## 9. A separate word column without ال

**Status:** Provisional, 2026-11-21. Keep if M2 numbers show it helps.

The article is attached to the word, which breaks whole-word matching: الرز scores lower than كرز against رز. A second hidden column holds each word with a leading ال removed, for whole-word matching. The name shown to users is unchanged. Both columns are built from the original fields, because Postgres doesn't allow a generated column to use another one.

---

## 10. Licences: MIT for code, CC0 for data

**Status:** Accepted, 2026-11-21

Code is MIT. Alias lists are CC0: anyone can use them without conditions, not even credit, since a credit notice inside a database table is awkward. CC0 also lets us contribute aliases to Wikidata, which only accepts CC0.

**Trade-off:** we can only add entries we wrote ourselves or that come from CC0 sources. Wiktionary (CC BY-SA) and Open Food Facts (ODbL) are out.

---

## 11. Our own open test catalog

**Status:** Accepted, 2026-11-21

The public tests and demo use a catalog Mutabiq owns: names we write, plus USDA data (CC0). Real search logs and users' own foods are personal data and are never published. GHBot runs the measuring tool on its own data privately.

---

## 12. Tech stack

**Status:** Accepted, 2026-11-21

- **Python 3.11+.** A library should run on more than the newest version.
- **uv, Ruff, pytest, Hypothesis.** Random tests plus hand-picked tricky cases.
- **No dependencies in the core.** Cleaning only needs the standard library. psycopg 3, the measuring tool and the demo are optional extras.
- **CLI on `argparse`,** from the standard library.
- **Postgres 15–18** in CI. `ALTER COLUMN … SET EXPRESSION` only exists from 17, so 15 and 16 get a tested manual upgrade.
- **SQL files inside the package,** printed or applied by `mutabiq sql`. An Alembic recipe in the docs before any plugin.
- **FastAPI** only for the demo.
- **No placeholder PyPI release.** Empty name-holding packages break PyPI's policy, so the first release has working code.

---

## 13. Measure before choosing

**Status:** Accepted, 2026-11-21

The measuring tool (M2) comes before the search pattern (M3). Thresholds and operators are chosen by numbers on labelled queries, not guessed. Some queries are kept aside and only used for final grading, so tuning can't flatter the result. Plan checks run on a large table only, because reading a small table in full is the right choice.

---

## 14. Docs layout

**Status:** Accepted, 2026-11-21

- `docs/plan.md`: scope and milestones. It changes often.
- `docs/decisions.md`: this file. Entries are added, never rewritten.
- `docs/findings.md`: measurements and how to rerun them.

One combined report was considered. It mixes text that ages differently, finished plan items next to permanent reasons, and slowly turns back into a discussion.
