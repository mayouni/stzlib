#!/usr/bin/env python3
"""Move misplaced modular test blocks to the correct topic dir.

Uses the verdict from _audit_topic_placement.py. For each file the
audit says belongs in topic Y instead of its current X, git-mv to
test/Y/ with a uniqueness-preserving rename:

  string/153_pr.ring                -> list/from_string_153.ring
  string/901_pr.ring                -> listofchars/from_string_901.ring
  listofstrings/14_stztext...ring   -> ttext/from_listofstrings_14.ring

The "from_<topic>_<original-stem>" naming makes the move auditable
later (a contributor can grep for from_string_ in list/ to see what
came from where without diving into git log).
"""
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path('.').resolve()
TEST = ROOT / 'libraries' / 'stzlib' / 'base' / 'test'


def load_audit():
    res = subprocess.run(
        [sys.executable, '_audit_topic_placement.py', '--json'],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
    )
    return json.loads(res.stdout)


def safe_dst_name(dst_dir: Path, src_stem: str, src_topic: str) -> str:
    """Construct a destination filename that doesn't collide and
    encodes its provenance."""
    # Strip any leading "NN_" sequence number from the original stem
    # so we don't carry stale numbering into the new home.
    m = re.match(r'^\d+_(.+)$', src_stem)
    body = m.group(1) if m else src_stem
    # If the body is just 'pr', use the original number instead.
    if body in ('pr', 'startprofiler') and m:
        body = m.group(0)  # keep "NN_pr"
    candidate = f'from_{src_topic}_{body}.ring'
    if not (dst_dir / candidate).exists():
        return candidate
    # collision: append a sequence
    for i in range(2, 1000):
        bumped = f'from_{src_topic}_{body}__{i}.ring'
        if not (dst_dir / bumped).exists():
            return bumped
    raise RuntimeError(f'cannot find free name for {src_stem}')


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

    audit = load_audit()
    moves = []
    for r in audit:
        # Skip rows the audit annotated 'expected dir missing' -- we
        # don't want to create new topic dirs as a side effect.
        if r.get('note') == 'expected dir missing':
            continue
        src = TEST / r['file']
        if not src.exists():
            continue
        # Regression baselines should live with their topic. If they
        # got placed under a parent topic (e.g. test_hashlist_regression
        # under list/), the audit's dominant-class signal will route
        # them correctly. Engine-bridge tests of internal helper
        # classes (test_engine_<helper>_*.ring) usually have no
        # destination dir of their own and are filtered out by the
        # 'expected dir missing' note upstream -- but a few helpers
        # share a topic with their parent and we want to keep them
        # there. Detect: skip when the file name matches a known
        # internal-helper pattern.
        INTERNAL_HELPER = re.compile(
            r'test_engine_(list|string)_'
            r'(counter|leadtrail|mover|remover|replacer|random|'
            r'flattener|trimmer|case|inserter|crypto|len|item)',
            re.I,
        )
        if INTERNAL_HELPER.search(src.name):
            continue
        moves.append(r)

    print(f'planned moves: {len(moves)}')
    by_target = {}
    for r in moves:
        by_target.setdefault(r['expected'], []).append(r)
    for tgt, items in sorted(by_target.items(), key=lambda kv: -len(kv[1])):
        print(f'  -> {tgt}/: {len(items)}')

    if '--dry-run' in sys.argv:
        return

    moved = 0
    failed = []
    for r in moves:
        src = TEST / r['file']
        if not src.exists():
            continue
        src_topic = r['current']
        dst_topic = r['expected']
        dst_dir = TEST / dst_topic
        dst_name = safe_dst_name(dst_dir, src.stem, src_topic)
        dst = dst_dir / dst_name
        # Determine git-tracked source path
        src_rel = str(src.relative_to(ROOT)).replace('\\', '/')
        dst_rel = str(dst.relative_to(ROOT)).replace('\\', '/')
        res = subprocess.run(['git', 'mv', src_rel, dst_rel],
                             cwd=str(ROOT),
                             capture_output=True, text=True)
        if res.returncode == 0:
            moved += 1
        else:
            failed.append((src_rel, dst_rel, res.stderr.strip()))
    print(f'moved: {moved}')
    if failed:
        print(f'failed: {len(failed)}')
        for s, d, err in failed[:10]:
            print(f'  {s} -> {d}: {err}')


if __name__ == '__main__':
    main()
