load "../../stzBase.ring"

# PERFORMANCE-REGRESSION GUARD
#
# Times the hot engine-backed list ops at scale and FAILS if any exceeds a
# generous threshold. Thresholds sit well above the measured (unboxed) times
# but well below the pre-optimization / pathological numbers, so this catches
# real regressions -- e.g. losing dense int-mode (Sum was ~1.25s boxed), or the
# O(n^2) dedup that effectively hung -- without flaking on machine noise.
#
# Prints actual times + "N pass, M fail"; the test sweep flags regressions and a
# human can watch for drift. Generous by design.

N = 1000000
nFail = 0

# --- shared inputs (built once; build time is NOT measured) ---
anNums   = Q(1:N)                                  # 1M distinct ints
afFloats = Q( Q([1.5]) * N )                       # 1M floats (flat-tiled)
aStrMix  = Q( Q([ "alpha","beta","gamma" ]) * (N / 3) )  # ~1M strings, 3 groups
acDistinct = []
for i = 1 to 50000 acDistinct + ("key_" + i) next  # 50k distinct strings

? "=== perf guard (N=" + N + ") ==="

# int Sum  (boxed regression -> ~1.25s)
t1=clock() s = anNums.Sum() t2=clock()
if chkT("int Sum", (t2-t1)/clockspersecond(), 0.6) nFail++ ok

# int Min/Max/Mean
t1=clock() anNums.Min() anNums.Max() anNums.Mean() t2=clock()
if chkT("int Min+Max+Mean", (t2-t1)/clockspersecond(), 1.0) nFail++ ok

# int Sort (fresh copy each so we actually sort 1M)
o = Q(N:1)
t1=clock() o.Sort() t2=clock()
if chkT("int Sort", (t2-t1)/clockspersecond(), 2.0) nFail++ ok

# int Reverse
o = Q(1:N)
t1=clock() o.Reverse() t2=clock()
if chkT("int Reverse", (t2-t1)/clockspersecond(), 1.5) nFail++ ok

# int Count/Find (Ring-helper regression -> ~0.27s; dense -> ~0.04s)
t1=clock() anNums.NumberOfOccurrences(999999) t2=clock()
if chkT("int Count", (t2-t1)/clockspersecond(), 1.0) nFail++ ok

# HIGH-CARDINALITY dedup (O(n^2) regression -> effectively hangs)
o = Q(1:N)
t1=clock() o.RemoveDuplicates() t2=clock()
if chkT("int Dedup (1M distinct)", (t2-t1)/clockspersecond(), 3.0) nFail++ ok

# set-ops
t1=clock() u = anNums.UnionWith(500001:1500000) t2=clock()
if chkT("int UnionWith", (t2-t1)/clockspersecond(), 6.0) nFail++ ok
t1=clock() x = anNums.IntersectWith(500001:1500000) t2=clock()
if chkT("int IntersectWith", (t2-t1)/clockspersecond(), 5.0) nFail++ ok

# float Sum (boxed -- no dense-int fast path, so ~0.7s is normal, not a
# regression; the 0.6s copied from int Sum was too tight and flaked)
t1=clock() afFloats.Sum() t2=clock()
if chkT("float Sum", (t2-t1)/clockspersecond(), 2.0) nFail++ ok

# string dedup (50k distinct)
o = Q(acDistinct)
t1=clock() o.RemoveDuplicates() t2=clock()
if chkT("string Dedup (50k distinct)", (t2-t1)/clockspersecond(), 2.0) nFail++ ok

# classify ~1M strings into 3 groups
t1=clock() cl = aStrMix.Classify() t2=clock()
if chkT("string Classify (1M)", (t2-t1)/clockspersecond(), 6.0) nFail++ ok

? "================================================"
? "PERF GUARD: " + (11 - nFail) + " pass, " + nFail + " fail"
if nFail = 0 ? "STATUS: OK" else ? "STATUS: FAIL" ok
? "================================================"

func chkT cName, nSecs, nThresh
    cMark = "ok  "
    if nSecs > nThresh cMark = "SLOW" ok
    ? "  [" + cMark + "] " + cName + " = " + nSecs + "s  (limit " + nThresh + "s)"
    return nSecs > nThresh
