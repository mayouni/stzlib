# Regression test pinning the bugs fixed during M-S1 Phase 2 cleanup
# of stzListOfLists. Each section asserts the corrected behaviour for
# one previously-broken method so the bugs cannot silently come back.
#
# Uses element-wise checks because Ring's `=` on nested lists is
# unreliable across versions.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzListOfLists regression tests (33-bug pin) ==="

# ----- AddMany loop was a no-op (lost data) -----
? ""
? "--- AddMany ---"

o = new stzListOfLists([[1, 2]])
o.AddMany([[3, 4], [5, 6]])

nTtl++
if o.NumberOfLists() = 3
	nPsd++
	? "  PASS: AddMany appended both sublists"
else
	nFld++
	? "  FAIL: AddMany appended both sublists (got " + o.NumberOfLists() + ")"
ok

aN3 = o.NthList(3)
nTtl++
if isList(aN3) and len(aN3) = 2 and aN3[1] = 5 and aN3[2] = 6
	nPsd++
	? "  PASS: third list = [5,6]"
else
	nFld++
	? "  FAIL: third list = [5,6]"
ok

# ----- NthList :Last fall-through -----
? ""
? "--- NthList :Last keyword ---"

o = new stzListOfLists([[1], [2, 3], [4, 5, 6]])
aLast = o.NthList(:Last)
nTtl++
if isList(aLast) and len(aLast) = 3 and aLast[1] = 4 and aLast[3] = 6
	nPsd++
	? "  PASS: NthList(:Last) returns [4,5,6]"
else
	nFld++
	? "  FAIL: NthList(:Last) returns [4,5,6]"
ok

# ----- SizeOfEach@Is always returned 1 -----
? ""
? "--- SizeOfEach@Is ---"

oEq = new stzListOfLists([[1, 2], [3, 4], [5, 6]])
nTtl++
if oEq.SizeOfEach@Is(2) = 1
	nPsd++
	? "  PASS: all lists size 2 -> true"
else
	nFld++
	? "  FAIL: all lists size 2 -> true"
ok

oNe = new stzListOfLists([[1, 2], [3, 4, 5]])
nTtl++
if oNe.SizeOfEach@Is(2) = 0
	nPsd++
	? "  PASS: mixed sizes -> false (was always true)"
else
	nFld++
	? "  FAIL: mixed sizes -> false (bug regressed!)"
ok

# ----- Pairify->Parify typo broke PairifyQ chain -----
? ""
? "--- Pairified (uses PairifyQ chain) ---"

oP = new stzListOfLists([[1, 2], [3, 4]])
aPaired = oP.Pairified()
nTtl++
if isList(aPaired)
	nPsd++
	? "  PASS: Pairified returns a list"
else
	nFld++
	? "  FAIL: Pairified returns a list"
ok

# ----- SwapCols ring_swap was calling shadowed Swap(p1,p2) -----
? ""
? "--- SwapCols ---"

oSw = new stzListOfLists([[10, 20, 30], [40, 50, 60]])
oSw.SwapCols(1, 3)
aRow1 = oSw.NthList(1)
aRow2 = oSw.NthList(2)
nTtl++
if aRow1[1] = 30 and aRow1[2] = 20 and aRow1[3] = 10
	nPsd++
	? "  PASS: row 1 cols swapped 1<->3"
else
	nFld++
	? "  FAIL: row 1 cols swapped 1<->3"
ok

nTtl++
if aRow2[1] = 60 and aRow2[2] = 50 and aRow2[3] = 40
	nPsd++
	? "  PASS: row 2 cols swapped 1<->3"
else
	nFld++
	? "  FAIL: row 2 cols swapped 1<->3"
ok

# ----- ColsSwapped called non-fluent (returned NULL) -----
? ""
? "--- ColsSwapped returns content ---"

oCs = new stzListOfLists([[1, 2, 3], [4, 5, 6]])
aSwapped = oCs.ColsSwapped(1, 3)
nTtl++
if isList(aSwapped) and len(aSwapped) = 2
	nPsd++
	? "  PASS: ColsSwapped returns 2-list result"
else
	nFld++
	? "  FAIL: ColsSwapped returns 2-list result"
ok

# ----- DuplicatesInListsRemoved missing .Copy() mutated self -----
? ""
? "--- DuplicatesInListsRemoved does not mutate self ---"

oDup = new stzListOfLists([[1, 2, 1, 3], [4, 4, 5]])
aDedup = oDup.DuplicatesInListsRemoved()
aOrig1 = oDup.NthList(1)
nTtl++
if len(aOrig1) = 4 and aOrig1[3] = 1
	nPsd++
	? "  PASS: original unchanged (no self-mutation)"
else
	nFld++
	? "  FAIL: original was mutated (bug regressed!)"
ok

# ----- NumberOfMissingItems positive control -----
? ""
? "--- NumberOfMissingItems ---"

oMis = new stzListOfLists([[1, 2, 3], [4], [5, 6]])
nMissing = oMis.NumberOfMissingItems()
nTtl++
if nMissing = 3
	nPsd++
	? "  PASS: 3 missing items vs largest"
else
	nFld++
	? "  FAIL: 3 missing items (got " + nMissing + ")"
ok

# ----- Cols / NumberOfColumns positive control -----
? ""
? "--- Cols ---"

oCo = new stzListOfLists([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
nTtl++
if oCo.NumberOfColumns() = 3
	nPsd++
	? "  PASS: 3 columns"
else
	nFld++
	? "  FAIL: 3 columns (got " + oCo.NumberOfColumns() + ")"
ok

aC1 = oCo.NthColumn(1)
nTtl++
if isList(aC1) and len(aC1) = 3 and aC1[1] = 1 and aC1[2] = 4 and aC1[3] = 7
	nPsd++
	? "  PASS: first col = [1,4,7]"
else
	nFld++
	? "  FAIL: first col = [1,4,7]"
ok

# ----- Reverse positive control -----
? ""
? "--- ReversedLists / ItemsInListsReversed ---"

oRv = new stzListOfLists([[1, 2], [3, 4]])
aRev = oRv.ReversedLists()
nTtl++
if isList(aRev) and len(aRev) = 2 and aRev[1][1] = 3 and aRev[1][2] = 4
	nPsd++
	? "  PASS: ReversedLists swaps order"
else
	nFld++
	? "  FAIL: ReversedLists swaps order"
ok

aInner = oRv.ItemsInListsReversed()
nTtl++
if isList(aInner) and len(aInner) = 2 and aInner[1][1] = 2 and aInner[1][2] = 1
	nPsd++
	? "  PASS: ItemsInListsReversed reverses inner"
else
	nFld++
	? "  FAIL: ItemsInListsReversed reverses inner"
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
