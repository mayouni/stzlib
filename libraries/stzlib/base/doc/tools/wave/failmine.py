import json,sys
cls=sys.argv[1]
mine={e["name"] for e in json.load(open("w1_docs_%s.json"%cls,encoding="utf-8"))["entries"]}
r=json.load(open("ref_pilot.json",encoding="utf-8"))
c=[c for c in r["classes"] if c["name"]==cls][0]
f=[m for m in c["methods"] if m["name"] in mine and not m.get("pass")]
print(len(f),"of",len(mine),"of mine fail")
for m in f: print(" ",m["name"],m.get("checks"),"|",(m.get("brief") or "")[:90])
