#!/usr/bin/env python
"""Runs the examples of SOFTANZA_PAYMENTS_PORT.md and compares what they print.

The charter promised that every verb carries an example that RUNS. A promise nobody runs is
a memory, so this is the run: every ```ring block (not ```ring PY3 / PY4, which are specs of
rungs not yet built) is concatenated in document order into one Ring session, each `?` line
carries its expected output after `#-->`, and the script fails if any line differs or if
a `?` has no expectation.

    cd libraries/stzlib/base/test/system && python charter_examples.py

Exit status 0 when every printed value is what the charter says.
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
CHARTER = os.path.normpath(os.path.join(HERE, "..", "..", "service", "SOFTANZA_PAYMENTS_PORT.md"))


def blocks(text):
    # only a fence that says exactly "ring": the later rungs say "ring PY3", "ring PY4"
    return re.findall(r"^```ring\n(.*?)^```", text, flags=re.S | re.M)


def main(path=None):
    text = open(path or CHARTER, encoding="utf-8").read()
    bs = blocks(text)
    script = "\n\n".join(bs) + "\n"
    expected = []
    for line in script.splitlines():
        m = re.match(r"\s*\?\s*(.*)$", line)
        if not m:
            continue
        mm = re.search(r"#-->\s*(.*?)\s*$", line)
        if not mm:
            print("NO EXPECTATION on a ? line: " + line.strip())
            return 2
        expected.append(mm.group(1))
    path = os.path.join(HERE, "_charter_examples_run.ring")
    open(path, "w", encoding="utf-8", newline="\n").write(script)
    try:
        r = subprocess.run(["ring", os.path.basename(path)], cwd=HERE, capture_output=True,
                           text=True, encoding="utf-8", errors="replace", timeout=300)
    finally:
        os.remove(path)
    out = [l.rstrip() for l in (r.stdout + r.stderr).splitlines()
           if l.strip() and not l.startswith("WARNING")]
    ok = True
    n = max(len(out), len(expected))
    for i in range(n):
        got = out[i] if i < len(out) else "<missing>"
        want = expected[i] if i < len(expected) else "<unexpected extra output>"
        if got != want:
            ok = False
            print("line %d: expected %r, got %r" % (i + 1, want, got))
    print("%d blocks, %d printed values checked, %s" % (len(bs), len(expected), "ALL AS DOCUMENTED" if ok else "FAILED"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else None))
