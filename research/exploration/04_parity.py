"""Parity: Python reference of GHBot issue-57 rules vs SQL ar_norm(), over hand cases + 20k random strings."""
import random, re, subprocess, json, sys
DIAC = re.compile('[\u064B-\u0652\u0670\u0640]')
MAP = str.maketrans({'أ':'ا','إ':'ا','آ':'ا','ة':'ه','ى':'ي','ئ':'ي','ی':'ي','ک':'ك',
    **{chr(0x0660+i):str(i) for i in range(10)}, **{chr(0x06F0+i):str(i) for i in range(10)}})
def py_norm(s): return DIAC.sub('', s.lower()).translate(MAP)
db = sys.argv[1]
hand = ['مَقْلُوبَة','مقلوبه','أرز','إرز','آرز','ارز','رز','مستشفى','شاطئ','سماء','جزء','مؤمن','ـــدجاجـــ','٢ بيض','۲ بيض','کیک','ی','Rice ARZ','İSTANBUL','ΣΑΣ','الأَرُزّ','قُرْآن','ٱلرَّحْمَٰن']
pool = list('ابتثجحخدذرزسشصضطظعغفقكلمنهويءآأإؤئةىیکـ ') + [chr(c) for c in range(0x064B,0x0653)] + ['\u0670'] + [chr(0x0660+i) for i in range(10)] + [chr(0x06F0+i) for i in range(10)] + list('AbCzİI0')
random.seed(1)
rand = [''.join(random.choice(pool) for _ in range(random.randint(1,12))) for _ in range(20000)]
allw = hand + rand
data = json.dumps(allw, ensure_ascii=False)
sql = "SELECT json_agg(ar_norm(x) ORDER BY o) FROM json_array_elements_text(%s::json) WITH ORDINALITY t(x,o);" % ("$J$"+data+"$J$")
out = subprocess.run(['psql','-h','/tmp','-p','5499','-U','postgres','-X','-At','-d',db],input=sql,capture_output=True,text=True)
res = json.loads(out.stdout)
mism = [(w, py_norm(w), r) for w,r in zip(allw,res) if py_norm(w)!=r]
print(f"db={db} tested={len(allw)} mismatches={len(mism)}")
for w,p,r in mism[:15]: print("  MISMATCH", repr(w), "py=",repr(p), "sql=",repr(r))
for w,r in zip(hand,res[:len(hand)]): print(f"  {w!r:22} -> {r!r}")
non_arabic_cause = [m for m in mism if not any(ch in m[0] for ch in 'İΣ')]
print(f"  mismatches NOT explained by İ / Greek sigma (Unicode lower() special cases): {len(non_arabic_cause)}")
