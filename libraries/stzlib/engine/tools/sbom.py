#!/usr/bin/env python3
"""SBOM for the engine's vendored code -- generated, never hand-written.

Every library under engine/vendor/ carries a version file (VERSION.txt, or
VERSION where it predates the rule below) ending in an SBOM RECORD: a block
of `Key: value` lines this script reads. The prose above the block is for
people; the block is for this script.

    Component / Version / Source / Licence / Purl / Archive-SHA-256 / Tree-Digest

Tree-Digest is SHA-256 over the lines "<git blob id>  <path>\\n" of every
file in the library's folder EXCEPT its version file, as the git INDEX
holds them. It is the committed content, so it does not change with a
platform's line endings, and it cannot include itself.

    python sbom.py            write sbom.cdx.json (CycloneDX 1.6) at the repo root
    python sbom.py --check    verify every record's Tree-Digest against the index:
                              a vendored file changed without its record is a
                              failure (exit 1), and it prints each library by name

Why VERSION.txt and not VERSION: a vendor root on a C include path resolves
C++'s `#include <version>` to a file named VERSION on a case-insensitive
filesystem, which broke the build once (vendor/glfw/VERSION.txt says how).
"""

import hashlib
import json
import os
import subprocess
import sys
import uuid
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
VENDOR = os.path.normpath(os.path.join(HERE, "..", "vendor"))
KEYS = ("Component", "Version", "Source", "Licence", "Purl", "Archive-SHA-256", "Tree-Digest")
MARK = "--- SBOM record"


def git(*args, cwd=None):
    return subprocess.run(["git", *args], cwd=cwd or VENDOR, capture_output=True,
                          text=True, check=True).stdout


def repo_root():
    return git("rev-parse", "--show-toplevel").strip()


def version_file(lib_dir):
    for name in ("VERSION.txt", "VERSION"):
        p = os.path.join(lib_dir, name)
        if os.path.isfile(p):
            return p
    return None


def read_record(path):
    rec, inside = {}, False
    with open(path, encoding="utf-8") as f:
        for line in f:
            if line.startswith(MARK):
                inside = True
                continue
            if inside and ":" in line:
                k, v = line.split(":", 1)
                if k.strip() in KEYS:
                    rec[k.strip()] = v.strip()
    return rec


def tree_digest(lib):
    """SHA-256 over '<blob>  <path>' for the library's indexed files, minus its version file."""
    out = git("ls-files", "-s", "--", lib)
    lines = []
    for row in out.splitlines():
        meta, path = row.split("\t", 1)
        if os.path.basename(path) in ("VERSION", "VERSION.txt"):
            continue
        blob = meta.split()[1]
        rel = path[len(lib) + 1:] if path.startswith(lib + "/") else path
        lines.append(f"{blob}  {rel}\n")
    lines.sort()
    return hashlib.sha256("".join(lines).encode("utf-8")).hexdigest(), len(lines)


def libraries():
    return sorted(d for d in os.listdir(VENDOR) if os.path.isdir(os.path.join(VENDOR, d)))


def check():
    bad = 0
    for lib in libraries():
        vf = version_file(os.path.join(VENDOR, lib))
        if vf is None:
            print(f"  FAIL  {lib}: no VERSION.txt")
            bad += 1
            continue
        rec = read_record(vf)
        missing = [k for k in ("Component", "Version", "Source", "Licence", "Tree-Digest") if k not in rec]
        if missing:
            print(f"  FAIL  {lib}: record lacks {', '.join(missing)}")
            bad += 1
            continue
        got, n = tree_digest(lib)
        if got != rec["Tree-Digest"]:
            print(f"  FAIL  {lib}: its {n} files differ from the recorded Tree-Digest -- a vendored file changed without {os.path.basename(vf)}")
            bad += 1
        else:
            print(f"  ok    {lib} {rec['Version']} ({n} files)")
    return bad


def generate():
    comps = []
    for lib in libraries():
        vf = version_file(os.path.join(VENDOR, lib))
        rec = read_record(vf) if vf else {}
        c = {
            "type": "library",
            "bom-ref": f"vendor/{lib}",
            "name": rec.get("Component", lib),
            "version": rec.get("Version", "unknown"),
            "licenses": [{"expression": rec["Licence"]}] if rec.get("Licence") else [],
            "externalReferences": [{"type": "vcs" if "github.com" in rec.get("Source", "") else "website",
                                    "url": rec["Source"]}] if rec.get("Source") else [],
            "properties": [{"name": "softanza:vendor-path", "value": f"libraries/stzlib/engine/vendor/{lib}"},
                           {"name": "softanza:tree-digest", "value": rec.get("Tree-Digest", "")}],
        }
        if rec.get("Purl"):
            c["purl"] = rec["Purl"]
        h = rec.get("Archive-SHA-256", "")
        if len(h) == 64 and all(ch in "0123456789abcdef" for ch in h.lower()):
            c["hashes"] = [{"alg": "SHA-256", "content": h.lower()}]
        else:
            c["properties"].append({"name": "softanza:archive-sha-256", "value": h or "not recorded"})
        comps.append(c)
    head = git("rev-parse", "HEAD").strip()
    bom = {
        "bomFormat": "CycloneDX",
        "specVersion": "1.6",
        "serialNumber": f"urn:uuid:{uuid.uuid5(uuid.NAMESPACE_URL, 'stzlib-sbom-' + head)}",
        "version": 1,
        "metadata": {
            "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "tools": {"components": [{"type": "application", "name": "engine/tools/sbom.py"}]},
            "component": {"type": "library", "bom-ref": "stzlib", "name": "stzlib (Softanza engine)",
                          "properties": [{"name": "softanza:generated-from-commit", "value": head}]},
        },
        "components": comps,
        "dependencies": [{"ref": "stzlib", "dependsOn": [c["bom-ref"] for c in comps]}],
    }
    out = os.path.join(repo_root(), "sbom.cdx.json")
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        json.dump(bom, f, indent=2)
        f.write("\n")
    print(f"wrote {out}: {len(comps)} components")


if __name__ == "__main__":
    if "--check" in sys.argv:
        n = check()
        print(f"vendored records: {len(libraries()) - n} ok, {n} failing")
        sys.exit(1 if n else 0)
    generate()
