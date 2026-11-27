# PROBE for the ONE defect that cost two hours on 2026-11-27 -- and it uses no
# haro, no library and no engine, so it can run while another desk owns the
# machine. PX.md: "a new guard section is born standalone."
#
# THE DEFECT. renders.py ran each test file with subprocess.run(
# capture_output=True, timeout=180). diagram/41_import_as_subdiagram.ring calls
# oDiag.View(), which shells out to graphviz and then to the system viewer. Those
# GRANDCHILDREN inherit the write end of the captured pipe. When the timeout
# fires, subprocess.run kills the direct child and then drains the pipes -- and a
# pipe a surviving grandchild still holds never reaches EOF, so the drain blocks
# for ever. The 180-second bound was honoured by the clock and ignored by the
# process, and the run ended only when the DRIVER's two-hour topic timeout fired
# one level up.
#
# So the thing to prove is not "a timeout exists" -- one existed. It is "the
# timeout RETURNS when a grandchild holds the output open". That is a property of
# the plumbing, not of haro, so it can be proved with a synthetic child.
#
# THE SYNTHETIC CHILD exits immediately after spawning a grandchild that holds
# the inherited stdout and sleeps. That is diagram/41 with the library taken out.
# The grandchild sleeps GRANDCHILD_LIFE seconds rather than for ever, so the
# FAILING arm below terminates and can be measured instead of hanging this probe.

import io
import os
import subprocess
import sys
import tempfile
import time

TIMEOUT = 5.0              # the bound under test, scaled down from 180
GRANDCHILD_LIFE = 20       # 4x the bound: enough to tell a hang from a bound

CHILD = '''
import subprocess, sys, time
# Spawn a grandchild that INHERITS this process's stdout, then exit at once.
# Inheriting the handle is the whole mechanism: it is what graphviz and the
# system viewer do when a test calls View().
subprocess.Popen([sys.executable, '-I', '-c',
                  'import time; time.sleep(%d)'])
print('child printed this and exited', flush=True)
''' % GRANDCHILD_LIFE

NL = chr(10)
ok = bad = 0


def report(label, elapsed, returned, want_bounded):
    global ok, bad
    bounded = elapsed < TIMEOUT * 2
    good = (bounded == want_bounded)
    if good:
        ok += 1
    else:
        bad += 1
    print('  %-4s %-46s %6.2f s  %s'
          % ('ok' if good else 'FAIL', label, elapsed,
             'returned ' + repr(returned)[:40]))


def kill_tree(pid):
    if os.name == 'nt':
        subprocess.call(['taskkill', '/T', '/F', '/PID', str(pid)],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        subprocess.call(['pkill', '-9', '-P', str(pid)],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


fd, script = tempfile.mkstemp(suffix='.py')
os.close(fd)
with io.open(script, 'w', encoding='utf-8') as fh:
    fh.write(CHILD)

print('=== THE OLD SHAPE: a pipe, and a grandchild holding it ===')
print('    a %.0f s timeout against a grandchild that lives %d s' % (TIMEOUT, GRANDCHILD_LIFE))
t0 = time.time()
try:
    subprocess.run([sys.executable, '-I', script],
                   capture_output=True, timeout=TIMEOUT)
    outcome = 'completed'
except subprocess.TimeoutExpired:
    outcome = 'TimeoutExpired'
old = time.time() - t0
# The FAILING direction: this must NOT be bounded. If it ever comes back inside
# the bound, the defect is gone from Python itself and this probe is obsolete.
report('old shape respects its %.0f s timeout' % TIMEOUT, old, outcome, False)

print()
print('=== THE NEW SHAPE: a file sink, DEVNULL stdin, kill the tree ===')
fd, sinkpath = tempfile.mkstemp(suffix='.txt')
os.close(fd)
t0 = time.time()
try:
    with io.open(sinkpath, 'wb') as sink:
        p = subprocess.Popen([sys.executable, '-I', script],
                             stdin=subprocess.DEVNULL,
                             stdout=sink, stderr=subprocess.STDOUT)
        try:
            p.wait(timeout=TIMEOUT)
            outcome = 'completed'
        except subprocess.TimeoutExpired:
            kill_tree(p.pid)
            p.wait(timeout=30)
            outcome = 'TimeoutExpired'
    with io.open(sinkpath, 'rb') as fh:
        captured = fh.read().decode('utf-8', 'replace')
finally:
    for f in (sinkpath,):
        try:
            os.unlink(f)
        except OSError:
            pass
new = time.time() - t0
report('new shape returns inside its bound', new, outcome, True)

# AND IT MUST STILL CAPTURE THE OUTPUT. A bound that returns promptly by losing
# what the test printed would be a worse defect than the hang: every baseline in
# the store would silently become empty.
got = 'child printed this and exited' in captured
if got:
    ok += 1
    print('  ok   the file sink still captured the output')
else:
    bad += 1
    print('  FAIL the file sink lost the output: %r' % captured[:80])

# === THE ARM THAT MATTERS MOST, and the first run of this probe did not have it.
# Above, the synthetic child EXITS after spawning, so the new shape returned
# 'completed' and the kill_tree branch never ran. The real diagram/41 does not
# behave that way: haro calls ExecuteAndView, which BLOCKS until the viewer is
# closed, so the child is still alive when the bound expires and kill_tree is the
# branch that actually executes. An untaken branch is not a proven branch, so
# here is the blocking child -- and it must leave NOTHING behind, because a sweep
# of 5,416 files that orphans one process per viewer is its own defect.
print('=== THE REAL SHAPE: a child that BLOCKS on its grandchild ===')
BLOCKING = '''
import subprocess, sys, time
g = subprocess.Popen([sys.executable, '-I', '-c', 'import time; time.sleep(%d)'])
print('GRANDCHILD_PID=' + str(g.pid), flush=True)
g.wait()                      # this is ExecuteAndView blocking on the viewer
''' % GRANDCHILD_LIFE

fd, script2 = tempfile.mkstemp(suffix='.py')
os.close(fd)
with io.open(script2, 'w', encoding='utf-8') as fh:
    fh.write(BLOCKING)

fd, sink2 = tempfile.mkstemp(suffix='.txt')
os.close(fd)
t0 = time.time()
with io.open(sink2, 'wb') as sink:
    p = subprocess.Popen([sys.executable, '-I', script2],
                         stdin=subprocess.DEVNULL,
                         stdout=sink, stderr=subprocess.STDOUT)
    child_pid, grand = p.pid, None
    try:
        p.wait(timeout=TIMEOUT)
        outcome = 'completed'
    except subprocess.TimeoutExpired:
        kill_tree(child_pid)
        p.wait(timeout=30)
        outcome = 'TimeoutExpired'
blocking = time.time() - t0
report('blocking child is bounded and killed', blocking, outcome, True)

# AND NOTHING SURVIVES. Asked of the OS about the EXACT pid the child reported,
# not inferred from kill_tree's exit status -- taskkill reports success for a
# tree it only partly reached, and a command-line pattern match would need three
# layers of quoting to say what one pid says plainly.
time.sleep(1.0)
gpid = ''
try:
    with io.open(sink2, 'rb') as fh:
        for line in fh.read().decode('utf-8', 'replace').split(NL):
            if line.startswith('GRANDCHILD_PID='):
                gpid = line.split('=', 1)[1].strip()
except OSError:
    pass

if not gpid:
    bad += 1
    print('  FAIL the child never reported its grandchild pid, so survival is untested')
else:
    q = subprocess.run(['tasklist', '/FI', 'PID eq ' + gpid, '/NH'],
                       capture_output=True, encoding='utf-8', errors='replace')
    listing = (q.stdout or '') + (q.stderr or '')
    alive = gpid in listing
    if not alive:
        ok += 1
        print('  ok   the viewer process (pid %s) did not survive the kill' % gpid)
    else:
        bad += 1
        print('  FAIL the viewer (pid %s) survived -- a sweep of 5,416 files would '
              'orphan one per viewer' % gpid)

for f in (script, script2, sink2):
    try:
        os.unlink(f)
    except OSError:
        pass

print()
print('old shape %.2f s against a %.0f s timeout -- %.1fx over'
      % (old, TIMEOUT, old / TIMEOUT))
print('new shape %.2f s against a %.0f s timeout' % (new, TIMEOUT))
print('%d passed, %d failed' % (ok, bad))
sys.exit(1 if bad else 0)
