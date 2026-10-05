import json, re, sys
cls = sys.argv[1]
out = sys.argv[2]
r = json.load(open("ref_pilot.json", encoding="utf-8"))
c = [c for c in r["classes"] if c["name"] == cls][0]
done = set()
lines = []
for m in c["methods"]:
    n = m["name"]
    if m.get("pass") or not n.endswith("NamedParam") or not n.startswith("Is"):
        continue
    core = n[2:-len("NamedParam")]
    if core == "":
        lines.append("%s | TRUE if the list is a named param: a pair whose first item is a keyword and whose second is its value. | TRUE or FALSE | | IsNamedParam" % n)
        continue
    names = [x for x in re.split(r"Or(?=[A-Z])", core) if x]
    shown = " or ".join(":" + x for x in names)
    lines.append("%s | TRUE if the list is a pair whose first item is the keyword %s, such as :%s = value. | TRUE or FALSE | | IsNamedParam" % (n, shown, names[0]))
open(out, "w", encoding="utf-8").write("\n".join(lines) + "\n")
print(len(lines))
