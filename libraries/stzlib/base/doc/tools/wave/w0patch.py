"""Wave 0 helper: exact text replacements in a source file, line-ending safe, each checked to match once.

    from w0patch import patch, patchdoc
    patch(path, [ (old, new), ... ])
    patchdoc(path, name, brief=None, returns=None, drop_warning=True, drop_fields=(), old_brief=None)

patchdoc rewrites the comment block right above `def <name>(`: the brief (first line), the `returns`
field, and removes the `warning` field. Used after a defect is fixed, so the block stops saying
"Raises ... today". Nothing here touches code lines except through patch().
"""
import re, io


def _read(path):
    b = open(path, "rb").read()
    crlf = b"\r\n" in b
    t = b.decode("utf-8").replace("\r\n", "\n")
    return t, crlf


def _write(path, t, crlf):
    if crlf:
        t = t.replace("\n", "\r\n")
    open(path, "wb").write(t.encode("utf-8"))


def patch(path, pairs):
    t, crlf = _read(path)
    for old, new in pairs:
        n = t.count(old)
        if n != 1:
            raise SystemExit("patch: %d matches (want 1) for: %s" % (n, old[:80].replace("\n", "\\n")))
        t = t.replace(old, new)
    _write(path, t, crlf)


def patchdoc(path, name, brief=None, returns=None, drop_warning=True, drop_fields=(), old_brief=None):
    t, crlf = _read(path)
    L = t.split("\n")
    rx = re.compile(r"^\s*def\s+" + re.escape(name) + r"\s*\(", re.I)
    hits = []
    for i, ln in enumerate(L):
        if rx.match(ln):
            j = i - 1
            while j >= 0 and L[j].strip().startswith("#"):
                j -= 1
            block = L[j + 1:i]
            if old_brief is None or (block and old_brief in block[0]):
                hits.append((j + 1, i))
    if len(hits) != 1:
        raise SystemExit("patchdoc: %d candidate blocks for %s" % (len(hits), name))
    top, at = hits[0]
    block = L[top:at]
    ind = re.match(r"^(\s*)#", block[0]).group(1) if block else ""
    out = []
    skip = False
    for k, ln in enumerate(block):
        s = ln.strip()
        m = re.match(r"^#\s{3}(\w+)\s", s + " ")
        if k == 0 and brief:
            out.append(ind + "# " + brief)
            continue
        if m:
            key = m.group(1)
            skip = (key == "warning" and drop_warning) or key in drop_fields
            if key == "returns" and returns is not None:
                out.append(ind + "#   returns    " + returns)
                skip = True
                continue
        elif s == "#" or s.startswith("#@") or not s.startswith("#   "):
            skip = False
        elif skip:
            continue
        if skip:
            continue
        out.append(ln)
    L[top:at] = out
    _write(path, "\n".join(L), crlf)
