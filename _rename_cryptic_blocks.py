#!/usr/bin/env python3
"""Replace cryptic block filenames with descriptive slugs.

Targets the four common boilerplate shapes:
  - <NN>_pr.ring
  - <NN>_block_<NN>.ring
  - <NN>_startprofiler.ring
  - <NN>_block_<NN>_<garbage>.ring

For each, inspect the file body and derive a slug from the first
real `?` assertion. Keep the leading sequence number so block order
in the topic dir stays stable.

Examples:
  string/05_pr.ring          (first ?: @@(o1.FindAllCS(...)))
  -> string/05_findallcs.ring

  list/12_block_12.ring      (first ?: o1.NumberOfItems())
  -> list/12_numberofitems.ring
"""
import subprocess
import re
import sys
from pathlib import Path

ROOT = Path('.').resolve()
TEST = ROOT / 'libraries' / 'stzlib' / 'base' / 'test'

CRYPTIC_RE = re.compile(
    r'^(?P<num>\d+)'
    r'(?:_pr|_block_\d+|_startprofiler|_block_\d+_.*)'
    r'\.ring$'
)

# First `?` line that produces output. We deliberately don't match
# `//?` (commented out) or `# ?` (hash-comment).
ASSERT_LINE_RE = re.compile(r'^\s*\?\s+(.+?)\s*$', re.M)

# Extract a method name or stand-out word from the assertion expression.
METHOD_CALL_RE = re.compile(
    r'\.([A-Za-z][A-Za-z0-9]+)\s*\('
)
GLOBAL_CALL_RE = re.compile(
    r'\b([A-Z][A-Za-z][A-Za-z0-9]+)\s*\('
)


def derive_slug(text: str) -> str | None:
    m = ASSERT_LINE_RE.search(text)
    if not m:
        return None
    expr = m.group(1)
    # Prefer dotted method calls (o1.SomeMethod(...))
    methods = METHOD_CALL_RE.findall(expr)
    if methods:
        candidate = methods[0]
    else:
        # Fall back to the first CapCase global call (e.g. NowXT(...))
        globals_ = GLOBAL_CALL_RE.findall(expr)
        if not globals_:
            return None
        # Avoid the Q/SQ/LQ/TQ wrapper functions if a more specific
        # call follows
        for g in globals_:
            if g not in ('Q', 'SQ', 'LQ', 'TQ', 'L'):
                candidate = g
                break
        else:
            candidate = globals_[0]
    # Drop the StzXxxQ -> stzxxx prefix
    candidate = re.sub(r'^Stz', '', candidate)
    candidate = re.sub(r'Q$', '', candidate)
    return candidate.lower()


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

    renamed = 0
    skipped_unparseable = 0
    skipped_collision = 0
    for f in TEST.rglob('*.ring'):
        rel = f.relative_to(TEST)
        if len(rel.parts) != 2:
            continue
        if rel.parts[0].startswith('_'):
            continue
        m = CRYPTIC_RE.match(f.name)
        if not m:
            continue
        text = f.read_text(encoding='utf-8', errors='replace')
        slug = derive_slug(text)
        if not slug:
            skipped_unparseable += 1
            continue
        num = m.group('num')
        new_name = f'{num}_{slug}.ring'
        if new_name == f.name:
            continue
        dst = f.parent / new_name
        if dst.exists():
            skipped_collision += 1
            continue
        src_rel = f.resolve().relative_to(ROOT).as_posix()
        dst_rel = dst.resolve().parent.relative_to(ROOT).as_posix() + '/' + dst.name
        res = subprocess.run(
            ['git', 'mv', src_rel, dst_rel],
            capture_output=True, text=True,
        )
        if res.returncode == 0:
            renamed += 1
        else:
            # If git rejects the case-only difference on Windows, try
            # with a stash-via-tmpname
            tmp_rel = (
                dst.resolve().parent.relative_to(ROOT).as_posix()
                + f'/__rn_{num}_tmp.ring'
            )
            res1 = subprocess.run(
                ['git', 'mv', src_rel, tmp_rel],
                capture_output=True, text=True,
            )
            if res1.returncode == 0:
                res2 = subprocess.run(
                    ['git', 'mv', tmp_rel, dst_rel],
                    capture_output=True, text=True,
                )
                if res2.returncode == 0:
                    renamed += 1
                    continue
            print(f'  FAIL {f.name}: {res.stderr.strip()}')

    print(f'renamed:              {renamed}')
    print(f'skipped unparseable:  {skipped_unparseable}')
    print(f'skipped collision:    {skipped_collision}')


if __name__ == '__main__':
    main()
