#!/usr/bin/env python3
"""Find candidate duplicate blocks across topic dirs.

A "duplicate" here is: two .ring files whose normalised body
(stripped of the narrative header, blank lines collapsed, leading/
trailing whitespace removed from each non-comment line) is byte-for-
byte identical. Those are extraction-artefact dupes -- the same
block ended up in the modular suite twice -- and one of them should
be removed.

Run with --delete to actually `git rm` the second-and-later copies
of each duplicate group (keeping the lowest-numbered filename, i.e.
the one most likely to be the "canonical" version).
"""
from __future__ import annotations

import hashlib
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path('.').resolve()
TEST = ROOT / 'libraries' / 'stzlib' / 'base' / 'test'

# Header lines that aren't part of the assertion body (so they don't
# affect dup-detection).
HEADER_RE = re.compile(r'^\s*#.*$', re.M)


def normalise_body(text: str) -> str:
    # Strip every comment line, then collapse runs of whitespace.
    lines = []
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith('#'):
            continue
        # Collapse runs of whitespace inside the line
        stripped = re.sub(r'\s+', ' ', stripped)
        lines.append(stripped)
    return '\n'.join(lines)


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

    groups: dict[str, list[Path]] = defaultdict(list)
    for f in TEST.rglob('*.ring'):
        rel = f.relative_to(TEST)
        if len(rel.parts) != 2:
            continue
        if rel.parts[0].startswith('_'):
            continue
        text = f.read_text(encoding='utf-8', errors='replace')
        norm = normalise_body(text)
        # Ignore files with only trivial bodies (a single `load`)
        if norm.count('\n') < 2:
            continue
        digest = hashlib.sha1(norm.encode('utf-8')).hexdigest()
        groups[digest].append(f)

    dup_groups = [paths for paths in groups.values() if len(paths) > 1]
    print(f'duplicate groups:           {len(dup_groups)}')
    print(f'total duplicate copies:     {sum(len(g) for g in dup_groups)}')
    print(f'redundant files to remove:  '
          f'{sum(len(g) - 1 for g in dup_groups)}')

    if '--delete' not in sys.argv:
        print()
        # Show top 10 groups
        for grp in sorted(dup_groups, key=lambda g: -len(g))[:10]:
            print(f'  group of {len(grp)}:')
            for p in grp[:5]:
                print(f'    {p.relative_to(TEST).as_posix()}')
            if len(grp) > 5:
                print(f'    ... and {len(grp) - 5} more')
        return

    # --delete: remove all but the first in each group. "First" by
    # sort order = lowest sequence number, then alphabetic.
    removed = 0
    for grp in dup_groups:
        grp.sort(key=lambda p: (p.parent.name, p.name))
        keep = grp[0]
        for victim in grp[1:]:
            src_rel = victim.resolve().relative_to(ROOT).as_posix()
            res = subprocess.run(
                ['git', 'rm', src_rel],
                capture_output=True, text=True,
            )
            if res.returncode == 0:
                removed += 1
            else:
                print(f'  FAIL rm {src_rel}: {res.stderr.strip()}')
    print(f'\nremoved: {removed} duplicate file(s)')


if __name__ == '__main__':
    main()
