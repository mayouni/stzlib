#!/usr/bin/env python3
"""Rewrite `for X in <expr>` -> indexed-access form library-wide.

Ring's iterator-style for-in is a perf trap: the expression is
re-evaluated on each iteration step and the iterator binding adds
overhead. The Softanza canonical loop shape is:

  _aTmp_      = <expr>            # evaluate once
  _nTmpLen_   = ring_len(_aTmp_)  # hoist length
  for _iLoop_ = 1 to _nTmpLen_    # indexed access
      X = _aTmp_[_iLoop_]
      <body>                       # unchanged
  next

This script walks every .ring file under libraries/stzlib/base/ and
applies that transformation to every `for <ident> in <expr>` line.

The body and matching `next` are left untouched. Each rewrite gets
a unique numeric suffix on the helper var names so nested rewrites
in the same scope don't collide.

Skips archive/ subdirs (dead legacy copies).
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path('.').resolve()
LIB = ROOT / 'libraries' / 'stzlib' / 'base'

# Matches: `for <ident> in <expr>` (one line). We require the keyword
# `in` to be the standalone Ring keyword, not part of an identifier,
# AND we forbid the captured `<expr>` from containing `\bnext\b` --
# Ring allows a one-line form `for x in list <body> next` and our
# rewrite would otherwise mangle the body into the expression.
FOR_IN_RE = re.compile(
    r'^(?P<indent>[ \t]*)'
    r'for\s+(?P<var>[a-zA-Z_][\w]*)\s+in\s+'
    r'(?P<expr>(?:(?!\bnext\b).)+?)\s*$',
    re.M,
)


def slugify(expr: str) -> str:
    """Build a short readable suffix from the expression body."""
    s = expr.strip()
    s = s.lstrip('@$')
    s = s.rstrip('_')
    if len(s) > 1 and s[0] in 'apcnoq' and s[1].isupper():
        s = s[1:]
    elif s.startswith('pa') and len(s) > 2 and s[2].isupper():
        s = s[2:]
    s = re.sub(r'[^\w]', '', s)
    s = s[:24]
    return s or 'X'


def sweep_file(path: Path, dry_run: bool) -> int:
    text = path.read_text(encoding='utf-8', errors='replace')

    # Skip generator-style or special directives that look like for-in
    # but are actually data declarations: the `for` line being inside
    # a triple-quoted block etc. We rely on the simple regex anchor
    # (^[ \t]*for ...) which already excludes inline occurrences.

    matches = list(FOR_IN_RE.finditer(text))
    if not matches:
        return 0

    existing = set(re.findall(r'\b_[an][A-Z]\w*\b', text))

    # Process from end so positions stay valid.
    matches.sort(key=lambda m: -m.start())

    rewrites = 0
    out = text
    for m in matches:
        indent = m.group('indent')
        var = m.group('var')
        expr = m.group('expr').strip()

        # Two flavours of bookkeeping. If the expression is already a
        # bare identifier (no method call, no indexing), we don't need
        # to copy it to a local: re-evaluating a bare name is cheap.
        is_bare = bool(re.match(r'^[@$]?[a-zA-Z_][\w]*$', expr))

        slug = slugify(expr)
        slug = slug[0].upper() + slug[1:] if slug else 'X'
        # Pick a numbered suffix so multiple rewrites in the same
        # scope don't collide on _aTmp_, _nTmpLen_, _iLoop_.
        i = 1
        while True:
            tmp_name = f'_a{slug}{i}_'
            len_name = f'_n{slug}{i}Len_'
            idx_name = f'_iLoop{slug}{i}_'
            if (tmp_name not in existing
                and len_name not in existing
                and idx_name not in existing):
                break
            i += 1
        existing.add(tmp_name)
        existing.add(len_name)
        existing.add(idx_name)

        if is_bare:
            replacement = (
                f'{indent}{len_name} = ring_len({expr})\n'
                f'{indent}for {idx_name} = 1 to {len_name}\n'
                f'{indent}\t{var} = {expr}[{idx_name}]'
            )
        else:
            replacement = (
                f'{indent}{tmp_name} = {expr}\n'
                f'{indent}{len_name} = ring_len({tmp_name})\n'
                f'{indent}for {idx_name} = 1 to {len_name}\n'
                f'{indent}\t{var} = {tmp_name}[{idx_name}]'
            )

        out = out[:m.start()] + replacement + out[m.end():]
        rewrites += 1

    if rewrites and not dry_run:
        path.write_text(out, encoding='utf-8')
    return rewrites


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

    total = 0
    files_touched = 0
    per_file = []
    for f in targets:
        n = sweep_file(f, args.dry_run)
        if n > 0:
            files_touched += 1
            total += n
            per_file.append((n, f.relative_to(ROOT)))

    print(f'scope:           {args.scope}')
    print(f'files touched:   {files_touched}')
    print(f'for-in rewrites: {total}')
    if args.dry_run:
        print('(dry-run; nothing written)')
    print()
    print('top 10 by rewrite count:')
    for n, p in sorted(per_file, reverse=True)[:10]:
        print(f'  {n:5d}  {p.as_posix()}')


if __name__ == '__main__':
    main()
