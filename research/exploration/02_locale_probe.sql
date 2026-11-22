CREATE EXTENSION IF NOT EXISTS pg_trgm;
SELECT current_database() db, d.datlocprovider prov, d.datcollate collate, d.datctype ctype, coalesce(d.datlocale,'') locale
  FROM pg_database d WHERE datname=current_database();
SELECT show_trgm('أرز') AS trgm_arz, show_trgm('مقلوبة') AS trgm_maqluba, show_trgm('rice') AS trgm_rice;
SELECT similarity('مقلوبة','مقلوبه') sim_maqluba, word_similarity('رز','ارز') ws_rz_arz,
       'أرز' % 'ارز' AS pct_arz;
-- lower()/upper() and case behaviour
SELECT lower('أرز ABC') l1, lower('İSTANBUL') l_turkish_I, upper('ı') u_dotless, lower('ΣΑΣ') greek_final_sigma;
