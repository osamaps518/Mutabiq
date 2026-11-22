DROP DATABASE IF EXISTS t_b2; CREATE DATABASE t_b2 TEMPLATE template0 LOCALE_PROVIDER builtin BUILTIN_LOCALE 'C.UTF-8' ENCODING UTF8;
DROP DATABASE IF EXISTS t_lc; CREATE DATABASE t_lc TEMPLATE template0 ENCODING UTF8 LC_COLLATE 'C' LC_CTYPE 'C';
\c t_b2
CREATE EXTENSION pg_trgm;
SELECT version(), datname, datlocprovider, datcollate, datctype, datlocale FROM pg_database WHERE datname=current_database();
SELECT show_trgm('ارز') ;
\c t_lc
CREATE EXTENSION pg_trgm;
SELECT datname, datlocprovider, datcollate, datctype, datlocale FROM pg_database WHERE datname=current_database();
SELECT show_trgm('ارز');
\c t_en
SELECT proname, provolatile FROM pg_proc WHERE proname IN ('normalize','is_normalized','lower','translate','regexp_replace') ORDER BY 1;
SELECT normalize('ﻻ ﺍﻟﺮﺯ', NFKC) nfkc, normalize(E'\u0627\u0654', NFC) nfc_alef_hamza_above, E'\u0627\u0654' = 'أ' raw_equal;
SELECT ar_norm(E'\u0627\u0654\u0631\u0632') decomposed_arz, ar_norm('أرز') precomposed;
SELECT oprname, oprleft::regtype, oprright::regtype FROM pg_operator WHERE oprname IN ('<<%','%>>','<<<->','<->>>') ORDER BY 1;
SELECT strict_word_similarity('رز','كرز رز') a, 'رز' <<% 'رز ابيض' b, 'رز' <<% 'كرز' c;
\c postgres
CREATE TEMP TABLE g(a int, b int GENERATED ALWAYS AS (a*2));
SELECT attname, attgenerated FROM pg_attribute WHERE attrelid='g'::regclass AND attname='b';
CREATE INDEX ON g(b);
