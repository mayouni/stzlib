#!/usr/bin/env python3
"""Write the doc blocks of a docs file into the library's source -- COMMENTS ONLY.

DOCREFORM migration tool (not a library dependency). It reads the same docs file
as docblock_runexamples.py (+ the examples file that script wrote, once a person
has read it), finds each `def` inside the class, and replaces the comment run
the extractor already attaches to that def with the block of DOCBLOCK.md. What it
keeps: `#@` retrieval lines, #TODO/#WARNING markers, divider lines. What it
refuses: to write a file whose CODE changed -- before and after, with every
comment and blank line removed, the file must be identical, or nothing is written.

    python docblock_apply.py docs_stzNumber.json examples_stzNumber.json [--dry]

Class block: "class_block": { "brief", "detail", "receiver", "example", "see" } in the docs file.
"""
import json, re, sys, pathlib, textwrap

HERE = pathlib.Path(__file__).resolve().parent
BASE = HERE.parent.parent
CLASS = re.compile(r"^\s*class\s+(\w+)", re.I)
STOP = re.compile(r"^\s*(class|package)\s", re.I)
WIDTH = 100


def read(p):
    b = p.read_bytes()
    crlf = b"\r\n" in b
    return b.decode("utf-8").replace("\r\n", "\n"), crlf


def find_class(name):
    for p in BASE.rglob("*.ring"):
        rel = p.relative_to(BASE).parts
        if rel[0] in ("test", "doc") or "archive" in rel or "recovered" in rel or "plugin" in rel:
            continue
        txt, _ = read(p)
        for i, l in enumerate(txt.split("\n")):
            m = CLASS.match(l)
            if m and m.group(1).lower() == name.lower():
                return p, i
    sys.exit("class not found: " + name)


def strip_comments(lines):
    return [l.rstrip() for l in lines if l.strip() and not l.strip().startswith("#")]


def is_box(s):
    s = s.strip()
    return len(s) >= 2 and s.startswith("#") and s.endswith("#")


KEEP = re.compile(r"^\s*(#@|#todo|#warning|#<|#>)", re.I)


def fields(entry, params, example_lines):
    """[(key, value)], in the order of DOCBLOCK.md"""
    out = []
    for pn in params:
        role = entry.get("params", {}).get(pn)
        if role:
            out.append((pn, role))
    if entry.get("returns"): out.append(("returns", entry["returns"]))
    for n in entry.get("note", []): out.append(("note", n))
    for n in entry.get("warning", []): out.append(("warning", n))
    if entry.get("see"): out.append(("see", ", ".join(entry["see"])))
    for f in entry.get("forms", []): out.append(("forms", f))
    if entry.get("since"): out.append(("since", entry["since"]))
    if entry.get("status"): out.append(("status", entry["status"]))
    if entry.get("detour"): out.append(("detour", entry["detour"]))
    if example_lines: out.append(("example", "\n".join(example_lines)))
    return out


def render_block(ind, brief, detail, flds):
    L = ["%s# %s" % (ind, brief)]
    if detail:
        L.append("%s#" % ind)
        for w in textwrap.wrap(detail, WIDTH - len(ind.replace("\t", "    ")) - 2):
            L.append("%s# %s" % (ind, w))
    if flds:
        L.append("%s#" % ind)
        W = max(len(k) for k, _ in flds) + 3
        W = max(W, 11)
        for k, v in flds:
            if k == "example":
                first, *rest = v.split("\n")
                L.append("%s#   %s%s" % (ind, k.ljust(W), first))
                for r in rest:
                    L.append("%s#   %s%s" % (ind, " " * W, r))
                continue
            width = max(30, WIDTH - len(ind.replace("\t", "    ")) - 4 - W)
            wr = textwrap.wrap(v, width) or [""]
            L.append("%s#   %s%s" % (ind, k.ljust(W), wr[0]))
            for r in wr[1:]:
                L.append("%s#   %s%s" % (ind, " " * W, r))
    return L


def main():
    if len(sys.argv) < 3:
        print(__doc__); sys.exit(2)
    doc = json.load(open(sys.argv[1], encoding="utf-8"))
    exs = json.load(open(sys.argv[2], encoding="utf-8"))
    dry = "--dry" in sys.argv
    path, cl = find_class(doc["class"])
    txt, crlf = read(path)
    old = txt.split("\n")
    L = list(old)
    end = len(L) - 1
    for k in range(cl + 1, len(L)):
        if STOP.match(L[k]) and "{" not in L[k]:
            end = k - 1; break
    done, missing, skipped = 0, [], []
    # process from the bottom up, so line numbers above stay valid
    entries = doc["entries"]
    located = []
    for e in entries:
        pat = re.compile(r"^\s*(def|func)\s+%s\s*\(" % re.escape(e["name"]), re.I)
        at = next((k for k in range(cl + 1, end + 1) if pat.match(L[k])), None)
        if at is None:
            missing.append(e["name"]); continue
        located.append((at, e))
    located.sort(key=lambda t: -t[0])
    for at, e in located:
        if not e.get("brief"):
            skipped.append(e["name"]); continue
        ind = re.match(r"\s*", L[at]).group(0)
        # the run: comments and blanks directly above, up to code or a box
        k = at - 1
        keep = []
        top = at
        removed = []          # the plain comment lines of the old run, top to bottom
        while k >= 0:
            s = L[k].strip()
            if s == "":
                top = k; removed.insert(0, ""); k -= 1; continue
            if s.startswith("#") and not is_box(L[k]):
                top = k
                if KEEP.match(L[k]) or s.startswith("# ---") or s.startswith("#---"):
                    keep.insert(0, L[k])
                else:
                    removed.insert(0, "#" if s == "#" else L[k].strip())
                k -= 1; continue
            break
        # a blank line right under a box or code belongs to spacing, not to the run
        while top < at and L[top].strip() == "":
            top += 1
        params = re.findall(r"[A-Za-z_]\w*", re.search(r"\((.*)\)", L[at]).group(1)) if re.search(r"\((.*)\)", L[at]) else []
        ex = exs.get(e["name"], {})
        if e.get("example") and not ex.get("ok"):
            skipped.append(e["name"] + " (example not ok)"); continue
        block = render_block(ind, e["brief"], e.get("detail", ""), fields(e, params, ex.get("lines") if e.get("example") else None))
        # The old description is replaced by the new brief; what a maintainer wrote AFTER
        # its first paragraph (why the body is the way it is) is not documentation and
        # is not lost: it moves into the body, under the def line.
        paras, cur = [], []
        for r in removed:
            if r in ("", "#"):
                if cur: paras.append(cur); cur = []
            else:
                cur.append(r)
        if cur: paras.append(cur)
        # only what reads as a maintainer's rationale moves: a date, an error code, an
        # internal helper, a "because". Anything else was description, now replaced.
        why = re.compile(r"20\d\d-\d\d-\d\d|R\d\d|_Stz|because|used to|bug|quirk|never|so this|raised", re.I)
        keepers = [para for para in paras[1:] if why.search(" ".join(para))]
        notes = [ln for para in keepers for ln in para + [""]][:-1] if keepers else []
        # The old description fed the retrieval (Ask finds a method by the words it was
        # described with: "lower case", "capitals"). The new brief is written for a reader,
        # so the old words are kept where retrieval has always read them: an #@ aka line.
        legacy = " ".join(x.lstrip("#").strip() for x in paras[0]) if paras else ""
        legacy = re.sub(r"\s+", " ", legacy).strip()[:400]
        akas = [ln for ln in keep if ln.lstrip().startswith("#@")]
        if legacy and legacy.lower() != e["brief"].lower():
            keep = keep + [ind + "#@ aka  " + legacy]
        L[top:at] = block + keep
        # a comment under the def line that says the opposite of the new block
        # (the old brief repeated inside the body): the entry names it to drop it
        for frag in e.get("drop_body", []):
            at3 = top + len(block) + len(keep)
            j = at3 + 1
            while j < len(L) and L[j].strip().startswith("#"):
                if frag in L[j]:
                    del L[j]
                    continue
                j += 1
        if notes:
            body_ind = ind + "	"
            at2 = top + len(block) + len(keep)        # the def line
            moved = [body_ind + n for n in notes if n != ""]
            L[at2 + 1:at2 + 1] = moved
        done += 1
    cb = doc.get("class_block")
    if cb:
        at = cl
        k = at - 1
        top = at
        while k >= 0 and L[k].strip().startswith("#") and not is_box(L[k]) and not L[k].strip().startswith("#@"):
            top = k; k -= 1
        flds = []
        if cb.get("receiver"): flds.append(("receiver", cb["receiver"]))
        if cb.get("example"): flds.append(("example", "\n".join(cb["example"])))
        if cb.get("see"): flds.append(("see", ", ".join(cb["see"])))
        L[top:at] = render_block("", cb["brief"], cb.get("detail", ""), flds)
    new = L
    if strip_comments(old) != strip_comments(new):
        sys.exit("REFUSED: the code would change. Nothing written.")
    print("%s: %d blocks, %d skipped, %d not found; code unchanged: yes" % (path.name, done, len(skipped), len(missing)))
    if missing: print("  not found:", ", ".join(missing))
    if skipped: print("  skipped:", ", ".join(skipped))
    if not dry:
        out = "\n".join(new)
        if crlf: out = out.replace("\n", "\r\n")
        path.write_bytes(out.encode("utf-8"))


if __name__ == "__main__":
    main()
