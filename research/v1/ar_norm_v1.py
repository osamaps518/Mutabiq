"""Reference Python implementation of Arabic search normalization spec v1 (mirror of sql/ar_norm_v1)."""
import re, unicodedata
_STRIP = re.compile('[\u064B-\u065F\u0670\u06D6-\u06ED\u0640\u200B-\u200F\u202A-\u202E\u2066-\u2069\u061C\uFEFF\u00AD]')
_MAP = str.maketrans({**dict(zip('أإآٱةىئیک', 'ااااهيييك')),
    **{chr(0x0660+i): str(i) for i in range(10)}, **{chr(0x06F0+i): str(i) for i in range(10)}})
_WS = re.compile('[ \t\n\r\f\v]+')
def ar_norm_v1(s: str) -> str:
    s = unicodedata.normalize('NFKC', s).lower()
    return _WS.sub(' ', _STRIP.sub('', s).translate(_MAP)).strip(' ')
