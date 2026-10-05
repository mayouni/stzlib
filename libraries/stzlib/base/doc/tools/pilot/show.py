import json,sys
d=json.load(open(sys.argv[1],encoding="utf-8"))
for k,v in d.items():
    print("==",k, "" if v["ok"] else "  !!"+v["error"][:200])
    for l in v["lines"]: print("   ",l)
    if not v["ok"]: print("    printed:",v["printed"])
