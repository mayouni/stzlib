load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzList Split Tests (Engine-Backed) ==="

# --- SplitBeforePosition ---
? ""
? "--- SplitBeforePosition ---"

o = new stzList([1, 2, 3, 4, 5])
aResult = o.SplittedBeforePosition(3)
nTtl++
if len(aResult) = 2 and len(aResult[1]) = 2 and len(aResult[2]) = 3
	? "  PASS: SplitBeforePosition(3) = [[1,2],[3,4,5]]"
	nPsd++
else
	? "  FAIL: SplitBeforePosition(3) got " + len(aResult) + " groups"
	nFld++
ok

# --- SplitAfterPosition ---
? ""
? "--- SplitAfterPosition ---"

o = new stzList([1, 2, 3, 4, 5])
aResult = o.SplittedAfterPosition(3)
nTtl++
if len(aResult) = 2 and len(aResult[1]) = 3 and len(aResult[2]) = 2
	? "  PASS: SplitAfterPosition(3) = [[1,2,3],[4,5]]"
	nPsd++
else
	? "  FAIL: SplitAfterPosition(3) got " + len(aResult) + " groups"
	if len(aResult) >= 1
		? "    group1 size=" + len(aResult[1])
	ok
	if len(aResult) >= 2
		? "    group2 size=" + len(aResult[2])
	ok
	nFld++
ok

# --- SplitToPartsOfNItems ---
? ""
? "--- SplitToPartsOfNItems ---"

o = new stzList([1, 2, 3, 4, 5, 6])
aResult = o.SplittedToPartsOfNItems(2)
nTtl++
if len(aResult) = 3
	? "  PASS: SplitToPartsOf(2) = 3 groups"
	nPsd++
else
	? "  FAIL: SplitToPartsOf(2) got " + len(aResult) + " groups"
	nFld++
ok

o = new stzList([1, 2, 3, 4, 5])
aResult = o.SplittedToPartsOfNItems(2)
nTtl++
if len(aResult) = 3
	? "  PASS: SplitToPartsOf(2) on 5 items = 3 groups (last has 1)"
	nPsd++
else
	? "  FAIL: SplitToPartsOf(2) on 5 items got " + len(aResult) + " groups"
	nFld++
ok

# --- SplitToNParts ---
? ""
? "--- SplitToNParts ---"

o = new stzList([1, 2, 3, 4, 5, 6])
aResult = o.SplittedToNParts(3)
nTtl++
if len(aResult) = 3
	? "  PASS: SplitToNParts(3) on 6 items = 3 groups"
	nPsd++
else
	? "  FAIL: SplitToNParts(3) got " + len(aResult) + " groups"
	nFld++
ok

o = new stzList([1, 2, 3, 4, 5])
aResult = o.SplittedToNParts(2)
nTtl++
if len(aResult) = 2
	? "  PASS: SplitToNParts(2) on 5 items = 2 groups"
	nPsd++
else
	? "  FAIL: SplitToNParts(2) got " + len(aResult) + " groups"
	nFld++
ok

# --- SplitAtPosition ---
? ""
? "--- SplitAtPosition ---"

o = new stzList(["a", "b", "c", "d", "e"])
aResult = o.SplittedAtPosition(3)
nTtl++
if len(aResult) = 2 and len(aResult[1]) = 2
	? "  PASS: SplitAtPosition(3) = [[a,b],[c,d,e]]"
	nPsd++
else
	? "  FAIL: SplitAtPosition(3)"
	nFld++
ok

# --- Delegated from stzList ---
? ""
? "--- stzList Delegations ---"

o = new stzList([1, 2, 3, 4, 5])
aResult = o.SplittedBeforePosition(3)
nTtl++
if len(aResult) = 2
	? "  PASS: stzList.SplittedBeforePosition(3) = 2 groups"
	nPsd++
else
	? "  FAIL: stzList.SplittedBeforePosition(3)"
	nFld++
ok

aResult = o.SplittedAfterPosition(2)
nTtl++
if len(aResult) = 2 and len(aResult[1]) = 2 and len(aResult[2]) = 3
	? "  PASS: stzList.SplittedAfterPosition(2) = [[1,2],[3,4,5]]"
	nPsd++
else
	? "  FAIL: stzList.SplittedAfterPosition(2)"
	nFld++
ok

aResult = o.SplittedToPartsOf(2)
nTtl++
if len(aResult) = 3
	? "  PASS: stzList.SplittedToPartsOf(2) = 3 groups"
	nPsd++
else
	? "  FAIL: stzList.SplittedToPartsOf(2) got " + len(aResult) + " groups"
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
