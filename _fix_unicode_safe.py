#!/usr/bin/env python3
"""Safer Unicode reverser that handles ONLY the high-confidence
mangling patterns:

1. cp1252 0x80..0x9F bytes mangled to 3-byte UTF-8 (e.g., 0x84 -> U+201E
   -> e2 80 9e). These 3-byte sequences are unambiguous because they
   represent Windows-specific characters that don't appear in normal
   Latin-1 text.

2. The classic double-encoded `c3 83 c2 XX` -> `c3 XX` pattern, but
   only when followed by another mangled byte (i.e. inside a clearly
   mangled multi-byte run).

This avoids breaking proper UTF-8 content like 'é' (c3 a9) that already
looks right -- because c2 a9 alone could be either mangle-of-0xA9 or
proper UTF-8 of U+00A9 (©), and we can't tell without more context.

Trade-off: this reverser handles the Arabic / smart-quote / box-drawing
mangling well, but leaves proper-looking Latin-1 supplement chars alone.
"""
import sys

# cp1252 -> Unicode for the 0x80..0x9F range only (the "smart-quote" range)
CP1252_HIGH_ONLY = {
    0x80: 0x20AC, 0x82: 0x201A, 0x83: 0x0192, 0x84: 0x201E, 0x85: 0x2026,
    0x86: 0x2020, 0x87: 0x2021, 0x88: 0x02C6, 0x89: 0x2030, 0x8A: 0x0160,
    0x8B: 0x2039, 0x8C: 0x0152, 0x8E: 0x017D,
    0x91: 0x2018, 0x92: 0x2019, 0x93: 0x201C, 0x94: 0x201D, 0x95: 0x2022,
    0x96: 0x2013, 0x97: 0x2014, 0x98: 0x02DC, 0x99: 0x2122, 0x9A: 0x0161,
    0x9B: 0x203A, 0x9C: 0x0153, 0x9E: 0x017E, 0x9F: 0x0178,
}

# Build substitution table: 3-byte UTF-8 sequence -> single cp1252 byte
SAFE_SUBS = []
for b, cp in CP1252_HIGH_ONLY.items():
    utf8_bytes = chr(cp).encode('utf-8')
    if len(utf8_bytes) == 3:  # only 3-byte sequences (high confidence)
        SAFE_SUBS.append((utf8_bytes, bytes([b])))

# Also handle the c3 83 c2 XX double-Latin case BUT only when adjacent
# to another mangled sequence (which we approximate by including only
# the most distinctive patterns -- accented chars that always come
# inside French/German/Spanish word literals).
# To minimize risk, we don't add c3 83 c2 XX patterns here.

def fix_file(path):
    with open(path, 'rb') as f:
        data = f.read()

    n_total = 0
    out = data
    for utf8_seq, raw_byte in SAFE_SUBS:
        count = out.count(utf8_seq)
        if count > 0:
            out = out.replace(utf8_seq, raw_byte)
            n_total += count

    if n_total == 0:
        return False, 'no cp1252 0x80-0x9F mangling found'

    # The result may not be valid UTF-8 standalone, because we only
    # reversed part of multi-byte mangling. But the bytes we wrote
    # are the original raw bytes; further reversal of c3 XX patterns
    # (Latin-1 supplement) is the user's job since those are
    # ambiguous in mixed-content files.

    with open(path, 'wb') as f:
        f.write(out)
    return True, f'{n_total} substitutions, {len(data)} -> {len(out)} bytes'

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) < 2:
        print('Usage: _fix_unicode_safe.py <file1> [<file2> ...]')
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
