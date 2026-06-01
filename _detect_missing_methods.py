#!/usr/bin/env python3
"""Walk every FAIL'd modular test block, run it, and collect the
runtime error ('Calling Method without definition: X'). Output a
deduped catalogue of missing methods, grouped by frequency.
"""
import sys, subprocess, re, os
from pathlib import Path
from collections import Counter

RING = r'D:\Ring126\bin\ring.exe'

MISSING_RE = re.compile(r'Calling Method without definition:\s*([a-zA-Z_][\w]*)')

def run(path):
    try:
        proc = subprocess.run(
            [RING, path.name],
            cwd=str(path.parent),
            capture_output=True, timeout=20,
        )
        return (proc.stdout + proc.stderr).decode('utf-8', errors='replace')
    except Exception:
        return ''

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) < 2:
        print('Usage: _detect_missing_methods.py <modular_root>')
        return
    # Accept either a single module dir or multiple
    paths = [Path(a) for a in sys.argv[1:]]
    files = []
    for p in paths:
        if p.is_dir():
            # Try as module-dir (direct *.ring files) or as parent
            direct = list(p.glob('*.ring'))
            nested = list(p.glob('*/*.ring'))
            files.extend(direct if direct else nested)
    missing = Counter()
    by_module = {}
    n_files = 0
    for ring in files:
        if ring.name == '_RUN.txt':
            continue
        n_files += 1
        out = run(ring)
        for m in MISSING_RE.findall(out):
            key = m.lower()
            missing[key] += 1
            mod = ring.parent.name
            by_module.setdefault(mod, set()).add(key)
        if n_files % 100 == 0:
            print(f'  {n_files} files scanned, {len(missing)} unique missing methods', file=sys.stderr)
    print(f'# Missing-method catalogue ({n_files} files scanned)')
    print(f'# {len(missing)} unique methods missing')
    print()
    print('## By frequency')
    for name, count in missing.most_common():
        mods = sorted(m for m, s in by_module.items() if name in s)
        print(f'{count:4d}  {name:<40s}  {", ".join(mods[:5])}{"..." if len(mods)>5 else ""}')
    print()
    print('## By module')
    for mod in sorted(by_module):
        methods = sorted(by_module[mod])
        print(f'{mod:<22} ({len(methods)} unique): {", ".join(methods[:10])}{"..." if len(methods)>10 else ""}')

if __name__ == '__main__':
    main()
