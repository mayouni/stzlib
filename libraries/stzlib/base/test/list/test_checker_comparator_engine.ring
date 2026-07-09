load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzListChecker & stzListComparator Engine Delegation Tests ==="

# --- ContainsItemCS (engine-backed) ---
? ""
? "--- ContainsCS ---"

o = new stzList([1, 2, 3, "hello", "world"])
nTtl++
if o.Contains(2) = 1
	? "  PASS: Contains(2) = true"
	nPsd++
else
	? "  FAIL: Contains(2)"
	nFld++
ok

nTtl++
if o.Contains(99) = 0
	? "  PASS: Contains(99) = false"
	nPsd++
else
	? "  FAIL: Contains(99)"
	nFld++
ok

nTtl++
if o.Contains("hello") = 1
	? "  PASS: Contains('hello') = true"
	nPsd++
else
	? "  FAIL: Contains('hello')"
	nFld++
ok

# --- ContainsAllOfThese ---
? ""
? "--- ContainsAllOfThese ---"

nTtl++
if o.ContainsAllOfThese([1, 3, "world"]) = 1
	? "  PASS: ContainsAllOfThese([1,3,'world']) = true"
	nPsd++
else
	? "  FAIL: ContainsAllOfThese"
	nFld++
ok

nTtl++
if o.ContainsAllOfThese([1, 99]) = 0
	? "  PASS: ContainsAllOfThese([1,99]) = false"
	nPsd++
else
	? "  FAIL: ContainsAllOfThese false case"
	nFld++
ok

# --- ContainsOneOfThese ---
? ""
? "--- ContainsOneOfThese ---"

nTtl++
if o.ContainsOneOfThese([99, "hello"]) = 1
	? "  PASS: ContainsOneOfThese([99,'hello']) = true"
	nPsd++
else
	? "  FAIL: ContainsOneOfThese"
	nFld++
ok

# --- IsEqualToCS (engine-backed) ---
? ""
? "--- IsEqualToCS (Checker) ---"

o = new stzList([1, 2, 3])
nTtl++
if o.IsEqualTo([1, 2, 3]) = 1
	? "  PASS: [1,2,3].IsEqualTo([1,2,3]) = true"
	nPsd++
else
	? "  FAIL: IsEqualTo same list"
	nFld++
ok

nTtl++
if o.IsEqualTo([1, 2, 4]) = 0
	? "  PASS: [1,2,3].IsEqualTo([1,2,4]) = false"
	nPsd++
else
	? "  FAIL: IsEqualTo different list"
	nFld++
ok

# --- IsStrictlyEqualToCS (Comparator, engine-backed) ---
? ""
? "--- IsStrictlyEqualToCS ---"

o = new stzList(["A", "B", "C"])
nTtl++
if o.IsStrictlyEqualTo(["A", "B", "C"]) = 1
	? "  PASS: IsStrictlyEqualTo same = true"
	nPsd++
else
	? "  FAIL: IsStrictlyEqualTo same"
	nFld++
ok

nTtl++
if o.IsStrictlyEqualTo(["C", "B", "A"]) = 0
	? "  PASS: IsStrictlyEqualTo reversed = false"
	nPsd++
else
	? "  FAIL: IsStrictlyEqualTo reversed"
	nFld++
ok

# --- StartsWithCS / EndsWithCS (engine-backed) ---
? ""
? "--- StartsWith / EndsWith ---"

o = new stzList([1, 2, 3, 4, 5])
nTtl++
if o.StartsWith([1, 2]) = 1
	? "  PASS: [1..5].StartsWith([1,2]) = true"
	nPsd++
else
	? "  FAIL: StartsWith"
	nFld++
ok

nTtl++
if o.StartsWith([2, 3]) = 0
	? "  PASS: [1..5].StartsWith([2,3]) = false"
	nPsd++
else
	? "  FAIL: StartsWith false case"
	nFld++
ok

nTtl++
if o.EndsWith([4, 5]) = 1
	? "  PASS: [1..5].EndsWith([4,5]) = true"
	nPsd++
else
	? "  FAIL: EndsWith"
	nFld++
ok

nTtl++
if o.EndsWith([3, 4]) = 0
	? "  PASS: [1..5].EndsWith([3,4]) = false"
	nPsd++
else
	? "  FAIL: EndsWith false case"
	nFld++
ok

# --- SUMMARY ---
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
# Executed in almost 0 second(s) in Ring 1.27
