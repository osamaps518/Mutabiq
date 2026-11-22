\pset footer off
SELECT cfgname FROM pg_ts_config WHERE cfgname='arabic';
SELECT w, ts_lexize('arabic_stem', w) lexize, to_tsvector('arabic', w) tsv, ts_lexize('arabic_stem', ar_norm(w)) lexize_after_ar_norm
FROM (VALUES ('رز'),('أرز'),('ارز'),('الأرز'),('الارز'),('بالأرز'),('مقلوبة'),('مقلوبه'),('بيض'),('بيضة'),('بيضات'),('دجاج'),('الدجاج'),('دجاجة'),('طماطم'),('بندورة'),('مَقْلُوبَة'),('كرز'),('برز')) v(w);
\echo '--- Does FTS equate رز and أرز?'
SELECT to_tsvector('arabic','أرز بسمتي') @@ plainto_tsquery('arabic','رز') AS rz_matches_arz,
       to_tsvector('arabic','الأرز') @@ plainto_tsquery('arabic','ارز') AS arz_matches_alarz,
       to_tsvector('arabic','مقلوبة') @@ plainto_tsquery('arabic','مقلوبه') AS taa_marbuta,
       to_tsvector('arabic','بيضة') @@ plainto_tsquery('arabic','بيض') AS bayda_bayd,
       to_tsvector('arabic','أرز') @@ plainto_tsquery('arabic','ارز') AS hamza_alef,
       to_tsvector('arabic','مقلوبة') @@ to_tsquery('arabic','مقل:*') AS prefix_query;
