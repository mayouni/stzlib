import json,sys
a,b,v,m=sys.argv[1:5]
def load(p):
    D=json.load(open(p,encoding='utf-8'))['documents']; return D if isinstance(D,dict) else {d['id']:d for d in D}
A=load(f'{a}/native_golden_v{v}.json'); B=load(f'{b}/native_golden_v{v}.json')
for k in sorted(B):
    x,y=A[k].get(m),B[k].get(m)
    if x!=y and x is not None and y is not None and abs(x-y)>0.005: print(v,k,round(x,3),'->',round(y,3))
