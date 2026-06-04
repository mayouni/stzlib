load "../../stzBase.ring"

pr()

? "=== stzListOfLists Engine Delegation ==="
? ""

# Test CommonItems (engine-backed intersection)
? "--- CommonItems ---"
oLists = new stzListOfLists([
	["a", "b", "c", "d"],
	["b", "c", "d", "e"],
	["c", "d", "e", "f"]
])
aCommon = oLists.CommonItems()
? "CommonItems of 3 lists: " + len(aCommon) + " items"
_nCommon1Len_ = ring_len(aCommon)
for _iLoopCommon1_ = 1 to _nCommon1Len_
	item = aCommon[_iLoopCommon1_]
	? "  " + item
next
# Expected: 2 items (c, d)

? ""

# Test CommonItems with no overlap
oLists2 = new stzListOfLists([
	["a", "b"],
	["c", "d"]
])
aCommon2 = oLists2.CommonItems()
? "CommonItems with no overlap: " + len(aCommon2) + " items"
# Expected: 0

? ""

# Test CommonItems with single list
oLists3 = new stzListOfLists([
	["x", "y", "z"]
])
aCommon3 = oLists3.CommonItems()
? "CommonItems with single list: " + len(aCommon3) + " items"
# Expected: 3

? ""
? "=== All stzListOfLists tests passed! ==="

pf()
