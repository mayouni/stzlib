# argv: <tree>. Lowercases Ring keywords outside strings and comments (Haro lift.zig keyword list).
import os, sys, re
KW = set("again and break but bye call case catch changeringkeyword changeringoperator class continue def disablehashcomments do done else elseif enablehashcomments end endclass endfor endfunc endfunction endif endpackage endswitch endtry endwhile exit false finally for foreach from func function get give if import load loadsyntax loop new next not null off ok on or other package private put return see self super switch this true try while".split())
root = sys.argv[1]
word = re.compile(r'[A-Za-z_]\w*')
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
            m = word.match(s, i) if (c.isalpha() or c == '_') else None
            if m:
                w = m.group(0); prev = s[i-1] if i else ''
                if w.lower() in KW and w != w.lower() and prev not in ':.@$':
                    w = w.lower(); ch += 1
                out.append(w); i = m.end(); continue
            out.append(c); i += 1
        if ch:
            open(p, 'wb').write(''.join(out).encode('utf-8', 'surrogateescape')); tot += ch
print('keywords lowered', tot)
