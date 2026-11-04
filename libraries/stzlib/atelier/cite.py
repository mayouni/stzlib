"""RESOLVE A CITATION -- from `<commit>:<id>` to the check, its state and what judged it.

    python cite.py <citation> [--data <folder>] [--format json|markdown|html]

A book or a page cites a check as  <commit>:<id>  -- for example

    74757d462:adverb/00_adverb_narrated#099386a7

The commit is the library commit the check was RECORDED at; the id is the check's own (its file without
.ring, a `#`, and eight hex digits of the digest of its text: it does not move when the file changes
elsewhere). This resolves one, from the committed data of that commit (checks.json and results.json beside
this script, from a checkout pinned there) or from a built edition (--data <edition>/data). It answers
what the citation names and nothing it was not asked: the description, the file and line, the scenario, the
code, the recorded state, and the library, rnxc and engine that judged it. A citation whose commit is not the
data's, or whose id is absent, is REFUSED with exit 2 and the reason: a quoted state without its commit is
not quoted. Standard library only. The contract is EMBED.md.
"""
import html, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))


def find(folder, name):
    for rel in (name, os.path.join('data', name)):
        p = os.path.join(folder, rel)
        if os.path.isfile(p):
            with open(p, encoding='utf-8') as f:
                return json.load(f)
    sys.exit('cite: no %s in %s (or %s/data)' % (name, folder, folder))


def resolve(citation, folder):
    if ':' not in citation:
        return None, 'a citation is <commit>:<id>, with a colon'
    commit, cid = citation.split(':', 1)
    checks = find(folder, 'checks.json')
    results = find(folder, 'results.json')
    rec = str(results.get('library', '')).split(' ')[0]
    if commit != rec:
        return None, 'the data here was recorded at %s, not %s: pin the library at %s, or build that edition' % (rec, commit, commit)
    for c in checks['checks']:
        if c['id'] == cid:
            kind = results['states'].get(cid)
            return {
                'citation': citation, 'commit': commit, 'id': cid, 'domain': c['domain'], 'file': c['file'], 'line': c['line'],
                'scenario': c['scenario'], 'description': c['desc'], 'code': c['code'],
                'state': kind, 'said': (results.get('said') or {}).get(cid, ''),
                'judged_by': {'library': results.get('library'), 'rnxc': results.get('rnxc'), 'engine': results.get('engine'), 'taken': results.get('taken')},
                'harvested_from': '%s at %s' % (checks.get('source'), checks.get('commit')),
            }, ''
    return None, 'no check has the id %s in the data recorded at %s' % (cid, commit)


def render(r, fmt):
    if fmt == 'json':
        return json.dumps(r, ensure_ascii=False, indent=1)
    j = r['judged_by']
    if fmt == 'markdown':
        out = ['**%s**' % r['description'], '',
               '`%s`, line %d, scenario: %s' % (r['file'], r['line'], r['scenario'] or '-'), '',
               'Recorded state: **%s**, by the library %s, rnxc %s, engine %s, %s.' % (r['state'], j['library'], j['rnxc'], j['engine'], j['taken'])]
        if r['said']:
            out += ['', '```', r['said'], '```']
        out += ['', '```ring', r['code'].rstrip(), '```', '', 'Citation: `%s`' % r['citation']]
        return '\n'.join(out)
    e = html.escape
    return ('<article class="atelier-check"><p><b>%s</b></p><p><code>%s</code>, line %d, scenario: %s</p>'
            '<p>Recorded state: <b>%s</b>, by the library %s, rnxc %s, engine %s, %s.</p>%s<pre>%s</pre><p>Citation: <code>%s</code></p></article>'
            % (e(r['description']), e(r['file']), r['line'], e(r['scenario'] or '-'), e(str(r['state'])), e(str(j['library'])), e(str(j['rnxc'])),
               e(str(j['engine'])), e(str(j['taken'])), ('<pre>%s</pre>' % e(r['said'])) if r['said'] else '', e(r['code'].rstrip()), e(r['citation'])))


def main():
    args = sys.argv[1:]
    folder, fmt, cit = HERE, 'json', None
    i = 0
    while i < len(args):
        if args[i] == '--data' and i + 1 < len(args):
            folder = args[i + 1]; i += 1
        elif args[i] == '--format' and i + 1 < len(args):
            fmt = args[i + 1]; i += 1
        else:
            cit = args[i]
        i += 1
    if not cit or fmt not in ('json', 'markdown', 'html'):
        sys.exit('usage: python cite.py <commit>:<id> [--data <folder>] [--format json|markdown|html]')
    r, why = resolve(cit, folder)
    if r is None:
        print('cite: REFUSED: ' + why, file=sys.stderr)
        sys.exit(2)
    sys.stdout.reconfigure(encoding='utf-8')
    print(render(r, fmt))


main()
