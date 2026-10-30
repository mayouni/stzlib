import sys,json,re
def load(f):
    d={};p={}
    for l in open(f):
        m=re.match(r'(v\d+) (\{.*\})',l)
        if m: d[m.group(1)]=json.loads(m.group(2))
        m=re.match(r'(v\d+) native .*pooled precision ([\d.]+)',l)
        if m: p[m.group(1)]=float(m.group(2))
    return d,p
a,pa=load(sys.argv[1]); b,pb=load(sys.argv[2])
for v in a:
    if v not in b: continue
    ch=[f"{k} {a[v][k]:.3f}->{b[v][k]:.3f}" for k in a[v] if abs(a[v][k]-b[v][k])>0.0005]
    if abs(pa[v]-pb[v])>0.0005: ch.append(f"prec {pa[v]:.3f}->{pb[v]:.3f}")
    if ch: print(v, '; '.join(ch))
