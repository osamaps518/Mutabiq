# Cleaning rules (draft)

The cleaning rules from [decision 7](decisions.md#7-cleaning-rules), written out character by character. M1 turns this draft into `spec/v1.md` with shared test cases. Until then the rules are provisional, to be checked against the labelled queries before 1.0.

The rules run in this order, on the whole text. Every example below is `input → output`, and was checked against `research/v1/ar_norm_v1.py`. Where an invisible character is part of an example, it's written as its code point.

Rules 3 to 10 touch separate sets of characters, and none of them produces a character another one touches, so their order among themselves doesn't change the output. Rules 1, 2 and 11 have to be where they are, as each section says.

---

## 1. Unicode NFKC

Apply Unicode normalization form NFKC.

- **Touches:** every character NFKC changes. For these rules that means most Arabic presentation forms (in U+FB50–U+FDFF and U+FE70–U+FEFC), fullwidth ASCII (U+FF01–U+FF5E), the non-ASCII spaces listed in rule 11, and letter + mark pairs that have a precomposed letter.
- **Examples:**
  - `ﻻ ﺍﻟﺮﺯ` (U+FEFB U+0020 U+FE8D U+FEDF U+FEAE U+FEAF) → `لا الرز`
  - `ＲＩＣＥ` → `rice`
  - ا U+0654 رز → `ارز`
  - مسو U+0654 ول → `مسؤول`
- **Why:** text pasted from PDFs often comes in presentation forms ([plan](plan.md#the-problem)), and decomposed hamza otherwise cleans differently from the precomposed letter ([findings 9](findings.md#9-postgres-details)).
- **Order:** first, because its output feeds every later rule:
  - Some presentation forms become a space plus a mark: U+FE70 ARABIC FATHATAN ISOLATED FORM → U+0020 U+064B. Rule 3 deletes the mark and rule 11 cleans up the space, so رز U+FE70 ابيض → `رز ابيض`.
  - Fullwidth capitals become A–Z before rule 2 maps them.
  - NBSP and other spaces become U+0020 before rule 11.
  - و U+0654 becomes ؤ, which the rules keep, like the precomposed letter. Without NFKC first, rule 3 would delete the hamza and give مسوول.

**Unicode versions.** Python 3.11 has Unicode 14.0 and 3.15 has 17.0. Postgres 15 has 14.0, 16 has 15.0, 17 has 15.1 and 18 has 16.0. Every character named in these rules existed in Unicode 14.0, and none of them changes under NFKC, so the version doesn't matter for them: Unicode's stability policy fixes NFKC output for characters that already exist. It matters only for characters added later that NFKC maps to ones the rules touch. The outlined Latin letters and digits U+1CCD6–U+1CCF9 (Unicode 16.0) and U+A7F1 MODIFIER LETTER CAPITAL S (17.0) become A–Z and 0–9 on newer versions and stay as they are on older ones. No Arabic character added since 14.0 changes under NFKC.

---

## 2. A–Z to a–z, then `lower()`

Map U+0041–U+005A (A–Z) to U+0061–U+007A (a–z), then apply `lower()`.

- **Example:** `Rice ARZ` → `rice arz`
- **Why:** Postgres's `lower()` follows the database locale, and a Turkish locale turns `I` into `ı` ([decision 7](decisions.md#7-cleaning-rules), [findings 2](findings.md#2-sql-cleaning-matches-python)). The explicit map changes nothing in Python, whose `lower()` ignores locale. It exists for Postgres. For other scripts `lower()` can still differ by locale, as decision 7 says.
- **Order:** after NFKC, so that fullwidth and other compatibility capitals are A–Z by then.

---

## 3. Delete marks, tatweel and invisible characters

Delete every character listed below.

### Diacritics, Quranic marks and small letters

| Code point | Name |
|---|---|
| U+064B | ARABIC FATHATAN |
| U+064C | ARABIC DAMMATAN |
| U+064D | ARABIC KASRATAN |
| U+064E | ARABIC FATHA |
| U+064F | ARABIC DAMMA |
| U+0650 | ARABIC KASRA |
| U+0651 | ARABIC SHADDA |
| U+0652 | ARABIC SUKUN |
| U+0653 | ARABIC MADDAH ABOVE |
| U+0654 | ARABIC HAMZA ABOVE |
| U+0655 | ARABIC HAMZA BELOW |
| U+0656 | ARABIC SUBSCRIPT ALEF |
| U+0657 | ARABIC INVERTED DAMMA |
| U+0658 | ARABIC MARK NOON GHUNNA |
| U+0659 | ARABIC ZWARAKAY |
| U+065A | ARABIC VOWEL SIGN SMALL V ABOVE |
| U+065B | ARABIC VOWEL SIGN INVERTED SMALL V ABOVE |
| U+065C | ARABIC VOWEL SIGN DOT BELOW |
| U+065D | ARABIC REVERSED DAMMA |
| U+065E | ARABIC FATHA WITH TWO DOTS |
| U+065F | ARABIC WAVY HAMZA BELOW |
| U+0670 | ARABIC LETTER SUPERSCRIPT ALEF |
| U+06D6 | ARABIC SMALL HIGH LIGATURE SAD WITH LAM WITH ALEF MAKSURA |
| U+06D7 | ARABIC SMALL HIGH LIGATURE QAF WITH LAM WITH ALEF MAKSURA |
| U+06D8 | ARABIC SMALL HIGH MEEM INITIAL FORM |
| U+06D9 | ARABIC SMALL HIGH LAM ALEF |
| U+06DA | ARABIC SMALL HIGH JEEM |
| U+06DB | ARABIC SMALL HIGH THREE DOTS |
| U+06DC | ARABIC SMALL HIGH SEEN |
| U+06DD | ARABIC END OF AYAH |
| U+06DE | ARABIC START OF RUB EL HIZB |
| U+06DF | ARABIC SMALL HIGH ROUNDED ZERO |
| U+06E0 | ARABIC SMALL HIGH UPRIGHT RECTANGULAR ZERO |
| U+06E1 | ARABIC SMALL HIGH DOTLESS HEAD OF KHAH |
| U+06E2 | ARABIC SMALL HIGH MEEM ISOLATED FORM |
| U+06E3 | ARABIC SMALL LOW SEEN |
| U+06E4 | ARABIC SMALL HIGH MADDA |
| U+06E5 | ARABIC SMALL WAW |
| U+06E6 | ARABIC SMALL YEH |
| U+06E7 | ARABIC SMALL HIGH YEH |
| U+06E8 | ARABIC SMALL HIGH NOON |
| U+06E9 | ARABIC PLACE OF SAJDAH |
| U+06EA | ARABIC EMPTY CENTRE LOW STOP |
| U+06EB | ARABIC EMPTY CENTRE HIGH STOP |
| U+06EC | ARABIC ROUNDED HIGH STOP WITH FILLED CENTRE |
| U+06ED | ARABIC SMALL LOW MEEM |

That's U+064B–U+065F, U+0670 and U+06D6–U+06ED. The last range also holds three signs that aren't marks (U+06DD, U+06DE, U+06E9) and two small letters (U+06E5, U+06E6). Deleting them is still right for search, since they only appear in Quranic text ([findings 10](findings.md#10-unicode-details)).

### Tatweel

| Code point | Char | Name |
|---|---|---|
| U+0640 | ـ | ARABIC TATWEEL |

### Invisible characters

| Code point | Name |
|---|---|
| U+200C | ZERO WIDTH NON-JOINER |
| U+200D | ZERO WIDTH JOINER |
| U+200E | LEFT-TO-RIGHT MARK |
| U+200F | RIGHT-TO-LEFT MARK |
| U+202A | LEFT-TO-RIGHT EMBEDDING |
| U+202B | RIGHT-TO-LEFT EMBEDDING |
| U+202C | POP DIRECTIONAL FORMATTING |
| U+202D | LEFT-TO-RIGHT OVERRIDE |
| U+202E | RIGHT-TO-LEFT OVERRIDE |
| U+2066 | LEFT-TO-RIGHT ISOLATE |
| U+2067 | RIGHT-TO-LEFT ISOLATE |
| U+2068 | FIRST STRONG ISOLATE |
| U+2069 | POP DIRECTIONAL ISOLATE |
| U+061C | ARABIC LETTER MARK |
| U+FEFF | ZERO WIDTH NO-BREAK SPACE |
| U+00AD | SOFT HYPHEN |

U+200B ZERO WIDTH SPACE isn't here: rule 4 turns it into a space.

This is a fixed list, not "Unicode category Cf". SQL can't test a character's category, and categories grow with each Unicode version, so Python 3.11 and 3.15 would disagree.

- **Examples:**
  - `مَقْلُوبَة` → `مقلوبه`
  - `ٱلرَّحْمَٰنِ` → `الرحمن`
  - `دجـــاج` → `دجاج`
  - ر U+200C ز U+200F → `رز`
  - U+202B رز U+202C → `رز`
- **Why:** diacritics and Quranic marks are optional in writing, tatweel only stretches a word, and invisible characters come in with pasted text. None of them changes the word ([plan](plan.md#the-problem)). The mark range has to reach U+065F so that a decomposed hamza is removed ([findings 9](findings.md#9-postgres-details)).

---

## 4. Zero-width space becomes a space

| Code point | Name | Becomes |
|---|---|---|
| U+200B | ZERO WIDTH SPACE | U+0020 SPACE |

- **Example:** رز U+200B ابيض → `رز ابيض`. This differs from the research code, which gives `رزابيض`.
- **Why:** deleting it would glue two words together ([decision 7](decisions.md#7-cleaning-rules), [findings 10](findings.md#10-unicode-details)).
- **Order:** before rule 11, which collapses the space with any next to it.

---

## 5. Alef forms to ا

| Code point | Char | Name | Becomes |
|---|---|---|---|
| U+0623 | أ | ARABIC LETTER ALEF WITH HAMZA ABOVE | U+0627 ا |
| U+0625 | إ | ARABIC LETTER ALEF WITH HAMZA BELOW | U+0627 ا |
| U+0622 | آ | ARABIC LETTER ALEF WITH MADDA ABOVE | U+0627 ا |
| U+0671 | ٱ | ARABIC LETTER ALEF WASLA | U+0627 ا |

- **Example:** `أرز إرز آرز ٱرز` → `ارز ارز ارز ارز`
- **Why:** the same word is written with any of these alef forms, or with a bare alef ([plan](plan.md#the-problem)).

---

## 6. ة to ه

| Code point | Char | Name | Becomes |
|---|---|---|---|
| U+0629 | ة | ARABIC LETTER TEH MARBUTA | U+0647 ه ARABIC LETTER HEH |

- **Example:** `مقلوبة` → `مقلوبه`
- **Why:** a final ة is often typed as ه ([plan](plan.md#the-problem)).

---

## 7. ى to ي

| Code point | Char | Name | Becomes |
|---|---|---|---|
| U+0649 | ى | ARABIC LETTER ALEF MAKSURA | U+064A ي ARABIC LETTER YEH |

- **Example:** `مستشفى` → `مستشفي`
- **Why:** a final ى and ي are used for each other ([plan](plan.md#the-problem)).

---

## 8. ئ to ي

| Code point | Char | Name | Becomes |
|---|---|---|---|
| U+0626 | ئ | ARABIC LETTER YEH WITH HAMZA ABOVE | U+064A ي ARABIC LETTER YEH |

- **Example:** `شاطئ` → `شاطي`
- **Why:** شاطئ is also written شاطي. ء (U+0621) and ؤ (U+0624) are kept, since mapping ؤ → و wouldn't make مسؤول and مسئول match ([decision 7](decisions.md#7-cleaning-rules)). So `سماء مسؤول` → `سماء مسؤول`.

---

## 9. Persian ی and ک

| Code point | Char | Name | Becomes |
|---|---|---|---|
| U+06CC | ی | ARABIC LETTER FARSI YEH | U+064A ي ARABIC LETTER YEH |
| U+06A9 | ک | ARABIC LETTER KEHEH | U+0643 ك ARABIC LETTER KAF |

- **Example:** `کیک` → `كيك`
- **Why:** Persian keyboards type these instead of the Arabic letters ([plan](plan.md#the-problem)).

---

## 10. Digits to 0–9

| Arabic-Indic | Persian | Becomes |
|---|---|---|
| U+0660 ٠ | U+06F0 ۰ | U+0030 0 |
| U+0661 ١ | U+06F1 ۱ | U+0031 1 |
| U+0662 ٢ | U+06F2 ۲ | U+0032 2 |
| U+0663 ٣ | U+06F3 ۳ | U+0033 3 |
| U+0664 ٤ | U+06F4 ۴ | U+0034 4 |
| U+0665 ٥ | U+06F5 ۵ | U+0035 5 |
| U+0666 ٦ | U+06F6 ۶ | U+0036 6 |
| U+0667 ٧ | U+06F7 ۷ | U+0037 7 |
| U+0668 ٨ | U+06F8 ۸ | U+0038 8 |
| U+0669 ٩ | U+06F9 ۹ | U+0039 9 |

The first column is ARABIC-INDIC DIGIT ZERO to NINE, the second EXTENDED ARABIC-INDIC DIGIT ZERO to NINE.

- **Examples:** `٢٥٠ غرام` → `250 غرام`, `۱۲ بیضه` → `12 بيضه`
- **Why:** the same number is typed in any of the three digit sets ([plan](plan.md#the-problem)).

---

## 11. Collapse whitespace

Replace each run of ASCII whitespace with one U+0020 SPACE, then trim it from both ends.

| Code point | Name |
|---|---|
| U+0009 | CHARACTER TABULATION (`\t`) |
| U+000A | LINE FEED (`\n`) |
| U+000B | LINE TABULATION (`\v`) |
| U+000C | FORM FEED (`\f`) |
| U+000D | CARRIAGE RETURN (`\r`) |
| U+0020 | SPACE |

NFKC (rule 1) has already turned U+00A0 NO-BREAK SPACE, U+2000–U+200A, U+202F, U+205F and U+3000 into U+0020, and rule 4 has turned U+200B into U+0020.

- **Examples:**
  - U+0020 U+0020 رز U+00A0 U+00A0 ابيض U+0009 U+0009 مسلوق U+0020 U+0020 → `رز ابيض مسلوق`
  - رز U+0020 U+064B U+0020 ابيض → `رز ابيض`
- **Why:** pasted text brings extra spaces, tabs and line breaks. Decision 7 says "collapse whitespace". Trimming both ends is part of that, not a new rule.
- **Order:** last, because rules 1, 3 and 4 can leave spaces next to each other or at the ends.

---

## Differences from research/v1

Each rule compared with `research/v1/ar_norm_v1.py` and `ar_norm_v1.sql`:

| Rule | research/v1 |
|---|---|
| 1. NFKC | Same |
| 2. A–Z, then `lower()` | Only `lower()`. Same output in Python. In a Turkish-locale database its SQL turns `I` into `ı` ([findings 2](findings.md#2-sql-cleaning-matches-python)) |
| 3. Delete | Same list, plus U+200B |
| 4. Zero-width space | Deletes it, because its range U+200B–U+200F includes it: رز U+200B ابيض → `رزابيض`, where this draft gives `رز ابيض` |
| 5–10. Letters and digits | Same |
| 11. Whitespace | Same, including the trim |

The draft follows decision 7 in rules 2 and 4. The trim in rule 11 isn't in decision 7, and the draft states it as part of collapsing whitespace.

---

## Open cases

These are kept as they are for now. Settle each against the labelled queries before 1.0. Changing any of them would change a rule, so it needs a new entry in [decisions.md](decisions.md).

1. **Other invisible characters.** U+2060 WORD JOINER and U+180E MONGOLIAN VOWEL SEPARATOR (category Cf), and U+034F COMBINING GRAPHEME JOINER (a mark that is also invisible), aren't deleted: رز U+2060 ابيض stays as it is.
2. **Whitespace NFKC leaves alone.** U+0085 NEXT LINE, U+1680 OGHAM SPACE MARK, U+2028 LINE SEPARATOR, U+2029 PARAGRAPH SEPARATOR and U+001C–U+001F aren't turned into spaces: رز U+2028 ابيض stays one word. Python's `str.split()` treats them as whitespace, rule 11 doesn't.
3. **Arabic marks outside the ranges.** U+0610–U+061A (honorific signs and small fatha, damma, kasra) and the marks in U+0898–U+08FF (Arabic Extended-A and -B) aren't deleted: رز U+0618 keeps its mark.
4. **High hamza and wavy hamza alefs.** NFKC turns U+0675–U+0678 into a letter plus U+0674 ARABIC LETTER HIGH HAMZA, which no rule removes: U+0675 → ا U+0674. U+0672 and U+0673 (ALEF WITH WAVY HAMZA ABOVE and BELOW) aren't mapped to ا.
5. **Other Persian and Urdu letters.** Only ی and ک are mapped. ۀ (U+06C0), ہ (U+06C1), ۃ (U+06C3), ھ (U+06BE), ە (U+06D5) and ے (U+06D2) are kept. NFKC also composes ە U+0654 into ۀ, which then stays.
6. **Arabic decimal and thousands separators.** U+066B and U+066C aren't mapped, so `١٫٥` → `1٫5`, not `1.5`. Punctuation in general, Arabic (، ؛ ؟) or ASCII, is kept.
