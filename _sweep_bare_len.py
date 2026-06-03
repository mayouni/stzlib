#!/usr/bin/env python3
"""Mass-replace bare `len(...)` -> `ring_len(...)` inside class bodies.

Ring 1.26 has a class-method-scope regression: when a class method
calls bare `len(arg)`, the lookup tries to resolve `len` as a class
attribute first and falls through to R20 'extra parameters'. The
canonical Softanza workaround is to route through `ring_len`, a tiny
top-of-namespace function defined in stkRingFuncs.ring that just
returns `len(p)`. Resolving against a global func dodges the
class-scope misbehavior.

This script:
  1. Walks every .ring file under libraries/stzlib/base/ (skipping
     archive/ dirs which hold dead legacy copies).
  2. Tracks class-scope boundaries (every `class X` opens; every
     blank-line-followed-by-another-class or func closes).
  3. Replaces `len(...)` with `ring_len(...)` ONLY inside class
     bodies. Module-level `len()` calls (outside any class) stay
     untouched -- they work fine.
  4. Preserves `ring_len`, `@len`, `MaxLen`, `StzLen`, etc.

Run with --dry-run to see how many calls would be touched without
modifying anything.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path('.').resolve()
LIB = ROOT / 'libraries' / 'stzlib' / 'base'

CLASS_RE = re.compile(r'^\s*class\s+\w', re.M)
FUNC_RE = re.compile(r'^\s*func\s+\w', re.M)
DEF_RE = re.compile(r'^\s*def\s+\w', re.M)

# Match `len(...)` but NOT: ring_len, MaxLen, _aLen_, @len, StzLen,
# .Len(, "len(", #len(, etc. Negative lookbehind for word/ID chars
# and the @ / . / " / # prefixes.
BARE_LEN = re.compile(r'(?<![\w_@.\#"])len\s*\(')


def is_inside_class(text: str, pos: int) -> bool:
    """Return True if pos is inside the body of a `class X` rather
    than inside a top-level `func` or before any class."""
    # Walk backwards to find the most-recent class/func/def opener.
    # A `class` opener means we're inside a class body. A top-level
    # `func` opener means we left class scope.
    # `def` openers are inner methods of the current class; they
    # don't change class-vs-func status.
    head = text[:pos]
    last_class = head.rfind('\nclass ')
    if last_class == -1:
        # Maybe at file start
        if head.lstrip().startswith('class '):
            last_class = 0
        else:
            last_class = -1
    last_func = head.rfind('\nfunc ')
    if last_class == -1:
        return False
    return last_class > last_func


def sweep_file(path: Path, dry_run: bool) -> int:
    text = path.read_text(encoding='utf-8', errors='replace')
    if not CLASS_RE.search(text):
        return 0

    matches = [m for m in BARE_LEN.finditer(text) if is_inside_class(text, m.start())]
    if not matches:
        return 0

    # Replace from end so positions stay valid.
    out = text
    for m in reversed(matches):
        out = out[:m.start()] + 'ring_len(' + out[m.end():]

    if not dry_run:
        path.write_text(out, encoding='utf-8')
    return len(matches)


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('paths', nargs='*',
                        help='restrict to specific .ring files')
    args = parser.parse_args()

    if args.paths:
        files = [Path(p) for p in args.paths]
    else:
        files = sorted(LIB.rglob('*.ring'))

    # Skip archive/ subdirs -- those are dead legacy copies.
    files = [f for f in files
             if '/archive/' not in f.as_posix()
             and '\\archive\\' not in str(f)]

    total = 0
    touched_files = 0
    per_file = []
    for f in files:
        n = sweep_file(f, args.dry_run)
        if n > 0:
            touched_files += 1
            total += n
            per_file.append((n, f.relative_to(LIB)))

    print(f'files touched: {touched_files}')
    print(f'len() -> ring_len() replacements: {total}')
    if args.dry_run:
        print('(dry-run; nothing written)')
    print()
    print('top 10 by replacements:')
    for n, p in sorted(per_file, reverse=True)[:10]:
        print(f'  {n:5d}  {p}')


if __name__ == '__main__':
    main()
