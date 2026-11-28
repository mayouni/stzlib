# Drive renders.py --seed across every test topic, ONE AT A TIME, RESUMABLY.
#
# 161 topics, 5,416 test files, measured at 2.86 s per file on calendar and
# 6.65 s/file on graph (a render-shaped file runs TWICE, by design, to refuse
# non-reproducible output). One process at a time, never a parallel sweep: this
# machine does not slow down under memory pressure, it freezes and costs a
# restart, and it must never overlap another desk's -j2 build.
#
# FIVE DEFECTS THIS DRIVER HAS HAD, all five fixed, each one having cost something:
#
# 1. IT TRUNCATED ITS OWN LOG. The progress TSV was opened 'w' at startup, so a
#    restart destroyed the completed rows -- after 95 minutes of real work (87
#    baselines on disk) the log held nothing but its header, and I had to read the
#    ARTEFACT DIRECTORIES to answer another desk asking where the sweep had got
#    to. Everything here is append-only.
#
# 2. IT WAS NOT RESUMABLE. A stop meant re-running finished topics. A topic is
#    recorded in SWEPT.txt the moment it completes, and a resume skips it. The
#    manifest cannot serve as the resume key: a topic with no render-shaped files
#    legitimately has no entries, and would be re-swept on every resume for ever.
#
# 3. IT HAD NO WAY TO EXCLUDE A TOPIC, which mattered while the GPU desk held the
#    card under a hardware lease. EXCLUDE is by name, not by ordering, because
#    "it is last in my ordering" is a weak promise about a four-hour process.
#    (The lease was released at 14:05 on 2026-11-27, so EXCLUDE is empty now.)
#
# 4. A TOPIC THAT TIMED OUT WROTE NO ROW AT ALL. On 2026-11-27 `diagram` burned
#    two hours and the TSV recorded NOTHING -- the one event most worth a line in
#    the log was the one event that could not produce one, because the timeout
#    path broke out of the loop before the write. A burn is now logged like any
#    other outcome, with its reason in the topic column.
#
# 5. ITS TOPIC TIMEOUT WAS A FLAT TWO HOURS, which is both too long for a small
#    topic and too short for a big one. It is now derived from the file count,
#    now that renders.py's per-file bound is real (see below).
#
# WHY THE PER-FILE BOUND IS REAL NOW. renders.py had a 180-second per-file
# timeout all along, and on 2026-11-27 it bought NOTHING: the file hung for two
# hours anyway. subprocess.run with capture_output=True handles a timeout by
# killing the direct child and then draining the pipes, and
# diagram/41_import_as_subdiagram.ring calls oDiag.View(), which shells out to
# graphviz and then to the system viewer -- both inheriting the write end of that
# pipe. A pipe a surviving grandchild holds never reaches EOF, so the drain
# blocks for ever. renders.py now writes output to a FILE, reads stdin from
# DEVNULL and kills the whole process tree, so 180 s is a bound and not a wish.
#
# THE PREFIX RAIL. Every root is cheap only because the cache holds a compiled
# library image, silently dropped if any library file or haro.exe changes, in a
# tree shared with a dozen sessions. A whole compile measured 5m32s, so a dropped
# prefix turns 5,416 files into weeks. The driver watches its per-file rate and
# stops, naming the reason. It also keeps the cache from eating the disk: 71
# per-root images reached 3.5 GB on a drive that was at 94% with the page file
# that stops this machine freezing living on it.

import io
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time

# THE THREE SETTINGS THIS FILE READS, and nothing else from the machine it runs
# on. The repository is public, so no folder of any particular machine appears
# below; the hook at base/security/hooks/pre-commit names its settings in its
# own header for the same reason.
#
#   STZ_SWEEP_DIR    where the cache, the log and the swept-topic record live.
#                    Defaults to a directory in the system temp folder. Point it
#                    at a drive with room: the per-root images are large and are
#                    trimmed to CACHE_CAP_GB as the sweep runs.
#   HARO_EXE         the haro runtime. Defaults to `haro` on PATH.
#   STZ_ENGINE_DIR   passed through to haro if it is already set in the
#                    environment, and left unset otherwise.
#
# The tree to sweep is NOT a setting: it is derived from this file's own
# location, so the checkout this file lives in is the checkout it sweeps.
# renders_selftest.py carries the same derivation and the same reason -- an
# absolute root once meant a worktree silently graded a different checkout.
BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
META = os.path.join(BASE, 'meta')
TESTS = os.path.join(BASE, 'test')

WORK = os.environ.get('STZ_SWEEP_DIR') or os.path.join(tempfile.gettempdir(),
                                                       'stz-render-sweep')
if not os.path.isdir(WORK):
    os.makedirs(WORK)
CACHE = os.path.join(WORK, 'rendercache')
LOG = os.path.join(WORK, 'seed-all-progress.tsv')
SWEPT = os.path.join(WORK, 'seed-all-swept.txt')
HARO = os.environ.get('HARO_EXE') or 'haro'
NL = chr(10)
TAB = chr(9)

ABORT_RATE = 20.0          # calendar 2.86, graph 6.65; a whole compile is ~330
CACHE_CAP_GB = 2.0         # per-root images are regenerable; the disk is not
MIN_FREE_GB = 8.0          # below this, stop: D: holds the page file
EXCLUDE = set()            # the GPU lease was released 2026-11-27 14:05

env = dict(os.environ)
env['HARO_CACHE'] = CACHE
                           # STZ_ENGINE_DIR is inherited if the environment has
                           # it; this file never writes a path of its own there.
env['STZ_NO_VIEW'] = '1'   # renders.py sets this too; harmless twice, cheap here
env['PYTHONIOENCODING'] = 'utf-8'

# VALUE FIRST, not alphabetical: if this stops early, the topics the empty-arrow
# survey showed carrying render-shaped files should already be done.
FIRST = ['diagram', 'char', 'timeline', 'matrex', 'list', 'table',
         'numbrex', 'locale', 'listofhashlists', 'folder', 'dataset', 'gpu']

swept = set()
if os.path.isfile(SWEPT):
    with io.open(SWEPT, encoding='utf-8') as fh:
        swept = {l.strip() for l in fh if l.strip()}

# DEFECT 9, found 2026-11-28 at the end of the sweep. This line used to read
#
#     swept |= {'calendar', 'graph'}
#
# with a comment stating that both topics had completed. They were seeded by
# hand before this driver existed, and that sentence was my recollection, not a
# record: nothing measured them, and the two topics were then skipped by every
# one of the five runs. The file SWEPT.txt was accurate throughout -- it listed
# 159 topics and never claimed these two -- so the instrument and its own log
# disagreed for eleven hours and the log was right.
#
# A hard-written set membership is a claim with no provenance, and it is worth
# noticing WHERE it sat: three lines under a loop that reads the real record
# from disk. The repair is to delete it and let the record speak, which is all
# it took: both topics were swept on the next run and the measurement settles
# whether anything was missing.
#
# diagram was always absent from this set for the same reason, stated the other
# way round: it burned two hours under the first driver and wrote 20 of its 61
# files, so it was never claimed as done and --seed skips the 20 that exist.

topics = sorted(d for d in os.listdir(TESTS)
                if os.path.isdir(os.path.join(TESTS, d)) and not d.startswith('_'))
order = ([t for t in FIRST if t in topics and t not in swept and t not in EXCLUDE] +
         [t for t in topics if t not in FIRST and t not in swept and t not in EXCLUDE])

SUMMARY = re.compile(r'^topic (\S+) -- (\d+) files in ([0-9.]+) s', re.M)
COUNTS = re.compile(r'seeded (\d+)\s+refused (\d+)\s+skipped \(not render-shaped\) (\d+)')

if not os.path.isfile(LOG):           # append-only; header only when absent
    with io.open(LOG, 'w', encoding='utf-8', newline='') as fh:
        fh.write(TAB.join(('n', 'topic', 'files', 'seconds', 'per_file',
                           'seeded', 'refused', 'skipped', 'stamp')) + NL)


def note(line):
    print(line, flush=True)
    with io.open(LOG + '.log', 'a', encoding='utf-8', newline='') as fh:
        fh.write(line + NL)


def row(i, topic, files, secs, rate, seeded, refused, skipped):
    """Append one row. Called on EVERY outcome, a timeout included -- defect 4."""
    with io.open(LOG, 'a', encoding='utf-8', newline='') as fh:
        fh.write(TAB.join((str(i), topic, str(files), '%.1f' % secs, '%.2f' % rate,
                           str(seeded), str(refused), str(skipped),
                           time.strftime('%H:%M:%S'))) + NL)


def free_gb(path):
    try:
        return shutil.disk_usage(path).free / (1024.0 ** 3)
    except OSError:
        return 999.0


def trim_cache():
    """Drop the per-root images, keep the library prefix.

    A .haroi is one root's compiled image at about 52 MB, regenerable by
    definition; the .harop is the 30 MB library prefix that makes every root
    cheap and costs 5m32s to rebuild. 71 of the former reached 3.5 GB.
    """
    try:
        names = [n for n in os.listdir(CACHE) if n.endswith('.haroi')]
    except OSError:
        return 0
    total = 0
    for n in names:
        p = os.path.join(CACHE, n)
        try:
            total += os.path.getsize(p)
        except OSError:
            continue
    if total < CACHE_CAP_GB * (1024.0 ** 3):
        return 0
    freed = 0
    for n in names:
        p = os.path.join(CACHE, n)
        try:
            sz = os.path.getsize(p)
            os.unlink(p)
            freed += sz
        except OSError:
            pass
    return freed


# DEFECT 6, and the one that stopped the 2026-11-27 evening sweep. The rate rail
# below is a PROXY, and it lied: after `gpu` ran at 46.12 s/file it announced
# that the library prefix had been dropped and stopped the run with 147 topics
# still to sweep. The prefix was perfectly fine. The eleven topics before gpu had
# run at 3.49 to 13.85 s/file, and gpu is slow for the ordinary reason that its
# files drive a device -- 40 of its 43 files ran, at about 50 s each.
#
# The error was in the inference, not the measurement: a dropped prefix is
# SYSTEMIC and slows every topic after it, so one slow topic is evidence of a
# slow topic and nothing else. The rail read a local symptom as a global cause
# and acted on it.
#
# So the proxy now only TRIGGERS, and a direct measurement decides. The canary is
# one real test file -- the smallest in the corpus that has a stored baseline, so
# it is known to run, to terminate and to produce storable output -- run through
# the same haro.exe, the same cache and the same working-directory convention as
# every file in the sweep. Its time with a live prefix is measured ONCE at
# startup, when the prefix is known good because it was just built, and every
# later reading is compared against that control rather than against a number
# written here by hand.
#
# DEFECT 7, found 2026-11-28 by reading the rail's own log rather than trusting
# it. The control must be measured under the SAME conditions as the readings it
# will be compared against, and the first haro.exe call of a run is not: at
# 17:54 the control came back 75.9 s, while the two live readings hours later
# were 3.1 s and 3.7 s. A ~20x inflated control put the stopping threshold at
# 759 s per file, and a genuinely dropped prefix costs about 330 s -- so the
# rail could continue correctly and could no longer STOP at all. It had become
# a rail that only ever says yes, which reads on a log exactly like a rail that
# is working.
#
# The cure is to throw the first reading away and keep the second. Whatever
# makes the first call expensive -- the 30.8 MB prefix image not yet in the OS
# file cache, this file's own per-root image absent, ambient load from the
# desk that just handed the machine over -- the second reading is taken the way
# every later reading is taken, and that is the only property the control needs.
# The threshold is printed, because a rail whose number nobody can read is the
# same class of defect as the one above it.
# DEFECT 8, found 2026-11-28 by reading the fix for DEFECT 7 in its own log.
# The repaired control came back at exactly 2.0 s -- the floor -- so the raw
# warm reading was at or under 2 s and the clamp caught it. Then the stopping
# threshold became 2.0 x 10 = 20.0 s, which is ABORT_RATE: the trigger and the
# verdict had landed on the same number, not by design but because a clamp and
# a multiplier happened to meet there. A threshold that arrives by coincidence
# is not a threshold, and this one sat only 5x above the warm readings actually
# observed (3.1, 3.7 and 4.2 s across six hours) while a genuine drop measures
# 150 to 330 s. That is a false STOP waiting for a loaded machine -- the exact
# failure that cost 147 topics, rebuilt from the other direction.
#
# So the verdict now carries an absolute floor as well as a ratio. 60 s sits
# far above every warm reading this corpus has produced, including after a
# cache trim, and far below the 149.7 s that a cold prefix cost this very run.
# Nothing between 20 and 150 s is evidence of anything, and the rail now
# declines to rule there instead of guessing.
CANARY = 'numbrex/25_extracting_digit_list.ring'
CANARY_FACTOR = 10.0       # a dropped prefix costs ~330 s against a few seconds
CANARY_FLOOR = 2.0         # so a freakishly fast control cannot over-tighten it
CANARY_STOP_MIN = 60.0     # and no reading under this is ever read as a drop


def canary():
    """Seconds for one tiny known-good root. Measures the prefix, not a topic."""
    rel = CANARY.split('/')
    path = os.path.join(TESTS, *rel)
    if not os.path.isfile(path):
        return None
    t = time.time()
    try:
        subprocess.run([HARO, rel[-1]],
                       cwd=os.path.dirname(path), env=env,
                       stdin=subprocess.DEVNULL,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                       timeout=600)
    except (subprocess.TimeoutExpired, OSError):
        return None
    return time.time() - t


def count_files(topic):
    try:
        return len([f for f in os.listdir(os.path.join(TESTS, topic))
                    if f.endswith('.ring')])
    except OSError:
        return 0


note('=== resume %s: %d topics to sweep, %d already swept, excluding %s ==='
     % (time.strftime('%H:%M:%S'), len(order), len(swept),
        ','.join(sorted(EXCLUDE)) or '(nothing)'))
note('    sweep drive free %.1f GB' % free_gb(WORK))

# The control, taken while the prefix is known live because it was just built.
# TWO readings, and the second is the control: see DEFECT 7 above.
CANARY_WARMUP = canary()
CANARY_BASE = canary()
if CANARY_BASE is None:
    note('    canary %s did not run; the prefix check is DISABLED for this run '
         'and a slow topic will not be able to stop the sweep.' % CANARY)
else:
    CANARY_BASE = max(CANARY_BASE, CANARY_FLOOR)
    note('    canary %s: %.1f s with a live prefix (the control; first call was '
         '%s, discarded as warm-up). A topic over %.1f s/file will re-run it, '
         'and the sweep stops only if it then exceeds %.1f s.'
         % (CANARY, CANARY_BASE,
            '%.1f s' % CANARY_WARMUP if CANARY_WARMUP is not None else 'not run',
            ABORT_RATE, max(CANARY_BASE * CANARY_FACTOR, CANARY_STOP_MIN)))

t_start = time.time()
tot_files = tot_seeded = tot_refused = tot_skipped = 0

for i, topic in enumerate(order, 1):
    n_expected = count_files(topic)
    # Derived from the file count now that the per-file bound is real: 180 s per
    # file is renders.py's own cap, and a render-shaped file runs twice.
    budget = max(900, int(n_expected * 200) + 300)

    if free_gb(WORK) < MIN_FREE_GB:
        note('STOPPING before %s: the sweep drive has %.1f GB free, under the '
             '%.1f GB floor. A sweep must not be the reason a page file cannot '
             'grow, so this stops rather than trims further.'
             % (topic, free_gb(WORK), MIN_FREE_GB))
        break

    freed = trim_cache()
    if freed:
        note('    cache trimmed: %.2f GB of per-root images dropped, prefix kept'
             % (freed / (1024.0 ** 3)))

    t0 = time.time()
    timed_out = False
    try:
        p = subprocess.run([sys.executable, '-I', 'renders.py', topic, '--seed'],
                           cwd=META, env=env, capture_output=True,
                           encoding='utf-8', errors='replace', timeout=budget)
        out = (p.stdout or '') + (p.stderr or '')
        rc = p.returncode
    except subprocess.TimeoutExpired as e:
        timed_out = True
        out = ''
        for stream in (e.stdout, e.stderr):
            if stream:
                out += stream if isinstance(stream, str) else stream.decode('utf-8', 'replace')
        rc = None
    el = time.time() - t0

    files = seeded = refused = skipped = 0
    secs = el
    m = SUMMARY.search(out)
    if m:
        files, secs = int(m.group(2)), float(m.group(3))
    m2 = COUNTS.search(out)
    if m2:
        seeded, refused, skipped = (int(m2.group(1)), int(m2.group(2)), int(m2.group(3)))
    # Fallback, so the rate rail works even when the summary line is absent --
    # which is exactly the case when the run was killed.
    if not files:
        files = (seeded + refused + skipped) or n_expected

    rate = (secs / files) if files else 0.0
    tot_files += files
    tot_seeded += seeded
    tot_refused += refused
    tot_skipped += skipped

    if timed_out:
        # DEFECT 4: this row is the whole point. A burn must leave a trace.
        row(i, topic + ' TIMED-OUT', files, secs, rate, seeded, refused, skipped)
        note('[%3d/%3d] %-26s TIMED OUT after %.0f s of a %d s budget (%d files)'
             % (i, len(order), topic, el, budget, n_expected))
        note('   The topic is NOT recorded as swept, so a rerun retries it; the '
             'artefacts it did write are kept and --seed will skip them.')
        continue

    row(i, topic, files, secs, rate, seeded, refused, skipped)
    with io.open(SWEPT, 'a', encoding='utf-8', newline='') as fh:
        fh.write(topic + NL)      # only AFTER it finished, so a kill retries it

    note('[%3d/%3d] %-26s %4d files %6.1fs %5.2fs/f  seeded %3d  refused %2d  skip %3d'
         % (i, len(order), topic, files, secs, rate, seeded, refused, skipped))

    if rc not in (0, 1):
        note('   note: renders.py exited %s' % rc)
        for l in [x for x in out.split(NL) if x.strip()][-4:]:
            note('   | ' + l[:150])

    # The proxy only TRIGGERS; the canary decides. See the note above canary().
    if files >= 5 and rate > ABORT_RATE and CANARY_BASE is not None:
        c = canary()
        if c is None:
            note('   %s ran at %.2f s/file and the canary could not be run, so the '
                 'cause is unverified. Continuing, because stopping on an '
                 'unverified cause is what cost 147 topics once already.'
                 % (topic, rate))
        elif c > max(CANARY_BASE * CANARY_FACTOR, CANARY_STOP_MIN):
            note('')
            note('STOPPING after %s: the canary took %.1f s against the %.1f s '
                 'control, %.0fx slower, so the library prefix in %s HAS been '
                 'dropped -- a session changed a library file or haro.exe and '
                 'every root now pays a whole compile.'
                 % (topic, c, CANARY_BASE, c / CANARY_BASE, CACHE))
            note('Rebuild the prefix and run this again: every topic already '
                 'swept is recorded and will be skipped.')
            break
        else:
            note('   %s ran at %.2f s/file, over the %.1f s trigger, but the canary '
                 'returned in %.1f s against a %.1f s control -- the prefix is '
                 'live. A slow topic, not a dropped prefix. Continuing.'
                 % (topic, rate, ABORT_RATE, c, CANARY_BASE))

note('')
note('=== ran %.1f min; files %d  seeded %d  refused %d  skipped %d ==='
     % ((time.time() - t_start) / 60.0, tot_files, tot_seeded, tot_refused, tot_skipped))
note('    sweep drive free %.1f GB' % free_gb(WORK))
