\pset footer off
SET pg_trgm.word_similarity_threshold = 0.5;
SELECT word_similarity('رز','ارز') ws_rz_arz, word_similarity('ارز','رز') ws_reverse, similarity('رز','ارز') sim,
       strict_word_similarity('رز','ارز') strict_ws, show_limit() sim_limit, current_setting('pg_trgm.word_similarity_threshold') ws_limit;
WITH w(name) AS (VALUES ('أرز'),('ارز'),('الأرز'),('رز'),('رز أبيض'),('أرز بسمتي'),('رز بحليب'),('أرز بالشعيرية'),
  ('برز'),('فرز'),('مرزوق'),('برزة'),('حرز'),('طرز'),('خرزة'),('مقرمرزة'),('جرز'),('تمر زهدي'),('زيت'),('زعتر'),('أرزة لبنان'),('كرز'),('كرزات'),('مارزيبان'),('ترمس'))
SELECT name, ar_norm(name) norm,
  ar_norm(name) LIKE '%'||ar_norm('رز')||'%' AS contains,
  ar_norm('رز') <% ar_norm(name) AS ws_ge_05,
  round(word_similarity(ar_norm('رز'), ar_norm(name))::numeric,3) ws,
  (ar_norm(name) LIKE '%'||ar_norm('رز')||'%' OR ar_norm('رز') <% ar_norm(name)) AS ghbot_hit,
  ar_norm(name) ~ ('(^|\s)' || ar_norm('رز') || '(\s|$)') AS whole_word_only
FROM w ORDER BY ghbot_hit DESC, name;
