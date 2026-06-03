# Regression test for the engine string-direct variants added in
# session 43 to fix the cross-DLL handle-table bug. These exercise
# the re-enabled engine fast paths in stzListReplacer + stzListRemover.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== Engine string-direct fast path ==="

# ------------------------------------------------------------
# Replacer engine fast path
# ------------------------------------------------------------
? ""
? "--- stzListReplacer engine fast path ---"

oRep = new stzListReplacer(["a", "b", "a", "c", "a"])
oRep.ReplaceAllOccurrencesCS("a", "X", 1)
aR1 = oRep.Content()

nTtl++
if isList(aR1) and len(aR1) = 5 and aR1[1] = "X" and aR1[3] = "X" and aR1[5] = "X" and aR1[2] = "b" and aR1[4] = "c"
	nPsd++
	? "  PASS: ReplaceAllOccurrencesCS via engine string-direct"
else
	nFld++
	? "  FAIL: ReplaceAllOccurrencesCS (got " + @@(aR1) + ")"
ok

# Case insensitive
oRep2 = new stzListReplacer(["Foo", "foo", "FOO", "bar"])
oRep2.ReplaceAllOccurrencesCS("foo", "X", 0)
aR2 = oRep2.Content()

nTtl++
if isList(aR2) and len(aR2) = 4 and aR2[1] = "X" and aR2[2] = "X" and aR2[3] = "X" and aR2[4] = "bar"
	nPsd++
	? "  PASS: CI replace via engine"
else
	nFld++
	? "  FAIL: CI replace (got " + @@(aR2) + ")"
ok

# ReplaceAt single position via engine
oRep3 = new stzListReplacer(["a", "b", "c"])
oRep3.ReplaceAt(2, "X")
aR3 = oRep3.Content()

nTtl++
if isList(aR3) and len(aR3) = 3 and aR3[1] = "a" and aR3[2] = "X" and aR3[3] = "c"
	nPsd++
	? "  PASS: ReplaceAt(2,'X') via engine SetString"
else
	nFld++
	? "  FAIL: ReplaceAt (got " + @@(aR3) + ")"
ok

# AllOccurrencesReplacedCS (passive form -- exercises chain)
oRep4 = new stzListReplacer(["x", "y", "x", "z", "x"])
aR4 = oRep4.AllOccurrencesReplacedCS("x", "Q", 1)

nTtl++
if isList(aR4) and len(aR4) = 5 and aR4[1] = "Q" and aR4[3] = "Q" and aR4[5] = "Q"
	nPsd++
	? "  PASS: AllOccurrencesReplacedCS via engine"
else
	nFld++
	? "  FAIL: AllOccurrencesReplacedCS (got " + @@(aR4) + ")"
ok

# Original should be unchanged (Replaced form is passive)
nTtl++
if oRep4.Content()[1] = "x"
	nPsd++
	? "  PASS: Passive form doesnt mutate self"
else
	nFld++
	? "  FAIL: Passive form mutated self"
ok

# ------------------------------------------------------------
# Remover engine fast path
# ------------------------------------------------------------
? ""
? "--- stzListRemover engine fast path ---"

oRmv = new stzListRemover(["a", "b", "a", "c", "a"])
oRmv.RemoveAllCS("a", 1)
aRm1 = oRmv.Content()

nTtl++
if isList(aRm1) and len(aRm1) = 2 and aRm1[1] = "b" and aRm1[2] = "c"
	nPsd++
	? "  PASS: RemoveAllCS via engine string-direct"
else
	nFld++
	? "  FAIL: RemoveAllCS (got " + @@(aRm1) + ")"
ok

# Case insensitive remove
oRmv2 = new stzListRemover(["Foo", "foo", "FOO", "bar"])
oRmv2.RemoveAllCS("foo", 0)
aRm2 = oRmv2.Content()

nTtl++
if isList(aRm2) and len(aRm2) = 1 and aRm2[1] = "bar"
	nPsd++
	? "  PASS: CI remove via engine"
else
	nFld++
	? "  FAIL: CI remove (got " + @@(aRm2) + ")"
ok

# AllOccurrencesRemoved (passive)
oRmv3 = new stzListRemover(["x", "y", "x", "z"])
aRm3 = oRmv3.AllOccurrencesRemoved("x")

nTtl++
if isList(aRm3) and len(aRm3) = 2 and aRm3[1] = "y" and aRm3[2] = "z"
	nPsd++
	? "  PASS: AllOccurrencesRemoved via engine"
else
	nFld++
	? "  FAIL: AllOccurrencesRemoved (got " + @@(aRm3) + ")"
ok

# Original unchanged
nTtl++
if oRmv3.Content()[1] = "x" and oRmv3.NumberOfItems() = 4
	nPsd++
	? "  PASS: Removed form doesnt mutate self"
else
	nFld++
	? "  FAIL: Removed form mutated self"
ok

# ------------------------------------------------------------
# Non-string items should still work via fallback path
# ------------------------------------------------------------
? ""
? "--- Non-string fallback path ---"

oRmv4 = new stzListRemover([1, 2, 3, 2, 4, 2])
oRmv4.RemoveAll(2)
aRm4 = oRmv4.Content()

nTtl++
if isList(aRm4) and len(aRm4) = 3 and aRm4[1] = 1 and aRm4[2] = 3 and aRm4[3] = 4
	nPsd++
	? "  PASS: RemoveAll(integer) via Ring fallback"
else
	nFld++
	? "  FAIL: RemoveAll integer (got " + @@(aRm4) + ")"
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
