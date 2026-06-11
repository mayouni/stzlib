import sys
from pathlib import Path
sys.path.insert(0, '.')
from _sweep_substr import find_substr_calls, categorize, walk_files, ROOT

files = walk_files(ROOT, ['libraries/stzlib/base'])
for f in files:
    src = f.read_text(encoding='utf-8', errors='replace')
    calls = find_substr_calls(src)
    if not calls:
        continue
    rel = str(f.relative_to(ROOT)).replace('\\', '/')
    for start, end, call in calls:
        mode, _ = categorize(call)
        if mode == 'unknown':
            ln = src[:start].count('\n') + 1
            line_start = src.rfind('\n', 0, start) + 1
            line_end = src.find('\n', start)
            ctx = src[line_start:line_end].strip()
            ctx_safe = ctx.encode('ascii', 'replace').decode('ascii')
            print(f'{rel}:{ln}\t{ctx_safe}')
