# SOFTANZA_ONE_HOUR.md B1 (W0): every listener door in the library, its default
# bind address, and whether it tells stzExposure (StzNoteListener) before opening.
#
#   python -I listener_sweep.py [base-dir]     exits with the number of doors that
#                                              either default beyond loopback or do
#                                              not note themselves
#
# Node-RED's lesson (CVE-2026-58115): a code-running surface reachable from the
# network with no credential. The rule here is narrower and checkable: a listener
# that opens by default on anything but loopback is a finding, and a listener that
# opens without telling the exposure is one too. Static, by function body; tests
# and recovered code are skipped.
import os, re, sys

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
OPEN = re.compile(r'\bStzEngine(TcpListen|ReactorListen|ReactorListenTls|TestServerStart|WsServerListen)\s*\(', re.I)
head_re = re.compile(r'^\s*(func|def)\s+([A-Za-z_@][\w@]*)', re.I)
note_re = re.compile(r'\bStzNoteListener\s*\(', re.I)
all_re = re.compile(r'"0\.0\.0\.0"|"::"|cHost\s*=\s*""\s*cHost\s*=\s*"0', re.I)
rows = []
for dp, dn, fn in os.walk(ROOT):
    rel = os.path.relpath(dp, ROOT)
    if rel.split(os.sep)[0] == 'test' or 'recovered' in rel: continue
    for f in fn:
        if not f.endswith('.ring'): continue
        p = os.path.join(dp, f)
        L = open(p, encoding='utf-8', errors='replace').read().split('\n')
        starts = [i for i, l in enumerate(L) if head_re.match(l)] + [len(L)]
        for a, b in zip(starts, starts[1:]):
            body = L[a:b]
            if not any(OPEN.search(x) for x in body if not x.strip().startswith('#')): continue
            noted = any(note_re.search(x) for x in body)
            wide = any(all_re.search(x) for x in body if not x.strip().startswith('#'))
            rows.append((os.path.relpath(p, ROOT), a + 1, head_re.match(L[a]).group(2), noted, wide))
bad = [r for r in rows if not r[3] or r[4]]
print(f"listener doors: {len(rows)}; noting the exposure: {len([r for r in rows if r[3]])}; defaulting beyond loopback: {len([r for r in rows if r[4]])}")
for r in rows:
    flag = 'ok      ' if r[3] and not r[4] else ('UNNOTED ' if not r[3] else 'WIDE    ')
    print(f"  {flag} {r[0]}:{r[1]}  {r[2]}")
sys.exit(len(bad))
