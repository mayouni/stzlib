# Integration regression suite for stzListOfPairs.
# Covers init validation, Content, NumberOfPairs, PairAt/FirstPair/
# LastPair, FirstItems/SecondItems, FindPair/FindInFirst/SecondItems,
# Sort by first item, Sort by second item, Reverse-as-Swap (note:
# Reverse means swap-pair-items here, not list reversal),
# UpdatePairWith, edges.
#
# Run from base/list/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzListOfPairs integration regression ==="

# ------------------------------------------------------------
# Init + Content + counts
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oLp = new stzListOfPairs([ ["Ali", 35], ["Dania", 28], ["Han", 42] ])
chk("NumberOfPairs = 3",            oLp.NumberOfPairs() = 3)
chk("Content is list",              isList(oLp.Content()))
chk("Content[1][1] = Ali",          oLp.Content()[1][1] = "Ali")
chk("Content[1][2] = 35",           oLp.Content()[1][2] = 35)

# ------------------------------------------------------------
# Pair access
# ------------------------------------------------------------
? ""
? "--- Pair access ---"

aP1 = oLp.PairAt(1)
chk("PairAt(1) returns list",       isList(aP1) and len(aP1) = 2)
chk("PairAt(1)[1] = Ali",           aP1[1] = "Ali")
chk("PairAt(2)[1] = Dania",         oLp.PairAt(2)[1] = "Dania")

# Pair() alias
chk("Pair(3)[1] = Han",             oLp.Pair(3)[1] = "Han")

# ------------------------------------------------------------
# FirstItems / SecondItems projections
# ------------------------------------------------------------
? ""
? "--- Projections ---"

aFi = oLp.FirstItems()
chk("FirstItems is list",           isList(aFi))
chk("FirstItems = [Ali, Dania, Han]", len(aFi) = 3 and aFi[1] = "Ali" and aFi[2] = "Dania" and aFi[3] = "Han")

aSi = oLp.SecondItems()
chk("SecondItems = [35, 28, 42]",   len(aSi) = 3 and aSi[1] = 35 and aSi[2] = 28 and aSi[3] = 42)

# ------------------------------------------------------------
# Find
# ------------------------------------------------------------
? ""
? "--- Find ---"

nFp = oLp.FindPair([ "Dania", 28 ])
chk("FindPair returns position",    nFp = 2)

nFp0 = oLp.FindPair([ "Nobody", 99 ])
chk("FindPair missing = 0",         nFp0 = 0)

aFf = oLp.FindInFirstItems("Han")
chk("FindInFirstItems('Han')",      isList(aFf) and len(aFf) >= 1)

aFs = oLp.FindInSecondItems(28)
chk("FindInSecondItems(28)",        isList(aFs) and len(aFs) >= 1)

# ------------------------------------------------------------
# Sort by first / Sort by second
# ------------------------------------------------------------
? ""
? "--- Sort ---"

oLs = new stzListOfPairs([ ["zoo", 3], ["apple", 1], ["mango", 2] ])
oLs.Sort()
aSr = oLs.FirstItems()
chk("Sort by first: apple first",   aSr[1] = "apple")
chk("Sort by first: zoo last",      aSr[3] = "zoo")

oLsd = new stzListOfPairs([ ["zoo", 3], ["apple", 1], ["mango", 2] ])
oLsd.SortDown()
aSd = oLsd.FirstItems()
chk("SortDown: zoo first",          aSd[1] = "zoo")
chk("SortDown: apple last",         aSd[3] = "apple")

# Passive form
oLsp = new stzListOfPairs([ ["zoo", 3], ["apple", 1], ["mango", 2] ])
aPas = oLsp.Sorted()
chk("Sorted returns list",          isList(aPas))
chk("Sorted preserves self",        oLsp.FirstItems()[1] = "zoo")

# ------------------------------------------------------------
# Reverse-as-Swap (semantics: swaps items WITHIN each pair)
# ------------------------------------------------------------
? ""
? "--- Reverse-as-Swap ---"

oLr = new stzListOfPairs([ ["a", 1], ["b", 2] ])
oLr.Reverse()
chk("Reverse swaps items in pair 1", oLr.PairAt(1)[1] = 1 and oLr.PairAt(1)[2] = "a")
chk("Reverse swaps items in pair 2", oLr.PairAt(2)[1] = 2 and oLr.PairAt(2)[2] = "b")

# Swap alias
oLsw = new stzListOfPairs([ ["x", 10] ])
oLsw.Swap()
chk("Swap = Reverse semantically",  oLsw.PairAt(1)[1] = 10)

# Passive (returns swapped list, leaves self)
oLrp = new stzListOfPairs([ ["a", 1] ])
aRv = oLrp.ItemsSwapped()
chk("ItemsSwapped returns list",    isList(aRv))
chk("ItemsSwapped leaves self",     oLrp.PairAt(1)[1] = "a")

# ------------------------------------------------------------
# UpdatePairWith
# ------------------------------------------------------------
? ""
? "--- UpdatePairWith ---"

oUp = new stzListOfPairs([ ["a", 1], ["b", 2], ["c", 3] ])
oUp.UpdatePairWith(2, ["X", 99])
chk("UpdatePairWith(2) replaces pair", oUp.PairAt(2)[1] = "X" and oUp.PairAt(2)[2] = 99)
chk("Other pairs preserved",        oUp.PairAt(1)[1] = "a" and oUp.PairAt(3)[1] = "c")

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Single pair
oOne = new stzListOfPairs([ ["only", 1] ])
chk("Single NumberOfPairs = 1",     oOne.NumberOfPairs() = 1)
chk("Single PairAt(1)",             oOne.PairAt(1)[1] = "only")

# Same items in pair (e.g. [3, 3])
oSame = new stzListOfPairs([ [3, 3], [5, 5] ])
chk("PairsAreMadeOfEqualItems",     oSame.PairsAreMadeOfEqualItems() = 1)

oNot = new stzListOfPairs([ [3, 4], [5, 5] ])
chk("Not all equal = 0",            oNot.PairsAreMadeOfEqualItems() = 0)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzListOfPairs CHECKS PASSED!"
else
	? "SOME stzListOfPairs CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
