# argv: <tree> <haro checkout>. Respells built-in calls by Haro study/v48/builtin_names.py.
import os, sys, re
# argv: <tree> <haro checkout>
src = open(os.path.join(sys.argv[2], 'study', 'v48', 'builtin_names.py'), encoding='utf-8').read()
blk = src.split('SPLIT = """', 1)[1].split('"""', 1)[0]
M = {}
for part in blk.replace('\n', '|').split('|'):
    t = part.split()
    if len(t) == 2: M[t[0].lower()] = t[1].replace('-', '')
root = sys.argv[1]
word = re.compile(r'[A-Za-z_]\w*')
tot = 0
for d, _, fs in os.walk(root):
    for f in fs:
        if not f.endswith('.haro'): continue
        p = os.path.join(d, f)
        s = open(p, 'rb').read().decode('utf-8', 'surrogateescape')
        out = []; i = 0; n = len(s); ch = 0; last = ''
        while i < n:
            c = s[i]
            if c in '"\'`':
                j = s.find(c, i + 1); j = n - 1 if j < 0 else j
                out.append(s[i:j+1]); i = j + 1; continue
            if c == '#' or s.startswith('//', i):
                j = s.find('\n', i); j = n if j < 0 else j
                out.append(s[i:j]); i = j; continue
            if s.startswith('/*', i):
                j = s.find('*/', i + 2); j = n if j < 0 else j + 2
                out.append(s[i:j]); i = j; continue
            m = word.match(s, i) if (c.isalpha() or c == '_') else None
            if m:
                w = m.group(0); prev = s[i-1] if i else ''
                k = m.end()
                while k < n and s[k] in ' \t': k += 1
                if (w.lower() in M and w != M[w.lower()] and prev not in ':.@$' and k < n and s[k] == '('
                        and last not in ('def', 'func', 'function')):
                    w = M[w.lower()]; ch += 1
                last = w.lower(); out.append(w); i = m.end(); continue
            if not c.isspace(): last = ''
            out.append(c); i += 1
        if ch:
            open(p, 'wb').write(''.join(out).encode('utf-8', 'surrogateescape')); tot += ch
print('table', len(M), 'calls respelled', tot)
