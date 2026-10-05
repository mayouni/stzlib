"""fixlines.py <file> : replace whole lines by name from a 'fix' text on stdin (same format)."""
import sys, re
f = sys.argv[1]
fix = {}
for ln in sys.stdin.read().split("\n"):
    if ln.strip() and not ln.startswith("#"):
        fix[ln.split("|")[0].strip()] = ln
out = []
seen = set()
for ln in open(f, encoding="utf-8").read().split("\n"):
    n = ln.split("|")[0].strip()
    if n in fix:
        out.append(fix[n]); seen.add(n)
    else:
        out.append(ln)
missing = set(fix) - seen
if missing:
    print("NOT IN FILE:", missing)
open(f, "w", encoding="utf-8").write("\n".join(out))
print("fixed", len(seen))
