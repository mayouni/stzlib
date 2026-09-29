#!/usr/bin/env python3
"""The pre-commit SECURITY GATE -- local, before any hosted CI (ruling 4).

    python libraries/stzlib/engine/tools/security_gate.py          scoped to what is staged
    python libraries/stzlib/engine/tools/security_gate.py --full   everything, whatever is staged
    python libraries/stzlib/engine/tools/security_gate.py --fast   secrets + vendored only (under 1 s):
                                                                   the shape for a git pre-commit hook

A HOOK IS THE AUTHOR'S CHOICE, and only --fast is fit for one: the hooks
folder is shared by every session and worktree of this repository, and a
hook that builds the fuzz harnesses would start a heavy build in each of
them at once -- the way this machine freezes. To install it:

    printf '#!/bin/sh
exec python libraries/stzlib/engine/tools/security_gate.py --fast
' > .git/hooks/pre-commit

Four gates, each timed, each printed as RAN or SKIPPED with its reason --
a skip nobody can see is coverage nobody earned:

  secrets    the lines being ADDED by the staged diff, against known secret
             shapes (private keys, cloud and API tokens). Prints file:line and
             the kind, never the value.
  vendored   every engine/vendor library's recorded Tree-Digest against the
             index (sbom.py --check): vendored code changed without its record
             fails.
  guards     base/test/security/*_narrated.ring, each from its own folder.
             They exercise the BUILT engine: build it first when engine
             sources changed, or they judge the previous build.
  fuzz       `zig build fuzz -j2`: the five memory-safety harnesses (HTTP
             framing, TLS cert/record, PCRE2, utf8proc, SQLite). Seeded, so an
             unchanged harness is a cache hit. Scoped: it runs when engine
             sources, vendored code or build.zig are staged, or with --full.

Exit 1 when any gate that ran failed. One heavy job at a time: this runs
the fuzz build at -j2 and never in parallel with anything else.
"""

import os
import re
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import sbom  # noqa: E402

ROOT = sbom.repo_root()
ENGINE = os.path.normpath(os.path.join(HERE, ".."))
GUARDS = os.path.join(ROOT, "libraries", "stzlib", "base", "test", "security")

SECRET_SHAPES = [
    ("private key", re.compile(r"-----BEGIN (?:RSA |EC |DSA |OPENSSH |ENCRYPTED )?PRIVATE KEY-----")),
    ("AWS access key", re.compile(r"\b(?:AKIA|ASIA)[0-9A-Z]{16}\b")),
    ("GitHub token", re.compile(r"\b(?:gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{60,})\b")),
    ("Anthropic key", re.compile(r"\bsk-ant-[A-Za-z0-9_-]{20,}")),
    ("OpenAI-style key", re.compile(r"\bsk-(?:proj-)?[A-Za-z0-9]{32,}\b")),
    ("Slack token", re.compile(r"\bxox[abprs]-[A-Za-z0-9-]{10,}")),
    ("Google API key", re.compile(r"\bAIza[0-9A-Za-z_-]{35}\b")),
    ("Stripe live key", re.compile(r"\b(?:sk|rk)_live_[0-9A-Za-z]{20,}\b")),
]
# throwaway TEST-ONLY material, committed on purpose and labelled as such
ALLOWED_PATHS = ("libraries/stzlib/engine/src/mtls_certs/",)

results = []  # (name, state, seconds, detail)


def run(cmd, cwd, timeout):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout,
                          encoding="utf-8", errors="replace")


def staged_files():
    out = sbom.git("diff", "--cached", "--name-only", "--diff-filter=ACMR", cwd=ROOT)
    return [l for l in out.splitlines() if l]


def gate_secrets():
    diff = sbom.git("diff", "--cached", "-U0", "--no-color", "--diff-filter=ACMR", cwd=ROOT)
    path, line_no, hits = None, 0, []
    for line in diff.splitlines():
        if line.startswith("+++ "):
            path = line[6:] if line.startswith("+++ b/") else None
        elif line.startswith("@@"):
            m = re.search(r"\+(\d+)", line)
            line_no = int(m.group(1)) - 1 if m else 0
        elif line.startswith("+") and path:
            line_no += 1
            if path.startswith(ALLOWED_PATHS):
                continue
            for kind, rx in SECRET_SHAPES:
                if rx.search(line):
                    hits.append(f"{path}:{line_no}: {kind}")
    return (not hits), ("; ".join(hits) if hits else "no secret shape in the added lines")


def gate_vendored():
    bad = sbom.check()
    return bad == 0, f"{len(sbom.libraries()) - bad} of {len(sbom.libraries())} records match the index"


def gate_guards():
    fails, n = [], 0
    for f in sorted(os.listdir(GUARDS)):
        if not f.endswith("_narrated.ring"):
            continue
        n += 1
        t0 = time.time()
        try:
            r = run(["ring", f], GUARDS, 240)
            ok = "STATUS: OK" in r.stdout
            total = re.search(r"TOTAL: (\d+) assertions, (\d+) pass", r.stdout)
            tally = f"{total.group(2)}/{total.group(1)}" if total else "no tally"
        except subprocess.TimeoutExpired:
            ok, tally = False, "timed out"
        print(f"      {'ok  ' if ok else 'FAIL'}  {f}  {tally}  {time.time() - t0:.1f}s")
        if not ok:
            fails.append(f)
    return (not fails), (f"{n} guards green" if not fails else "failing: " + ", ".join(fails))


def gate_fuzz():
    r = run(["zig", "build", "fuzz", "-j2"], ENGINE, 1800)
    passes = [l.strip() for l in (r.stdout + r.stderr).splitlines() if "PASS" in l or "no crash" in l]
    for p in passes:
        print(f"      {p}")
    return r.returncode == 0, f"{len(passes)} harness reports, exit {r.returncode}"


def gate(name, fn, skip_reason=None):
    if skip_reason:
        results.append((name, "SKIPPED", 0.0, skip_reason))
        print(f"  -- {name}: SKIPPED ({skip_reason})")
        return
    print(f"  -- {name}")
    t0 = time.time()
    try:
        ok, detail = fn()
    except Exception as e:  # a gate that cannot run is a failure, named
        ok, detail = False, f"could not run: {e}"
    dt = time.time() - t0
    results.append((name, "RAN-OK" if ok else "RAN-FAIL", dt, detail))
    print(f"     {'ok' if ok else 'FAIL'} in {dt:.1f}s -- {detail}")


def main():
    full = "--full" in sys.argv
    fast = "--fast" in sys.argv
    staged = staged_files()
    engine_touched = any(p.startswith("libraries/stzlib/engine/src/") or
                         p.startswith("libraries/stzlib/engine/vendor/") or
                         p == "libraries/stzlib/engine/build.zig" for p in staged)
    print(f"security gate ({'full' if full else 'fast' if fast else 'scoped'}; {len(staged)} staged files)")
    t0 = time.time()
    gate("secrets", gate_secrets, None if staged else "nothing staged")
    gate("vendored", gate_vendored)
    gate("guards", gate_guards, "--fast (hook mode) -- run the gate without it" if fast else None)
    gate("fuzz", gate_fuzz, "--fast (hook mode) -- run the gate without it" if fast else
         None if (full or engine_touched) else
         "no engine source, vendored code or build.zig staged -- run with --full to force")
    ran = [r for r in results if r[1].startswith("RAN")]
    failed = [r for r in results if r[1] == "RAN-FAIL"]
    skipped = [r for r in results if r[1] == "SKIPPED"]
    print(f"\ngates run: {len(ran)} ({', '.join(r[0] for r in ran) or 'none'})")
    print(f"gates skipped: {len(skipped)} ({', '.join(r[0] + ': ' + r[3] for r in skipped) or 'none'})")
    print(f"gates failed: {len(failed)} ({', '.join(r[0] for r in failed) or 'none'})")
    print(f"wall time: {time.time() - t0:.1f}s")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
