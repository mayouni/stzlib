#!/usr/bin/env python3
"""Fix double-encoded UTF-8 in Softanza .ring files via targeted byte
substitution.

The mass-migration commit (60852618) re-read files as Latin-1 then
wrote them as UTF-8, double-encoding the multi-byte chars. For each
multi-byte UTF-8 sequence `XX YY`, the result became `c3 (XX-0x40)
c2 YY` if XX is in c0-df, or `c3 (XX-0x40) c2 YY c2 ZZ` for longer
sequences, etc. We map known doubles back to singles.

This is safer than a full round-trip because:
- Files that mix proper UTF-8 (e.g. " " quote chars from a code paste)
  with double-encoded literals are common
- Only the recognized double-encoded patterns get touched
"""
import sys, os

# Map of (double-encoded bytes) -> (proper UTF-8 bytes).
# Each Latin-supplement / Latin-extended char shows as `c3 83 c2 XX`
# when double-encoded. Each Arabic char shows as `c3 98 c2 XX` etc.
SUBSTITUTIONS = []

# Latin-1 supplement (U+0080..U+00FF: UTF-8 = c2 XX or c3 XX)
# When double-encoded: c3 82 c2 XX (for c2 XX originals) and c3 83 c2 XX (for c3 XX originals)
for x in range(0x80, 0xc0):  # c2 XX cases
    SUBSTITUTIONS.append((bytes([0xc3, 0x82, 0xc2, x]), bytes([0xc2, x])))
for x in range(0x80, 0xc0):  # c3 XX cases (XX shifted from raw to UTF-8 trail byte form)
    # c3 83 c2 XX -> c3 XX (where the Latin-1 codepoint is 0xC3 = X+0x40 ish)
    # Actually for U+00C3 the latin-1 byte is c3. UTF-8 of U+00C3 is c3 83. When
    # re-encoded latin-1 then UTF-8 the c3 byte becomes c3 83 again, and 83 becomes
    # c2 83. So we get c3 83 c2 83 for U+00C3. To recover: c3 83 c2 XX -> c3 (XX or XX+0x40?)
    # The mapping is: original utf-8 byte 0xc3 + trail byte Z -> double = c3 83 c2 Z
    SUBSTITUTIONS.append((bytes([0xc3, 0x83, 0xc2, x]), bytes([0xc3, x])))

# Arabic block U+0600..U+06FF: UTF-8 = d8 XX, d9 XX, da XX, db XX
# Double-encoded: c3 98 c2 XX, c3 99 c2 XX, c3 9a c2 XX, c3 9b c2 XX
for lead in (0xd8, 0xd9, 0xda, 0xdb):
    for x in range(0x80, 0xc0):
        SUBSTITUTIONS.append((bytes([0xc3, lead - 0x40, 0xc2, x]), bytes([lead, x])))

# Detect any double-encoded marker that suggests fix is needed
RECOGNIZED_MARKERS = [
    b'\xc3\x83\xc2\xa9',  # é
    b'\xc3\x83\xc2\xa8',  # è
    b'\xc3\x83\xc2\xa0',  # à
    b'\xc3\x83\xc2\xa7',  # ç
    b'\xc3\x83\xc2\xb4',  # ô
    b'\xc3\x98\xc2',      # Arabic d8 XX double-encode
    b'\xc3\x99\xc2',      # Arabic d9 XX
]

def needs_fix(data):
    # Broader detection: any `c3 83 c2 XX` or `c3 98/99/9a/9b c2 XX`
    # sequence indicates double-encoded Latin or Arabic content.
    for lead in (0x83, 0x98, 0x99, 0x9a, 0x9b):
        if bytes([0xc3, lead, 0xc2]) in data:
            return True
    return any(m in data for m in RECOGNIZED_MARKERS)

def fix_file(path):
    with open(path, 'rb') as f:
        data = f.read()

    if not needs_fix(data):
        return False, 'no double-encoding detected'

    out = data
    n_subs = 0
    for src, dst in SUBSTITUTIONS:
        if src in out:
            n_subs += out.count(src)
            out = out.replace(src, dst)

    if n_subs == 0:
        return False, 'no recognized substitutions to apply'

    # Validate the result is itself valid UTF-8 (modulo a possible BOM)
    try:
        out.decode('utf-8-sig')
    except UnicodeDecodeError as e:
        return False, f'fix produced invalid UTF-8: {e}'

    with open(path, 'wb') as f:
        f.write(out)

    return True, f'{n_subs} substitutions, {len(data)} -> {len(out)} bytes'

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) < 2:
        print('Usage: _fix_unicode.py <file1> [<file2> ...]')
        return
    for path in sys.argv[1:]:
        ok, msg = fix_file(path)
        status = 'FIXED' if ok else 'skip '
        print(f'[{status}] {path}: {msg}')

if __name__ == '__main__':
    main()
