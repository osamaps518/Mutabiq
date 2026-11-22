# Mutabiq verification scripts (2026-11-21)

## v1/  (the current spec, use these)
- `ar_norm_v1.sql`  Postgres IMMUTABLE function, spec v1. Requires a UTF8 database.
- `ar_norm_v1.py`   Python reference implementation (must stay identical in behaviour).
- `checks.sql` / `checks.out`  Spot checks of v1 (marks, alef forms, digits, invisible chars, idempotence).
- `parity_v1.py` / `parity_v1.out`  20,000 random strings, SQL vs Python. Result: 0 mismatches on PG18.7 and PG17.12.
  Usage: `python3 parity_v1.py <port>`. It connects via `psql -h /tmp -U postgres -d t_en`, so edit those for your setup,
  and load `ar_norm_v1.sql` into that database first.

## exploration/  (the exploration that led to v1, numbered in order)
01 create test DBs per locale | 02 locale probe (pg_trgm returns {} under C/POSIX and builtin C.UTF-8)
03/04 first normalization draft + parity (superseded by v1) | 05 index + EXPLAIN (generated column vs expression index)
06 lower() per locale | 07 the 2-char رز contains branch and its false positives | 08 Snowball stemmer
09 PG17 locale probe | 10 Python stemmers | 11 alias table SQL | 12 builtin-provider recheck | 13 normalization mark range
`run_all.sh` reproduces 01–11 with throwaway clusters (needs PGDG postgresql-17/18 and en_US, ar_EG, tr_TR locales).
`README.md` in exploration/ has the findings summary.

Key working locale: `LC_COLLATE 'C' LC_CTYPE 'C.UTF-8'` (libc).
