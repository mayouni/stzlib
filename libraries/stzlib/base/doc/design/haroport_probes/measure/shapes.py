# argv: <tree>. Counts the shapes of names with no Haro type letter (a text scan).
import os, sys, re, collections
root = sys.argv[1]
LET = set('bidfntxkvmroehs')
ok = re.compile(r'^[a-z][A-Z0-9]')
C = collections.Counter(); EX = collections.defaultdict(collections.Counter)
tokre = re.compile(r'(?m)(?:^\s*(?:for\s+)?|[\s(,])([$@]?[A-Za-z_]\w*)\s*(?==(?!=)|\s+in\s|\s+=)')
for d, _, fs in os.walk(root):
    for f in fs:
        if not f.endswith('.haro'): continue
        s = open(os.path.join(d, f), 'rb').read().decode('utf-8', 'replace')
        s = re.sub(r'"[^"\n]*"|\'[^\'\n]*\'|`[^`]*`', '""', s)
        s = re.sub(r'(?m)#.*$|//.*$', '', s)
        names = []
        names += [m.group(1) for m in re.finditer(r'(?m)^\s*(?:for\s+)?([$@]?[A-Za-z_]\w*)\s*=(?!=)', s)]
        for m in re.finditer(r'(?im)^\s*(?:def|func)\s+\w+\s*\(?([^)\n]*)', s):
            names += [p.strip() for p in m.group(1).split(',') if p.strip()]
        names += re.findall(r'[$@][A-Za-z_]\w*', s)
        for w in names:
            if not re.match(r'^[$@]?[A-Za-z_]\w*$', w): continue
            b = w.lstrip('$@')
            if ok.match(b) and b[0] in LET: continue
            if len(b) == 1: k = 'one-letter (i, j, x)'
            elif re.match(r'^[A-Z0-9_]+$', b) and len(b) > 1: k = 'ALL_CAPS constant'
            elif re.match(r'^p[a-z]{1,2}[A-Z]', b): k = 'p-prefixed parameter (pcStr, paList)'
            elif ok.match(b) and b[0] in 'acpl': k = 'Softanza letter a/c/p/l (cName, aList)'
            elif ok.match(b): k = 'other lowercase letter (%s...)' % b[0]
            elif b[0].isupper(): k = 'Capitalised (Result, Value)'
            elif '_' in b: k = 'snake or underscored (_x, my_var)'
            else: k = 'lowercase word (count, item)'
            C[k] += 1; EX[k][w] += 1
tot = sum(C.values())
for k, n in C.most_common():
    print('%7d  %5.1f%%  %-40s %s' % (n, 100.0*n/tot, k, ', '.join(x for x, _ in EX[k].most_common(6))))
print('total sites', tot)
