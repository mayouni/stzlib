import json,sys
cls=sys.argv[1]
p=json.load(open("probe_%s.json"%cls,encoding="utf-8"))
import os
p2=json.load(open("probe2_%s.json"%cls,encoding="utf-8")) if os.path.exists("probe2_%s.json"%cls) else {}
for n in sys.argv[2].split(","):
    for tag,src in (("1",p),("2",p2)):
        v=src.get(n)
        if not v: continue
        for r in v["runs"]:
            if r.get("changed"):
                print(n,"("+tag+")",r.get("args"),"=>",r.get("after","")[:70]); break
