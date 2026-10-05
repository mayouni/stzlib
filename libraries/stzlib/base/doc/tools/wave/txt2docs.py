"""Compact wave-doc lines -> w1_docs_<class>.json.

    python txt2docs.py stzList w1_stzList_*.txt

A line:  Name | brief | returns | p1=role; p2=role | See1, See2 | warning | note
Empty fields stay empty. '#' lines and blank lines are ignored. The names are checked against
the class's roots in reference.json so a typo is caught here, not at the gate.
"""
import json, sys, glob, os

S = os.environ.get("DOCWAVE_DIR", ".").rstrip("/") + "/"
cls = sys.argv[1]
files = []
for a in sys.argv[2:]:
    files += sorted(glob.glob(a))
ref = json.load(open(os.environ.get("DOCWAVE_REF", "reference.json"), encoding="utf-8"))
roots = {m["name"] for c in ref["classes"] if c["name"] == cls for m in c["methods"]}
entries, seen = [], set()
for f in files:
    for ln, raw in enumerate(open(f, encoding="utf-8"), 1):
        raw = raw.rstrip("\n")
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        f_ = [x.strip() for x in raw.split("|")]
        while len(f_) < 7:
            f_.append("")
        name, brief, ret, par, see, warn, note = f_[:7]
        if name not in roots:
            print("UNKNOWN %s (%s:%d)" % (name, f, ln)); continue
        if name in seen:
            print("DUPLICATE %s (%s:%d)" % (name, f, ln)); continue
        seen.add(name)
        e = {"name": name, "brief": brief}
        if ret: e["returns"] = ret
        if par:
            d = {}
            for kv in par.split(";"):
                if "=" in kv:
                    k, v = kv.split("=", 1)
                    d[k.strip()] = v.strip()
            if d: e["params"] = d
        if see: e["see"] = [x.strip() for x in see.split(",") if x.strip()]
        if warn: e["warning"] = [warn]
        if note: e["note"] = [note]
        entries.append(e)
json.dump({"class": cls, "entries": entries}, open(S + "w1_docs_%s.json" % cls, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
print(len(entries), "entries ->", "w1_docs_%s.json" % cls)
