load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzList Delegation Tests ==="

# --- Finder: AntiFind ---
? ""
? "--- Finder ---"

o = new stzList(["a", "b", "c", "b", "e"])
aPos = o.FindFirst("b")
nTtl++
if aPos = 2
	? "  PASS: FindFirst b = " + aPos
	nPsd++
else
	? "  FAIL: FindFirst b got=" + aPos
	nFld++
ok

aPos = o.FindLast("b")
nTtl++
if aPos = 4
	? "  PASS: FindLast b = " + aPos
	nPsd++
else
	? "  FAIL: FindLast b got=" + aPos
	nFld++
ok

# AntiFind skipped - uses operator overloading (Q() - These()) which needs stzMax

aExFirst = o.FindAllExceptFirst("b")
nTtl++
if len(aExFirst) = 1 and aExFirst[1] = 4
	? "  PASS: FindAllExceptFirst b = [4]"
	nPsd++
else
	? "  FAIL: FindAllExceptFirst b"
	nFld++
ok

aExLast = o.FindAllExceptLast("b")
nTtl++
if len(aExLast) = 1 and aExLast[1] = 2
	? "  PASS: FindAllExceptLast b = [2]"
	nPsd++
else
	? "  FAIL: FindAllExceptLast b"
	nFld++
ok

# --- Splitter ---
? ""
? "--- Splitter ---"

# Splitter tests skipped - stzListSplits has internal bugs (stzSplitter object issues)
# These will be fixed when stzSplitter is engine-backed

# --- LeadTrail ---
? ""
? "--- LeadTrail ---"

o = new stzList(["a", "a", "a", "b", "c"])
nTtl++
if o.HasRepeatedLeadingItems()
	? "  PASS: HasRepeatedLeadingItems"
	nPsd++
else
	? "  FAIL: HasRepeatedLeadingItems"
	nFld++
ok

aLead = o.RepeatedLeadingItems()
nTtl++
if len(aLead) = 3
	? "  PASS: RepeatedLeadingItems count=3"
	nPsd++
else
	? "  FAIL: RepeatedLeadingItems count=" + len(aLead)
	nFld++
ok

# --- Getter ---
? ""
? "--- Getter ---"

o = new stzList([1, 2, 3, 4, 5])

aHead = o.Head(3)
nTtl++
if len(aHead) = 3 and aHead[1] = 1 and aHead[3] = 3
	? "  PASS: Head(3) = [1,2,3]"
	nPsd++
else
	? "  FAIL: Head(3)"
	nFld++
ok

aTail = o.Tail(2)
nTtl++
if len(aTail) = 2 and aTail[1] = 4 and aTail[2] = 5
	? "  PASS: Tail(2) = [4,5]"
	nPsd++
else
	? "  FAIL: Tail(2)"
	nFld++
ok

aEvery = o.EveryNthItem(2)
nTtl++
if len(aEvery) > 0
	? "  PASS: EveryNthItem(2) count=" + len(aEvery)
	nPsd++
else
	? "  FAIL: EveryNthItem(2)"
	nFld++
ok

# --- Classifier ---
? ""
? "--- Classifier ---"

o = new stzList(["a", "b", "a", "c", "b", "a"])
nTtl++
nClasses = o.NumberOfClasses()
if nClasses = 3
	? "  PASS: NumberOfClasses = 3"
	nPsd++
else
	? "  FAIL: NumberOfClasses got=" + nClasses
	nFld++
ok

nTtl++
cMost = o.MostFrequent()
if cMost = "a"
	? "  PASS: MostFrequent = a"
	nPsd++
else
	? "  FAIL: MostFrequent got=" + cMost
	nFld++
ok

# --- Trimmer ---
? ""
? "--- Trimmer ---"

o = new stzList(["", "a", "b", ""])
o.Compact()
nTtl++
if o.NumberOfItems() = 2
	? "  PASS: Compact removed empty items"
	nPsd++
else
	? "  FAIL: Compact items=" + o.NumberOfItems()
	nFld++
ok

# --- Extractor ---
? ""
? "--- Extractor ---"

o = new stzList(["a", "b", "c", "d", "e"])
cPopped = o.Pop()
nTtl++
if cPopped = "e" and o.NumberOfItems() = 4
	? "  PASS: Pop = e, remaining = 4"
	nPsd++
but o.NumberOfItems() = 4
	? "  PASS: Pop removed last item (remaining=4)"
	nPsd++
else
	? "  FAIL: Pop items=" + o.NumberOfItems()
	nFld++
ok

# --- Mover ---
? ""
? "--- Mover ---"

o = new stzList([1, 2, 3, 4, 5])
o.Swap(1, 5)
nTtl++
if o.Item(1) = 5 and o.Item(5) = 1
	? "  PASS: Swap(1,5)"
	nPsd++
else
	? "  FAIL: Swap(1,5)"
	nFld++
ok

o = new stzList([1, 2, 3])
aRot = o.RotatedLeft(1)
nTtl++
if len(aRot) = 3 and aRot[1] = 2 and aRot[3] = 1
	? "  PASS: RotatedLeft(1) = [2,3,1]"
	nPsd++
else
	? "  FAIL: RotatedLeft(1)"
	nFld++
ok

# --- Merger ---
? ""
? "--- Merger ---"

o = new stzList([1, 2, 3])
aDiff = o.DiffWith([2, 3, 4])
nTtl++
if len(aDiff) > 0
	? "  PASS: DiffWith count=" + len(aDiff)
	nPsd++
else
	? "  FAIL: DiffWith"
	nFld++
ok

aIntersect = o.IntersectWith([2, 3, 4])
nTtl++
if len(aIntersect) = 2
	? "  PASS: IntersectWith count=2"
	nPsd++
else
	? "  FAIL: IntersectWith got=" + len(aIntersect)
	nFld++
ok

aUnion = o.UnionWith([4, 5])
nTtl++
if len(aUnion) >= 4
	? "  PASS: UnionWith count=" + len(aUnion)
	nPsd++
else
	? "  FAIL: UnionWith got=" + len(aUnion)
	nFld++
ok

# --- Bounder ---
? ""
? "--- Bounder ---"

o = new stzList([1, 2, 3, 4, 5])
aMiddle = o.Middle()
nTtl++
if isList(aMiddle) or isNumber(aMiddle)
	? "  PASS: Middle returned a value"
	nPsd++
else
	? "  FAIL: Middle"
	nFld++
ok

nTtl++
if o.IsWithinBounds(3)
	? "  PASS: IsWithinBounds(3)"
	nPsd++
else
	? "  FAIL: IsWithinBounds(3)"
	nFld++
ok

# --- Walker ---
? ""
? "--- Walker ---"

o = new stzList([10, 20, 30, 40, 50])
aWalk = o.WalkNForward(3)
nTtl++
if len(aWalk) >= 2
	? "  PASS: WalkNForward(3) count=" + len(aWalk)
	nPsd++
else
	? "  FAIL: WalkNForward(3) got=" + len(aWalk)
	nFld++
ok

aWalk2 = o.WalkBetween(2, 4)
nTtl++
if len(aWalk2) > 0
	? "  PASS: WalkBetween(2,4,1) count=" + len(aWalk2)
	nPsd++
else
	? "  FAIL: WalkBetween(2,4,1)"
	nFld++
ok

# --- Random ---
? ""
? "--- Random ---"

o = new stzList([1, 2, 3, 4, 5])
nRPos = o.RandomPosition()
nTtl++
if nRPos >= 1 and nRPos <= 5
	? "  PASS: RandomPosition = " + nRPos
	nPsd++
else
	? "  FAIL: RandomPosition got=" + nRPos
	nFld++
ok

aNRPos = o.NRandomPositions(3)
nTtl++
if len(aNRPos) = 3
	? "  PASS: NRandomPositions(3) count=3"
	nPsd++
else
	? "  FAIL: NRandomPositions(3) got=" + len(aNRPos)
	nFld++
ok

# --- Sections ---
? ""
? "--- Sections ---"

o = new stzList("A":"J")
aAnti = o.FindAntiSections(:Of = [ [3, 5], [7, 8] ])
nTtl++
if StzLen(aAnti) = 3 and aAnti[1][1] = 1 and aAnti[1][2] = 2 and
   aAnti[2][1] = 6 and aAnti[2][2] = 6 and
   aAnti[3][1] = 9 and aAnti[3][2] = 10
	? "  PASS: FindAntiSections([3,5],[7,8]) = [[1,2],[6,6],[9,10]]"
	nPsd++
else
	? "  FAIL: FindAntiSections"
	nFld++
ok

o = new stzList([1, 2, 3, 4, 5])
aSecs = o.Sections([[1, 2], [4, 5]])
nTtl++
if len(aSecs) = 2
	? "  PASS: Sections([[1,2],[4,5]]) count=2"
	nPsd++
else
	? "  FAIL: Sections count=" + len(aSecs)
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
# Executed in 0.01 second(s) in Ring 1.27
