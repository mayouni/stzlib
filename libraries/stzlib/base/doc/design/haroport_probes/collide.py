"""If every _x_ local in a method became x, how many would hit an attribute of
the class declared in the same file (bare or @-spelled), case-folded as Ring does?
Lower bound: inherited attributes from other files are not seen."""
import os, re, sys, collections
root = sys.argv[1]
CLS = re.compile(r'^\s*class\s+([A-Za-z_][A-Za-z0-9_]*)', re.I)
DEF = re.compile(r'^\s*(def|func)\b', re.I)
ATTR = re.compile(r'^\s*(@?[A-Za-z_][A-Za-z0-9_]*)\s*=(?!=)')
U = re.compile(r'(?<![A-Za-z0-9_@$])_([A-Za-z][A-Za-z0-9]*)_(?![A-Za-z0-9_])')
tot_m = 0; hit_bare = 0; hit_at = 0; files_hit = set(); ex = []
attrs_bare = attrs_at = 0
for dp, dn, fn in os.walk(root):
    if '/test' in dp.replace('\\', '/'): continue
    for f in fn:
        if not f.endswith('.ring'): continue
        fp = os.path.join(dp, f)
        cls = None; in_body = False; attrs = set()
        for line in open(fp, encoding='utf-8', errors='replace'):
            m = CLS.match(line)
            if m: cls = m.group(1); in_body = False; attrs = set(); continue
            if DEF.match(line):
                in_body = cls is not None
                if not line.lstrip().lower().startswith('def') and not cls: in_body = False
                if line.lstrip().lower().startswith('func') and cls is None: in_body = False
                continue
            if cls and not in_body:
                a = ATTR.match(line)
                if a:
                    n = a.group(1).lower(); attrs.add(n)
                    if n.startswith('@'): attrs_at += 1
                    else: attrs_bare += 1
                continue
            if in_body:
                for u in U.finditer(line):
                    tot_m += 1; x = u.group(1).lower()
                    if x in attrs:
                        hit_bare += 1; files_hit.add(fp)
                        if len(ex) < 12: ex.append((os.path.relpath(fp, root), cls, u.group(0)))
                    elif '@' + x in attrs: hit_at += 1
print('_x_ tokens inside methods:', tot_m)
print('attributes declared: bare', attrs_bare, ' @-spelled', attrs_at)
print('would hit a BARE attribute of the same class:', hit_bare, 'in', len(files_hit), 'files')
print('would hit only an @-spelled attribute (distinct names on Ring, @ is part of the name):', hit_at)
for e in ex: print('  ', e)
