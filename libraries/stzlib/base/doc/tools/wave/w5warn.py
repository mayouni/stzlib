"""Add a warning to a method's doc block AND to its saved wave line, so a later rebuild keeps it.

    from w5warn import addwarn
    addwarn(BASE, "stzDiagram", "ToPNG", "text of the warning")

Source: the block above `def <method>(` gets the text as a continuation of its `warning` field, or a new
`warning` field before `see` / `#@` / the def. Data: every line `<method> | ...` in
doc/tools/wave/data/w[2-5]_<Class>_*.txt gets the text joined to its 6th field. Comments only.
"""
import re, glob, json


def _read(p):
    b = open(p, "rb").read()
    return b.decode("utf-8").replace("\r\n", "\n"), b"\r\n" in b


def _write(p, t, crlf):
    open(p, "wb").write((t.replace("\n", "\r\n") if crlf else t).encode("utf-8"))


def addwarn(base, cls, method, text, ref=None):
    ref = ref or json.load(open(base + "/doc/reference.json", encoding="utf-8"))
    c = next(c for c in ref["classes"] if c["name"] == cls)
    src = base + "/" + c["file"]
    t, crlf = _read(src)
    L = t.split("\n")
    rx = re.compile(r"^\s*def\s+" + re.escape(method) + r"\s*\(", re.I)
    at = next((i for i, ln in enumerate(L) if rx.match(ln)), None)
    if at is None:
        raise SystemExit("no def for %s.%s" % (cls, method))
    j = at - 1
    while j >= 0 and L[j].strip().startswith("#"):
        j -= 1
    top = j + 1
    block = L[top:at]
    ind = re.match(r"^(\s*)#", block[0]).group(1) if block else re.match(r"^(\s*)", L[at]).group(1)
    # an existing warning field: append a continuation line after its last line
    wi = next((k for k, ln in enumerate(block) if re.match(r"^\s*#\s{3}warning\s", ln)), None)
    if wi is not None:
        k = wi + 1
        while k < len(block) and re.match(r"^\s*#\s{8,}\S", block[k]):
            k += 1
        block.insert(k, ind + "#              " + text)
    else:
        pos = next((k for k, ln in enumerate(block) if re.match(r"^\s*#\s{3}see\s", ln) or ln.strip().startswith("#@")), len(block))
        block.insert(pos, ind + "#   warning    " + text)
    L[top:at] = block
    _write(src, "\n".join(L), crlf)
    # the saved wave lines
    n = 0
    for f in glob.glob(base + "/doc/tools/wave/data/w[2-5]_%s_*.txt" % cls):
        d, cr = _read(f)
        out = []
        for ln in d.split("\n"):
            p = ln.split("|")
            if len(p) >= 2 and p[0].strip().lower() == method.lower():
                while len(p) < 7:
                    p.append("")
                p[5] = " " + ((p[5].strip() + "; " + text) if p[5].strip() else text) + " "
                ln = "|".join(p)
                n += 1
            out.append(ln)
        _write(f, "\n".join(out), cr)
    return n
