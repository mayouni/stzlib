"""MP3: REPLAY the catalogue's conversion steps on this machine, and say which reproduce the catalogued file byte for byte.

    python -I catalog_replay.py <models/catalog.zcat> <engine/tools/onnx_to_gguf.py> <out dir> <source dir> [<source dir> ...] [--only=a,b]

A setup plan that tells a developer "convert this source with these arguments" is a claim until the steps have been run and the result
compared with the file the measurements were made with. For every `file` row whose `how` is `convert` and whose steps are ONE call of
onnx_to_gguf.py, this finds the source by its file name under the source dirs, checks the source's sha256 against the catalogue, runs the
call into <out dir>, and compares the result's sha256 with the catalogued one. It prints one line per file and the `replayed|...` rows to
append to the catalogue. Steps of several stages (OWL-ViT's exports) are listed as NOT REPLAYED, with the reason. One conversion at a time.
"""
import datetime
import hashlib
import os
import shlex
import subprocess
import sys


def sha(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


def find(name, roots, want_sha=""):
    """the source by its file name -- and, when several files share the name (two repositories' model.onnx), the one whose sha256 is the
    catalogued source's"""
    hits = []
    for r in roots:
        for d, _, fs in os.walk(r):
            if name in fs:
                hits.append(os.path.join(d, name))
    if want_sha:
        for h in hits:
            if sha(h) == want_sha:
                return h
    return hits[0] if hits else None


def main(argv):
    only = None
    args = []
    for a in argv:
        if a.startswith("--only="):
            only = set(a[7:].split(","))
        else:
            args.append(a)
    cat, tool, out, roots = args[0], args[1], args[2], args[3:]
    os.makedirs(out, exist_ok=True)
    today = datetime.date.today().isoformat()
    rows = []
    for line in open(cat, encoding="utf-8"):
        f = line.rstrip("\n").split("|")
        if f[0] != "file" or len(f) < 10:
            continue
        path, size, digest, how, url, src_sha, steps = f[1], f[2], f[3], f[5], f[6], f[8], f[9]
        if only and path not in only:
            continue
        if how != "convert":
            continue
        cmd = steps.split("   (")[0].strip()
        if not cmd.startswith("python engine/tools/onnx_to_gguf.py") or ";" in cmd.replace("--static-inputs=", "").split(" --")[0]:
            print("NOT REPLAYED  %-36s  several stages (%s)" % (path, cmd[:60]))
            rows.append("replayed|%s|%s|not replayed: several stages, torch and transformers needed" % (path, today))
            continue
        parts = shlex.split(cmd, posix=True)
        src_name, target = parts[2], parts[3]
        src = find(src_name, roots, src_sha)
        if not src:
            print("NO SOURCE     %-36s  %s not found under the source dirs" % (path, src_name))
            continue
        if src_sha and sha(src) != src_sha:
            print("SOURCE DIFFERS %-35s  %s is not the catalogued source" % (path, src))
            continue
        extra = parts[4:]
        # a config file named beside the source (labels, tokenizer) is looked up next to it
        fixed = []
        for a in extra:
            if "=" in a:
                k, v = a.split("=", 1)
                if v.endswith(".json") and not os.path.isabs(v):
                    near = os.path.join(os.path.dirname(src), v)
                    if os.path.exists(near):
                        a = k + "=" + near
            fixed.append(a)
        dst = os.path.join(out, os.path.basename(target))
        r = subprocess.run([sys.executable, tool, src, dst] + fixed, capture_output=True, text=True)
        if r.returncode != 0 or not os.path.exists(dst):
            print("FAILED        %-36s  %s" % (path, (r.stderr or r.stdout).strip().splitlines()[-1:] or ""))
            rows.append("replayed|%s|%s|FAILED: the steps did not run" % (path, today))
            continue
        got = sha(dst)
        ok = got == digest
        print("%-13s %-36s  %s bytes, sha256 %s" % ("REPRODUCED" if ok else "DIFFERS", path, os.path.getsize(dst), got[:16]))
        rows.append("replayed|%s|%s|%s" % (path, today, "reproduced byte for byte" if ok else "DIFFERS: %s" % got))
        os.remove(dst)
    print("\n".join(rows))


if __name__ == "__main__":
    main(sys.argv[1:])
