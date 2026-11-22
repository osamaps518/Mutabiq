import json, random, subprocess, sys
from ar_norm_v1 import ar_norm_v1
port = sys.argv[1]
pool = list('ابتثجحخدذرزسشصضطظعغفقكلمنهويءآأإؤئةىیکٱـ ') + [chr(c) for c in range(0x064B,0x0660)] + ['\u0670','\u06D6','\u06DA','\u06ED','\u200C','\u200F','\u061C','\uFEFF','\u00A0','\t','\u202B','\u2067','\u00AD'] \
     + [chr(0x0660+i) for i in range(10)] + [chr(0x06F0+i) for i in range(10)] + ['\uFEFB','\uFE8D','\uFEDF','\uFEAE','\uFEAF','\uFB8E','\uFBFD'] + list('AbCz0')
random.seed(7)
words = [''.join(random.choice(pool) for _ in range(random.randint(1,14))) for _ in range(20000)]
sql = "SELECT json_agg(ar_norm_v1(x) ORDER BY o) FROM json_array_elements_text($J$%s$J$::json) WITH ORDINALITY t(x,o);" % json.dumps(words, ensure_ascii=False)
res = json.loads(subprocess.run(['psql','-h','/tmp','-p',port,'-U','postgres','-X','-At','-d','t_en'],input=sql,capture_output=True,text=True).stdout)
mism = [(w, ar_norm_v1(w), r) for w, r in zip(words, res) if ar_norm_v1(w) != r]
print(f"port={port} tested={len(words)} mismatches={len(mism)}")
for m in mism[:10]: print("  ", [hex(ord(c)) for c in m[0]], repr(m[1]), repr(m[2]))
