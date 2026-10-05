#!/usr/bin/env python3
"""Run the examples of a docs file and write down what they REALLY print.

DOCREFORM migration tool (not a library dependency). A docs file is JSON:

  { "class": "stzString",
    "receiver": "o1 = new stzString(\"banana\")",
    "entries": [ { "name": "Find", "brief": "...", "params": {...}, "returns": "...",
                   "note": [...], "see": [...],
                   "example": [ "? @@( o1.Find(\"an\") )" ] }, ... ] }

Every example runs in a FRESH receiver: the class `receiver` line, unless the
example's own first line is an assignment to o1. The outcome is read, not
trusted: this script only captures it. A passing example can still be wrong
(the site found one that said SetCaseSensitive(TRUE) leaves 0 words), so a
person reads examples_<class>.json before docblock_apply.py freezes it.

    python docblock_runexamples.py docs_stzNumber.json examples_stzNumber.json [--only Name,Name]

One Ring process, one class. Run it alone: it loads the whole library.
"""
import json, re, subprocess, sys, pathlib, tempfile, os

HERE = pathlib.Path(__file__).resolve().parent
BASE = HERE.parent.parent                      # .../base
STZLIB = BASE.parent / "stzlib.ring"
RING = os.environ.get("RING", "ring")
PREDICATE = re.compile(r"\.\s*(Is[A-Z]\w*|Are[A-Z]\w*|Has[A-Z]\w*|Can[A-Z]\w*|Does[A-Z]\w*|Are|Check|Represents\w*|Exists\w*|Contains\w*|Starts\w*With\w*|Ends\w*With\w*)\s*\(")


def gen_script(doc, entries):
    out = ['load "%s"' % str(STZLIB).replace("\\", "/"), '? "@@@BEGIN"']
    recv = doc["receiver"]
    for i, e in enumerate(entries):
        lines = e["example"]
        own = bool(lines) and re.match(r"^\s*o1\s*=", lines[0])
        out.append('? "@@@%d"' % i)
        out.append("try")
        if not own:
            out.append(recv)
        for ln in lines:
            out.append(ln)
        out.append("catch")
        out.append('? "@@@ERROR " + cCatchError')
        out.append("done")
    out.append('? "@@@END"')
    return "\n".join(out) + "\n"


def parse_output(text, n):
    res = {i: [] for i in range(n)}
    cur = None
    for raw in text.replace("\r\n", "\n").split("\n"):
        m = re.match(r"^@@@(\d+)$", raw)
        if m:
            cur = int(m.group(1)); continue
        if raw.startswith("@@@"):
            if cur is not None and raw.startswith("@@@ERROR"):
                res[cur].append("ERROR:" + raw[8:].strip())
            continue
        if cur is not None:
            res[cur].append(raw)
    for k in res:                      # blank lines at the end are the separator, not output
        while res[k] and res[k][-1].strip() == "":
            res[k].pop()
    return res


def main():
    if len(sys.argv) < 3:
        print(__doc__); sys.exit(2)
    doc = json.load(open(sys.argv[1], encoding="utf-8"))
    only = None
    if "--only" in sys.argv:
        only = set(sys.argv[sys.argv.index("--only") + 1].split(","))
    entries = [e for e in doc["entries"] if e.get("example") and (only is None or e["name"] in only)]
    script = gen_script(doc, entries)
    tmp = pathlib.Path(tempfile.gettempdir()) / ("docblock_run_%s.ring" % doc["class"])
    tmp.write_text(script, encoding="utf-8")
    p = subprocess.run([RING, str(tmp)], cwd=str(BASE / "test" / "reflect"), capture_output=True,
                       text=True, encoding="utf-8", errors="replace", timeout=900)
    got = parse_output(p.stdout, len(entries))
    if "@@@END" not in p.stdout:
        print("THE RUN DID NOT REACH THE END -- a syntax or fatal error in an example:")
        print((p.stdout + p.stderr)[-1500:])
    out = {}
    nbad = 0
    for i, e in enumerate(entries):
        lines = e["example"]
        printed = got.get(i, [])
        err = next((x for x in printed if x.startswith("ERROR:")), "")
        qlines = [k for k, ln in enumerate(lines) if ln.lstrip().startswith("?")]
        actual = [x for x in printed if not x.startswith("ERROR:")]
        printing = bool(e.get("printing"))      # the call itself prints (Show): its output follows the last line
        ok = (not err) and (printing or len(actual) == len(qlines))
        framed = []
        j = 0
        for k, ln in enumerate(lines):
            framed.append(ln)
            if (not printing) and k in qlines and j < len(actual):
                v = actual[j].strip(); j += 1
                if PREDICATE.search(ln):          # Ring prints TRUE as 1: show what the method means
                    if v == "1": v = "TRUE"
                    if v == "0": v = "FALSE"
                framed.append("#--> " + v)
        if printing and not err:
            for v in actual:
                framed.append("#--> " + v.rstrip())
        if not ok:
            nbad += 1
        out[e["name"]] = {"lines": framed, "printed": actual, "error": err, "ok": ok}
    json.dump(out, open(sys.argv[2], "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print("%d examples run, %d need a look (error, or the prints do not match the ? lines)" % (len(entries), nbad))
    for name, r in out.items():
        if not r["ok"]:
            print("  !", name, r["error"] or ("prints %d, ? lines %d" % (len(r["printed"]), sum(1 for l in r["lines"] if l.lstrip().startswith('?')))))


if __name__ == "__main__":
    main()
