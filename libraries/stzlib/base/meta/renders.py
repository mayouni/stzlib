# The RENDER RATCHET: a drift gate for the test files whose output is a picture.
#
# promises.py reads inline `#--> value` annotations. 298 test files carry an
# arrow that was left EMPTY, and measured over the 153 unambiguous ones, 102 of
# them are empty for a reason that filling cannot fix:
#
#     57 print a box-drawing RENDER (a calendar, a table, an org chart)
#     45 print more than ten lines (graph/74 prints 174)
#
# The blank is the author declining to paste a 25-line calendar into a comment,
# not an oversight. A further 88 cannot carry an inline promise at ALL, whatever
# is written in them, because promises.py:73 requires a `?` line directly above
# the arrow and their printing site is `.Show()` or a bare call.
#
# So this gate compares the file's WHOLE OUTPUT against a stored artefact. It
# needs no `?` line, no arrow, and no particular arrow count, which is exactly
# why it reaches the files the inline harness structurally cannot.
#
# WHAT IT CLOSES, AND WHAT IT DOES NOT.
#
# It closes DRIFT. Column padding, box-drawing junctions and unicode display
# width break silently and no existing assertion in this library sees them.
#
# It closes NOTHING ABOUT CORRECTNESS, and the house law is blunt about why:
# "a comparison proves SAMENESS, never RIGHTNESS" (PERCEPTION.md). Its worked
# example is this exact shape -- a cross-tier guard passing 26 assertions that
# prove a browser and a desktop render the identical motif, every one of which
# two tiers rendering the same WRONG motif also passes. A baseline captured from
# a run is a record of what the code DOES. Nobody has judged it.
#
# That is why every entry carries a `judged` flag and why `render-unjudged` is a
# standing WARNING: the perceptual debt is counted, it can only shrink, and it is
# paid a few entries at a time instead of in one impossible sitting of 102.
#
# WHY A RATCHET AND NOT A GOLDEN-FILE TOOL.
#
# base/meta/stzDocGate.ring already carries the house's ratchet contract, and one
# of its properties matters more than anything else here:
#
#     "StzDocGateBaselineUpdate never ADDS a key: it keeps the baseline roots
#      that still fail, so a regression of a written method shows as a doc-floor
#      error and cannot be hidden by running the update."
#
# Every snapshot tool I would otherwise have written does the opposite. Its
# `--update` re-blesses whatever it currently sees, so the first person who runs
# it to clear a red build launders the regression into the new truth. Transposed
# to renders, the property is NEVER OVERWRITES A KEY:
#
#     --seed            captures entries that do NOT exist yet. Never touches one
#                       that does.
#     --accept <file>   overwrites ONE named entry, and prints the diff it is
#                       about to bless. There is deliberately no --accept-all.
#
# Findings come out in the house shape so they can be ingested beside the other
# gates rather than read as a parallel contract (perf-law 9, CLAUDE.md):
#
#     [ rule, subject, where, severity, message ]
#
#     render-drift      ERROR    the stored render and the current output differ
#     render-gone       ERROR    a baseline entry whose file no longer renders
#     render-new        WARNING  a render-shaped file with no baseline entry, so
#                                new renders cannot silently escape coverage
#     render-unjudged   WARNING  a baseline entry no human has ever looked at
#
# COST. promises.py:298 does `continue` BEFORE calling run(), so a file with no
# readable promise is never executed by it at all -- the output of exactly this
# population is not already in hand. This gate therefore runs those files itself:
# ~0.4 s per root with a prefixed library image, a few seconds for the heavy
# graph scenarios. It is a pre-commit gate, not an edit-time check.
#
# Usage:
#     python renders.py <topic>                  judge
#     python renders.py <topic> --seed           capture what is missing
#     python renders.py <topic> --accept <file>  bless one changed render
#     python renders.py <topic> --judged <file>  mark one entry as looked at

import io, os, re, subprocess, sys, time, hashlib, collections

# Same reason as promises.py:28 -- redirected to a file, Python picks the system
# codepage (cp1252 here) and these outputs are full of box-drawing, Arabic, CJK
# and emoji. A run whose counts survive and whose detail dies is the worst shape
# of failure, because it looks complete.
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

RUNNER = os.environ.get("STZ_RUNNER", "D:/GitHub/haro/vm/zig-out/bin/haro.exe")
ENGINE_DIR = os.environ.get("STZ_ENGINE_DIR", "C:/haro-engine")

NL = chr(10)
CR = chr(13)
TAB = chr(9)

# The tree THIS FILE lives in, so a worktree gates its own files. promises.py
# learned this the hard way: ROOT named D:/GitHub/stzlib absolutely, so a run
# from a worktree silently graded the main checkout and reported the number as
# the worktree's own.
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

argv = sys.argv[1:]
MODE = 'judge'
TARGET = None
if '--seed' in argv:
    MODE = 'seed'
    argv.remove('--seed')
for flag in ('--accept', '--judged'):
    if flag in argv:
        i = argv.index(flag)
        MODE = flag[2:]
        TARGET = argv[i + 1] if i + 1 < len(argv) else None
        del argv[i:i + 2]

TOPIC = argv[0] if argv else 'calendar'
if ':' in TOPIC or '/' in TOPIC or os.path.isdir(TOPIC):
    ROOT = TOPIC
    TOPIC = os.path.basename(os.path.normpath(TOPIC))
else:
    ROOT = os.path.join(BASE_DIR, 'test', TOPIC)

STORE = os.path.join(BASE_DIR, 'test', '_renders')
TOPIC_STORE = os.path.join(STORE, TOPIC)
MANIFEST = os.path.join(STORE, 'MANIFEST.tsv')


# ---------------------------------------------------------------- volatility
#
# A drift gate over volatile output is a gate that cries every morning, and
# "flaky is a latency defect" (PX.md) -- a re-run is the most expensive wait
# there is. Three separate hazards, and only the first is the obvious one.

# 1. NOISE: present every run, differing every run. Stripped before comparison.
#     The patterns are matched against the STRIPPED line, so none of them may
#     anchor on leading whitespace. The first version of this matched the v0.78
#     note's continuation lines as `      that did not`, which never fired: two
#     lines of the note leaked through into the comparison. That is the worst
#     possible leak here, because the note is emitted ONLY ON A COLD COMPILE
#     (reference_haro_cold_compile_note) -- the baseline would have depended on
#     the image cache's state rather than on the code, and a gate that answers
#     differently on a cold run is not a gate. Found by renders_selftest.py
#     before this ever touched a file.
NOISE = re.compile(
    r'^(Executed in [0-9.]+|STOPPED!|'
    r'In raise\(\)|In (method|function) |Called from line |'
    r'Line [0-9]+\s*$|'
    r'note: the top level|'
    r'that did not\. Running it measures|'
    r'result it produces is NOT certified)', re.I)

# 2. NON-REPRODUCIBLE CONTENT: differs between two runs of the same code. Caught
#    by running twice, which this gate does on every capture.

# 3. DATE-DEPENDENT CONTENT: identical across two runs today and different
#    tomorrow. RUNNING TWICE DOES NOT CATCH IT, and a calendar module is the
#    single most likely place in this library to render "the current month".
#    So a capture is refused outright when today's date appears in the output in
#    any of the forms this library prints. The cost is refusing a handful of
#    legitimately fixed renders that happen to contain today's numbers; the
#    alternative is a baseline that goes red at midnight.
def date_tokens():
    t = time.localtime()
    out = {
        time.strftime('%Y-%m-%d', t), time.strftime('%d/%m/%Y', t),
        time.strftime('%m/%d/%Y', t), time.strftime('%Y/%m/%d', t),
        time.strftime('%d-%m-%Y', t), time.strftime('%B %Y', t),
        time.strftime('%b %Y', t), time.strftime('%B %d, %Y', t),
    }
    return {s for s in out if s}

DATES = date_tokens()

# 4. MACHINE IDENTITY. This repository is PUBLIC and the baseline is tracked, so
#    an absolute path, a drive letter or the operator's account name must never
#    reach a stored artefact. The account name on this machine contains spaces,
#    which is also why an earlier instrument's awk column indices were wrong.
HOME = os.path.expanduser('~')
SECRETS = [p for p in (HOME, BASE_DIR, os.path.dirname(RUNNER), ENGINE_DIR) if p]
DRIVEPATH = re.compile(r'\b[A-Za-z]:[/\\][A-Za-z0-9_.\\/ -]{6,}')

DIDNOTRUN = re.compile(r'Error \([CSE][0-9]+\)')
RAISED = re.compile(r'Error \(|Traceback', re.I)
BOXDRAW = re.compile('[' + ''.join(chr(c) for c in (0x2500, 0x2502, 0x250c, 0x2510,
                                                    0x2514, 0x2518, 0x251c, 0x2524,
                                                    0x252c, 0x2534, 0x253c, 0x2550,
                                                    0x2551, 0x2554, 0x2557, 0x255a,
                                                    0x255d, 0x2588, 0x2591)) + ']')


def run(path):
    env = dict(os.environ)
    env["STZ_ENGINE_DIR"] = ENGINE_DIR
    try:
        p = subprocess.run([RUNNER, os.path.basename(path)], cwd=os.path.dirname(path),
                           capture_output=True, timeout=180, env=env)
    except subprocess.TimeoutExpired:
        return None
    raw = (p.stdout + p.stderr).decode('utf-8', 'replace')
    return raw.replace(CR + NL, NL).split(NL)


def strip_noise(lines):
    out = [l.rstrip() for l in lines]
    out = [l for l in out if not NOISE.match(l.strip())]
    while out and out[-1].strip() == '':
        out.pop()
    while out and out[0].strip() == '':
        out.pop(0)
    return out


def is_render(lines):
    """Render-shaped: box drawing, or more than ten lines of output."""
    if any(BOXDRAW.search(l) for l in lines):
        return True
    return len([l for l in lines if l.strip()]) > 10


def digest(lines):
    return hashlib.sha256(NL.join(lines).encode('utf-8')).hexdigest()[:16]


def unstorable(lines):
    """Why this output may not become a tracked artefact. '' when it may."""
    text = NL.join(lines)
    if not [l for l in lines if l.strip()]:
        return 'prints nothing'
    if any(RAISED.search(l) for l in lines):
        return 'it raises -- a stack trace is not an expectation'
    for s in SECRETS:
        if s and s.lower() in text.lower():
            return 'the output names a path on this machine (public repository)'
    m = DRIVEPATH.search(text)
    if m:
        return 'the output carries an absolute path: %s' % m.group(0)[:40]
    for d in DATES:
        if d in text:
            return "the output contains today's date (%s): it would go red at midnight" % d
    return ''


# ---------------------------------------------------------------- the store
#
# One artefact per test, not one bundle. A bundle tells you that something moved;
# a per-test file makes `git diff` print the render that changed, next to the one
# that was blessed. The whole value of this gate is being able to LOOK at the
# difference, which is also why the store holds full text and not hashes.
#
# This is 102 tracked files, four commits after 28f2fd989 deleted 844 generated
# test outputs ("the folders only grew", 513 of them committed). The distinction
# that makes it legitimate: those SVGs carried a CLOCK in the filename, so every
# run wrote a NEW file and nothing ever compared them. These have fixed names,
# are overwritten rather than accumulated, and are read on every run. An artefact
# nobody compares is litter; an artefact a gate reads is the gate.

def store_path(fn):
    return os.path.join(TOPIC_STORE, fn[:-5] + '.out' if fn.endswith('.ring') else fn + '.out')


def read_store(fn):
    p = store_path(fn)
    if not os.path.isfile(p):
        return None
    with io.open(p, encoding='utf-8', errors='replace', newline='') as fh:
        return fh.read().replace(CR + NL, NL).split(NL)


def write_store(fn, lines):
    os.makedirs(TOPIC_STORE, exist_ok=True)
    with io.open(store_path(fn), 'w', encoding='utf-8', newline='') as fh:
        fh.write(NL.join(lines))


def read_manifest():
    rows = {}
    if not os.path.isfile(MANIFEST):
        return rows
    with io.open(MANIFEST, encoding='utf-8') as fh:
        head = fh.readline()
        for line in fh:
            p = line.rstrip(NL).split(TAB)
            if len(p) >= 6:
                rows[p[0]] = {'lines': p[1], 'digest': p[2], 'judged': p[3],
                              'runtime': p[4], 'engine': p[5],
                              'captured': p[6] if len(p) > 6 else ''}
    return rows


def write_manifest(rows):
    os.makedirs(STORE, exist_ok=True)
    with io.open(MANIFEST, 'w', encoding='utf-8', newline='') as fh:
        fh.write(TAB.join(('key', 'lines', 'digest', 'judged',
                           'runtime', 'engine', 'captured')) + NL)
        for k in sorted(rows):
            r = rows[k]
            fh.write(TAB.join((k, str(r['lines']), r['digest'], str(r['judged']),
                               r['runtime'], r['engine'], r['captured'])) + NL)


def runtime_id():
    try:
        with open(RUNNER, 'rb') as fh:
            return hashlib.sha256(fh.read()).hexdigest()[:16]
    except OSError:
        return 'unknown'


def engine_id():
    ref = os.path.join(ENGINE_DIR, 'REF.txt')
    try:
        with io.open(ref, encoding='utf-8', errors='replace') as fh:
            return fh.read().strip().split()[0][:16]
    except (OSError, IndexError):
        return 'unknown'


# ---------------------------------------------------------------- findings

findings = []


def finding(rule, subject, severity, message):
    findings.append((rule, subject, '%s/%s' % (TOPIC, subject), severity, message))


def main():
    if not os.path.isdir(ROOT):
        print('no such topic directory: %s' % ROOT)
        return 2

    files = sorted(f for f in os.listdir(ROOT)
                   if f.endswith('.ring') and not f.startswith('_'))
    manifest = read_manifest()
    rt, eng = runtime_id(), engine_id()

    if MODE in ('accept', 'judged'):
        return single(manifest, rt, eng)

    t0 = time.time()
    seeded = refused = drifted = unchanged = skipped = 0
    timings = []

    for fn in files:
        key = '%s/%s' % (TOPIC, fn)
        stored = read_store(fn)
        known = key in manifest

        # A file with no baseline entry is only interesting if it is
        # render-shaped; everything else is promises.py's business.
        t1 = time.time()
        out = run(os.path.join(ROOT, fn))
        timings.append((time.time() - t1, fn))

        if out is None:
            if known:
                finding('render-gone', fn, 'error', 'the file now times out (180 s)')
            skipped += 1
            continue

        joined = NL.join(l for l in out if not l.lstrip().startswith('eval '))
        if DIDNOTRUN.search(joined):
            # A FILE THAT DID NOT COMPILE HAS NOT DRIFTED -- the same lesson
            # promises.py:314 paid for, where one unrelated parse failure was
            # reported as 277 divergences out of 286.
            if known:
                finding('render-gone', fn, 'error',
                        'the file no longer compiles, so its render cannot be checked')
            skipped += 1
            continue

        cur = strip_noise(out)

        if not known:
            if not is_render(cur):
                skipped += 1
                continue
            why = unstorable(cur)
            if why:
                if MODE == 'seed':
                    print('   REFUSED  %-52s %s' % (fn[:52], why))
                    refused += 1
                else:
                    # INFO, not WARNING, and a rule of its own. This file can
                    # NEVER be gated, so a warning here would stand for ever and
                    # inflate the count the ratchet exists to shrink. A gate with
                    # permanent noise in it is a gate people stop reading.
                    finding('render-ungateable', fn, 'info',
                            'render-shaped and cannot be baselined at all: ' + why)
                continue
            if MODE != 'seed':
                finding('render-new', fn, 'warning',
                        'a render-shaped file with no baseline entry (%d lines): run --seed'
                        % len(cur))
                continue

            # RUN IT TWICE. Two runs of the same code that differ mean the output
            # is not reproducible, and a baseline taken from one of them is a
            # trap for whoever reads the first red build. This rail was bought:
            # uuid/06_multiple_generations was nearly filled with a UUID.
            out2 = run(os.path.join(ROOT, fn))
            if out2 is None or strip_noise(out2) != cur:
                print('   REFUSED  %-52s not reproducible across two runs' % fn[:52])
                refused += 1
                continue

            write_store(fn, cur)
            manifest[key] = {'lines': len(cur), 'digest': digest(cur), 'judged': 0,
                             'runtime': rt, 'engine': eng,
                             'captured': time.strftime('%Y-%m-%dT%H:%M:%S')}
            print('   SEEDED   %-52s %4d lines  %s' % (fn[:52], len(cur), digest(cur)))
            seeded += 1
            continue

        # Known entry: compare.
        if stored is None:
            finding('render-gone', fn, 'error',
                    'the manifest has this entry and its artefact file is missing')
            continue
        if cur == stored:
            unchanged += 1
            if str(manifest[key].get('judged', '0')) != '1':
                finding('render-unjudged', fn, 'warning',
                        'nobody has ever looked at this render: it records what the '
                        'code DOES, not what it should do (--judged to clear)')
            continue

        drifted += 1
        a, b = len(stored), len(cur)
        first = next((i for i in range(min(a, b)) if stored[i] != cur[i]), min(a, b))
        finding('render-drift', fn, 'error',
                'the render changed: %d lines -> %d, first difference at line %d '
                '(--accept to bless it, after looking)' % (a, b, first + 1))

    # Baseline entries whose file is gone from the topic entirely.
    for key in sorted(manifest):
        if not key.startswith(TOPIC + '/'):
            continue
        fn = key.split('/', 1)[1]
        if fn not in files:
            finding('render-gone', fn, 'error',
                    'the baseline has this entry and the test file no longer exists')

    if MODE == 'seed':
        write_manifest(manifest)

    # PX.md: a long suite prints per-section wall time, and a scoped run PRINTS
    # WHAT IT SKIPPED. A budget nobody can attribute is unenforceable.
    print()
    print('topic %s -- %d files in %.1f s' % (TOPIC, len(files), time.time() - t0))
    if MODE == 'seed':
        print('   seeded %d   refused %d   skipped (not render-shaped) %d'
              % (seeded, refused, skipped))
    else:
        print('   baselined and unchanged %d   drifted %d   not checked %d'
              % (unchanged, drifted, skipped))
    timings.sort(reverse=True)
    if timings:
        print('   slowest: ' + ', '.join('%s %.1fs' % (f, t) for t, f in timings[:3]))

    print()
    if not findings:
        print('no findings')
        return 0
    order = {'error': 0, 'warning': 1}
    findings.sort(key=lambda f: (order.get(f[3], 2), f[0], f[1]))
    counts = collections.Counter((f[0], f[3]) for f in findings)
    for (rule, sev), n in sorted(counts.items(), key=lambda kv: order.get(kv[0][1], 2)):
        print('   %-9s %-16s %3d' % (sev.upper(), rule, n))
    print()
    for rule, subject, where, sev, msg in findings:
        print('%-9s %-16s %-44s %s' % (sev.upper(), rule, where[:44], msg))
    return 1 if any(f[3] == 'error' for f in findings) else 0


def single(manifest, rt, eng):
    """--accept one render, or --judged one entry. One file, named, never bulk."""
    if not TARGET:
        print('name the file: --%s <file.ring>' % MODE)
        return 2
    fn = os.path.basename(TARGET)
    key = '%s/%s' % (TOPIC, fn)

    if MODE == 'judged':
        if key not in manifest:
            print('%s is not in the baseline' % key)
            return 2
        manifest[key]['judged'] = 1
        write_manifest(manifest)
        print('%s marked as looked at. One artefact, one act of looking.' % key)
        return 0

    stored = read_store(fn)
    out = run(os.path.join(ROOT, fn))
    if out is None:
        print('%s timed out' % fn)
        return 2
    cur = strip_noise(out)
    why = unstorable(cur)
    if why:
        print('refusing to store this output: %s' % why)
        return 2
    if stored == cur:
        print('%s has not changed; nothing to accept' % key)
        return 0

    # PRINT THE DIFF IT IS ABOUT TO BLESS. An accept that shows nothing is the
    # laundering this whole design exists to prevent -- the operator must see
    # what they are making true.
    import difflib
    print('about to bless this change to %s:' % key)
    print()
    for line in list(difflib.unified_diff(stored or [], cur, 'stored', 'current',
                                          lineterm='', n=2))[:120]:
        print('   ' + line)
    print()
    write_store(fn, cur)
    manifest[key] = {'lines': len(cur), 'digest': digest(cur), 'judged': 1,
                     'runtime': rt, 'engine': eng,
                     'captured': time.strftime('%Y-%m-%dT%H:%M:%S')}
    write_manifest(manifest)
    print('blessed, and marked judged because you were shown the diff.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
