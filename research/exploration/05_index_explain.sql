\pset footer off
\timing off
-- run in t_en after 03_ar_norm.sql
DROP TABLE IF EXISTS foods;
CREATE TABLE foods (id bigserial PRIMARY KEY, name text NOT NULL,
  name_search text GENERATED ALWAYS AS (ar_norm(name)) STORED);   -- generated column works
-- 50k synthetic rows: base food words (with hamza/taa-marbuta/diacritic variants) x modifiers
WITH base(w) AS (VALUES ('أرز'),('ارز'),('رز'),('الأرز'),('مقلوبة'),('مقلوبه'),('دجاج'),('الدجاج'),('بيض'),('بيضة'),('طماطم'),('بندورة'),
   ('خبز'),('لبن'),('زبادي'),('حمص'),('فول'),('فلافل'),('كبسة'),('منسف'),('مَنْسَف'),('شاورما'),('كنافة'),('برغل'),('عدس'),('شوربة'),('سلطة'),('تبولة'),('فتوش'),('بطاطا'),('بطاطس'),('كوسا'),('باذنجان'),('مرزوق'),('برزة'),('فرزات'),('جزر'),('تمر'),('حليب'),('جبنة')),
mods(m) AS (VALUES (''),(' أبيض'),(' بسمتي'),(' مسلوق'),(' مقلي'),(' مشوي'),(' بالخضار'),(' باللحم'),(' بالدجاج'),(' ١٠٠ غرام'),(' 200g'),(' كبير'),(' صغير'),(' منزلي'),(' عضوي'),(' مطبوخ'),(' طازج'),(' مجمد'),(' قليل الدسم'),(' كامل الدسم'))
INSERT INTO foods(name)
SELECT b.w || m.m || ' ' || (g % 63)::text FROM base b, mods m, generate_series(1,63) g;
SELECT count(*) AS rows FROM foods;
CREATE INDEX foods_ar_norm_trgm ON foods USING gin (ar_norm(name) gin_trgm_ops);   -- expression index
CREATE INDEX foods_name_search_trgm ON foods USING gin (name_search gin_trgm_ops);  -- generated-column index
ANALYZE foods;
SET pg_trgm.word_similarity_threshold = 0.5;

\echo '--- Q1: expression form, 4-char query مقلوبة (prepared, raw input normalized in SQL)'
PREPARE q(text) AS SELECT id, name FROM foods
  WHERE ar_norm(name) LIKE '%' || ar_norm($1) || '%' OR ar_norm($1) <% ar_norm(name);
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF, SUMMARY ON) EXECUTE q('مقلوبة');
\echo '--- Q2: same, 2-char query رز'
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF, SUMMARY ON) EXECUTE q('رز');
\echo '--- Q3: forcing generic plan (what a driver with server-side prepared statements may get)'
SET plan_cache_mode = force_generic_plan;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF, SUMMARY ON) EXECUTE q('مقلوبة');
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF, SUMMARY ON) EXECUTE q('رز');
RESET plan_cache_mode;
\echo '--- Q4: generated-column form'
PREPARE g(text) AS SELECT id, name FROM foods
  WHERE name_search LIKE '%' || ar_norm($1) || '%' OR ar_norm($1) <% name_search;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF, SUMMARY ON) EXECUTE g('مقلوبة');
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF, SUMMARY ON) EXECUTE g('رز');
\echo '--- Q5: baseline seq scan for comparison (index disabled)'
SET enable_bitmapscan = off; SET enable_indexscan = off;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF, SUMMARY ON) EXECUTE q('مقلوبة');
RESET enable_bitmapscan; RESET enable_indexscan;
\echo '--- trigrams extracted from short queries'
SELECT q, show_trgm(q) FROM (VALUES ('رز'),('ارز'),('مقلوبه')) v(q);
SELECT pg_size_pretty(pg_relation_size('foods')) heap, pg_size_pretty(pg_relation_size('foods_ar_norm_trgm')) idx_expr, pg_size_pretty(pg_relation_size('foods_name_search_trgm')) idx_gen;
\echo '--- result counts'
SELECT 'مقلوبة' q, count(*) FROM foods WHERE ar_norm(name) LIKE '%'||ar_norm('مقلوبة')||'%' OR ar_norm('مقلوبة') <% ar_norm(name)
UNION ALL SELECT 'رز', count(*) FROM foods WHERE ar_norm(name) LIKE '%'||ar_norm('رز')||'%' OR ar_norm('رز') <% ar_norm(name);
