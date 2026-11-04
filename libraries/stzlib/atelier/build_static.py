"""THE STATIC EDITION -- the Atelier frozen at one library commit, for a place that cannot run code.

    python build_static.py --out <folder> [--allow-mixed] [--from <folder>]

A site served from static files (a project site, a book's web reader) cannot admit code into a live
program. It does not need to: the checks, what was recorded when the library at one commit judged them, and
the sweep of whole files are DATA this folder already carries, committed with the tests they come from. This
builds the page over that data in read-only mode: nothing runs, no playground, no run buttons, and no Ring
column (the author's rulings of 2026-10-30: no comparison with Ring on a public page until he says so).

It writes <out>/<commit>/ -- the commit being the library commit the recording names -- holding

    index.html      the checks, by domain, with search; each check's provenance, state and citation
    coverage.html   the Then lines judged, per domain and per file, the five states apart
    check.html      ONE check, by ?id=<id> (add &embed=1 for a bare card, to put in a frame)
    data/           checks.json, results.json, tours.json, i18n.json -- the page's own data, readable by anyone
    edition.json    what judged it: the library commit, the rnxc build, the engine, when, and the counts

and adds the edition to <out>/editions.json. Every file is static and relative: put the folder behind any
web server, or open index.html from disk in a browser that allows local fetches. `--out` has no default on
purpose: a folder inside this one would be copied into an install. The edition is DERIVED from a pinned
commit of the library, so nothing built here is committed anywhere.

It REFUSES to mix: the checks must be harvested at the commit the recording names, and the sweep taken at
it, else it names which to record again (`rnxc record.ring`, `rnxc tours.ring`). --allow-mixed builds
anyway and the page states each file's own commit. No machine path goes out: any folder of the machine that
took the recording is replaced by <path> and counted, so a recording made without the scrub is mended here
and the maintainer told. Standard library only; run from anywhere.
"""
import json, os, re, shutil, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
PATH = re.compile(r'(?<![A-Za-z0-9])[A-Za-z]:[\\/][^\s"\'<>|]*')
MARK = 'const EDITION = null; /*EDITION*/'


SRC = HERE


def load(name, required=True):
    p = os.path.join(SRC, name)
    if not os.path.isfile(p):
        if required:
            sys.exit('build_static: %s is missing beside this script' % name)
        return None
    with open(p, encoding='utf-8') as f:
        return json.load(f)


def commit_of(text):
    """The commit token of '74757d462 on atelier/a0' or '0950e246a (installed)'."""
    return str(text or '').split(' ')[0]


def scrub(obj, counter):
    """Every string of a JSON value with this machine's drive paths replaced; counts what it replaced."""
    if isinstance(obj, str):
        new, n = PATH.subn('<path>', obj)
        counter[0] += n
        return new
    if isinstance(obj, list):
        return [scrub(x, counter) for x in obj]
    if isinstance(obj, dict):
        return {k: scrub(v, counter) for k, v in obj.items()}
    return obj


def main():
    args = sys.argv[1:]
    global SRC
    out = None
    mixed = '--allow-mixed' in args
    for i, a in enumerate(args):
        if a == '--out' and i + 1 < len(args):
            out = args[i + 1]
        elif a.startswith('--out='):
            out = a.split('=', 1)[1]
        elif a == '--from' and i + 1 < len(args):
            SRC = os.path.abspath(args[i + 1])       # data and page from another folder (a guard plants one)
    if not out:
        sys.exit('build_static: give --out <folder> (no default: a folder inside the library would ride into an install)')
    def inside(a, b):
        try:
            return os.path.commonpath([os.path.abspath(a), os.path.abspath(b)]) == os.path.abspath(b)
        except ValueError:          # another drive: certainly not inside
            return False
    if inside(out, HERE):
        sys.exit('build_static: --out is inside the Atelier folder; choose a folder outside the library')

    checks = load('checks.json')
    results = load('results.json')
    tours = load('tours.json', required=False)
    i18n = load('i18n.json')
    with open(os.path.join(SRC, 'atelier.html'), encoding='utf-8') as f:
        page = f.read()
    if MARK not in page:
        sys.exit('build_static: atelier.html has lost its edition marker')

    commit = commit_of(results.get('library'))
    problems = []
    if commit_of(checks.get('commit')) != commit:
        problems.append('the checks were harvested at %s but the recording names %s: run python harvest.py then rnxc record.ring'
                        % (commit_of(checks.get('commit')), commit))
    if tours is None:
        problems.append('there is no tours.json: run rnxc tours.ring for the coverage section')
    elif commit_of(tours.get('library')) != commit:
        problems.append('the sweep (tours.json) was taken at %s but the recording names %s: run rnxc tours.ring'
                        % (commit_of(tours.get('library')), commit))
    ids = {c['id'] for c in checks['checks']}
    states = set(results.get('states', {}))
    if ids != states:
        problems.append('the recording and the checks do not name the same ids (%d against %d): record again'
                        % (len(states), len(ids)))
    if problems and not mixed:
        print('build_static: REFUSED, the three files do not describe one commit:')
        for p in problems:
            print('   -', p)
        print('(--allow-mixed builds anyway; each file then says at which commit it was taken)')
        sys.exit(2)
    for p in problems:
        print('build_static: mixed, as allowed -', p)

    counter = [0]
    checks_s = scrub(checks, counter)
    results_s = scrub(results, counter)
    tours_s = scrub(tours, counter) if tours else None
    if counter[0]:
        print('build_static: %d machine path(s) replaced by <path> in the data: record again with the scrub on' % counter[0])

    counts = {k: results.get(k) for k in ('pass', 'fail', 'err')}
    edition = {
        'commit': commit, 'built': time.strftime('%Y-%m-%d %H:%M'),
        'taken': results.get('taken'), 'library': results.get('library'), 'rnxc': results.get('rnxc'),
        'engine': results.get('engine'), 'checks_from': checks.get('commit'), 'source': checks.get('source'),
        'checks': len(checks['checks']), 'counts': counts,
        'tours': ({'library': tours.get('library'), 'totals': tours.get('totals')} if tours else None),
        'mixed': bool(problems),
        'ring_column': False,
    }
    dest = os.path.join(out, commit)
    if os.path.isdir(dest):
        shutil.rmtree(dest)
    os.makedirs(os.path.join(dest, 'data'))

    def put(rel, obj):
        with open(os.path.join(dest, rel), 'w', encoding='utf-8', newline='\n') as f:
            json.dump(obj, f, ensure_ascii=False, indent=0)

    put('data/checks.json', checks_s)
    put('data/results.json', results_s)
    if tours_s:
        put('data/tours.json', tours_s)
    put('data/i18n.json', i18n)
    put('edition.json', edition)
    ed_js = 'const EDITION = ' + json.dumps({k: edition[k] for k in ('commit', 'taken', 'library', 'rnxc', 'engine', 'checks_from', 'source', 'checks')},
                                            ensure_ascii=False) + ';'
    for name in ('index.html', 'coverage.html', 'check.html'):
        with open(os.path.join(dest, name), 'w', encoding='utf-8', newline='\n') as f:
            f.write(page.replace(MARK, ed_js))

    eds_path = os.path.join(out, 'editions.json')
    eds = []
    if os.path.isfile(eds_path):
        with open(eds_path, encoding='utf-8') as f:
            eds = [e for e in json.load(f) if e.get('commit') != commit]
    eds.append({'commit': commit, 'taken': edition['taken'], 'checks': edition['checks'], 'counts': counts,
                'judged': (tours['totals'].get('judged') if tours else None),
                'then_lines': (tours['totals'].get('claims') if tours else None)})
    with open(eds_path, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(sorted(eds, key=lambda e: str(e.get('taken'))), f, ensure_ascii=False, indent=1)

    size = sum(os.path.getsize(os.path.join(dp, f)) for dp, _, fs in os.walk(dest) for f in fs)
    print('build_static: edition %s written to %s (%d files, %.0f KB): %d checks recorded %s / %s / %s (pass/fail/error)%s'
          % (commit, dest, sum(len(fs) for _, _, fs in os.walk(dest)), size / 1024, edition['checks'],
             counts['pass'], counts['fail'], counts['err'],
             '' if not tours else '; %s of %s Then lines judged' % (tours['totals'].get('judged'), tours['totals'].get('claims'))))
    print('build_static: no Ring column, no playground, nothing runs; open %s' % os.path.join(dest, 'index.html'))


main()
