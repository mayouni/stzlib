"""RING'S VERDICT ON EVERY CHECK -- so a check that does not pass in the Atelier says whose failure it is.

    RING=<ring.exe> RING_TREE=<a library folder Ring can load> python verdicts.py

A check is an author's assertion, and an assertion can fail for two different reasons: the suite's own
expectation is not met by Softanza (it fails on Ring too), or Ring++ answers differently from Ring. The
page shows the two apart only if it knows Ring's answer, so this asks for it: every check becomes one
function of ONE Ring program (its `Run` and its helpers renamed apart, each call inside a `try`), and
that program runs

    on the ORACLE      RING, a Ring 1.27 built so that the library's engine loads Ring-flavoured, from
                       RING_TREE, a library folder of the same commit as the checks (a checkout, since an
                       install carries no Ring-flavour engine) -- both from the environment, never from a
                       path written here
    on rnxc, WHOLE     the same program compiled at once by rnxc (RNXC, else `rnxc` on the path) from
                       STZ_TREE (else the library this folder sits in): the compiler and the VM without the
                       resident path, so a check that differs only on the server names the server

Writes verdicts.json beside this file: {meta, verdicts: {id: {ring, whole, ring_said, whole_said}}}, each a
pass | fail | err | none. `meta` names what the verdicts were taken on -- the oracle's version and the commit
of its tree, the rnxc build, the library commit -- and no folder of the machine. Read-only on both trees.
A maintainer's instrument: the oracle is not part of any install.
"""
import json, os, re, shutil, subprocess, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
RING = os.environ.get('RING', '')
RING_TREE = os.environ.get('RING_TREE', '')
RNXC = os.environ.get('RNXC') or shutil.which('rnxc') or ''
STZ_TREE = os.environ.get('STZ_TREE') or os.path.normpath(os.path.join(HERE, '..'))
WORK = os.path.join(HERE, '_work')
NAME = r'[A-Za-z_@$][A-Za-z0-9_@$]*'


def kit():
    """AtelierThen and AtelierShow, as atelier.ring defines them."""
    src = open(os.path.join(HERE, 'atelier.ring'), encoding='utf-8').read()
    keep = []
    for name in ('AtelierThen', 'AtelierShow'):
        m = re.search(r'^func ' + name + r'\b.*?(?=^func |\Z)', src, re.M | re.S)
        keep.append(m.group(0).rstrip() + '\n')
    return '\n'.join(keep)


def program(checks):
    top, funcs = ['load "stzlib.ring"', ''], []
    for c in checks:
        code, i = c['code'], c['n']          # the rank names the function; the id keys the verdict
        for nm in set(re.findall(r'^(?:func|def)\s+(' + NAME + ')', code, re.M)):
            code = re.sub(r'(?<![A-Za-z0-9_@$])' + re.escape(nm) + r'(?![A-Za-z0-9_@$])', '%s_%d' % (nm, i), code, flags=re.I)
        funcs.append(code.rstrip() + '\n')
        top += ['try', '\t? "#%d " + Run_%d("")' % (i, i), 'catch', '\t? "#%d E " + cCatchError' % i, 'done']
    return '\n'.join(top) + '\n? "#END"\n\n' + kit() + '\n' + '\n'.join(funcs)


def parse(out):
    """id -> (pass|fail|err, what it said): a FAIL's expected and got lines, an error's message."""
    v, cur = {}, None
    for line in out.replace('\r\n', '\n').split('\n'):
        m = re.match(r'#(\d+) (.*)', line)
        if not m:
            if cur is not None and v[cur][0] != 'pass' and line.strip():
                v[cur] = (v[cur][0], (v[cur][1] + '\n' + line).strip()[:400])
            continue
        cur, rest = int(m.group(1)), m.group(2)
        kind = 'pass' if rest.startswith('PASS') else 'err' if rest.startswith('E ') else 'fail'
        v[cur] = (kind, rest[2:].strip() if kind == 'err' else '')
    return v


def run(cmd, cwd, what):
    t = time.perf_counter()
    env = dict(os.environ, STZ_NO_VIEW='1')
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, timeout=3600, env=env)
    out = r.stdout.decode('utf-8', 'replace')
    print('%s: exit %d, %.0f s, reached the end: %s' % (what, r.returncode, time.perf_counter() - t, '#END' in out))
    if '#END' not in out:
        print('   its last lines:', ' | '.join(out.strip().split('\n')[-3:])[:400], (r.stderr.decode('utf-8', 'replace')[-300:]))
    return parse(out)


def git_head(folder):
    try:
        r = subprocess.run(['git', '-C', folder, 'log', '-1', '--format=%h %cs'], capture_output=True, text=True, timeout=30)
        return r.stdout.strip() or 'unknown'
    except (OSError, subprocess.SubprocessError):
        return 'unknown'


def build_of(exe, key):
    """What an executable is: an installed package names it in PACKAGE.txt beside bin/; a build inside a checkout
    says that checkout's HEAD and when the binary was built; anything else, its size and date. No path."""
    exe = os.path.abspath(exe)
    built = time.strftime('%Y-%m-%d %H:%M', time.localtime(os.path.getmtime(exe)))
    pkg = os.path.join(os.path.dirname(os.path.dirname(exe)), 'PACKAGE.txt')
    if os.path.isfile(pkg):
        m = re.search(key + r'\s+(\S+)\s+(\S+)', open(pkg, encoding='utf-8').read())
        if m:
            return '%s %s %s, installed' % (key, m.group(1), m.group(2))
    d = os.path.dirname(exe)
    while os.path.dirname(d) != d:
        if os.path.exists(os.path.join(d, '.git')):
            return '%s checkout %s, built %s' % (key, git_head(d), built)
        d = os.path.dirname(d)
    return '%s %d bytes, built %s' % (os.path.basename(exe), os.path.getsize(exe), built)


def tree_commit(folder):
    """A library folder's commit: PACKAGE.txt two folders up names it in an install; else git."""
    pkg = os.path.normpath(os.path.join(folder, '..', '..', 'PACKAGE.txt'))
    if os.path.isfile(pkg):
        m = re.search(r'stzlib\s+(\S+)', open(pkg, encoding='utf-8').read())
        if m:
            return m.group(1) + ', installed'
    return git_head(folder)


def main():
    if not (RING and os.path.isfile(RING)):
        sys.exit('verdicts: set RING to the oracle ring.exe (it is not part of any install)')
    if not (RING_TREE and os.path.isdir(RING_TREE)):
        sys.exit('verdicts: set RING_TREE to a library folder the oracle can load')
    if not (RNXC and os.path.isfile(RNXC)):
        sys.exit('verdicts: set RNXC to an rnxc, or put rnxc on the path')
    d = json.load(open(os.path.join(HERE, 'checks.json'), encoding='utf-8'))
    os.makedirs(WORK, exist_ok=True)
    prog = os.path.join(WORK, 'verdicts_all.ring')
    open(prog, 'w', encoding='utf-8', newline='\n').write(program(d['checks']))
    ring = run([RING, prog], RING_TREE, 'the oracle')
    whole = run([RNXC, prog], STZ_TREE, 'rnxc, compiled whole')
    res = {}
    for c in d['checks']:
        i = c['n']
        rk, rt = ring.get(i, ('none', ''))
        wk, wt = whole.get(i, ('none', ''))
        res[c['id']] = {'ring': rk, 'whole': wk, 'ring_said': rt, 'whole_said': wt}
    meta = {'taken': time.strftime('%Y-%m-%d %H:%M'), 'checks_from': d.get('commit', 'unknown'),
            'ring': build_of(RING, 'ring'), 'ring_tree': tree_commit(RING_TREE),
            'rnxc': build_of(RNXC, 'ringpp'), 'library': tree_commit(STZ_TREE)}
    json.dump({'meta': meta, 'verdicts': res}, open(os.path.join(HERE, 'verdicts.json'), 'w', encoding='utf-8', newline='\n'), indent=0)
    from collections import Counter
    print('on Ring:        ', dict(Counter(v['ring'] for v in res.values())))
    print('on rnxc, whole: ', dict(Counter(v['whole'] for v in res.values())))
    print('differ:', sum(1 for v in res.values() if v['ring'] != v['whole']))
    print('wrote verdicts.json;', meta)


main()
