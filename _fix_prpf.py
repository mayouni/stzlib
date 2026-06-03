#!/usr/bin/env python3
"""Insert missing pr()/pf() profiling pairs into every modular test
block. Skips files the user has already hand-tuned (anything dirty in
the working tree) and skips the regression-baseline files that use
their own PASS/FAIL accounting.
"""
import subprocess
import re
from pathlib import Path


TEST = Path('libraries/stzlib/base/test')

PR_RE = re.compile(r'^\s*pr\s*\(\s*\)', re.M)
PF_RE = re.compile(r'^\s*pf\s*\(\s*\)', re.M)
PROFON_RE = re.compile(r'^\s*profon\s*\(\s*\)', re.M)
LOAD_LINE_RE = re.compile(r'^\s*load\s+"[^"]+"\s*$', re.M)

SKIP_RE = re.compile(
    r'test_.*_regression\.ring$|test_load_base\.ring$|test_integration_audit\.ring$'
)


def collect_touched():
    """Files the user is currently editing (dirty in the working tree)."""
    res = subprocess.run(['git', 'status', '--short'],
                         capture_output=True, text=True)
    out = set()
    for line in res.stdout.splitlines():
        parts = line.split(maxsplit=1)
        if len(parts) == 2 and parts[1].endswith('.ring'):
            norm = parts[1].replace('\\', '/')
            out.add(norm)
    return out


def fix_file(path: Path):
    text = path.read_text(encoding='utf-8', errors='replace')
    has_pr = bool(PR_RE.search(text))
    has_pf = bool(PF_RE.search(text))
    has_profon = bool(PROFON_RE.search(text))
    if has_profon:
        return None
    if has_pr and has_pf:
        return None

    load_positions = list(LOAD_LINE_RE.finditer(text))
    if not load_positions:
        return None
    last_load = load_positions[-1]
    nl = text.find('\n', last_load.end())
    if nl == -1:
        return None

    # Skip any contiguous blank lines after the load. pr() goes after
    # the load + blank-line buffer, just before the first real body line.
    cursor = nl + 1
    while cursor < len(text) and text[cursor] == '\n':
        cursor += 1

    head = text[:cursor]
    rest = text[cursor:]

    if not has_pr:
        head = head.rstrip('\n') + '\n\npr()\n\n'

    if not has_pf:
        # Place pf() right before the trailing "# Executed in ..."
        # historical-timing line if present, otherwise at EOF.
        timing_re = re.compile(
            r'(\n*# Executed in [^\n]*(?:\n# Executed in [^\n]*)*\s*)$'
        )
        m = timing_re.search(rest)
        if m:
            rest = rest[:m.start()].rstrip() + '\n\npf()\n' + rest[m.start():].lstrip('\n')
        else:
            rest = rest.rstrip() + '\n\npf()\n'

    path.write_text(head + rest, encoding='utf-8')
    if not has_pr and not has_pf:
        return 'both'
    elif not has_pr:
        return 'pr'
    else:
        return 'pf'


def main():
    touched = collect_touched()
    fixed = {'pr': 0, 'pf': 0, 'both': 0}
    skipped_touched = 0
    skipped_pattern = 0
    total_seen = 0
    for f in TEST.rglob('*.ring'):
        rel = f.relative_to(TEST)
        if len(rel.parts) != 2:
            continue
        total_seen += 1
        rel_str = str(f.as_posix())
        if rel_str in touched or rel_str.startswith('./') and rel_str[2:] in touched:
            skipped_touched += 1
            continue
        # touched paths from git status are relative to repo root
        rel_repo = str(f).replace('\\', '/')
        if rel_repo in touched:
            skipped_touched += 1
            continue
        if SKIP_RE.search(rel.name):
            skipped_pattern += 1
            continue
        kind = fix_file(f)
        if kind:
            fixed[kind] += 1
    print(f'seen            : {total_seen}')
    print(f'pr() added      : {fixed["pr"]}')
    print(f'pf() added      : {fixed["pf"]}')
    print(f'both added      : {fixed["both"]}')
    print(f'skipped touched : {skipped_touched}')
    print(f'skipped pattern : {skipped_pattern}')


if __name__ == '__main__':
    main()
