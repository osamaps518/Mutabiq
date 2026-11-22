# Findings

What we measured, and what it means. The original runs used PostgreSQL 18.7 and 17.12; their scripts and outputs are in [`research/`](../research/README.md). Checks added on 2026-11-21 (sections 6, 9 and 10, partly) used 18.6 and aren't scripted yet.

Every database below was created with `LC_COLLATE 'C'` and `LC_CTYPE 'C.UTF-8'` unless stated.

---

## 1. The locale trap

`show_trgm('أرز')` lists the trigrams Postgres sees in a word. An empty result `{}` means fuzzy search ignores Arabic.

| Database setup | PG 17.12 | PG 18.7 |
|---|---|---|
| `LOCALE 'C'` or `'POSIX'` | `{}` | `{}` |
| builtin provider, `BUILTIN_LOCALE 'C.UTF-8'` | `{}` | `{}` |
| builtin `'C'` | `{}` | `{}` |
| ICU `'und'` with ctype C | `{}` | `{}` |
| any of the above plus a `COLLATE` clause | — | `{}` |
| libc `en_US.UTF-8`, `C.UTF-8`, `ar_EG.UTF-8` | works | works |
| ICU `en-US` with ctype `en_US.UTF-8` | works | works |
| builtin `C.UTF-8` plus `LC_CTYPE 'C.UTF-8'` | works | works |
| **libc `LC_COLLATE 'C'` + `LC_CTYPE 'C.UTF-8'`** | **works** | **works** |

**The rule:** `pg_trgm` follows the database's `LC_CTYPE`, not the locale provider. The ctype must be a UTF-8 locale. The last row is the recommended setup: fast byte-order sorting plus Arabic-aware trigrams.

- A database's ctype can't be changed in place. The fix is a new database plus dump and restore.
- `C.UTF-8` exists on modern Linux but not on macOS. `en_US.UTF-8` works on both.
- Postgres's full-text search does see Arabic in a C-locale database. The trap is specific to `pg_trgm`.

---

## 2. SQL cleaning matches Python

- GHBot's original rules in SQL matched Python on 20,023 strings with 0 Arabic mismatches, across 5 locale setups.
- The only differences (1,598, in libc and builtin databases; 0 with ICU) came from Turkish `İ` and Greek final `Σ`, where `lower()` follows the locale. In a `tr_TR.UTF-8` database, `lower('I')` gives `ı`. This is why the rules map A–Z themselves (decision 7).
- The v1 function matched Python on 20,000 random strings on PG 18 and 17. The strings included presentation forms, decomposed hamza, invisible characters, Quranic marks, NBSP and tabs. Cleaning twice equals cleaning once on 20,001 strings.

## 3. An off-by-one in `translate()`

An earlier version of the function had a stray space in the `translate()` target: 29 characters against 28. Every character after it shifted by one place: کباب became ` باب`, and ٣ became 2. Tests now check that both strings have the same length.

---

## 4. Stored column vs expression index

Query مقلوبة with `LIKE '%q%' OR q <% col` on 50,400 rows:

| Setup | Plan | Time |
|---|---|---|
| Stored generated column + GIN trigram index | two index scans | **1.5 ms** |
| GIN index on the expression `ar_norm(name)` | two index scans | 14.1 ms |
| Expression index, prepared (generic) plan | index | 19.3 ms |
| No index | full table scan | 319 ms |

An index only returns candidate rows, and Postgres re-checks each one. With an expression index, that check re-runs the cleaning. With a stored column, it just reads the value. Both indexes were 1,592 kB.

**Short queries:** `LIKE '%رز%'` gives no usable trigram. Postgres scans the table (82 ms stored, 292 ms expression), or with a generic plan reads the whole index (367 ms).

---

## 5. رز vs أرز

- `word_similarity('رز','ارز')` is 0.333, below the threshold. Fuzzy search alone can't connect them.
- "Contains" (`LIKE '%رز%'`) finds أرز, ارز, الأرز and أرز بسمتي, but also كرز (cherry), برز, فرز, مرزوق, حرز, خرزة, مارزيبان and more.
- **The fix:** a small alias table (رز ↔ ارز) and `name_search %> ANY(variants)`. It used the index (77 ms) and returned exactly the 5,040 rice rows, with no false matches.
- `%>` is word similarity: it finds the query inside part of the name. Whole-word matching is `%>>` (strict word similarity). `'رز' <<% 'كرز'` is false.

## 6. The attached ال

| Query | Name | word similarity | strict word similarity |
|---|---|---|---|
| ارز | الارز | 0.500 | 0.429 |
| رز | الرز | 0.333 | **0.143** |
| رز | كرز | 0.333 | **0.167** |
| خبز | الخبز | 0.500 | 0.250 |
| لبن | اللبن | 0.500 | 0.250 |
| بيض | البيض | 0.500 | 0.250 |

- Whole-word matching scores الرز *below* كرز. This is why decision 9 adds a word column without ال.
- The default thresholds are 0.6 (word) and 0.5 (strict), so at the defaults none of the ال rows match. 3-letter words sit right at 0.5.

---

## 7. Stemmers don't solve it

Postgres's built-in Arabic stemmer (Snowball):

| Input | Stem | |
|---|---|---|
| رز | رز | never equals ارز |
| أرز, ارز, الأرز, بالأرز | ارز | good: handles ال and ب |
| مقلوبة, مقلوبه | مقلوب | good |
| بيضات | يضا | over-stemmed: no longer matches بيض |
| بندورة | ندور | removed ب as if it were a preposition |
| بسمتي | سمت | same problem |

Python stemmers:
- **ISRI:** reduces to roots (مقلوبة → قلب, دجاج → دجج), which is far too aggressive for search.
- **Tashaphyne:** maps أرز to رز, but also كرز → رز and برز → رز. That would make cherry match rice.

رز ↔ أرز is a vocabulary problem, not a stemming problem.

---

## 8. Hosting

Azure Database for PostgreSQL Flexible Server: "You can't bring your own extensions" ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/postgresql/extensions/how-to-create-extensions)). `pg_trgm` and `unaccent` are allowed.

## 9. Postgres details

- **PG 18 generated columns are virtual by default.** Without `STORED`, `CREATE INDEX` fails: "indexes on virtual generated columns are not supported".
- **A generated column can't use another generated column.** "A generated column cannot reference another generated column."
- **`normalize()` is IMMUTABLE,** so it can be used in an indexed function. NFKC turns ﻻ ﺍﻟﺮﺯ into لا الرز.
- **`array_to_string()` is STABLE,** so a `text[]` column like `other_names` needs an IMMUTABLE helper before it can go into a generated column.
- **`%` and `_` in the user's text act as wildcards** in `LIKE`, even with bound parameters: `'axxc' LIKE '%a%c%'` is true. They must be escaped.
- **Decomposed hamza:** ا followed by U+0654 stayed أرز in the original function, while the precomposed form became ارز. NFKC first, plus the wider mark range up to U+065F, fixes it.
- **`ALTER COLUMN … SET EXPRESSION`** exists from PG 17 only.
- **Threshold settings set with `SET` stay on the connection,** and connection pools reuse it. Use `SET LOCAL` inside a transaction.

## 10. Unicode details

- Deleting a zero-width space glues words: رز + ZWSP + ابيض becomes رزابيض.
- U+06E5 and U+06E6 (small waw, small yeh) are letters, not marks. Deleting them is still right for search, because they only mark vowel length in Quranic text.
- NFKC is stable for characters already in Unicode: their output never changes across versions. Only newly added characters can behave differently on an older Postgres.

---

## 11. AI claims we checked

| Claim | Source | Result |
|---|---|---|
| builtin `C.UTF-8` fixes `pg_trgm` | Claude (earlier) | **Wrong** on PG 17 and 18 |
| PG 18 `pg_trgm` respects the builtin provider | Gemini | **Wrong.** Retested on 18.7 with the exact command: `{}` |
| `LC_COLLATE 'C'` + `LC_CTYPE 'C.UTF-8'` works | both | Confirmed on 17 and 18 |
| PG 18 generated columns are virtual by default | both | Confirmed |
| `normalize()` works in an IMMUTABLE function | both | Confirmed |
| Mark range must reach U+065F | Claude | Confirmed |
| Stored column is faster because of the re-check | both | Matches the 1.5 vs 14 ms. Confirming with `EXPLAIN (ANALYZE, BUFFERS)` is an M2 task |
| `%> ANY(array)` slows down at 500k+ rows | Gemini | Not tested yet. Fine at 50k (77 ms) |
| About 3% of Wikidata items have Arabic labels | Claude | Not verified |
