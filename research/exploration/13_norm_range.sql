\c t_en
CREATE OR REPLACE FUNCTION ar_norm_nfc(t text) RETURNS text LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
  SELECT translate(regexp_replace(lower(normalize(t, NFC)), '[\u064B-\u065F\u0670\u0640]', '', 'g'),
    'أإآةىئیک٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹','اااهيييك01234567890123456789') $$;
SELECT w AS label, ar_norm(v) cur, ar_norm_nfc(v) nfc_065f
FROM (VALUES ('أرز decomposed (ا+U+0654)', E'\u0627\u0654\u0631\u0632'), ('أرز precomposed','أرز'),
             ('مسؤول decomposed (و+U+0654)', E'\u0645\u0633\u0648\u0654\u0648\u0644'), ('مسؤول precomposed','مسؤول'),
             ('آ decomposed (ا+U+0653)', E'\u0627\u0653'), ('ﻻ presentation form', 'ﻻ')) v(w,v);
CREATE TABLE IF NOT EXISTS t_nfc(name text, s text GENERATED ALWAYS AS (ar_norm_nfc(name)) STORED);
CREATE INDEX IF NOT EXISTS t_nfc_i ON t_nfc USING gin (ar_norm_nfc(name) gin_trgm_ops);
SELECT 'nfc-based function accepted for generated col + expression index' ok;
