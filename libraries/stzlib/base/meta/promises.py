# Run the library's own recorded expectations.
#
# Thousands of test files carry lines like
#
#     ? o1.FindNext("ARABIC HA", :StartingAt = 1)        #--> 110819
#
# The value after #--> is what the library PROMISES that line prints. Nothing
# has ever compared the two. This runs each file, captures stdout, and walks the
# expectations against the output IN ORDER -- extra output (banners, multi-line
# prints, profiler noise) is skipped over, but the promises must appear in the
# order the file makes them.
#
# Ordered-subsequence rather than line-for-line, because one `?` can print
# several lines and the suites print banners of their own. It is deliberately
# forgiving: a MISSING verdict means the promised text appears NOWHERE in the
# remaining output, which is a strong signal.

import io, os, re, subprocess, sys, collections

RING = "D:/ring127/bin/ring.exe"
TOPIC = sys.argv[1] if len(sys.argv) > 1 else "char"

# A topic name, or an explicit directory. The second form exists so the
# harness can be pointed at a scratch folder of DELIBERATELY WRONG promises
# -- see below. A harness nobody has watched fail is not evidence.
if ':' in TOPIC or '/' in TOPIC or os.path.isdir(TOPIC):
    ROOT = TOPIC
else:
    ROOT = "D:/GitHub/stzlib/libraries/stzlib/base/test/" + TOPIC

TRAILING = re.compile(r'^\s*\?.*?#-->\s*(.+?)\s*$')

# A promise that argues with itself is a NOTE, not an expectation.
#
#     #--> "C" but should be "sm_AS"
#     #--> NULL! (see why)
#     #--> expected "...Gary!" (currently leaves "{cName}" verbatim)
#
# Someone reconciled these by hand and wrote the verdict in prose. Several
# record defects that have SINCE BEEN FIXED -- the library now returns sm_AS --
# so reading them as expectations accuses it of the very bug it no longer has.
# They are worth reporting as documentation debt, and must not be counted as
# divergences.
PROSE = re.compile('(but should|should be|should return|see why|currently|'
                   'instead of|expected |archive|deferred|TODO|typo)', re.I)


# The console here is cp1252, and this library's promises are full of Arabic,
# Hebrew, CJK and emoji -- printing one raw killed the whole run with a
# UnicodeEncodeError, AFTER the work was done. Escape on the way out: the
# report stays ASCII (which is the house rule for console output anyway) and
# the codepoint is still readable.
def safe(s):
    return s.encode('ascii', 'backslashreplace').decode('ascii')


def norm(s):
    return re.sub(r'\s+', ' ', s).strip()


# LIST NOTATION IS THE SAME VALUE SPELLED TWO WAYS.
#
#     ? @@(aResults)   #--> [6, 28]
#     prints             [ 6, 28 ]
#
# @@() puts a space inside the brackets and the promise, written by hand,
# usually does not. Every list-valued promise in the library diverges on that
# alone. Collapsing whitespace around brackets, braces and commas -- and ONLY
# there -- makes the two comparable without touching prose, where removing
# spaces wholesale would invent matches that are not there.
_PUNCT_WS = re.compile(r'\s*([\[\]\,])\s*')


def canon(s):
    return _PUNCT_WS.sub(r'\1', s)


def variants(expected):
    """Every spelling the promised value could legitimately print as.

    Three of these were learned by watching the harness accuse the library of
    things it had not done:

      - a human note in parentheses -- '#--> FALSE (absent)' -- where the value
        is the part before it
      - RING PRINTS BOOLEANS AS 1 AND 0. A file promising TRUE prints '1', and
        reading that as a broken promise was most of one run's divergences
      - a promise is often quoted ('#--> "13"') where the print is not
    """
    seen = []

    def add(v):
        v = norm(v)
        if v and v not in seen:
            seen.append(v)

    add(expected)
    add(re.sub(r'\s*\([^)]*\)\s*$', '', expected))

    # ...and again cutting at the LAST ' (', for a note that contains
    # parentheses of its own: '(alias for Data())' defeats the pattern
    # above, which stops at the first ')' and leaves a ragged tail.
    if expected.rstrip().endswith(')') and ' (' in expected:
        add(expected[:expected.rindex(' (')])

    for base in list(seen):
        if base.startswith('"') and base.endswith('"') and len(base) > 1:
            add(base[1:-1])
        up = base.upper()
        if up == 'TRUE':
            add('1')
        elif up == 'FALSE':
            add('0')

        # A SYMBOL IS WRITTEN :Number AND PRINTS number.
        #
        # The colon is Ring source syntax, and the value comes out bare and
        # LOWERCASED. 41 promises are a bare :Symbol and another 29 are lists
        # of them; read literally, all of them diverge -- one file alone,
        # global/50_inferetype, accounted for 17. Both spellings are added,
        # rather than lowercasing everything, so case still matters wherever
        # the promise was not written as a symbol.
        if re.match(r'^:[A-Za-z][A-Za-z0-9_]*$', base):
            add(base[1:])
            add(base[1:].lower())
        if base.startswith('[') and ':' in base:
            add(re.sub(r'(?<![A-Za-z0-9_]):([A-Za-z][A-Za-z0-9_]*)',
                       lambda m: m.group(1).lower(), base))
    return seen


def expectations(path):
    src = io.open(path, encoding='utf-8', errors='replace', newline='').read().replace('\r\n', '\n')
    lines = src.split('\n')
    out = []
    for i, l in enumerate(lines):
        m = TRAILING.match(l)
        if not m:
            continue

        # A TRAILING #--> FOLLOWED BY A STANDALONE ONE IS A LABEL, not a value.
        #
        #     ? @@( o1 * 3 )   #--> Leads to a normal Ring list
        #     #--> [ 1, 2, 3, 1, 2, 3, 1, 2, 3 ]
        #
        # The first line says what the reader is about to see; the second is
        # what it is. Read literally, the label diverges every time -- and it
        # is not prose in any way a keyword list would catch ("Leads to a
        # normal Ring list" contains nothing suspicious). The SHAPE is what
        # gives it away, so the shape is what is read.
        nxt = lines[i + 1].strip() if i + 1 < len(lines) else ''
        if nxt.startswith('#-->'):
            continue

        out.append((i + 1, m.group(1)))
    return out


def run(path):
    try:
        p = subprocess.run([RING, os.path.basename(path)], cwd=os.path.dirname(path),
                           capture_output=True, timeout=120)
        return (p.stdout + p.stderr).decode('utf-8', 'replace').replace('\r\n', '\n').split('\n')
    except subprocess.TimeoutExpired:
        return None


matched = missing = 0
timeouts = []
didnotrun = []
notreached = 0
raisedfiles = {}
annotated = 0
notes = []
misses = []

files = sorted(f for f in os.listdir(ROOT) if f.endswith('.ring') and not f.startswith('_'))
for fn in files:
    path = os.path.join(ROOT, fn)
    exp = expectations(path)
    if not exp:
        continue
    out = run(path)
    if out is None:
        timeouts.append(fn)
        continue

    # A FILE THAT DID NOT COMPILE HAS NOT BROKEN ANY PROMISE.
    #
    # The first run of this harness reported 277 divergences out of 286 -- a 97%
    # failure rate that was entirely one unrelated file failing to parse, so
    # nothing ran at all. A harness that cannot tell "the library is wrong" from
    # "the library did not load" is worse than no harness: it is confidently
    # wrong at scale. Ring compile errors are C-numbered -- and SCANNER
    # errors are S-numbered, which this check originally missed: number/75
    # died "Error (S2) Unclosed comment" and its three unreached promises
    # were reported as divergences.
    # ...but only when the FILE failed, not when an eval() inside it did.
    # Ring prefixes the latter with "eval ", and a W-condition that fails
    # to parse is a finding about that condition, not a file that never
    # ran -- listofstrings/50 runs fine and simply matches nothing.
    joined = chr(10).join(l for l in out if not l.lstrip().startswith('eval '))
    if re.search(r'Error \([CS][0-9]+\)', joined):
        didnotrun.append(fn)
        continue

    # NOR HAS A FILE RING COULD NOT OPEN AT ALL. E9 is "Can't open
    # file", and it fires on this library's own test names: Ring opens
    # paths through the ANSI code page, so a filename carrying Arabic or
    # Gujarati arrives mangled and the interpreter never sees the file.
    # Its promises are unknown, not broken.
    if re.search(r'Error \(E9\)', joined):
        didnotrun.append(fn)
        continue

    nout = [norm(x) for x in out]

    # A FILE THAT RAISED PART-WAY THROUGH DID NOT BREAK EVERY PROMISE BELOW.
    #
    # 62_isdiacritic.ring raises R14 at line 12 -- IsDiacritic() does not exist
    # -- and the twenty expectations under it were never reached. Counting them
    # as divergences turns ONE finding into twenty and buries it. The raise is
    # the finding; everything after it is unknown, not wrong.
    raised = re.search(r'Error \(R[0-9]+\)[^\n]*', chr(10).join(out))

    pos = 0
    for lineno, raw in exp:
        if PROSE.search(raw):
            annotated += 1
            notes.append((fn, lineno, raw))
            continue
        # A SHORT PROMISE IS NOT SEARCHED FOR AS A SUBSTRING.
        #
        # Caught by planting deliberate lies: `#--> 6` against a real answer of
        # 3 was recorded as KEPT, because "6" occurs inside a later line
        # reading "[ 6, 28 ]". Three of four planted lies were caught and this
        # one was not -- a promise short enough to hide inside any number,
        # date or list is unfalsifiable by containment.
        #
        # Short promises must EQUAL the line. Longer ones stay substring-
        # matched, because a `?` often prints a label with the value.
        # `#--> ERROR: <message>` MEANS "THIS LINE RAISES", not "this line
        # prints the word ERROR". 28 promises in the library use the
        # convention, and every one of them was being read as a divergence --
        # the library was doing exactly what was asked and being marked wrong
        # for it. The raise arrives as `Line NNNN <message>`, so the message
        # is what to look for, not the prefix.
        _m_err = re.match(r'\s*ERRORS?\s*[:!]\s*(.+)$', raw, re.I)
        if _m_err:
            msg = norm(_m_err.group(1)).strip('"').strip("'")
            if msg and any(msg in x for x in nout[pos:]):
                matched += 1
                continue
            missing += 1
            misses.append((fn, lineno, raw))
            continue

        # `#--> ''` is how these files write "prints nothing". An empty line
        # is the whole observation, and no substring search can express it.
        if norm(raw) in ("''", '""'):
            hit = -1
            for k in range(pos, len(nout)):
                if nout[k] == '':
                    hit = k
                    break
            if hit >= 0:
                matched += 1
                pos = hit + 1
            else:
                missing += 1
                misses.append((fn, lineno, raw))
            continue

        found = -1
        for cand in variants(raw):
            if not cand:
                continue
            ccand = canon(cand)
            loose = len(ccand) >= 5
            for k in range(pos, len(nout)):
                line = nout[k]
                cline = canon(line)
                if ccand == cline or cand == line:
                    found = k
                    break
                if loose and (cand in line or ccand in cline):
                    found = k
                    break
            if found >= 0:
                break

        # A LIST PRINTED WITHOUT @@() ARRIVES ONE ELEMENT PER LINE.
        #
        # `? aList` gives a line per item, so a promise written as [a, b, c]
        # appears NOWHERE in any single line. Join a forward window and try
        # again -- the window is bounded so a promise can never be satisfied
        # by scavenging matching fragments from across the whole run.
        if found < 0 and raw.lstrip().startswith('['):
            # A LIST PRINTED WITHOUT @@() ARRIVES ONE ELEMENT PER LINE, BARE.
            #
            #     ? StzCharQ("A").UpTo("E")   #--> [ "A", "B", "C", "D", "E" ]
            #     prints  A / B / C / D / E   -- five lines, no quotes
            #
            # So the promise appears in no single line, and joining a window
            # does not work either: the run continues into the NEXT print, so
            # a closing bracket never lines up. Compare item by item against
            # exactly as many non-blank lines as the promise has items -- that
            # is both permissive about quoting and strict about CONTENT and
            # ORDER, which is what a list promise is actually claiming.
            inner = canon(variants(raw)[0])
            items = []
            if inner.startswith('[') and inner.endswith(']'):
                items = [x.strip().strip('"').strip("'")
                         for x in inner[1:-1].split(',') if x.strip() != '']

            if items:
                n = len(items)
                for k in range(pos, len(nout)):
                    seg = []
                    j = k
                    while j < len(nout) and len(seg) < n:
                        if nout[j] != '':
                            seg.append(nout[j].strip('"').strip("'"))
                        j += 1
                    if len(seg) < n:
                        break
                    if seg == items:
                        found = j - 1
                        break
        if found >= 0:
            matched += 1
            pos = found + 1
        elif raised:
            notreached += 1
            if fn not in raisedfiles:
                raisedfiles[fn] = (lineno, raised.group(0).strip())
        else:
            missing += 1
            misses.append((fn, lineno, raw))
            # ONE DIVERGENCE MUST NOT SWALLOW THE NEXT PROMISE'S LINE.
            #
            # Without this the walk stays put, so the FOLLOWING promise can
            # match the output the failed one should have taken and be
            # recorded as kept. Planted proof: two consecutive wrong symbol
            # promises, and only the first was caught. Consuming one line is
            # the minimum a `?` can have printed.
            if pos < len(nout):
                pos += 1

print("=" * 68)
print("PROMISES RUN -- topic '%s'" % TOPIC)
print("=" * 68)
print("  files with expectations : %d" % len([f for f in files if expectations(os.path.join(ROOT, f))]))
print("  expectations checked    : %d" % (matched + missing))
print("  kept its promise        : %d" % matched)
print("  DIVERGED                : %d" % missing)
if timeouts:
    print("  timed out (not checked) : %d  %s" % (len(timeouts), ', '.join(safe(x) for x in timeouts[:4])))
if didnotrun:
    print("  DID NOT COMPILE         : %d  %s" % (len(didnotrun), ', '.join(safe(x) for x in didnotrun[:4])))
    print("     (nothing ran in these -- they are not divergences)")
if raisedfiles:
    print("  RAISED part-way        : %d files, %d expectations never reached" % (len(raisedfiles), notreached))
if annotated:
    print("  annotated in prose      : %d  (a note, not a checkable promise)" % annotated)
print()
if raisedfiles:
    print("-- files that RAISED (one finding each, not one per expectation) --")
    for fn in sorted(raisedfiles):
        ln, err = raisedfiles[fn]
        print("   %-44s from line %s" % (fn, ln))
        print("      %s" % err[:100])
    print()
by = collections.Counter(m[0] for m in misses)
print("-- divergences, by file --")
for fn, n in by.most_common():
    print("   %-52s %d" % (safe(fn), n))
print()
print("-- every divergence, in full --")
for fn, lineno, raw in misses:
    print("   %s:%d" % (safe(fn), lineno))
    print("      promised: %s" % safe(raw)[:150])
