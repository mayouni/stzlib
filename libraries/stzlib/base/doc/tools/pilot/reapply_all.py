#!/usr/bin/env python3
"""Rebuild the documented source of the pilot classes from PRISTINE sources.

docblock_apply.py is not idempotent over its own output (it would keep the previous block as the
"old description"), so a correction is made in the docs data and everything is re-applied from the
sources as they were before the pilot (git commit PRISTINE):

    python reapply_all.py <data dir> stzNumber [stzHashList stzList stzString]

<data dir> holds docs_<class>.json + examples_<class>.json (the 300 most used, with their run
examples) and w1_docs_<class>.json (wave 1, no examples). Run from anywhere inside the repository.
"""
import json, subprocess, sys, pathlib

PRISTINE = "40e2288ea"
FILES = {"stzNumber": "number/stzNumber.ring", "stzList": "list/stzList.ring",
         "stzHashList": "list/stzHashList.ring", "stzString": "string/stzString.ring"}
HERE = pathlib.Path(__file__).resolve().parent
TOOLS = HERE.parent
BASE = TOOLS.parent.parent                      # .../libraries/stzlib/base
REPO = subprocess.run(["git", "rev-parse", "--show-toplevel"], cwd=str(HERE), capture_output=True, text=True).stdout.strip()


def main():
    data = pathlib.Path(sys.argv[1])
    for cls in sys.argv[2:]:
        rel = "libraries/stzlib/base/" + FILES[cls]
        blob = subprocess.run(["git", "show", "%s:%s" % (PRISTINE, rel)], cwd=REPO, capture_output=True).stdout
        (pathlib.Path(REPO) / rel).write_bytes(blob)
        for docs, exs in (("docs_%s.json" % cls, "examples_%s.json" % cls), ("w1_docs_%s.json" % cls, None)):
            d = data / docs
            if not d.exists():
                continue
            e = data / exs if exs else data / "empty_examples.json"
            r = subprocess.run([sys.executable, str(TOOLS / "docblock_apply.py"), str(d), str(e)], capture_output=True, text=True)
            print(r.stdout.strip() or r.stderr.strip())
            if r.returncode != 0:
                sys.exit("apply failed for " + docs)


if __name__ == "__main__":
    main()
