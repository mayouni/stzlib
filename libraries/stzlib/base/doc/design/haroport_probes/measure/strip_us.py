# argv: <tree>. Unwraps _x_ locals and $_x globals; no collision check (a measure, not the tool).
import os, sys, re
root = sys.argv[1]
word = re.compile(r'[$@]?[A-Za-z_]\w*')
loc = re.compile(r'^_([a-z]{1,3}[A-Z0-9]\w*?|[a-z]{1,3})_$')
glo = re.compile(r'^\$_([a-z]{1,3}[A-Z0-9]\w*)$')
tot = 0
for d, _, fs in os.walk(root):
    for f in fs:
        if not f.endswith('.haro'): continue
        p = os.path.join(d, f)
        s = open(p, 'rb').read().decode('utf-8', 'surrogateescape')
        out = []; i = 0; n = len(s); ch = 0
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
            m = word.match(s, i) if (c.isalpha() or c in '_$@') else None
            if m:
                w = m.group(0); prev = s[i-1] if i else ''
                if prev not in ':.':
                    a = loc.match(w); b = glo.match(w)
                    if a: w = a.group(1); ch += 1
                    elif b: w = '$' + b.group(1); ch += 1
                out.append(w); i = m.end(); continue
            out.append(c); i += 1
        if ch:
            open(p, 'wb').write(''.join(out).encode('utf-8', 'surrogateescape')); tot += ch
print('names unwrapped', tot)
