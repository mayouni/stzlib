#!/usr/bin/env python3
"""Convert a Softanza narrative test file (.ring) into a runnable
sequence of try/catch'd blocks.

Original format:
    load "../stzbase.ring"

    /*---
    pr()
    <test code>
    pf()
    # Executed in ... second(s)

    /*---
    pr()
    <next test code>
    pf()
    ...

Most blocks are commented out by the `/*---` opener that never gets
explicitly closed -- so only the LAST unclosed block runs.

To modernize: each `/*---`-delimited block becomes a try/catch-wrapped
section so all blocks run independently. Failures in one block don't
stop the rest.
"""
import sys, os, io, re

# Match `/*---`, `/*-----`, `/*=== title`, `/* (with anything after)`,
# even decorated with `#ERR` notes or extra slashes.
BLOCK_OPEN_RE = re.compile(r'^\s*/\*[-=#/*\s\w!]')

def split_blocks(text):
    """Split text into header (before first block) + list of blocks."""
    lines = text.split('\n')
    header = []
    blocks = []
    current = None
    for line in lines:
        if BLOCK_OPEN_RE.match(line):
            if current is not None:
                blocks.append('\n'.join(current))
            current = []
            continue
        if current is None:
            header.append(line)
        else:
            current.append(line)
    if current is not None:
        blocks.append('\n'.join(current))
    return '\n'.join(header), blocks

def clean_block(text):
    """Remove pr()/pf() lines and trailing `*/`, normalize."""
    out = []
    for line in text.split('\n'):
        stripped = line.strip()
        # Skip closing-comment lines and standalone pr()/pf() calls
        if stripped in ('*/', "*/"):
            continue
        if stripped.startswith('*/'):
            # remove the */ and keep rest
            line = line.replace('*/', '', 1).rstrip()
            if not line.strip(): continue
        if stripped in ('pr()', 'pf()'):
            continue
        # Skip trailing executed-in comment lines (just noise)
        if stripped.startswith('# Executed in '):
            continue
        out.append(line)
    return '\n'.join(out).strip()

def make_runner(src_path, dst_path):
    with open(src_path, 'r', encoding='utf-8-sig', errors='replace') as f:
        text = f.read()
    header, blocks = split_blocks(text)

    out = [header.rstrip(), '']
    out.append('# === MODERNIZED TEST RUNNER ===')
    out.append('# Each original block now runs in its own try/catch.')
    out.append('# Failures are caught and counted; the harness reports')
    out.append('# overall pass/fail at the end.')
    out.append('')
    out.append('_nMtBlocksTotal = 0')
    out.append('_nMtBlocksPass  = 0')
    out.append('_nMtBlocksFail  = 0')
    out.append('_aMtFails       = []')
    out.append('')

    for i, block in enumerate(blocks, 1):
        cleaned = clean_block(block)
        if not cleaned:
            continue
        out.append(f'# --- Block {i} ---')
        out.append('_nMtBlocksTotal++')
        out.append('try')
        # Indent each line of the block
        for bl in cleaned.split('\n'):
            out.append('\t' + bl)
        out.append('\t_nMtBlocksPass++')
        out.append('catch')
        out.append('\t_nMtBlocksFail++')
        out.append(f'\t_aMtFails + [ {i}, cCatchError ]')
        out.append('done')
        out.append('')

    out.append('? "============================="')
    out.append('? "Blocks total : " + _nMtBlocksTotal')
    out.append('? "Blocks pass  : " + _nMtBlocksPass')
    out.append('? "Blocks fail  : " + _nMtBlocksFail')
    out.append('if _nMtBlocksFail > 0')
    out.append('\t? ""')
    out.append('\t? "FAILURES:"')
    out.append('\tfor _aMtF in _aMtFails')
    out.append('\t\t? "  Block " + _aMtF[1] + ": " + _aMtF[2]')
    out.append('\tnext')
    out.append('ok')

    with open(dst_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(out))
    return len(blocks)

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) < 3:
        print('Usage: _modernize_tests.py <src.ring> <dst.ring>')
        return
    src, dst = sys.argv[1], sys.argv[2]
    n = make_runner(src, dst)
    print(f'OK: {src} -> {dst} ({n} blocks)')

if __name__ == '__main__':
    main()
