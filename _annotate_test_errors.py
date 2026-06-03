#!/usr/bin/env python3
"""Run every modular test block, mark the ones that error.

For each `.ring` file under a topic dir, run it with the Ring
interpreter, capture stdout/stderr + exit code, and detect errors:

  - "Line N Error (R??) : <message>"   (Ring runtime error)
  - "Error (C??) : <message>"          (Ring syntax error)
  - "Error (E?) : ..."                 (Ring file-open error)
  - "thread N panic: <text>"           (Zig-engine crash from a DLL)
  - non-zero exit + a non-empty first stdout line
  - subprocess.TimeoutExpired

Files that error get a `#ERR <code>: <message>` line inserted at the
top, right before `load "..."`. Existing `#ERR` lines are replaced so
re-running the script keeps the annotation current. Files that pass
have any pre-existing `#ERR` line removed.

The script is idempotent and progress-resumable: it scans for
existing `#ERR` annotations to know what state each file is in, and
writes a checkpoint log (`_ERR_RUN.txt`) under each topic dir so a
crash mid-batch can pick up where it left off.

Run modes:
  python _annotate_test_errors.py                  # whole tree
  python _annotate_test_errors.py counter list     # a few topic dirs
  python _annotate_test_errors.py --timeout 20     # per-file timeout
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path('.').resolve()
TEST = ROOT / 'libraries' / 'stzlib' / 'base' / 'test'
RING = os.environ.get('RING_EXE', r'D:\Ring126\bin\ring.exe')

# Error-line patterns Ring + the Zig engine emit.
ERR_PATTERNS = [
    re.compile(r'^(?P<head>.*?Error\s+\([RECW]?\d+\)[^\n]*)$', re.M),
    re.compile(r'^(?P<head>.*?panic:[^\n]+)$', re.M),
    re.compile(r'^(?P<head>Error\s+\([RECW]?\d+\)[^\n]*)$', re.M),
]

# Lines we never want as the "error summary" -- noise from the
# Softanza profiler closing each block.
SUPPRESS_RE = re.compile(
    r'STOPPED!|stkProfiler|Called from line|^---*$'
)

# Header marker we inject.
ERR_TAG_RE = re.compile(r'^#ERR\b[^\n]*\n', re.M)


_PF_BANNER_RE = re.compile(
    r'STOPPED!|In raise\(\)|In function stop\(\)|stkProfiler|'
    r'Called from line \d+ In function pf\(\)'
)


def detect_error(stdout: str, stderr: str, exit_code: int,
                 timed_out: bool) -> str | None:
    if timed_out:
        return 'TIMEOUT'
    combined = stdout + '\n' + stderr

    # 1) Real errors first: Ring R/C/E codes, Zig-engine panics.
    for pat in ERR_PATTERNS:
        m = pat.search(combined)
        if not m:
            continue
        head = m.group('head').strip()
        # Drop noise from the Softanza profiler closing banner.
        if _PF_BANNER_RE.search(head):
            continue
        m2 = re.search(
            r'(Error\s+\([RECW]?\d+\)[^\n]*?:[^\n]+|panic:[^\n]+)',
            head,
        )
        if m2:
            return m2.group(1).strip()
        return head[:160]

    # 2) Non-zero exit. If the profiler banner appears, the non-zero
    # exit is the deliberate pf()/StzRaise(:Stop) close-out, NOT an
    # error. Only flag if there's no banner.
    if exit_code not in (0, None):
        if _PF_BANNER_RE.search(combined):
            return None
        first_line = next(
            (l.strip() for l in combined.splitlines() if l.strip()),
            '',
        )
        if first_line:
            return f'exit {exit_code}: {first_line[:140]}'
        return f'exit {exit_code}'
    return None


def annotate(path: Path, err_msg: str | None) -> str:
    """Inject (or remove) a `#ERR ...` line near the top of path.

    Returns 'added' / 'updated' / 'removed' / 'unchanged'.
    """
    text = path.read_text(encoding='utf-8', errors='replace')
    has_err = bool(ERR_TAG_RE.search(text))

    if err_msg is None:
        if not has_err:
            return 'unchanged'
        new_text = ERR_TAG_RE.sub('', text, count=1)
        path.write_text(new_text, encoding='utf-8')
        return 'removed'

    new_line = f'#ERR {err_msg}\n'
    if has_err:
        new_text = ERR_TAG_RE.sub(new_line, text, count=1)
        path.write_text(new_text, encoding='utf-8')
        return 'updated'

    # Insert just before the first `load "..."` line. If no load
    # line, insert at the very top.
    m = re.search(r'^load\s+"', text, re.M)
    if m:
        # Step back over any blank lines preceding the load
        cut = m.start()
        while cut > 0 and text[cut - 1] == '\n':
            cut -= 1
        head = text[:cut].rstrip()
        tail = text[cut:]
        new_text = head + '\n' + new_line + '\n' + tail.lstrip('\n')
    else:
        new_text = new_line + text
    path.write_text(new_text, encoding='utf-8')
    return 'added'


def run_one(path: Path, timeout: float) -> tuple[str | None, bool]:
    """Return (error_summary_or_None, timed_out)."""
    try:
        proc = subprocess.run(
            [RING, path.name],
            cwd=str(path.parent),
            capture_output=True,
            timeout=timeout,
            stdin=subprocess.DEVNULL,
        )
    except subprocess.TimeoutExpired as e:
        return ('TIMEOUT', True)
    stdout = proc.stdout.decode('utf-8', errors='replace') if proc.stdout else ''
    stderr = proc.stderr.decode('utf-8', errors='replace') if proc.stderr else ''
    return (detect_error(stdout, stderr, proc.returncode, False), False)


def iter_topic_dirs(args_topics: list[str]):
    if args_topics:
        for t in args_topics:
            p = TEST / t
            if p.is_dir():
                yield p
            else:
                print(f'skip (no such topic): {t}', file=sys.stderr)
    else:
        for p in sorted(TEST.iterdir()):
            if not p.is_dir():
                continue
            if p.name.startswith('_'):
                continue
            yield p


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('topics', nargs='*',
                        help='restrict to specific topic dir name(s)')
    parser.add_argument('--timeout', type=float, default=25.0,
                        help='per-file timeout in seconds (default 25)')
    parser.add_argument('--skip-existing', action='store_true',
                        help='do not re-run files that already have a #ERR')
    parser.add_argument('--dry-run', action='store_true',
                        help='report classifications without modifying files')
    args = parser.parse_args()

    totals = {'pass': 0, 'err': 0, 'timeout': 0,
              'annotated_added': 0, 'annotated_updated': 0,
              'annotated_removed': 0,
              'files_visited': 0}

    for topic_dir in iter_topic_dirs(args.topics):
        topic_start = time.time()
        per_topic = {'pass': 0, 'err': 0, 'timeout': 0}
        log_lines = []
        for f in sorted(topic_dir.iterdir()):
            if not f.is_file() or f.suffix != '.ring':
                continue
            if f.name.startswith('_'):
                continue
            totals['files_visited'] += 1
            text = f.read_text(encoding='utf-8', errors='replace')
            if args.skip_existing and ERR_TAG_RE.search(text):
                continue
            err, timed_out = run_one(f, args.timeout)
            if err == 'TIMEOUT':
                per_topic['timeout'] += 1
                totals['timeout'] += 1
                log_lines.append(f'[TIMEOUT] {f.name}')
                if not args.dry_run:
                    res = annotate(f, 'TIMEOUT (>'
                                    f'{int(args.timeout)}s)')
                    totals[f'annotated_{res}'] = totals.get(
                        f'annotated_{res}', 0) + 1
            elif err:
                per_topic['err'] += 1
                totals['err'] += 1
                log_lines.append(f'[ERR]     {f.name} :: {err}')
                if not args.dry_run:
                    res = annotate(f, err)
                    totals[f'annotated_{res}'] = totals.get(
                        f'annotated_{res}', 0) + 1
            else:
                per_topic['pass'] += 1
                totals['pass'] += 1
                log_lines.append(f'[PASS]    {f.name}')
                if not args.dry_run:
                    res = annotate(f, None)
                    if res == 'removed':
                        totals['annotated_removed'] = totals.get(
                            'annotated_removed', 0) + 1

        elapsed = time.time() - topic_start
        head = (f'== {topic_dir.name}  '
                f'PASS {per_topic["pass"]}  '
                f'ERR {per_topic["err"]}  '
                f'TIMEOUT {per_topic["timeout"]}  '
                f'({elapsed:.1f}s) ==')
        print(head)
        (topic_dir / '_ERR_RUN.txt').write_text(
            head + '\n' + '\n'.join(log_lines) + '\n',
            encoding='utf-8',
        )

    print()
    print('---- totals ----')
    for k, v in totals.items():
        print(f'  {k:22s} {v}')


if __name__ == '__main__':
    main()
