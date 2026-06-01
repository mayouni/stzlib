#!/usr/bin/env python3
"""Strip standalone `*/` lines from modular test files.

The narrative test source uses block comments like:
    /*--- Title
    [free-form prose, sometimes wrapped in /*  */]
    */
    pr()
    ...

When the extractor splits on `/*---` boundaries, it can leave a
trailing `*/` token inside the new block body if the prose itself
contained an inner `/*...*/` comment. That stray `*/` then trips
Ring with a C27 syntax error.

Fix: any `*/` line that has no matching `/*` earlier in the body
(i.e. would be an unbalanced close) gets removed.
"""
import sys, re
from pathlib import Path

ROOT = Path("libraries/stzlib/base/test/modular")

def clean(text):
    lines = text.splitlines(keepends=True)
    out = []
    depth = 0
    for line in lines:
        stripped = line.strip()
        # Track /* ... */ open/close balance LINE by line. Imperfect
        # for multi-comment lines but good enough for the simple
        # narrative format.
        if '/*' in stripped and '*/' not in stripped:
            depth += 1
            out.append(line)
        elif '*/' in stripped and '/*' not in stripped:
            if depth > 0:
                depth -= 1
                out.append(line)
            # else: stray, drop it
        else:
            out.append(line)
    return ''.join(out)

def main():
    n_files = 0
    n_changed = 0
    for f in ROOT.rglob('*.ring'):
        n_files += 1
        txt = f.read_text(encoding='utf-8', errors='replace')
        new = clean(txt)
        if new != txt:
            f.write_text(new, encoding='utf-8')
            n_changed += 1
    print(f'{n_files} files scanned, {n_changed} cleaned')

if __name__ == '__main__':
    main()
