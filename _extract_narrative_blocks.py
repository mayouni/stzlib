#!/usr/bin/env python3
"""Extract narrative `/*--- Title` blocks from a Softanza .ring test
file into independent runnable thematic files.

Source format (consistent across base/test/*Test.ring):
    /*--- Topic title here
    [optional blank lines]
    pr()
    ... block body with ? lines and #--> expected-output markers ...
    pf()
    # Executed in 0.0X second(s) in Ring 1.YY
    /*--- Next topic

Each block becomes <NN>_<slug>.ring under
base/test/modular/<topic>/. The first line of the block (the
`/*--- Title` line) becomes a `# Narrative` header comment.
"""
import sys, os, re
from pathlib import Path

BLOCK_RE = re.compile(r'^/\*[-=#]{2,}\s*(.*)$', re.MULTILINE)

def slugify(s, fallback):
    s = s.strip().lower()
    s = re.sub(r'#\w+', '', s)  # drop tags like #ERR
    s = re.sub(r'[^\w\s-]', '', s)
    s = re.sub(r'\s+', '_', s).strip('_')
    s = s[:50]
    return s or fallback

def extract(source_path, out_dir, load_relative='../../../stzBase.ring'):
    text = Path(source_path).read_text(encoding='utf-8')

    # Find all block-opener positions
    markers = list(BLOCK_RE.finditer(text))
    if not markers:
        print(f'no /*--- markers found in {source_path}')
        return 0

    # Build blocks: each block runs from end-of-marker-line until
    # next marker (or EOF)
    blocks = []
    for i, m in enumerate(markers):
        title = m.group(1).strip()
        body_start = m.end()
        # Skip to next line
        nl = text.find('\n', body_start)
        body_start = nl + 1 if nl >= 0 else body_start
        body_end = markers[i+1].start() if i+1 < len(markers) else len(text)
        body = text[body_start:body_end].rstrip()
        # Strip a leading `*/` line (legacy closing of prior comment)
        body = re.sub(r'^\s*\*/\s*\n', '', body)
        blocks.append((title, body))

    Path(out_dir).mkdir(parents=True, exist_ok=True)

    written = 0
    for idx, (title, body) in enumerate(blocks, 1):
        # Skip empty / too-tiny blocks
        meaningful = re.sub(r'#.*$', '', body, flags=re.MULTILINE).strip()
        if len(meaningful) < 20:
            continue
        slug = slugify(title, f'block_{idx}')
        fname = f'{idx:02d}_{slug}.ring'
        out_path = Path(out_dir) / fname
        header = (
            f'# Narrative\n'
            f'# --------\n'
            f'# {title or "(untitled block)"}\n'
            f'#\n'
            f'# Extracted from {Path(source_path).name}, block #{idx}.\n'
            f'\n'
            f'load "{load_relative}"\n'
            f'\n'
        )
        out_path.write_text(header + body + '\n', encoding='utf-8')
        written += 1
    print(f'{source_path}: {written} block(s) written to {out_dir}')
    return written

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) != 4:
        print('Usage: _extract_narrative_blocks.py <src.ring> <out_dir> <load_relative>')
        return
    extract(sys.argv[1], sys.argv[2], sys.argv[3])

if __name__ == '__main__':
    main()
