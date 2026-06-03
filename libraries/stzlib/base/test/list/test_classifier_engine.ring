load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzListClassifier Engine Delegation Tests ==="

# --- Classify ---
? ""
? "--- Classify ---"

o = new stzList(["a", "b", "a", "c", "b", "a"])
oClf = new stzListClassifier(o)

nTtl++
aClasses = oClf.Classes()
if len(aClasses) = 3
	? "  PASS: Classes() = 3 classes"
	nPsd++
else
	? "  FAIL: Classes() expected 3, got " + len(aClasses)
	nFld++
ok

nTtl++
if oClf.NumberOfClasses() = 3
	? "  PASS: NumberOfClasses() = 3"
	nPsd++
else
	? "  FAIL: NumberOfClasses()"
	nFld++
ok

# --- Frequencies ---
? ""
? "--- Frequencies ---"

nTtl++
aFreqs = oClf.Frequencies()
if len(aFreqs) = 3
	? "  PASS: Frequencies() has 3 entries"
	nPsd++
else
	? "  FAIL: Frequencies()"
	nFld++
ok

# --- MostFrequent / LeastFrequent ---
? ""
? "--- MostFrequent / LeastFrequent ---"

nTtl++
if oClf.MostFrequent() = "a"
	? "  PASS: MostFrequent() = a"
	nPsd++
else
	? "  FAIL: MostFrequent() = " + oClf.MostFrequent()
	nFld++
ok

nTtl++
if oClf.LeastFrequent() = "c"
	? "  PASS: LeastFrequent() = c"
	nPsd++
else
	? "  FAIL: LeastFrequent() = " + oClf.LeastFrequent()
	nFld++
ok

# --- FrequencyOf ---
? ""
? "--- FrequencyOf ---"

nTtl++
if oClf.FrequencyOf("a") = 3
	? "  PASS: FrequencyOf('a') = 3"
	nPsd++
else
	? "  FAIL: FrequencyOf('a') = " + oClf.FrequencyOf("a")
	nFld++
ok

nTtl++
if oClf.FrequencyOf("c") = 1
	? "  PASS: FrequencyOf('c') = 1"
	nPsd++
else
	? "  FAIL: FrequencyOf('c')"
	nFld++
ok

# --- ItemsAppearingNTimes ---
? ""
? "--- ItemsAppearingNTimes ---"

nTtl++
aOnce = oClf.ItemsAppearingNTimes(1)
if len(aOnce) = 1
	? "  PASS: ItemsAppearingNTimes(1) = 1 item"
	nPsd++
else
	? "  FAIL: ItemsAppearingNTimes(1)"
	nFld++
ok

nTtl++
aMoreThan1 = oClf.ItemsAppearingMoreThanNTimes(1)
if len(aMoreThan1) = 2
	? "  PASS: ItemsAppearingMoreThanNTimes(1) = 2 items"
	nPsd++
else
	? "  FAIL: ItemsAppearingMoreThanNTimes(1)"
	nFld++
ok

# --- Mode ---
? ""
? "--- Mode ---"

nTtl++
aMode = oClf.Mode()
if len(aMode) = 1 and aMode[1] = "a"
	? "  PASS: Mode() = ['a']"
	nPsd++
else
	? "  FAIL: Mode()"
	nFld++
ok

# --- Bisect ---
? ""
? "--- Bisect ---"

o2 = new stzList([1, 2, 3, 4, 5, 6])
oClf2 = new stzListClassifier(o2)

nTtl++
aHalves = oClf2.Bisect()
if len(aHalves) = 2 and len(aHalves[1]) = 3 and len(aHalves[2]) = 3
	? "  PASS: Bisect([1..6]) = two halves of 3"
	nPsd++
else
	? "  FAIL: Bisect()"
	nFld++
ok

# --- Partition ---
? ""
? "--- Partition ---"

nTtl++
aParts = oClf2.Partition(3)
if len(aParts) = 3
	? "  PASS: Partition(3) = 3 groups"
	nPsd++
else
	? "  FAIL: Partition(3)"
	nFld++
ok

# --- Chunks (engine-backed) ---
? ""
? "--- Chunks (engine-backed) ---"

nTtl++
aChunks = oClf2.Chunks(2)
if len(aChunks) = 3
	? "  PASS: Chunks(2) on 6 items = 3 chunks"
	nPsd++
else
	? "  FAIL: Chunks(2)"
	nFld++
ok

? ""
? "=========================="
? "Total: " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok

pf()
