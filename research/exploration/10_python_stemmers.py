from nltk.stem.isri import ISRIStemmer
from nltk.stem.snowball import ArabicStemmer
from tashaphyne.stemming import ArabicLightStemmer
isri, snow, tl = ISRIStemmer(), ArabicStemmer(), ArabicLightStemmer()
words = ['رز','أرز','ارز','الأرز','الارز','مقلوبة','مقلوبه','بيض','بيضة','بيضات','دجاج','الدجاج','طماطم','بندورة','بسمتي','كرز','برز']
print(f"{'word':8} | ISRI stem | ISRI pre32 (light) | NLTK Snowball | Tashaphyne light stem | Tashaphyne root")
for w in words:
    tl.light_stem(w)
    print(f"{w:8} | {isri.stem(w):9} | {isri.pre32(isri.norm(w,1)):9} | {snow.stem(w):9} | {tl.get_stem():9} | {tl.get_root()}")
