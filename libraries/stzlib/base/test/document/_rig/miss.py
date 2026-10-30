import json, sys, unicodedata, re
# miss.py <set> <id> <kind> -- expected items of a kind missing from the native predictions, and the native blocks that hold them
base = 'D:/GitHub/_wti_pub/libraries/stzlib/base/test/document/'
v, d, kind = sys.argv[1:4]
e = json.load(open(base + '_data/golden_v%s/%s.expected.json' % (v, d), encoding='utf-8'))
def norm(s):
    return re.sub(r'\s+', ' ', unicodedata.normalize('NFC', s or '')).strip()
rows = []
for l in open((sys.argv[4] if len(sys.argv)>4 else base + 'results/predictions_v%s') % v + '/%s.native.tsv' % d, encoding='utf-8'):
    p = l.rstrip('\n').split('\t')
    if len(p) >= 3:
        rows.append((p[0], p[1], p[2].replace('\\n', ' ')))
if kind == 'lists':
    got = [norm(t) for k, _, t in rows if k == 'list_item']
    for it in e['list_items']:
        t = norm(it['text'])
        ok = any(g == t or g.endswith(t) or t.endswith(g) and len(g) > 3 for g in got)
        if not ok:
            hit = [(k, lv, tx[:110]) for k, lv, tx in rows if t[:12] in norm(tx)]
            print('MISS', it['level'], t[:100], '\n     native:', hit[:2])
elif kind == 'furniture':
    body = ' '.join(norm(t) for k, _, t in rows if k in ('paragraph', 'heading', 'list_item', 'caption'))
    for f in e['furniture']:
        if norm(f) in body:
            print('IN BODY', norm(f)[:100])
elif kind == 'text':
    body = ' '.join(norm(t) for k, _, t in rows if k not in ('page_header', 'page_footer'))
    for s in e['key_sentences']:
        if norm(s) not in body:
            print('MISS', norm(s)[:140])
print('--- blocks')
for k, lv, t in rows:
    print(k, lv, t[:100])
