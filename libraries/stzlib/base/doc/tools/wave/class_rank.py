#!/usr/bin/env python3
"""Rank the library's classes by use, to pick the next wave.

    python class_rank.py <repo>/libraries/stzlib reference.json [out.json]

Use of a class = the number of .ring files (tests, examples, other library code) that create it
(`new stzX(`) or call its Q form (`StzXQ(`), with the number of its roots and how many already pass.
A file that only calls a method on an object does not count: the class is what a person reaches for.
Prints the table; the JSON has every class with its figures.
"""
import json, re, sys, pathlib

root = pathlib.Path(sys.argv[1])
ref = json.load(open(sys.argv[2], encoding="utf-8"))
out = sys.argv[3] if len(sys.argv) > 3 else None
classes = {c["name"].lower(): c for c in ref["classes"]}
creates = {k: set() for k in classes}
pat_new = re.compile(r"\bnew\s+(stz\w+)\s*\(?", re.I)
pat_q = re.compile(r"\b(stz\w+?)(?:q|qq)?\s*\(", re.I)
nfiles = 0
for p in root.rglob("*.ring"):
    s = p.read_text(encoding="utf-8", errors="replace").lower()
    nfiles += 1
    seen = set()
    for m in pat_new.finditer(s):
        seen.add(m.group(1))
    for m in pat_q.finditer(s):
        seen.add(m.group(1))
        n = m.group(1)
        if n.endswith("q"):
            seen.add(n[:-1])
    for n in seen:
        if n in creates:
            creates[n].add(str(p))
rows = []
for k, c in classes.items():
    ms = c["methods"]
    ok = sum(1 for m in ms if m.get("pass"))
    rows.append({"class": c["name"], "files": len(creates[k]), "roots": len(ms), "pass": ok, "todo": len(ms) - ok, "file": c["file"]})
rows.sort(key=lambda r: (-r["files"], -r["roots"]))
if out:
    json.dump(rows, open(out, "w", encoding="utf-8"), indent=1)
print("scanned", nfiles, "files")
tot = 0
for i, r in enumerate(rows[:60], 1):
    tot += r["todo"]
    print("%3d %-28s files %4d  roots %5d  todo %5d  (cum todo %6d)  %s" % (i, r["class"], r["files"], r["roots"], r["todo"], tot, r["file"]))
