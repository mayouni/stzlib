#!/usr/bin/env python3
"""Run-based mojibake reverser.

Scans a text file for RUNS of 2+ consecutive Unicode characters that
are all representable in cp1252 high range (0x80-0xFF) -- the
tell-tale signature of UTF-8 -> cp1252 -> UTF-8 mangling. For each
such run, reverses it to the raw bytes that produced it, and checks
whether those raw bytes form a valid UTF-8 sequence. If yes, the
substitution is committed; otherwise the run is left alone.

This is safer than blanket reversal because it only touches groups
of suspicious characters, leaving stray single accents (like 'e' in
'cafe') untouched.
"""
import sys

# cp1252 0x80..0x9F deviation from Latin-1
CP1252_HIGH = {
    0x80: 0x20AC, 0x82: 0x201A, 0x83: 0x0192, 0x84: 0x201E, 0x85: 0x2026,
    0x86: 0x2020, 0x87: 0x2021, 0x88: 0x02C6, 0x89: 0x2030, 0x8A: 0x0160,
    0x8B: 0x2039, 0x8C: 0x0152, 0x8E: 0x017D,
    0x91: 0x2018, 0x92: 0x2019, 0x93: 0x201C, 0x94: 0x201D, 0x95: 0x2022,
    0x96: 0x2013, 0x97: 0x2014, 0x98: 0x02DC, 0x99: 0x2122, 0x9A: 0x0161,
    0x9B: 0x203A, 0x9C: 0x0153, 0x9E: 0x017E, 0x9F: 0x0178,
}

# Inverse map: Unicode codepoint -> cp1252 byte
UC_TO_CP = {cp: b for b, cp in CP1252_HIGH.items()}
# 0xA0..0xFF map identically (Latin-1 supplement)
for b in range(0xA0, 0x100):
    UC_TO_CP[b] = b
# cp1252 undefined positions (0x81, 0x8D, 0x8F, 0x90, 0x9D) pass
# through as raw U+0081 etc. in pragmatic decoders -- mirror that
# so mangled box-drawing logos containing these bytes can be
# reversed as part of the surrounding run.
for b in (0x81, 0x8D, 0x8F, 0x90, 0x9D):
    UC_TO_CP[b] = b

def reverse_run(chars):
    """Given a list of Unicode codepoints all in cp1252, return the
    raw bytes that would have produced them via cp1252 decoding."""
    return bytes(UC_TO_CP[cp] for cp in chars)

def fix_text(text):
    """Walk text; collect runs of >=2 consecutive cp1252-decodable
    chars; reverse each run if its reversal is valid UTF-8."""
    out = []
    i = 0
    n = len(text)
    n_runs = 0
    n_bytes_changed = 0
    while i < n:
        # Look ahead for a run
        j = i
        while j < n and ord(text[j]) in UC_TO_CP:
            j += 1
        if j - i >= 2:
            run = text[i:j]
            raw = reverse_run([ord(c) for c in run])
            try:
                decoded = raw.decode('utf-8')
                # Only accept if the reversal genuinely changed
                # something (a no-op decode means no mangling).
                if decoded != run:
                    out.append(decoded)
                    n_runs += 1
                    n_bytes_changed += len(run) - len(decoded)
                else:
                    out.append(run)
            except UnicodeDecodeError:
                out.append(run)
            i = j
        else:
            out.append(text[i])
            i += 1
    return ''.join(out), n_runs, n_bytes_changed

def fix_file(path):
    with open(path, 'rb') as f:
        data = f.read()
    try:
        text = data.decode('utf-8')
    except UnicodeDecodeError as e:
        return False, f'source not valid UTF-8: {e}'

    new_text, n_runs, n_bytes_changed = fix_text(text)
    if n_runs == 0:
        return False, 'no reversible runs found'

    new_data = new_text.encode('utf-8')
    with open(path, 'wb') as f:
        f.write(new_data)
    return True, f'{n_runs} runs reversed ({len(data)} -> {len(new_data)} bytes)'

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) < 2:
        print('Usage: _fix_unicode_runs.py <file1> [<file2> ...]')
        return
    for path in sys.argv[1:]:
        try:
            ok, msg = fix_file(path)
        except Exception as e:
            ok, msg = False, f'error: {e}'
        status = 'FIXED' if ok else 'skip '
        print(f'[{status}] {path}: {msg}')

if __name__ == '__main__':
    main()
