\pset footer off
-- Plain-SQL variant/alias dictionary: expand the normalized query into its variant group, then search each
DROP TABLE IF EXISTS food_alias;
CREATE TABLE food_alias(grp int, term text);
INSERT INTO food_alias VALUES (1,ar_norm('أرز')),(1,ar_norm('رز')),(2,ar_norm('طماطم')),(2,ar_norm('بندورة')),(3,ar_norm('بطاطا')),(3,ar_norm('بطاطس'));
CREATE OR REPLACE FUNCTION ar_variants(q text) RETURNS text[] LANGUAGE sql STABLE AS $$
  SELECT coalesce(array_agg(DISTINCT a2.term), ARRAY[ar_norm(q)])
  FROM food_alias a1 JOIN food_alias a2 USING (grp) WHERE a1.term = ar_norm(q) $$;
SELECT ar_variants('رز') rz, ar_variants('بندورة') bandora, ar_variants('دجاج') no_alias;
SET pg_trgm.word_similarity_threshold = 0.5;
\echo '--- رز via alias expansion + whole-word trigram match (no substring LIKE): uses the GIN index, no برز/كرز/مرزوق'
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY ON)
SELECT id,name FROM foods WHERE name_search %> ANY (ar_variants('رز'));
SELECT DISTINCT regexp_replace(name,' [0-9]+$','') base FROM foods WHERE name_search %> ANY (ar_variants('رز')) ORDER BY 1 LIMIT 40;
