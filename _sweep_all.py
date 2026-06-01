#!/usr/bin/env python3
"""Re-run every modular test directory and update its _RUN.txt.
Sequential, with a per-module timeout cap so a single hang doesn't
stall the sweep. Prints a sorted summary at the end."""
import subprocess, sys, os, re
from pathlib import Path

ROOT = Path("libraries/stzlib/base/test/modular")

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    mods = [d for d in sorted(ROOT.iterdir()) if d.is_dir()]
    print(f"Sweeping {len(mods)} modules...", file=sys.stderr)
    results = []
    for i, d in enumerate(mods, 1):
        ring_files = list(d.glob("*.ring"))
        if not ring_files:
            continue
        try:
            p = subprocess.run(
                [sys.executable, "_run_modular_batch.py", str(d)],
                capture_output=True, timeout=180,
            )
            out = p.stdout.decode('utf-8', errors='replace')
            (d / "_RUN.txt").write_text(out, encoding='utf-8')
            last = out.strip().split('\n')[-1] if out.strip() else "(empty)"
        except subprocess.TimeoutExpired:
            last = "SWEEP_TIMEOUT 600s"
        except Exception as e:
            last = f"SWEEP_ERROR {e}"
        counts = {}
        for k in ("PASS","FAIL","TIMEOUT","skip"):
            mr = re.search(rf'{k}:\s*(\d+)', last)
            counts[k] = int(mr.group(1)) if mr else 0
        results.append((d.name, len(ring_files), counts, last))
        print(f"[{i:3d}/{len(mods)}] {d.name:<22} {last}", file=sys.stderr, flush=True)

    # Totals
    T = {k:0 for k in ("PASS","FAIL","TIMEOUT","skip")}
    TN = 0
    for _,n,c,_ in results:
        TN += n
        for k in T: T[k] += c[k]
    print()
    print("TOTAL across", len(results), "modules:", TN, "blocks")
    for k,v in T.items(): print(f"  {k}: {v}")
    total = T['PASS']+T['FAIL']+T['TIMEOUT']
    if total: print(f"PASS rate excl skip/timeout: {100*T['PASS']/total:.0f}%")

    print()
    print("Top FAIL counts (>5):")
    results.sort(key=lambda r: -r[2]['FAIL'])
    for name, n, c, _ in results:
        if c['FAIL'] >= 5:
            print(f"  {name:<22} {n:>4} blocks  PASS={c['PASS']:>3}  FAIL={c['FAIL']:>3}  TIMEOUT={c['TIMEOUT']:>2}  skip={c['skip']:>3}")

if __name__ == '__main__':
    main()
