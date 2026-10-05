#!/usr/bin/env python3
"""The defect register: every method whose doc block says it is broken today, from reference.json.

    python mk_defects.py <base>/doc/reference.json <base>/doc/DEFECTS.md <base>/doc/defects.json

A method is listed when its warning carries 'defect' or its brief says it raises, leaves the object
unchanged, or answers something wrong 'today'. The register is GENERATED: fix the method, fix its block
(or drop the warning), regenerate. The doc gate does not read it; stzlib sessions do.
"""
import json, re, sys, collections

ref = json.load(open(sys.argv[1], encoding="utf-8"))
RX = re.compile(r"^(Raises|Leaves|Answers|Does nothing|Returns)\b.*\btoday\b", re.I)
rows = []
for c in ref["classes"]:
    for m in c["methods"]:
        b = m.get("brief") or ""
        w = m.get("warnings") or []
        known = [x for x in w if "defect" in x.lower()]
        if known or RX.match(b):
            rows.append({"class": c["name"], "file": c["file"], "method": m["name"], "line": m["line"],
                         "symptom": b, "cause": " ".join(known or w)})
rows.sort(key=lambda r: (r["file"], r["class"].lower(), r["line"]))
json.dump({"count": len(rows), "defects": rows}, open(sys.argv[3], "w", encoding="utf-8"), indent=1, ensure_ascii=False)

by = collections.OrderedDict()
for r in rows:
    by.setdefault((r["file"], r["class"]), []).append(r)
out = ["# Defects found while documenting the library (generated)", "",
       "Each row is a method whose doc block says it is broken **today**: it raises, does nothing, or answers wrongly.",
       "They were found by calling every method once with real data before its block was written (DOCREFORM waves 1-4),",
       "and each was checked with a second call on different data. **None is fixed yet.** The register is generated from",
       "`reference.json` by `doc/tools/wave/mk_defects.py`: fix the method, fix its block (or drop the warning), regenerate.",
       "", "**At least %d methods in %d classes** (the register only catches the blocks worded as defects; the per-wave notes with the evidence list more, for instance stzTimeLine.HasMoment): `doc/tools/wave/data/w*_defects*.md`." % (len(rows), len(by)), "",
       "| file | class | defects |", "|---|---|---|"]
for (f, cl), rs in sorted(by.items(), key=lambda kv: -len(kv[1])):
    out.append("| %s | %s | %d |" % (f, cl, len(rs)))
out.append("")
for (f, cl), rs in by.items():
    out += ["## %s -- %s (%d)" % (cl, f, len(rs)), ""]
    for r in rs:
        cause = r["cause"].replace("known defect: ", "").replace("|", "/")
        out.append("- `%s` (line %d): %s%s" % (r["method"], r["line"], r["symptom"].replace("|", "/"), (" -- " + cause) if cause else ""))
    out.append("")
open(sys.argv[2], "w", encoding="utf-8", newline="\n").write("\n".join(out))
print(len(rows), "defects in", len(by), "classes")
