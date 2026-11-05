# COMPASS-KERN-05 gate: every library call to an engine function that RUNS a model
# must sit in a body that also passes a door (_StzNeuralDoor / _StzVisionDoor, or a
# model.call fact), so the call writes its chained ledger record before it returns.
#
#   python model_door_sweep.py [base-dir]      exits with the count of uncovered sites
#
# A static sweep by function body: a door in a helper the body calls is not seen, so
# a site found here is read before it is called a gap. Tests and recovered code are
# skipped. Owned by stzlib-security; the doors are stzlib-intelligence's.
import os, re, sys
ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
# continuations of a generation StzStartGeneration already recorded: one call, one record
ALLOWED = {('StzNextToken', 'gennext'), ('StzNextToken', 'genchunk')}
RUNS = """generate generatext generatecont genstart gennext genchunk prefilllogits embed embedtokens
backboneembed clipembed rerank ner ocrread ocrreadwith ocrregion ocrplatformread owlfind owlscores
visionclassify visiondepth visionembedimage visionembedtext visionfaces visionobjects visionsaliency
visionsamembed visionsammask vlmdescribe vlmembed vlmembedinput vlmfeed vlmpage vlmpageviews vlmstart""".split()
call_re = re.compile(r'\bstzengineneural(' + '|'.join(sorted(RUNS, key=len, reverse=True)) + r')\s*\(', re.I)
head_re = re.compile(r'^\s*(func|def)\s+([A-Za-z_@][\w@]*)', re.I)
door_re = re.compile(r'_Stz(Neural|Vision)Door\s*\(|StzNoteFact\w*\(\s*"model\.call"', re.I)
rows = []
for dp, dn, fn in os.walk(ROOT):
    rel = os.path.relpath(dp, ROOT)
    if rel.split(os.sep)[0] == 'test' or 'recovered' in rel: continue
    for f in fn:
        if not f.endswith('.ring'): continue
        p = os.path.join(dp, f)
        lines = open(p, encoding='utf-8', errors='replace').read().split('\n')
        bodies, cur, start = [], '(top level)', 0
        for i, l in enumerate(lines):
            m = head_re.match(l)
            if m:
                bodies.append((cur, start, i)); cur, start = m.group(2), i
        bodies.append((cur, start, len(lines)))
        for name, a, b in bodies:
            body = lines[a:b]
            calls = [(a + j + 1, call_re.search(x).group(1).lower()) for j, x in enumerate(body)
                     if call_re.search(x) and not x.strip().startswith('#')]
            if not calls: continue
            door = any(door_re.search(x) for x in body)
            for ln, c in calls:
                rows.append((door, os.path.relpath(p, ROOT), ln, name, c))
nd = [r for r in rows if not r[0] and (r[3], r[4]) not in ALLOWED]
na = len([r for r in rows if not r[0] and (r[3], r[4]) in ALLOWED])
print(f"model-running call sites: {len(rows)}; with a door: {len(rows)-len(nd)-na}; "
      f"continuations allowed: {na}; WITHOUT A DOOR: {len(nd)}")
for r in nd: print(f"  NO DOOR  {r[1]}:{r[2]}  {r[3]}  -> stzengineneural{r[4]}")
sys.exit(len(nd))
