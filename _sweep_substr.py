#!/usr/bin/env python3
"""Sweep substr() calls to engine-backed Stz* equivalents.

Ring's substr() is polymorphic by argument type:

  substr(s, n)         -> extract from codepoint n to end
  substr(s, n, len)    -> extract len codepoints from position n
  substr(s, sub)       -> position of first occurrence of sub (string)
  substr(s, old, new)  -> replace every occurrence of old with new

Maps to:

  substr(s, n)         -> StzMid(s, n, StzLen(s) - n + 1)   (no direct)
  substr(s, n, len)    -> StzMid(s, n, len)
  substr(s, sub)       -> StzFind(sub, s)
  substr(s, old, new)  -> StzReplace(s, old, new)

The mode is decidable from argument literal type when present.
For variable arguments we use a conservative heuristic plus
inline annotations the user can review.

Run:
  python _sweep_substr.py --dry         # categorise, do not modify
  python _sweep_substr.py --apply       # rewrite files
  python _sweep_substr.py --apply --paths libraries/stzlib/base/string
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path
from typing import Iterable, Optional

ROOT = Path('.').resolve()


# A substr call may have parens nested inside; we extract by paren-balance.

def find_substr_calls(src: str) -> list[tuple[int, int, str]]:
    """Return list of (start, end, full_call_text) for each substr( ... )."""
    out: list[tuple[int, int, str]] = []
    i = 0
    n = len(src)
    while i < n:
        m = re.search(r'\bsubstr\s*\(', src[i:])
        if not m:
            break
        start = i + m.start()
        # walk parens
        depth = 0
        j = i + m.end() - 1  # position of '('
        while j < n:
            c = src[j]
            if c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0:
                    out.append((start, j + 1, src[start:j + 1]))
                    i = j + 1
                    break
            elif c == '"' or c == "'":
                # skip string literal
                q = c
                j += 1
                while j < n and src[j] != q:
                    if src[j] == '\\':
                        j += 1
                    j += 1
            j += 1
        else:
            # malformed; break
            break
    return out


def split_args(arglist: str) -> list[str]:
    """Split 'a, b, c' respecting paren and string nesting."""
    parts: list[str] = []
    cur = ''
    depth = 0
    i = 0
    n = len(arglist)
    while i < n:
        c = arglist[i]
        if c in '([':
            depth += 1
            cur += c
        elif c in ')]':
            depth -= 1
            cur += c
        elif c == ',' and depth == 0:
            parts.append(cur.strip())
            cur = ''
        elif c == '"' or c == "'":
            q = c
            cur += c
            i += 1
            while i < n and arglist[i] != q:
                if arglist[i] == '\\':
                    cur += arglist[i]
                    i += 1
                cur += arglist[i]
                i += 1
            if i < n:
                cur += arglist[i]
        else:
            cur += c
        i += 1
    if cur.strip():
        parts.append(cur.strip())
    return parts


def looks_like_string(expr: str) -> bool:
    e = expr.strip()
    if not e:
        return False
    if e.startswith(('"', "'")):
        return True
    # Heuristic: variable names starting with c, pc, _c, ac, name like "pcSub"
    if re.match(r'^(pc|_c|c|p?cSub|p?cNew|p?cOld|pcStr|cStr)[A-Z_]', e):
        return True
    # Concatenated strings or trim() / lower() etc.
    if 'ring_left' in e or 'ring_right' in e or 'ring_trim' in e:
        return True
    if 'lower(' in e or 'upper(' in e:
        return True
    return False


def looks_like_number(expr: str) -> bool:
    e = expr.strip()
    if re.match(r'^-?\d+$', e):
        return True
    if re.match(r'^_?n[A-Z_]', e) or e in ('i', 'j', 'k', '_i_', '_j_', '_k_'):
        return True
    if 'len(' in e or 'StzLen(' in e or 'ring_len(' in e:
        return True
    # arithmetic with numeric vars
    if re.match(r'^.*[\+\-\*/].*$', e) and not e.startswith('"'):
        return True
    return False


def categorize(call_text: str) -> tuple[str, Optional[str]]:
    """Return (mode, rewrite_or_none).

    mode is one of: 'find', 'replace', 'mid2', 'mid3', 'unknown'.
    """
    inner = call_text[call_text.index('(') + 1: -1]
    args = split_args(inner)
    if len(args) == 2:
        a1, a2 = args
        if looks_like_string(a2) and not looks_like_number(a2):
            return 'find', f'StzFind({a2}, {a1})'
        if looks_like_number(a2) and not looks_like_string(a2):
            return 'mid2', f'StzMidToEnd({a1}, {a2})'
        return 'unknown', None
    if len(args) == 3:
        a1, a2, a3 = args
        # If a2 is clearly a string and a3 is clearly a string -> replace.
        a2_str = looks_like_string(a2)
        a3_str = looks_like_string(a3)
        a2_num = looks_like_number(a2)
        a3_num = looks_like_number(a3)
        if a2_str and a3_str and not (a2_num and a3_num):
            return 'replace', f'StzReplace({a1}, {a2}, {a3})'
        if a2_num and a3_num and not (a2_str and a3_str):
            return 'mid3', f'StzMid({a1}, {a2}, {a3})'
        return 'unknown', None
    return 'unknown', None


def walk_files(root: Path, paths: Iterable[str]) -> list[Path]:
    out: list[Path] = []
    for p in paths:
        base = (root / p).resolve()
        if not base.exists():
            continue
        if base.is_file() and base.suffix == '.ring':
            out.append(base)
            continue
        for f in base.rglob('*.ring'):
            sp = str(f).replace('\\', '/')
            if '/archive/' in sp or '/test/' in sp or '/_diagnostics/' in sp:
                continue
            out.append(f)
    return out


def process(file_path: Path, apply: bool) -> dict[str, int]:
    src = file_path.read_text(encoding='utf-8', errors='replace')
    calls = find_substr_calls(src)
    stats: dict[str, int] = {'find': 0, 'replace': 0, 'mid2': 0, 'mid3': 0, 'unknown': 0}
    if not calls:
        return stats
    # Rewrite from end to start so offsets stay valid.
    new_src = src
    for start, end, call in reversed(calls):
        mode, rewrite = categorize(call)
        stats[mode] += 1
        if apply and rewrite is not None:
            new_src = new_src[:start] + rewrite + new_src[end:]
    if apply and new_src != src:
        file_path.write_text(new_src, encoding='utf-8')
    return stats


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--apply', action='store_true', help='rewrite files in place')
    ap.add_argument('--paths', nargs='*', default=['libraries/stzlib/base'],
                    help='paths to walk')
    ap.add_argument('--verbose', action='store_true')
    args = ap.parse_args(argv)
    files = walk_files(ROOT, args.paths)
    total: dict[str, int] = {'find': 0, 'replace': 0, 'mid2': 0, 'mid3': 0, 'unknown': 0}
    for f in files:
        s = process(f, args.apply)
        if any(s.values()):
            if args.verbose:
                rel = str(f.relative_to(ROOT)).replace('\\', '/')
                print(f'{rel:60s}  find={s["find"]:3d}  replace={s["replace"]:3d}  mid2={s["mid2"]:3d}  mid3={s["mid3"]:3d}  ?={s["unknown"]:3d}')
            for k, v in s.items():
                total[k] += v
    print(f'\nTOTAL  find={total["find"]}  replace={total["replace"]}  mid2={total["mid2"]}  mid3={total["mid3"]}  unknown={total["unknown"]}')
    if not args.apply:
        print('\n(dry run — pass --apply to rewrite)')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
