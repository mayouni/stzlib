#!/usr/bin/env python3
"""Fix Softanza .ring files mangled by UTF-8 -> cp1252 -> UTF-8.

When the bytes of a UTF-8 string were re-read as cp1252 (Windows-1252)
then re-saved as UTF-8, each original byte b became:
  byte b -> codepoint cp1252_to_unicode(b) -> UTF-8(codepoint)

To reverse: scan for every UTF-8 sequence that decodes to a character
within the cp1252 representable set, replace it with the original
cp1252 byte (= the original raw UTF-8 byte before the mangling).
"""
import sys

# cp1252 -> Unicode codepoint table for the high range (0x80..0xFF).
# 0x80-0x9F is the "smart-quote" range that differs from Latin-1.
# 0xA0-0xFF maps identically.
CP1252_HIGH = {
    0x80: 0x20AC, 0x82: 0x201A, 0x83: 0x0192, 0x84: 0x201E, 0x85: 0x2026,
    0x86: 0x2020, 0x87: 0x2021, 0x88: 0x02C6, 0x89: 0x2030, 0x8A: 0x0160,
    0x8B: 0x2039, 0x8C: 0x0152, 0x8E: 0x017D,
    0x91: 0x2018, 0x92: 0x2019, 0x93: 0x201C, 0x94: 0x201D, 0x95: 0x2022,
    0x96: 0x2013, 0x97: 0x2014, 0x98: 0x02DC, 0x99: 0x2122, 0x9A: 0x0161,
    0x9B: 0x203A, 0x9C: 0x0153, 0x9E: 0x017E, 0x9F: 0x0178,
}

def build_substitution_table():
    subs = []
    for b in range(0x80, 0x100):
        if b in CP1252_HIGH:
            cp = CP1252_HIGH[b]
        elif b in (0x81, 0x8D, 0x8F, 0x90, 0x9D):
            continue
        else:
            cp = b
        utf8_bytes = chr(cp).encode('utf-8')
        subs.append((utf8_bytes, bytes([b])))
    # Longer patterns first so 3-byte cp1252 chars (like quotes) don't
    # leave dangling pieces.
    subs.sort(key=lambda p: -len(p[0]))
    return subs

SUBS = build_substitution_table()

def needs_fix(data):
    return (b'\xc3\x99' in data or b'\xc3\x83\xc2' in data or
            b'\xc3\x98\xc2' in data or b'\xe2\x80' in data and b'\xc3' in data)

def fix_file(path):
    with open(path, 'rb') as f:
        data = f.read()
    if not needs_fix(data):
        return False, 'no mangling markers detected'

    out = data
    n_total = 0
    for utf8_seq, raw_byte in SUBS:
        count = out.count(utf8_seq)
        if count > 0:
            out = out.replace(utf8_seq, raw_byte)
            n_total += count

    if n_total == 0:
        return False, 'no substitutions applied'

    try:
        out.decode('utf-8-sig')
    except UnicodeDecodeError as e:
        return False, f'result not valid UTF-8 (NOT written): {e}'

    with open(path, 'wb') as f:
        f.write(out)
    return True, f'{n_total} substitutions, {len(data)} -> {len(out)} bytes'

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) < 2:
        print('Usage: _fix_unicode.py <file1> [<file2> ...]')
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
