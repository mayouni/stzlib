import json, os, sys
S = os.environ.get("DOCWAVE_DIR", ".").rstrip("/") + "/"
B = os.environ.get("DOCWAVE_BASE", ".").rstrip("/") + "/"
cn = sys.argv[1]; lo = int(sys.argv[2]); hi = int(sys.argv[3])
b = json.load(open(B + "doc/reference.json", encoding="utf-8"))
rank = json.load(open(S + "usage_rank.json"))
top = {(r["class"].lower() + "." + r["name"].lower()) for r in rank[:300]}
order = {(r["class"] + "." + r["name"]): i for i, r in enumerate(rank)}
probe = json.load(open(S + "probe_%s.json" % cn, encoding="utf-8"))
p2 = json.load(open(S + "probe2_%s.json" % cn, encoding="utf-8")) if os.path.exists(S + "probe2_%s.json" % cn) else {}
done = set(open(S + "w1_done_%s.txt" % cn).read().split()) if os.path.exists(S + "w1_done_%s.txt" % cn) else set()
if os.path.exists(S + "w1_docs_%s.json" % cn):
    done |= {e["name"] for e in json.load(open(S + "w1_docs_%s.json" % cn, encoding="utf-8"))["entries"]}
c = next(x for x in b["classes"] if x["name"] == cn)
ms = [m for m in c["methods"] if m["key"] not in top and m["name"] not in done]
ms.sort(key=lambda m: order.get(cn + "." + m["name"], 99999))
for m in ms[lo:hi]:
    ps = ", ".join(p["name"] for p in m["parameters"])
    pr = probe.get(m["name"]); pt = ""
    if pr:
        good = [r for r in pr["runs"] if "ret" in r]
        if good:
            r = good[0]; pt = "=> %s%s" % (r["ret"][:70], " [CHANGES]" if r.get("changed") else "")
        else:
            pt = "ERR " + (pr["runs"][0].get("err", "") if pr["runs"] else "")[:60]
    q = p2.get(m["name"])
    if q:
        g = [r for r in q["runs"] if "ret" in r]
        if g:
            pt += " || 2nd: %s%s%s" % (g[0]["ret"][:60], " [CHANGES -> " + g[0].get("after", "")[:50] + "]" if g[0].get("changed") else "", " args " + g[0].get("args", "")[:30])
    print("%s(%s) | %s | %s%s" % (m["name"], ps, (m.get("brief") or "")[:110].replace("\n", " "), pt, " | INTERNAL" if m.get("status") == "internal" else ""))
print("#", len(ms[lo:hi]), "of", len(ms), file=sys.stderr)
