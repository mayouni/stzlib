#!/usr/bin/env python3
"""Hoist len()/ring_len() out of `for ... to len(...)` loops library-wide.

Ring re-evaluates the upper bound of a `for i = 1 to <expr>` on every
iteration. If <expr> is `ring_len(x)` (or `len(x)`), that's O(N) per
iteration => O(N^2) total. Standing project rule: always assign the
length to a local before the loop:

    nLen = ring_len(@aHeaders)
    for j = 1 to nLen
        ...
    next

This script walks every .ring file under libraries/stzlib/base/ and
rewrites every `for <var> = <expr> to (ring_)?len(<arg>)<tail>` to:

    <auto-local> = ring_len(<arg>)
    for <var> = <expr> to <auto-local><tail>

`<tail>` is preserved so `to ring_len(x) - 1` or `to ring_len(x) step 2`
keeps working.

The auto-local name is derived from the function `<arg>` so distinct
loops in the same scope get distinct names:

  ring_len(@aHeaders)   -> _nHeadersLen_
  ring_len(@aContent)   -> _nContentLen_
  ring_len(paItems)     -> _nItemsLen_
  ring_len(aSorted_)    -> _nSortedLen_
  ring_len(x)           -> _nXLen_

If the same name would collide with an existing var in the surrounding
scope, an integer suffix is appended (_nXLen_2 etc.).

Skips archive/ subdirs (dead legacy copies).
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path('.').resolve()
LIB = ROOT / 'libraries' / 'stzlib' / 'base'

# Matches:  for <var> = <start-expr> to (ring_)?len(<arg>)<tail>
# - <var>       captured group 1
# - <start>     captured group 2
# - <arg>       captured group 3  (the expression inside len/ring_len)
# - <tail>      captured group 4  (anything between the len(...) close
#                                  paren and the end of line, e.g.
#                                  " - 1" or " step 2")
FOR_RE = re.compile(
    r'^(?P<indent>[ \t]*)'
    r'for\s+(?P<var>[a-zA-Z_][\w]*)\s*=\s*'
    r'(?P<start>[^\n]+?)\s+to\s+(?:ring_)?len\s*\(\s*'
    r'(?P<arg>[^)]+?)\s*\)'
    r'(?P<tail>[^\n]*)$',
    re.M,
)


def slugify(arg: str) -> str:
    """Convert `@aHeaders` / `paItems` / `aSorted_` to a length-name slug."""
    s = arg.strip()
    # Drop leading sigils
    s = s.lstrip('@$')
    # Drop trailing underscores from helper-style names
    s = s.rstrip('_')
    # Drop the typical Hungarian prefix ('a' for list, 'p' for param, 'c'
    # for string, 'n' for number) so the slug reads as the noun.
    if len(s) > 1 and s[0] in 'apcnoq' and s[1].isupper():
        s = s[1:]
    elif s.startswith('pa') and len(s) > 2 and s[2].isupper():
        s = s[2:]
    elif s.startswith('ac') and len(s) > 2 and s[2].isupper():
        s = s[2:]
    elif s.startswith('an') and len(s) > 2 and s[2].isupper():
        s = s[2:]
    # Collapse arrays / dot access into a single name
    s = re.sub(r'[^\w]', '', s)
    # Cap length
    s = s[:30]
    return s or 'X'


def sweep_file(path: Path, dry_run: bool) -> tuple[int, int]:
    text = path.read_text(encoding='utf-8', errors='replace')

    matches = list(FOR_RE.finditer(text))
    if not matches:
        return (0, 0)

    # Collect existing local names to avoid colliding with them.
    existing_names = set(re.findall(r'\b_n[A-Z]\w*Len_\b', text))

    # Process matches from end so positions stay valid.
    matches.sort(key=lambda m: -m.start())

    rewrites = 0
    out = text
    for m in matches:
        indent = m.group('indent')
        var = m.group('var')
        start = m.group('start')
        arg = m.group('arg')
        tail = m.group('tail')

        # Generate a unique length-local name.
        slug = slugify(arg)
        # CamelCase the slug
        slug = slug[0].upper() + slug[1:] if slug else 'X'
        candidate = f'_n{slug}Len_'
        i = 2
        while candidate in existing_names:
            candidate = f'_n{slug}Len_{i}'
            i += 1
        existing_names.add(candidate)

        new_for = (
            f'{indent}{candidate} = ring_len({arg})\n'
            f'{indent}for {var} = {start} to {candidate}{tail}'
        )
        out = out[:m.start()] + new_for + out[m.end():]
        rewrites += 1

    if rewrites and not dry_run:
        path.write_text(out, encoding='utf-8')
    return (rewrites, 1 if rewrites else 0)


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument(
        '--scope',
        default='lib',
        choices=('lib', 'tests', 'all'),
        help='lib=base/ only (default), tests=test/ only, all=both',
    )
    args = parser.parse_args()

    if args.scope == 'lib':
        targets = [
            f for f in LIB.rglob('*.ring')
            if '/archive/' not in f.as_posix()
            and '\\archive\\' not in str(f)
            and '/test/' not in f.as_posix()
            and '\\test\\' not in str(f)
        ]
    elif args.scope == 'tests':
        targets = list((LIB / 'test').rglob('*.ring'))
    else:
        targets = [
            f for f in LIB.rglob('*.ring')
            if '/archive/' not in f.as_posix()
            and '\\archive\\' not in str(f)
        ]

    total_rewrites = 0
    files_touched = 0
    per_file = []
    for f in targets:
        n, touched = sweep_file(f, args.dry_run)
        if touched:
            files_touched += 1
            total_rewrites += n
            per_file.append((n, f.relative_to(ROOT)))

    print(f'scope: {args.scope}')
    print(f'files touched: {files_touched}')
    print(f'for-len hoists: {total_rewrites}')
    if args.dry_run:
        print('(dry-run; nothing written)')
    print()
    print('top 10 by hoist count:')
    for n, p in sorted(per_file, reverse=True)[:10]:
        print(f'  {n:5d}  {p.as_posix()}')


if __name__ == '__main__':
    main()
