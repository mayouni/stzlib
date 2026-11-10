# argv: <tree>. Renames every .ring file .haro and points its load lines at .haro (scratch copies only).
import os, re, sys
root = sys.argv[1]
pat = re.compile(r'(?im)^(\s*load\s+["\'])([^"\']+?)\.ring(["\'])')
nf = nl = 0
for d, _, fs in os.walk(root):
    for f in fs:
        if f.lower().endswith('.ring'):
            p = os.path.join(d, f)
            b = open(p, 'rb').read().decode('utf-8', 'surrogateescape')
            b2, n = pat.subn(r'\1\2.haro\3', b)
            nl += n
            open(p[:-5] + '.haro', 'wb').write(b2.encode('utf-8', 'surrogateescape'))
            os.remove(p); nf += 1
print('files', nf, 'load lines rewritten', nl)
