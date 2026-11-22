\pset footer off
CREATE EXTENSION IF NOT EXISTS pg_trgm;
SELECT current_database(), datctype FROM pg_database WHERE datname=current_database();
-- (a) Claude's function verbatim, WITH the space it says to remove
CREATE OR REPLACE FUNCTION ar_norm_claude_verbatim(t text) RETURNS text
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
  SELECT translate(
    regexp_replace(lower(t), '[\u064B-\u0652\u0670\u0640]', '', 'g'),
    'أإآةىئیک٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹',
    'اااهييي ك01234567890123456789');
$$;
-- (b) Corrected (space removed) = the candidate ar_norm
CREATE OR REPLACE FUNCTION ar_norm(t text) RETURNS text
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
  SELECT translate(
    regexp_replace(lower(t), '[\u064B-\u0652\u0670\u0640]', '', 'g'),
    'أإآةىئیک٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹',
    'اااهيييك01234567890123456789');
$$;
SELECT length('أإآةىئیک٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹') from_len, length('اااهييي ك01234567890123456789') to_len_verbatim, length('اااهيييك01234567890123456789') to_len_fixed;
SELECT w, ar_norm_claude_verbatim(w) verbatim, ar_norm(w) fixed FROM (VALUES ('کباب'),('كيک'),('٣ بيضات'),('۴ بیض')) v(w);
