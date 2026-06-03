#!/usr/bin/env python3
"""Tidy filenames left over by _relocate_misplaced_tests.

The relocator names moved files 'from_<src-topic>_<orig-stem>.ring' so
their provenance is auditable. For regression baselines and a few other
clean shapes, the from_ prefix is just noise. Strip it when the
underlying stem is already self-describing.
"""
import subprocess
import re
import sys
from pathlib import Path

ROOT = Path('.').resolve()
TEST = ROOT / 'libraries' / 'stzlib' / 'base' / 'test'


def gmv(src: Path, dst: Path) -> bool:
    src_rel = src.resolve().relative_to(ROOT).as_posix()
    dst_rel = dst.resolve().parent.relative_to(ROOT).as_posix() + '/' + dst.name
    res = subprocess.run(
        ['git', 'mv', src_rel, dst_rel],
        capture_output=True, text=True,
    )
    if res.returncode == 0:
        return True
    print(f'  FAIL {src.name} -> {dst.name}: {res.stderr.strip()}')
    return False


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

    # 1) from_<topic>_test_<x>_regression.ring  ->  test_<x>_regression.ring
    n_regression = 0
    for f in TEST.rglob('from_*_test_*_regression.ring'):
        new_name = re.sub(
            r'^from_[^_]+_(test_.+_regression\.ring)$',
            r'\1', f.name,
        )
        if new_name == f.name:
            continue
        dst = f.parent / new_name
        if dst.exists():
            print(f'  collision (regression): {f.name} <-> {dst.name}')
            continue
        if gmv(f, dst):
            n_regression += 1

    # 2) from_<topic>_test_<name>.ring  ->  test_<name>.ring  (engine,
    #    delegation, batch, etc. — when the dst doesn't yet have one)
    n_test = 0
    for f in TEST.rglob('from_*_test_*.ring'):
        new_name = re.sub(
            r'^from_[^_]+_(test_.+\.ring)$',
            r'\1', f.name,
        )
        if new_name == f.name:
            continue
        dst = f.parent / new_name
        if dst.exists():
            continue  # leave the from_ form so it's audit-traceable
        if gmv(f, dst):
            n_test += 1

    print(f'cleaned regression-baseline names: {n_regression}')
    print(f'cleaned test_ names:               {n_test}')


if __name__ == '__main__':
    main()
