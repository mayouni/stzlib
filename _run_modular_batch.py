#!/usr/bin/env python3
"""Run every .ring file in a modular topic directory and report
pass/fail. A block passes if every `? <expr>` line's runtime output
matches the immediately-following `#--> <expected>` marker.

Limitations:
- Multi-line expected outputs (a #--> block spanning multiple lines)
  are concatenated and matched against the runtime output that
  follows the corresponding ? line.
- Profiler pf() raises a STOPPED! banner -- everything after the
  "Executed in" line is ignored for matching.
"""
import sys, subprocess, re
from pathlib import Path

RING = r'D:\Ring126\bin\ring.exe'

def parse_expected(src):
    """Return [(expr_line, [expected_lines])] pairs."""
    pairs = []
    lines = src.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i].lstrip()
        if line.startswith('?'):
            expr = line
            expected = []
            j = i + 1
            # Look for #--> immediately or after blank lines
            while j < len(lines) and not lines[j].lstrip().startswith('#-->') and not lines[j].lstrip().startswith('?') and lines[j].strip() == '':
                j += 1
            if j < len(lines) and lines[j].lstrip().startswith('#-->'):
                first = lines[j].lstrip()[4:].strip()
                first = strip_annotations(first)
                if first:
                    expected.append(first)
                j += 1
                # Continuation lines starting with `#` and not `#-->`
                while j < len(lines):
                    l = lines[j].lstrip()
                    if l.startswith('#') and not l.startswith('#-->') and not l.startswith('# Executed') and not l.startswith('# RUNTIME'):
                        cont = strip_annotations(l.lstrip('#').strip())
                        if cont:
                            expected.append(cont)
                        j += 1
                    else:
                        break
                pairs.append((expr, expected))
            i = j
        else:
            i += 1
    return pairs

def run_file(path):
    proc = subprocess.run(
        [RING, str(path.name)],
        cwd=str(path.parent),
        capture_output=True, timeout=60,
    )
    return proc.stdout.decode('utf-8', errors='replace')

def normalise(s):
    return re.sub(r'\s+', ' ', s).strip()

# Strip narrator annotations from a `#-->` expected line so the
# matcher only compares against the actual VALUE the test claims.
# Cases handled:
#   - trailing comment after `#`  (e.g. "13 # Sum of weights" -> "13")
#   - trailing parenthetical hint (e.g. 'FALSE (because "c" ...)' -> 'FALSE')
#   - trailing English prose after a value (e.g.
#     `[ "a", "c", "d" ] Took the fast_road` -> `[ "a", "c", "d" ]`).
#     Heuristic: after a closing `]`, `}`, `)`, or `"`, a run of
#     space + letter + word(s) is treated as narrator prose, not
#     part of the literal value.
_INLINE_HASH_RE = re.compile(r'\s+#\s.*$')
_TRAILING_PAREN_RE = re.compile(r'\s+\([^)]*\)\s*$')
_TRAILING_PROSE_RE = re.compile(r'([\]\}\)"\'])\s+[A-Za-z]\w+(\s+\w+){1,}.*$')
# Same idea but allows the prose to be introduced by ` - ` or ` -- `
# (a hyphen separator the narrator commonly uses).
_TRAILING_DASH_PROSE_RE = re.compile(r'([\]\}\)"\'])\s+-+\s+[A-Za-z]\w+.*$')
# A pure-prose continuation line: starts with a Capword, has at
# LEAST one more word after it (so single-word values like `ring`,
# `softanza`, `TRUE` survive), and has no value-structure tokens.
_PURE_PROSE_RE = re.compile(r'^[A-Z][a-z]+(\s+[A-Za-z\d\.\,\;\!\?\:\-\_][\w\.\,\;\!\?\:\-\_]*){1,}\s*$')
def strip_annotations(s):
    prev = None
    while prev != s:
        prev = s
        s = _INLINE_HASH_RE.sub('', s)
        s = _TRAILING_PAREN_RE.sub('', s)
        s = _TRAILING_PROSE_RE.sub(r'\1', s)
        s = _TRAILING_DASH_PROSE_RE.sub(r'\1', s)
    s = s.strip()
    # If the whole line is pure narrator prose, drop it.
    if s and _PURE_PROSE_RE.match(s) and not any(c in s for c in '[]{}=<>'):
        return ''
    return s

# Relaxed form for tolerant matching: lowercase, drop the punctuation
# Ring strips/adds inconsistently between `?` print and @@() display
# (brackets, quotes, colons, commas) and collapse all whitespace.
# Used only as a fallback when strict matching has already failed.
_PUNCT_RE = re.compile(r"[\[\]\(\)\{\}\"',:=]")
# Trailing-zero stripper: "12.50" -> "12.5", "25.00" -> "25"
_TRAILING_ZEROS_RE = re.compile(r'(\d+\.\d*?)0+\b')
_BARE_DOT_RE = re.compile(r'(\d+)\.\b')
def relax(s):
    s = _PUNCT_RE.sub(' ', s)
    s = re.sub(r'\s+', ' ', s).strip().lower()
    # Normalise float representations: drop trailing zeros after
    # the decimal point ("12.50" -> "12.5"), then drop bare trailing
    # dots ("25." -> "25"). The library and the narrative often
    # disagree on the trailing-zero count for the same value.
    s = _TRAILING_ZEROS_RE.sub(r'\1', s)
    s = _BARE_DOT_RE.sub(r'\1', s)
    return s

def check_file(path):
    src = path.read_text(encoding='utf-8', errors='replace')
    pairs = parse_expected(src)
    if not pairs:
        return ('skip', 'no #--> markers')
    try:
        out = run_file(path)
    except subprocess.TimeoutExpired:
        return ('TIMEOUT', '60s')
    except Exception as e:
        return ('ERROR', str(e))

    # Trim the "Executed in / STOPPED!" tail.
    out = re.split(r'Executed in [^\n]*\n', out)[0]
    out_norm = normalise(out)
    out_relaxed = relax(out_norm)

    # Ordered-substring containment: each expected (after normalising
    # whitespace) must appear in the remaining runtime output past
    # the cursor of the previous match. We try a few format-tolerant
    # candidates so format-only drifts don't show up as FAIL:
    #   - TRUE / FALSE in #--> matches 1 / 0 at runtime
    #   - bracketed lists `[ a, b, c ]` match the same items printed
    #     one-per-line (Ring's default list output) by stripping all
    #     punctuation noise via relax()
    #   - `:Symbol` in the doc matches both `:symbol` and `symbol`
    #     (Ring tokenizes `:Symbol` lowercase, and `?` strips the
    #     leading colon)
    cursor_norm = 0
    cursor_relaxed = 0
    mismatches = []
    for idx, (expr, expected) in enumerate(pairs):
        exp_raw = normalise(' '.join(expected))
        candidates = [exp_raw]
        if exp_raw == 'TRUE': candidates.append('1')
        if exp_raw == 'FALSE': candidates.append('0')
        # Empty-list/dict tolerance: `[]` matches `[ ]`, `[  ]`, etc.
        # Ring's `?` print of empty lists adds whitespace; @@() output
        # collapses them. Add both forms as candidates.
        if exp_raw in ('[]', '[ ]', '[  ]'):
            candidates.extend(['[]', '[ ]'])
        # Also translate TRUE/FALSE inside larger expressions (lists,
        # parenthesised values, etc.). Ring prints booleans as 1/0
        # regardless of context.
        if re.search(r'\b(TRUE|FALSE)\b', exp_raw):
            tr = re.sub(r'\bTRUE\b', '1', exp_raw)
            tr = re.sub(r'\bFALSE\b', '0', tr)
            if tr != exp_raw:
                candidates.append(tr)

        # First try strict normalised match
        strict_pos = -1
        strict_end = 0
        for c in candidates:
            pos = out_norm.find(c, cursor_norm)
            if pos >= 0 and (strict_pos < 0 or pos < strict_pos):
                strict_pos = pos
                strict_end = pos + len(c)

        if strict_pos >= 0:
            cursor_norm = strict_end
            # Keep relaxed cursor in sync (approximate)
            cursor_relaxed = len(relax(out_norm[:strict_end]))
            continue

        # Strict failed -- try relaxed (punctuation- + symbol-folded).
        exp_relaxed = relax(exp_raw)
        if exp_relaxed and out_relaxed.find(exp_relaxed, cursor_relaxed) >= 0:
            pos = out_relaxed.find(exp_relaxed, cursor_relaxed)
            cursor_relaxed = pos + len(exp_relaxed)
            continue

        mismatches.append(f'#{idx+1} {expr.strip()[:60]} -> expected {exp_raw[:60]!r} not found past cursor {cursor_norm}')

    if mismatches:
        return ('FAIL', mismatches)
    return ('PASS', f'{len(pairs)} assertions matched')

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) < 2:
        print('Usage: _run_modular_batch.py <dir>')
        return
    d = Path(sys.argv[1])
    files = sorted(d.glob('*.ring'))
    stats = {'PASS': 0, 'FAIL': 0, 'TIMEOUT': 0, 'ERROR': 0, 'skip': 0}
    for f in files:
        status, detail = check_file(f)
        stats[status] = stats.get(status, 0) + 1
        if status == 'PASS':
            print(f'[ PASS ] {f.name}: {detail}')
        elif status == 'skip':
            print(f'[ skip ] {f.name}: {detail}')
        elif status == 'FAIL':
            print(f'[ FAIL ] {f.name}:')
            for m in detail[:5]:
                print('         ' + m.replace('\n', '\n         '))
            if len(detail) > 5:
                print(f'         ... +{len(detail)-5} more')
        else:
            print(f'[{status:^6}] {f.name}: {detail}')
    print('---')
    print(' / '.join(f'{k}: {v}' for k, v in stats.items() if v))

if __name__ == '__main__':
    main()
