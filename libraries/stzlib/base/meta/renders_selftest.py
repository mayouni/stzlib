# PROBE for the pure half of renders.py -- no haro, no subprocess, no machine.
#
# PX.md: "a new guard section is born standalone, relayed in only when green."
# The rails in renders.py (the noise stripper, the render classifier, the four
# refusal reasons) are where the bugs would hide, and every one of them is a pure
# function of a list of strings. So they can be judged tonight while the machine
# belongs to other desks.
#
# And every case below includes the FAILING direction as well as the passing one:
# a rail nobody has watched refuse is not a rail. promises.py carries the same
# note for the same reason ("a harness nobody has watched fail is not evidence").

import importlib.util
import io
import os
import sys
import time

# Derived from THIS file's location, never written absolutely: the tree this
# probe lives in is the tree it must judge (promises.py:52 paid for the other
# way round -- an absolute ROOT meant a worktree silently graded the main
# checkout), and an absolute path on this machine may not enter a public
# repository at all.
SPEC = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'renders.py')
spec = importlib.util.spec_from_file_location('renders', SPEC)
R = importlib.util.module_from_spec(spec)
spec.loader.exec_module(R)   # safe: renders.py has a __main__ guard. promises.py
                             # does NOT, which is how I once ran the whole harness
                             # by importing it beside a live control run.

NL = chr(10)
ok = bad = 0


def check(label, got, want):
    global ok, bad
    if got == want:
        ok += 1
    else:
        bad += 1
        print('  FAIL  %s' % label)
        print('        got  %r' % (got,))
        print('        want %r' % (want,))


print('=== strip_noise ===')
check('drops the profiler line',
      R.strip_noise(['value', 'Executed in 0.43 second(s)']), ['value'])
check('drops the pf() success banner',
      R.strip_noise(['value', 'STOPPED!']), ['value'])
check('drops a pf() stack trace',
      R.strip_noise(['value', 'In raise()', 'In function stop() in file x',
                     'Called from line 18 In function pf() in file y']), ['value'])
check('drops the v0.78 cold-compile note',
      R.strip_noise(['value',
                     "note: the top level's own body compiled, but it calls functions",
                     '      that did not. Running it measures how far it gets, and a',
                     '      result it produces is NOT certified correct.']), ['value'])
check('trims blank lines at both ends',
      R.strip_noise(['', '  ', 'a', 'b', '', '']), ['a', 'b'])
check('KEEPS a blank line in the middle (a render has them)',
      R.strip_noise(['a', '', 'b']), ['a', '', 'b'])
check('KEEPS real content that merely mentions a line number',
      R.strip_noise(['Line 3 of the poem']), ['Line 3 of the poem'])
check('trailing spaces are normalised, not the line',
      R.strip_noise(['a   ']), ['a'])

print('=== is_render ===')
BOX = chr(0x250c) + chr(0x2500) * 4 + chr(0x2510)
check('box drawing in one line is a render', R.is_render([BOX, 'x']), True)
check('eleven lines is a render', R.is_render(['l%d' % i for i in range(11)]), True)
check('exactly ten lines is NOT', R.is_render(['l%d' % i for i in range(10)]), False)
check('three lines is NOT', R.is_render(['a', 'b', 'c']), False)
check('blank lines do not pad a file into a render',
      R.is_render(['a'] + [''] * 20), False)

print('=== unstorable: the four refusals ===')
check('empty output', R.unstorable([]), 'prints nothing')
check('whitespace-only output', R.unstorable(['', '   ']), 'prints nothing')
check('a raise is refused',
      R.unstorable(['Error (R14) blah']).startswith('it raises'), True)
check('an absolute path is refused',
      'absolute path' in R.unstorable(['out: C:/Users/somebody/thing/file.txt']), True)
check('this machine own base dir is refused',
      R.unstorable([R.BASE_DIR + '/test/x']) != '', True)
today = time.strftime('%Y-%m-%d')
check("today's date is refused",
      "today's date" in R.unstorable(['generated on ' + today]), True)
check("today's month name is refused",
      "today's date" in R.unstorable([time.strftime('%B %Y')]), True)
check('a clean render is STORABLE', R.unstorable([BOX, 'Mon Tue Wed', BOX]), '')
check('a FIXED old date is storable',
      R.unstorable(['1990-01-15']), '')

print('=== digest ===')
check('stable across calls', R.digest(['a', 'b']), R.digest(['a', 'b']))
check('order matters', R.digest(['a', 'b']) == R.digest(['b', 'a']), False)
check('16 hex chars', len(R.digest(['a'])), 16)
check('a trailing blank changes it (so padding drift is caught)',
      R.digest(['a']) == R.digest(['a', '']), False)

print('=== calls_declared: the library own not-run-here marker ===')
import tempfile
fd, probe = tempfile.mkstemp(suffix='.ring')
os.close(fd)
DECLARED = {'view': 'graph/stzDiagram.ring:17988',
            'executeandview': 'extercode/stzDotCode.ring:298'}


def write_probe(text):
    with io.open(probe, 'w', encoding='utf-8') as fh:
        fh.write(text)
    return probe


check('a file calling View() is caught',
      R.calls_declared(write_probe('oDiag = new stzDiagram()' + NL + 'oDiag.View()'),
                       DECLARED) is not None, True)
check('the reason names the method and where it is declared',
      R.calls_declared(write_probe('oDiag.View()'), DECLARED),
      ('View', 'graph/stzDiagram.ring:17988'))
check('case does not matter, since Ring is case-insensitive',
      R.calls_declared(write_probe('oDiag.view()'), DECLARED) is not None, True)
# THE FAILING DIRECTION, and the one that matters most: a console print must NOT
# be refused. `.Show()` on a table prints the render this gate exists to store,
# and a first guess at method names matched it in 239 files.
check('a file calling Show() is NOT refused',
      R.calls_declared(write_probe('oTable.Show()'), DECLARED), None)
check('a plain print is NOT refused',
      R.calls_declared(write_probe('? "hello"'), DECLARED), None)
check('an empty declared set refuses nothing',
      R.calls_declared(write_probe('oDiag.View()'), {}), None)
try:
    os.unlink(probe)
except OSError:
    pass

print('=== not_run_here: read from the library, never a list in this file ===')
DECL = R.not_run_here()
check('the walk finds at least ten declared methods', len(DECL) >= 10, True)
check('View is among them', 'view' in DECL, True)
check('Display is among them', 'display' in DECL, True)
check('ExecuteAndView is among them', 'executeandview' in DECL, True)
# Show must NOT be declared: if it ever is, the gate would refuse the corpus and
# this case is the alarm rather than a silent collapse of coverage.
check('Show is NOT declared not-run-here', 'show' in DECL, False)
check('each entry says where it was declared',
      all(':' in v for v in DECL.values()), True)

print('=== store paths stay inside the tree ===')
p = R.store_path('09_test_8_display_options.ring')
check('a .ring becomes a .out', p.endswith('09_test_8_display_options.out'), True)
check('it lands under test/_renders',
      os.path.normpath(R.STORE).endswith(os.path.join('test', '_renders')), True)
check('the artefact is under the store',
      os.path.normpath(p).startswith(os.path.normpath(R.STORE)), True)

print()
print('%d passed, %d failed' % (ok, bad))
sys.exit(1 if bad else 0)
