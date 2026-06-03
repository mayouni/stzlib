# Regression test pinning the bugs fixed during M-E18 stzHashList
# cleanup. Each section asserts the corrected behaviour for one
# previously-broken method so the bugs cannot silently come back.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzHashList regression tests (8-bug pin) ==="

# ----- UpdateAllPairsWith mutated local copy but never persisted -----
# Verifies the mutation is applied (was previously a no-op since the
# local copy was discarded). Use a 1-pair list so we don't violate
# the hashlist unique-key invariant on the replace-all-with-same-pair
# semantics.
? ""
? "--- UpdateAllPairsWith persists -----"

o = new stzHashList([ :a = 1 ])
o.UpdateAllPairsWith([ :x, 99 ])

aContent = o.Content()
nTtl++
if len(aContent) = 1 and aContent[1][1] = "x" and aContent[1][2] = 99
	nPsd++
	? "  PASS: pair persisted after UpdateAllPairsWith"
else
	nFld++
	? "  FAIL: pair persisted (got " + @@(aContent) + ") -- bug regressed (was no-op)"
ok

# ----- ReverseKeysAndValues was writing NULL values -----
? ""
? "--- ReverseKeysAndValues actually swaps keys/values -----"

o2 = new stzHashList([ :name = "alice", :age = "thirty" ])
o2.ReverseKeysAndValues()
aContent2 = o2.Content()
# Originally keys are name/age; values alice/thirty
# After reverse: keys become alice/thirty; values become name/age
nTtl++
if aContent2[1][1] = "alice" and aContent2[1][2] = "name"
	nPsd++
	? "  PASS: first pair swapped"
else
	nFld++
	? "  FAIL: first pair swapped (got " + @@(aContent2[1]) + ")"
ok

nTtl++
if aContent2[2][1] = "thirty" and aContent2[2][2] = "age"
	nPsd++
	? "  PASS: second pair swapped"
else
	nFld++
	? "  FAIL: second pair swapped (got " + @@(aContent2[2]) + ") -- bug regressed (was NULL value)"
ok

# ----- ValuesAndKeys returned undefined `aResults` (typo) -----
? ""
? "--- ValuesAndKeys returns valid pairs -----"

o3 = new stzHashList([ :one = 1, :two = 2 ])
aVK = o3.ValuesAndKeys()
nTtl++
if isList(aVK) and len(aVK) = 2
	nPsd++
	? "  PASS: ValuesAndKeys returns 2 pairs"
else
	nFld++
	? "  FAIL: ValuesAndKeys returns 2 pairs (got " + @@(aVK) + ")"
ok

# Pairs should be [value, key] -- first pair value 1, key "one"
nTtl++
if isList(aVK) and len(aVK) >= 1 and isList(aVK[1]) and aVK[1][1] = 1 and aVK[1][2] = "one"
	nPsd++
	? "  PASS: first pair = [1, 'one']"
else
	nFld++
	? "  FAIL: first pair = [1, 'one'] -- bug regressed (was undefined)"
ok

# ----- FindNthKeyByValue had signature (pValue) but body used undefined n -----
# Now correctly takes (n, pValue). The method searches for `pValue`
# inside list-valued entries (uses Contains on each value list).
? ""
? "--- FindNthKeyByValue takes n + pValue -----"

o4 = new stzHashList([
    :alpha = [ "x", "common" ],
    :beta  = [ "y", "z" ],
    :gamma = [ "common", "q" ]
])
# Items containing "common" are at positions 1 and 3.
nTtl++
if o4.FindNthKeyByValue(1, "common") = 1
	nPsd++
	? "  PASS: 1st occurrence of 'common' at pos 1"
else
	nFld++
	? "  FAIL: 1st occurrence of 'common' at pos 1 (got " + o4.FindNthKeyByValue(1, "common") + ")"
ok

nTtl++
if o4.FindNthKeyByValue(2, "common") = 3
	nPsd++
	? "  PASS: 2nd occurrence of 'common' at pos 3"
else
	nFld++
	? "  FAIL: 2nd occurrence of 'common' at pos 3 (got " + o4.FindNthKeyByValue(2, "common") + ")"
ok

# ----- Engine-backed paths positive controls -----
? ""
? "--- Engine NumberOfPairs / typed value getters -----"

o5 = new stzHashList([ :a = 42, :b = "hello", :c = 3.14 ])
nTtl++
if o5.NumberOfPairs() = 3
	nPsd++
	? "  PASS: engine NumberOfPairs = 3"
else
	nFld++
	? "  FAIL: engine NumberOfPairs (got " + o5.NumberOfPairs() + ")"
ok

nTtl++
if o5.ValueIntByKey(:a) = 42
	nPsd++
	? "  PASS: engine ValueIntByKey(:a) = 42"
else
	nFld++
	? "  FAIL: engine ValueIntByKey(:a) (got " + o5.ValueIntByKey(:a) + ")"
ok

nTtl++
if o5.ValueStringByKey(:b) = "hello"
	nPsd++
	? "  PASS: engine ValueStringByKey(:b) = 'hello'"
else
	nFld++
	? "  FAIL: engine ValueStringByKey(:b)"
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
