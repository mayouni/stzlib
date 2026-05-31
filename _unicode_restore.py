#!/usr/bin/env python3
"""Restore pristine Unicode literals from an older commit (271afae9)
into the current file, using boundary-safe block matching.

Strategy: for each `$aXxxxx = [` block we want to restore, find the
START in both files, then locate the END by scanning for the unique
line that is exactly `]\\n` (closing bracket at column 0).
"""
import sys, subprocess

def find_block(data, start_marker):
    """Return (start, end) byte offsets covering `$xxx = [ ... ]\\n`."""
    start = data.find(start_marker)
    if start < 0:
        return None
    # Scan forward for a line that is just `]` (close at column 0)
    pos = start
    while True:
        nl = data.find(b'\n', pos)
        if nl < 0:
            return None
        line_start = pos if pos == start else pos + 1
        if pos != start:
            line_start = pos
        # Read this line
        line_end = nl
        line = data[line_start:line_end]
        # Check: is this line exactly `]`?
        if line.strip() == b']':
            return (start, nl + 1)
        pos = nl + 1
        if pos >= len(data):
            return None

def patch_blocks(current_path, original_commit, blocks):
    """blocks: list of start markers e.g. b'$aDayNames = ['"""
    proc = subprocess.run(['git', 'show', f'{original_commit}:{current_path.replace(chr(92), "/")}'],
                         capture_output=True, check=True)
    orig = proc.stdout

    with open(current_path, 'rb') as f:
        cur = f.read()

    changes = []
    for marker in blocks:
        orig_range = find_block(orig, marker)
        cur_range = find_block(cur, marker)
        if orig_range is None or cur_range is None:
            print(f'  [skip ] {marker.decode()}: not found in both')
            continue
        orig_bytes = orig[orig_range[0]:orig_range[1]]
        cur_bytes = cur[cur_range[0]:cur_range[1]]
        if orig_bytes == cur_bytes:
            print(f'  [skip ] {marker.decode()}: identical')
            continue
        changes.append((cur_range, orig_bytes, cur_bytes))
        print(f'  [QUEUE] {marker.decode()}: {len(cur_bytes)} -> {len(orig_bytes)} bytes')

    if not changes:
        return False

    # Apply patches in reverse order so offsets stay valid
    changes.sort(key=lambda c: -c[0][0])
    out = cur
    for (s, e), orig_b, cur_b in changes:
        out = out[:s] + orig_b + out[e:]

    with open(current_path, 'wb') as f:
        f.write(out)
    return True

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) < 4:
        print('Usage: _unicode_restore.py <commit> <file> <marker> [<marker>...]')
        return
    commit = sys.argv[1]
    path = sys.argv[2]
    markers = [m.encode() for m in sys.argv[3:]]
    print(f'Restoring {len(markers)} blocks in {path} from {commit}:')
    patch_blocks(path, commit, markers)

if __name__ == '__main__':
    main()
