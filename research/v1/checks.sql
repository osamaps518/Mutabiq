\pset footer off
SELECT version();
SELECT length('أإآٱةىئیک٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹') from_len, length('ااااهيييك01234567890123456789') to_len;
SELECT proname, provolatile, proparallel FROM pg_proc WHERE proname='ar_norm_v1';
SELECT label, ar_norm_v1(v) out FROM (VALUES
 ('diacritics+taa','مَقْلُوبَة'),('hamza alefs','أرز إرز آرز ٱرز'),('decomposed hamza (ا+U+0654)',E'\u0627\u0654\u0631\u0632'),
 ('decomposed madda (ا+U+0653)',E'\u0627\u0653'),('presentation forms',E'\uFEFB \uFE8D\uFEDF\uFEAE\uFEAF'),
 ('ZWNJ/RLM/ALM/BOM inside',E'ر\u200Cز\u200F \u061Cارز\uFEFF'),('NBSP + tabs','رز\u00A0\u00A0ابيض\t\tمسلوق  '),
 ('Quranic marks','ٱلرَّحْمَٰنِ ۖ'),('tatweel','دجـــاج'),('digits','٢ بيض ۴ بیض'),('alef maqsura / yeh hamza','مستشفى شاطئ'),
 ('keep hamza ء / ؤ','سماء مسؤول'),('Persian kaf/yeh','کیک'),('Latin','Rice ARZ')) v(label,v);
SELECT count(*) FILTER (WHERE ar_norm_v1(ar_norm_v1(x)) <> ar_norm_v1(x)) idempotence_failures, count(*) n
FROM (SELECT string_agg(chr(c), '') x FROM (SELECT g, (ARRAY[1569,1571,1573,1575,1577,1609,1610,1574,1611,1617,1648,1600,1632,1780,8204,65275,65165,1620,1619,1649,32,160,1740,1705,1572,1749,1758])[1+floor(random()*27)::int] c
      FROM generate_series(1,200000) g) s GROUP BY g/10) t;
DROP TABLE IF EXISTS v1_foods;
CREATE TABLE v1_foods(id serial, name text, name_search text GENERATED ALWAYS AS (ar_norm_v1(name)) STORED);
CREATE INDEX ON v1_foods USING gin (name_search gin_trgm_ops);
CREATE INDEX ON v1_foods USING gin (ar_norm_v1(name) gin_trgm_ops);
SELECT 'STORED generated column + both GIN indexes accepted' ok;
SELECT show_trgm(ar_norm_v1('أرز')) <> '{}' AS doctor_trgm_sees_arabic;
