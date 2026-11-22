-- ar_norm_v1: Arabic search normalization, spec v1. Requires a UTF8 database.
CREATE OR REPLACE FUNCTION ar_norm_v1(t text) RETURNS text
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
  SELECT btrim(regexp_replace(
    translate(
      regexp_replace(
        lower(normalize(t, NFKC)),
        -- harakat + extended marks, superscript alef, Quranic marks, tatweel, invisible/bidi controls, soft hyphen
        '[\u064B-\u065F\u0670\u06D6-\u06ED\u0640\u200B-\u200F\u202A-\u202E\u2066-\u2069\u061C\uFEFF\u00AD]',
        '', 'g'),
      'أإآٱةىئیک٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹',   -- 29 chars
      'ااااهيييك01234567890123456789'),   -- 29 chars
    '[ \t\n\r\f\v]+', ' ', 'g'));
$$;
