# Second batch of submodule regression tests covering Sorter, Getter,
# Bounder, Random -- submodules cleaned during M-S1 Phase 2 that
# lack dedicated test coverage.

load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== List submodule regression tests (batch 2) ==="

# ============================================================
# stzListSorter
# ============================================================
? ""
? "--- stzListSorter ---"

oSrt = new stzListSorter([3, 1, 4, 1, 5, 9, 2, 6])
aSorted = oSrt.SortedInAscending()
nTtl++
if isList(aSorted) and len(aSorted) = 8 and aSorted[1] = 1 and aSorted[8] = 9
	nPsd++
	? "  PASS: SortedInAscending"
else
	nFld++
	? "  FAIL: SortedInAscending (got " + @@(aSorted) + ")"
ok

aSortedDown = oSrt.SortedInDescending()
nTtl++
if isList(aSortedDown) and aSortedDown[1] = 9 and aSortedDown[8] = 1
	nPsd++
	? "  PASS: SortedInDescending"
else
	nFld++
	? "  FAIL: SortedInDescending (got " + @@(aSortedDown) + ")"
ok

oSrt2 = new stzListSorter([5, 2, 8, 1, 9, 3])
nTtl++
if oSrt2.Min() = 1
	nPsd++
	? "  PASS: Min = 1"
else
	nFld++
	? "  FAIL: Min (got " + oSrt2.Min() + ")"
ok

nTtl++
if oSrt2.Max() = 9
	nPsd++
	? "  PASS: Max = 9"
else
	nFld++
	? "  FAIL: Max (got " + oSrt2.Max() + ")"
ok

nTtl++
if oSrt2.Median() = 4
	nPsd++
	? "  PASS: Median = 4 (avg of 3 and 5)"
else
	nFld++
	? "  FAIL: Median (got " + oSrt2.Median() + ")"
ok

aRev = oSrt2.Reversed()
nTtl++
if isList(aRev) and len(aRev) = 6 and aRev[1] = 3 and aRev[6] = 5
	nPsd++
	? "  PASS: Reversed"
else
	nFld++
	? "  FAIL: Reversed (got " + @@(aRev) + ")"
ok

# IsSorted family
oSrt3 = new stzListSorter([1, 2, 3, 4, 5])
nTtl++
if oSrt3.IsSortedInAscending() = 1
	nPsd++
	? "  PASS: IsSortedInAscending = 1 on sorted list"
else
	nFld++
	? "  FAIL: IsSortedInAscending"
ok

oSrt4 = new stzListSorter([5, 4, 3, 2, 1])
nTtl++
if oSrt4.IsSortedInDescending() = 1
	nPsd++
	? "  PASS: IsSortedInDescending = 1 on reverse sorted"
else
	nFld++
	? "  FAIL: IsSortedInDescending"
ok

# NthSmallest / NthLargest
oSrt5 = new stzListSorter([10, 5, 30, 15, 20])
nTtl++
if oSrt5.NthSmallest(2) = 10
	nPsd++
	? "  PASS: NthSmallest(2) = 10"
else
	nFld++
	? "  FAIL: NthSmallest (got " + oSrt5.NthSmallest(2) + ")"
ok

nTtl++
if oSrt5.NthLargest(2) = 20
	nPsd++
	? "  PASS: NthLargest(2) = 20"
else
	nFld++
	? "  FAIL: NthLargest (got " + oSrt5.NthLargest(2) + ")"
ok

# ============================================================
# stzListGetter
# ============================================================
? ""
? "--- stzListGetter ---"

oG = new stzListGetter([10, 20, 30, 40, 50])

nTtl++
if oG.FirstItem() = 10
	nPsd++
	? "  PASS: FirstItem = 10"
else
	nFld++
	? "  FAIL: FirstItem"
ok

nTtl++
if oG.LastItem() = 50
	nPsd++
	? "  PASS: LastItem = 50"
else
	nFld++
	? "  FAIL: LastItem"
ok

aHead = oG.NFirstItems(3)
nTtl++
if isList(aHead) and len(aHead) = 3 and aHead[1] = 10 and aHead[3] = 30
	nPsd++
	? "  PASS: NFirstItems(3) = [10,20,30]"
else
	nFld++
	? "  FAIL: NFirstItems (got " + @@(aHead) + ")"
ok

aTail = oG.NLastItems(2)
nTtl++
if isList(aTail) and len(aTail) = 2 and aTail[1] = 40 and aTail[2] = 50
	nPsd++
	? "  PASS: NLastItems(2) = [40,50]"
else
	nFld++
	? "  FAIL: NLastItems (got " + @@(aTail) + ")"
ok

aSect = oG.Section(2, 4)
nTtl++
if isList(aSect) and len(aSect) = 3 and aSect[1] = 20 and aSect[3] = 40
	nPsd++
	? "  PASS: Section(2,4) = [20,30,40]"
else
	nFld++
	? "  FAIL: Section (got " + @@(aSect) + ")"
ok

aPos = oG.ItemsAtPositions([1, 3, 5])
nTtl++
if isList(aPos) and len(aPos) = 3 and aPos[1] = 10 and aPos[2] = 30 and aPos[3] = 50
	nPsd++
	? "  PASS: ItemsAtPositions([1,3,5]) = [10,30,50]"
else
	nFld++
	? "  FAIL: ItemsAtPositions (got " + @@(aPos) + ")"
ok

aEvery = oG.EveryNthItem(2)
nTtl++
if isList(aEvery) and len(aEvery) = 2 and aEvery[1] = 20 and aEvery[2] = 40
	nPsd++
	? "  PASS: EveryNthItem(2) = [20,40]"
else
	nFld++
	? "  FAIL: EveryNthItem (got " + @@(aEvery) + ")"
ok

# Type filters
oG2 = new stzListGetter([1, "a", 2, "b", 3])
aNums = oG2.OnlyNumbers()
nTtl++
if isList(aNums) and len(aNums) = 3 and aNums[1] = 1 and aNums[3] = 3
	nPsd++
	? "  PASS: OnlyNumbers = [1,2,3]"
else
	nFld++
	? "  FAIL: OnlyNumbers (got " + @@(aNums) + ")"
ok

aStrs = oG2.OnlyStrings()
nTtl++
if isList(aStrs) and len(aStrs) = 2 and aStrs[1] = "a" and aStrs[2] = "b"
	nPsd++
	? "  PASS: OnlyStrings"
else
	nFld++
	? "  FAIL: OnlyStrings (got " + @@(aStrs) + ")"
ok

# Pairs / Triplets
oG3 = new stzListGetter([1, 2, 3, 4, 5])
aPairs = oG3.Pairs()
nTtl++
if isList(aPairs) and len(aPairs) = 4 and aPairs[1][1] = 1 and aPairs[1][2] = 2
	nPsd++
	? "  PASS: Pairs from [1..5] gives 4 pairs"
else
	nFld++
	? "  FAIL: Pairs (got " + @@(aPairs) + ")"
ok

aTrips = oG3.Triplets()
nTtl++
if isList(aTrips) and len(aTrips) = 3 and aTrips[1][1] = 1 and aTrips[1][3] = 3
	nPsd++
	? "  PASS: Triplets from [1..5] gives 3 triplets"
else
	nFld++
	? "  FAIL: Triplets (got " + @@(aTrips) + ")"
ok

# SlidingWindow (engine-backed)
oG4 = new stzListGetter([1, 2, 3, 4])
aSlide = oG4.SlidingWindow(3)
nTtl++
if isList(aSlide) and len(aSlide) = 2
	nPsd++
	? "  PASS: SlidingWindow(3) on 4 items = 2 windows"
else
	nFld++
	? "  FAIL: SlidingWindow (got " + @@(aSlide) + ")"
ok

# ============================================================
# stzListBounder
# ============================================================
? ""
? "--- stzListBounder ---"

oB = new stzListBounder([1, 2, 3, 4, 5, 6, 7])

aMid = oB.Middle()
nTtl++
if isList(aMid) and len(aMid) = 5 and aMid[1] = 2 and aMid[5] = 6
	nPsd++
	? "  PASS: Middle drops first and last"
else
	nFld++
	? "  FAIL: Middle (got " + @@(aMid) + ")"
ok

nTtl++
if oB.IsWithinBounds(4) = 1
	nPsd++
	? "  PASS: IsWithinBounds(4) = 1"
else
	nFld++
	? "  FAIL: IsWithinBounds(4)"
ok

nTtl++
if oB.IsWithinBounds(99) = 0
	nPsd++
	? "  PASS: IsWithinBounds(99) = 0"
else
	nFld++
	? "  FAIL: IsWithinBounds(99)"
ok

aBnds = oB.Bounds()
nTtl++
if isList(aBnds) and len(aBnds) = 2 and aBnds[1] = 1 and aBnds[2] = 7
	nPsd++
	? "  PASS: Bounds = [1, 7]"
else
	nFld++
	? "  FAIL: Bounds (got " + @@(aBnds) + ")"
ok

# ClampedTo
oB2 = new stzListBounder([0, 5, 10, 15, 20])
aClamp = oB2.ClampedTo(3, 17)
nTtl++
if isList(aClamp) and aClamp[1] = 3 and aClamp[5] = 17 and aClamp[3] = 10
	nPsd++
	? "  PASS: ClampedTo(3,17) clamps endpoints"
else
	nFld++
	? "  FAIL: ClampedTo (got " + @@(aClamp) + ")"
ok

# Range
aRng = oB.Range(2, 3)
nTtl++
if isList(aRng) and len(aRng) = 3 and aRng[1] = 2 and aRng[3] = 4
	nPsd++
	? "  PASS: Range(2,3) = [2,3,4]"
else
	nFld++
	? "  FAIL: Range (got " + @@(aRng) + ")"
ok

# ============================================================
# stzListRandom
# ============================================================
? ""
? "--- stzListRandom ---"

oRnd = new stzListRandom([10, 20, 30, 40, 50])

# RandomPosition is non-deterministic but bounded
nPos = oRnd.RandomPosition()
nTtl++
if isNumber(nPos) and nPos >= 1 and nPos <= 5
	nPsd++
	? "  PASS: RandomPosition returns 1-5"
else
	nFld++
	? "  FAIL: RandomPosition (got " + nPos + ")"
ok

# NRandomPositions
aRpos = oRnd.NRandomPositions(3)
nTtl++
if isList(aRpos) and len(aRpos) = 3
	nPsd++
	? "  PASS: NRandomPositions(3) returns 3 positions"
else
	nFld++
	? "  FAIL: NRandomPositions (got " + @@(aRpos) + ")"
ok

# Bounds check on returned positions
bValid = 1
_nRposLen_ = ring_len(aRpos)
for i = 1 to _nRposLen_
	if aRpos[i] < 1 or aRpos[i] > 5
		bValid = 0
		exit
	ok
next
nTtl++
if bValid = 1
	nPsd++
	? "  PASS: all positions within 1..5"
else
	nFld++
	? "  FAIL: positions out of bounds"
ok

# RandomItem returns one of the list items
xItem = oRnd.RandomItem()
nTtl++
if isNumber(xItem) and (xItem = 10 or xItem = 20 or xItem = 30 or xItem = 40 or xItem = 50)
	nPsd++
	? "  PASS: RandomItem returns a list item"
else
	nFld++
	? "  FAIL: RandomItem (got " + xItem + ")"
ok

# NRandomItems
aNri = oRnd.NRandomItems(3)
nTtl++
if isList(aNri) and len(aNri) = 3
	nPsd++
	? "  PASS: NRandomItems(3) returns 3 items"
else
	nFld++
	? "  FAIL: NRandomItems (got " + @@(aNri) + ")"
ok

# Randomized -- non-destructive
oRnd2 = new stzListRandom([1, 2, 3, 4, 5])
aRz = oRnd2.Randomized()
nTtl++
if isList(aRz) and len(aRz) = 5
	nPsd++
	? "  PASS: Randomized returns 5 items"
else
	nFld++
	? "  FAIL: Randomized (got " + @@(aRz) + ")"
ok

# Original should be unchanged
nTtl++
if oRnd2.Content()[1] = 1 and oRnd2.Content()[5] = 5
	nPsd++
	? "  PASS: Randomized does not mutate self"
else
	nFld++
	? "  FAIL: Randomized mutated self (got " + @@(oRnd2.Content()) + ")"
ok

# RandomPositionExcept
oRnd3 = new stzListRandom([1, 2, 3])
nE = oRnd3.RandomPositionExcept(2)
nTtl++
if (nE = 1 or nE = 3) and nE != 2
	nPsd++
	? "  PASS: RandomPositionExcept(2) avoids pos 2"
else
	nFld++
	? "  FAIL: RandomPositionExcept (got " + nE + ")"
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
