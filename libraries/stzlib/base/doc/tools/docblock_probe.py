#!/usr/bin/env python3
"""Call every root method of a class once, with sample arguments, and record what happens.

DOCREFORM migration tool (not a library dependency). For each root method of a class in
reference.json it builds a fresh receiver, calls the method with arguments chosen from the
parameter names, and records: the type and value it returned, whether the object's content
changed, or the error it raised. A doc writer reads this BEFORE writing "returns" or "in place":
two thirds of the old briefs that said "(mutating)" or "returns a copy" were checked this way.

    python docblock_probe.py reference.json stzNumber probe_stzNumber.json

One Ring process per class. Methods that print, save, write or take an object are skipped.
A probe is a hint, not a proof: the sample arguments may not exercise the interesting case.
"""
import json, re, subprocess, sys, pathlib, tempfile, os

HERE = pathlib.Path(__file__).resolve().parent
BASE = HERE.parent.parent
STZLIB = BASE.parent / "stzlib.ring"
RING = os.environ.get("RING", "ring")

RECV = {
    "stzNumber": ["new stzNumber(12)", "new stzNumber(7)"],
    "stzString": ['new stzString("banana")', 'new stzString("the quick fox")', 'new stzString("<<a>> and <<b>>")'],
    "stzList": ['new stzList([ "a", "b", "c", "b" ])', "new stzList([ 3, 1, 4, 1, 5 ])", "new stzList([ [ 1, 2 ], [ 3, [ 4 ] ] ])"],
    "stzHashList": ['new stzHashList([ :one = "a", :two = "b", :three = "a", :four = 4 ])',
                    'new stzHashList([ :one = :NONE, :two = [ :is, :will, :can ], :three = [ :can, :will ] ])'],
}
TEXTY = {"stzString": '"an"', "stzList": '"b"', "stzHashList": '"a"', "stzNumber": '"2"'}
SKIP = re.compile(r"^(show|print|save|write|save|load|read|open|delete|draw|play|speak|init|stztype|classname)", re.I)


OVERRIDE = {
    "stzHashList": {
        "pckey": '"two"', "pcnewkey": '"zzz"', "pckey1": '"two"', "pacclasses": '[ "a", "b" ]', "pcclass": '"a"',
        "pakeys": '[ "two", "three" ]', "packeys": '[ "two", "three" ]',
        "papair": '[ "x", "y" ]', "panewpair": '[ "x", "y" ]', "palistofpairs": '[ [ "x", "y" ] ]',
        "panewhashlist": '[ [ "x", "y" ] ]', "pavalues": '[ "a", "b" ]', "pnewvalue": '"NEW"', "pvalue": '"a"',
        "pitem": '"will"', "palists": '[ [ "a" ] ]', "palist": '[ "a" ]', "panumber": '[ 4 ]', "pastring": '[ "a" ]',
        "panumbers": '[ [ 4 ] ]', "pastrings": '[ [ "a" ] ]', "anpos": '[ 1, 2 ]', "panpos": '[ 1, 2 ]',
        "paitems": '[ "will", "can" ]', "pcvalue": '"NEW"',
    },
}


def arg_for(cls, name, idx):
    n = name.lower()
    if n in OVERRIDE.get(cls, {}):
        return OVERRIDE[cls][n]
    if n in ("pcasesensitive", "pbcs", "pcs"):
        return "1"
    if n in ("pcexpr", "pccondition", "pcaction", "pcyielder", "pcexpression"):
        return "\"@char = 'a'\"" if cls == "stzString" else '"@item"'
    # the Hungarian prefix, read on the ORIGINAL case: pOtherNumber is p + OtherNumber, not po + therNumber
    m = re.match(r"^(pac|pan|pao|pab|pc|pn|pa|pb|po)(?=[A-Z0-9_]|$)", name)
    if m:
        k = m.group(1)
        if k in ("pao", "po"):
            return "[ 1, 2 ]"
        if k == "pan":
            return "[ 2, 3 ]"
        if k in ("pac",):
            return '[ "a", "b" ]'
        if k == "pa":
            return '[ "a", "b" ]' if cls != "stzNumber" else "[ 1, 2 ]"
        if k == "pb":
            return "1"
        if k == "pn":
            return "3" if idx > 0 else "2"
        if k == "pc":
            return TEXTY[cls]
    if n in ("n", "_n_", "n1", "n2", "_n1_", "_n2_", "_nstart_", "_nfrom_", "_nrange_", "nwidth", "pstartingat", "nmin", "_nmax_", "nplaces", "_nround_", "pround", "pnumber"):
        return "3" if idx > 0 else "2"
    if n.startswith("c"):
        return TEXTY[cls]
    if cls == "stzNumber":
        return "3"
    return TEXTY[cls]


def fmt_fn():
    return '''func zzFmt(r)
	if isList(r)
		return "LIST " + @@(r)
	but isNumber(r)
		return "NUMBER " + r
	but isString(r)
		return "STRING " + char(34) + r + char(34)
	but isObject(r)
		return "OBJECT " + classname(r)
	ok
	return "NULL"
'''


def build(cls, methods):
    out = ['load "%s"' % str(STZLIB).replace("\\", "/")]
    for i, (name, params) in enumerate(methods):
        args = ", ".join(arg_for(cls, p, k) for k, p in enumerate(params))
        out.append('? "@@@%d|%s"' % (i, name))
        for r, rc in enumerate(RECV[cls]):
            out.append("try")
            out.append("	o1 = %s" % rc)
            out.append("	zzB = @@(o1.Content())")
            out.append("	zzR = o1.%s(%s)" % (name, args))
            out.append("	? \"R|\" + zzFmt(zzR)")
            out.append("	? \"C|\" + (zzB != @@(o1.Content())) + \"|\" + left(@@(o1.Content()), 90)")
            out.append("	? \"A|%s\"" % args.replace('"', "'"))
            out.append("catch")
            out.append("	? \"E|\" + cCatchError")
            out.append("done")
            if r < len(RECV[cls]) - 1:
                # try the next receiver only when this one raised
                out[-1] = "done"
        out.append("")
    out.append("")
    out.append(fmt_fn())
    return "\n".join(out)


def main():
    if len(sys.argv) < 4:
        print(__doc__); sys.exit(2)
    ref = json.load(open(sys.argv[1], encoding="utf-8"))
    cls = sys.argv[2]
    c = next(x for x in ref["classes"] if x["name"] == cls)
    only = None
    if "--only" in sys.argv:
        only = set(sys.argv[sys.argv.index("--only") + 1].split(","))
    methods = []
    for m in c["methods"]:
        if SKIP.match(m["name"]) or m["name"].startswith("@") or (only and m["name"] not in only):
            continue
        methods.append((m["name"], [p["name"] for p in m["parameters"]]))
    tmp = pathlib.Path(tempfile.gettempdir()) / ("docblock_probe_%s.ring" % cls)
    tmp.write_text(build(cls, methods), encoding="utf-8")
    p = subprocess.run([RING, str(tmp)], cwd=str(BASE / "test" / "reflect"), capture_output=True,
                       text=True, encoding="utf-8", errors="replace", timeout=1800)
    res = {}
    cur = None
    for raw in p.stdout.replace("\r\n", "\n").split("\n"):
        m = re.match(r"^@@@(\d+)\|(.*)$", raw)
        if m:
            cur = m.group(2); res[cur] = {"runs": []}; continue
        if cur is None:
            continue
        if raw.startswith("R|"):
            res[cur]["runs"].append({"ret": raw[2:]})
        elif raw.startswith("C|"):
            if res[cur]["runs"]:
                a, b = raw[2:].split("|", 1)
                res[cur]["runs"][-1]["changed"] = (a == "1"); res[cur]["runs"][-1]["after"] = b
        elif raw.startswith("A|"):
            if res[cur]["runs"]:
                res[cur]["runs"][-1]["args"] = raw[2:]
        elif raw.startswith("E|"):
            res[cur]["runs"].append({"err": raw[2:].strip()[:140]})
    if "func zzFmt" in p.stdout or p.returncode not in (0, None):
        pass
    json.dump(res, open(sys.argv[3], "w", encoding="utf-8"), indent=0, ensure_ascii=False)
    ok = sum(1 for v in res.values() if any("ret" in r for r in v["runs"]))
    print("%d methods probed, %d answered, %d only raised" % (len(res), ok, len(res) - ok))
    tail = p.stdout[-300:] if len(res) < len(methods) else ""
    if tail:
        print("run stopped early? last output:", tail)


if __name__ == "__main__":
    main()
