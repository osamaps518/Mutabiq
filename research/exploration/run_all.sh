#!/bin/bash
# Reproduce everything. Needs postgresql-18 + postgresql-17 (PGDG) and locales en_US/ar_EG/tr_TR generated.
set -e; cd "$(dirname "$0")"
for v in 18:5499 17:5498; do V=${v%%:*}; PORT=${v##*:}; D=pgdata$([ $V = 17 ] && echo 17)
  [ -d $D ] || /usr/lib/postgresql/$V/bin/initdb -D $D -U postgres --encoding=UTF8 --locale=C
  /usr/lib/postgresql/$V/bin/pg_ctl -D $D -o "-p $PORT -k /tmp" -l pg$V.log start || true; done
sleep 2; P="psql -h /tmp -p 5499 -U postgres -X"
$P -f 01_create_dbs.sql; $P -c "CREATE DATABASE t_tr TEMPLATE template0 ENCODING 'UTF8' LOCALE 'tr_TR.UTF-8'" || true
for d in t_c t_posix t_builtin_c t_builtin t_builtin_ctype t_libc_mixed t_icu t_icu_en t_en t_cutf8 t_ar; do $P -d $d -f 02_locale_probe.sql; done > 02_locale_probe.out
for d in t_en t_builtin t_icu t_c t_ar; do $P -d $d -f 03_ar_norm.sql; python3 04_parity.py $d; done > 04_parity.out
$P -d t_en -f 05_index_explain.sql > 05_index_explain.out
for d in t_c t_en t_tr t_ar t_builtin t_icu; do $P -d $d -f 06_lower_locale.sql; done > 06_lower_locale.out
$P -d t_en -f 07_rz_contains.sql > 07_rz_contains.out
$P -d t_en -f 08_snowball.sql > 08_snowball.out
./venv/bin/python 10_python_stemmers.py > 10_python_stemmers.out
$P -d t_en -f 11_alias_sql.sql > 11_alias_sql.out
