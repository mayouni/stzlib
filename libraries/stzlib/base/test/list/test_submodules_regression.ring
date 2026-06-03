# Regression tests for the list submodules cleaned during M-S1
# Phase 2 that lack dedicated test coverage:
# Flattener, Walker, Performer, Trimmer, Stringify, Inserter, Mover

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== List submodule regression tests ==="

# ============================================================
# stzListFlattener
# ============================================================
? ""
? "--- stzListFlattener ---"

oF = new stzListFlattener([1, [2, [3, 4]], 5])

aFlat = oF.Flattened()
nTtl++
if isList(aFlat) and len(aFlat) = 5 and aFlat[1] = 1 and aFlat[2] = 2 and aFlat[3] = 3 and aFlat[4] = 4 and aFlat[5] = 5
	nPsd++
	? "  PASS: Flatten one level"
else
	nFld++
	? "  FAIL: Flatten one level (got " + @@(aFlat) + ")"
ok

oF2 = new stzListFlattener([1, [2, [3, [4, 5]]], 6])
aDeep = oF2.DeepFlattened()
nTtl++
if isList(aDeep) and len(aDeep) = 6 and aDeep[1] = 1 and aDeep[6] = 6
	nPsd++
	? "  PASS: DeepFlatten arbitrary depth"
else
	nFld++
	? "  FAIL: DeepFlatten (got " + @@(aDeep) + ")"
ok

oF3 = new stzListFlattener([1, 2, 3, 4, 5, 6])
aPaired = oF3.Paired()
nTtl++
if isList(aPaired) and len(aPaired) = 3 and isList(aPaired[1]) and aPaired[1][1] = 1 and aPaired[1][2] = 2
	nPsd++
	? "  PASS: Paired groups by 2"
else
	nFld++
	? "  FAIL: Paired (got " + @@(aPaired) + ")"
ok

aChunked = oF3.Chunked(3)
nTtl++
if isList(aChunked) and len(aChunked) = 2 and isList(aChunked[1]) and aChunked[1][3] = 3
	nPsd++
	? "  PASS: Chunked(3) on 6 items = 2 chunks"
else
	nFld++
	? "  FAIL: Chunked (got " + @@(aChunked) + ")"
ok

# Recursive global helpers must survive nesting
oF4 = new stzListFlattener([[[[1]], [[2, 3]]], [[[4]]]])
aDeep2 = oF4.DeepFlattened()
nTtl++
if isList(aDeep2) and len(aDeep2) = 4 and aDeep2[1] = 1 and aDeep2[4] = 4
	nPsd++
	? "  PASS: DeepFlatten recursive helper (4-level nesting)"
else
	nFld++
	? "  FAIL: DeepFlatten recursive (got " + @@(aDeep2) + ")"
ok

# ============================================================
# stzListWalker (engine FindW path)
# ============================================================
? ""
? "--- stzListWalker ---"

oW = new stzListWalker([1, 2, 3, 4, 5])

aFwd = oW.WalkNForward(2)
nTtl++
if isList(aFwd) and len(aFwd) = 3 and aFwd[1] = 1 and aFwd[2] = 3 and aFwd[3] = 5
	nPsd++
	? "  PASS: WalkNForward(2) = [1,3,5]"
else
	nFld++
	? "  FAIL: WalkNForward(2) (got " + @@(aFwd) + ")"
ok

aBwd = oW.WalkNBackward(2)
nTtl++
if isList(aBwd) and len(aBwd) = 3 and aBwd[1] = 5 and aBwd[2] = 3 and aBwd[3] = 1
	nPsd++
	? "  PASS: WalkNBackward(2) = [5,3,1]"
else
	nFld++
	? "  FAIL: WalkNBackward(2) (got " + @@(aBwd) + ")"
ok

aBtw = oW.WalkBetween(2, 4, 1)
nTtl++
if isList(aBtw) and len(aBtw) = 3 and aBtw[1] = 2 and aBtw[3] = 4
	nPsd++
	? "  PASS: WalkBetween(2,4,1) = [2,3,4]"
else
	nFld++
	? "  FAIL: WalkBetween (got " + @@(aBtw) + ")"
ok

aEvery = oW.WalkEveryNth(2)
nTtl++
if isList(aEvery) and len(aEvery) = 2 and aEvery[1] = 2 and aEvery[2] = 4
	nPsd++
	? "  PASS: WalkEveryNth(2) = [2,4]"
else
	nFld++
	? "  FAIL: WalkEveryNth (got " + @@(aEvery) + ")"
ok

# ============================================================
# stzListPerformer (engine MapExpr path)
# ============================================================
? ""
? "--- stzListPerformer ---"

oP = new stzListPerformer([1, 2, 3])
aYielded = oP.Yield("@item * 10")
nTtl++
if isList(aYielded) and len(aYielded) = 3 and aYielded[1] = 10 and aYielded[3] = 30
	nPsd++
	? "  PASS: Yield('@item * 10') = [10,20,30]"
else
	nFld++
	? "  FAIL: Yield (got " + @@(aYielded) + ")"
ok

# ============================================================
# stzListTrimmer
# ============================================================
? ""
? "--- stzListTrimmer ---"

oT = new stzListTrimmer(["", "", "x", "y", "", ""])
aTrimmed = oT.Trimmed()
nTtl++
if isList(aTrimmed) and len(aTrimmed) = 2 and aTrimmed[1] = "x" and aTrimmed[2] = "y"
	nPsd++
	? "  PASS: Trimmed removes empty leading/trailing"
else
	nFld++
	? "  FAIL: Trimmed (got " + @@(aTrimmed) + ")"
ok

oT2 = new stzListTrimmer([1, "", 2, "", 3])
aCompacted = oT2.Compacted()
nTtl++
if isList(aCompacted) and len(aCompacted) = 3 and aCompacted[1] = 1 and aCompacted[3] = 3
	nPsd++
	? "  PASS: Compacted removes empty strings"
else
	nFld++
	? "  FAIL: Compacted (got " + @@(aCompacted) + ")"
ok

oT3 = new stzListTrimmer([1, 2, 3, 4, 5])
aTrunc = oT3.TrimmedToSize(3)
nTtl++
if isList(aTrunc) and len(aTrunc) = 3 and aTrunc[1] = 1 and aTrunc[3] = 3
	nPsd++
	? "  PASS: TrimmedToSize(3) keeps first 3"
else
	nFld++
	? "  FAIL: TrimmedToSize (got " + @@(aTrunc) + ")"
ok

# ============================================================
# stzListStringify
# ============================================================
? ""
? "--- stzListStringify ---"

oS = new stzListStringify(["hello", "world"])
aUp = oS.Uppercased()
nTtl++
if isList(aUp) and len(aUp) = 2 and aUp[1] = "HELLO" and aUp[2] = "WORLD"
	nPsd++
	? "  PASS: Uppercased"
else
	nFld++
	? "  FAIL: Uppercased (got " + @@(aUp) + ")"
ok

oS2 = new stzListStringify(["A", "B"])
aLow = oS2.Lowercased()
nTtl++
if isList(aLow) and aLow[1] = "a" and aLow[2] = "b"
	nPsd++
	? "  PASS: Lowercased"
else
	nFld++
	? "  FAIL: Lowercased"
ok

oS3 = new stzListStringify([1, 2, "x"])
aN2S = oS3.NumbersToStrings()
nTtl++
if isList(aN2S) and aN2S[1] = "1" and aN2S[2] = "2" and aN2S[3] = "x"
	nPsd++
	? "  PASS: NumbersToStrings"
else
	nFld++
	? "  FAIL: NumbersToStrings (got " + @@(aN2S) + ")"
ok

# Singlify removes consecutive duplicates
oS4 = new stzListStringify([1, 1, 2, 2, 2, 3, 1])
oS4.Singlify()
aSingle = oS4.Content()
nTtl++
if isList(aSingle) and len(aSingle) = 4 and aSingle[1] = 1 and aSingle[2] = 2 and aSingle[3] = 3 and aSingle[4] = 1
	nPsd++
	? "  PASS: Singlify removes consecutive dupes"
else
	nFld++
	? "  FAIL: Singlify (got " + @@(aSingle) + ")"
ok

# Join via engine
oS5 = new stzListStringify(["a", "b", "c"])
cJoined = oS5.Join("-")
nTtl++
if cJoined = "a-b-c"
	nPsd++
	? "  PASS: Join('-') = 'a-b-c'"
else
	nFld++
	? "  FAIL: Join (got '" + cJoined + "')"
ok

# ============================================================
# stzListInserter (SwapItems engine)
# ============================================================
? ""
? "--- stzListInserter ---"

oI = new stzListInserter([10, 20, 30])
oI.SwapItems(1, 3)
aSwapped = oI.Content()
nTtl++
if isList(aSwapped) and aSwapped[1] = 30 and aSwapped[2] = 20 and aSwapped[3] = 10
	nPsd++
	? "  PASS: SwapItems(1,3) = [30,20,10]"
else
	nFld++
	? "  FAIL: SwapItems (got " + @@(aSwapped) + ")"
ok

# ============================================================
# stzListMover
# ============================================================
? ""
? "--- stzListMover ---"

oM = new stzListMover([1, 2, 3, 4, 5])
aRotated = oM.RotatedLeft(2)
nTtl++
if isList(aRotated) and len(aRotated) = 5 and aRotated[1] = 3 and aRotated[4] = 1 and aRotated[5] = 2
	nPsd++
	? "  PASS: RotatedLeft(2) = [3,4,5,1,2]"
else
	nFld++
	? "  FAIL: RotatedLeft(2) (got " + @@(aRotated) + ")"
ok

aRotR = oM.RotatedRight(2)
nTtl++
if isList(aRotR) and len(aRotR) = 5 and aRotR[1] = 4 and aRotR[5] = 3
	nPsd++
	? "  PASS: RotatedRight(2) = [4,5,1,2,3]"
else
	nFld++
	? "  FAIL: RotatedRight(2) (got " + @@(aRotR) + ")"
ok

aRev = oM.Reversed()
nTtl++
if isList(aRev) and len(aRev) = 5 and aRev[1] = 5 and aRev[5] = 1
	nPsd++
	? "  PASS: Reversed = [5,4,3,2,1]"
else
	nFld++
	? "  FAIL: Reversed (got " + @@(aRev) + ")"
ok

? ""
? "--- Passive Removed and Replaced chains ---"

oRmv = new stzListRemover([1, 2, 3, 2, 4, 2])
aRem = oRmv.AllOccurrencesRemoved(2)
nTtl++
if isList(aRem) and len(aRem) = 3 and aRem[1] = 1 and aRem[3] = 4
	nPsd++
	? "  PASS: Remover.AllOccurrencesRemoved"
else
	nFld++
	? "  FAIL: Remover.AllOccurrencesRemoved (got " + @@(aRem) + ")"
ok

# Replacer.AllOccurrencesReplaced
oRp = new stzListReplacer(["a", "b", "a", "c", "a"])
aRpl = oRp.AllOccurrencesReplacedCS("a", "X", 1)
nTtl++
if isList(aRpl) and len(aRpl) = 5 and aRpl[1] = "X" and aRpl[3] = "X" and aRpl[5] = "X"
	nPsd++
	? "  PASS: Replacer.AllOccurrencesReplacedCS"
else
	nFld++
	? "  FAIL: Replacer.AllOccurrencesReplacedCS (got " + @@(aRpl) + ")"
ok

# Stringify.Singlified (passive form)
oSt = new stzListStringify([1, 1, 2, 2, 3])
aSt = oSt.Singlified()
nTtl++
if isList(aSt) and len(aSt) = 3 and aSt[1] = 1 and aSt[2] = 2 and aSt[3] = 3
	nPsd++
	? "  PASS: Stringify.Singlified"
else
	nFld++
	? "  FAIL: Stringify.Singlified (got " + @@(aSt) + ")"
ok

# Trimmer.TrimmedLeft
oTm = new stzListTrimmer(["", "", "a", "b", "c"])
aTl = oTm.TrimmedLeft()
nTtl++
if isList(aTl) and len(aTl) = 3 and aTl[1] = "a" and aTl[3] = "c"
	nPsd++
	? "  PASS: Trimmer.TrimmedLeft"
else
	nFld++
	? "  FAIL: Trimmer.TrimmedLeft (got " + @@(aTl) + ")"
ok

# Trimmer.Compacted (already tested above but covers the chain too)
oTc = new stzListTrimmer([1, "", 2, "", 3])
aTc = oTc.Compacted()
nTtl++
if isList(aTc) and len(aTc) = 3
	nPsd++
	? "  PASS: Trimmer.Compacted via chain"
else
	nFld++
	? "  FAIL: Trimmer.Compacted via chain"
ok

# LeadTrail.RepeatedLeadingItemsRemoved
oLt = new stzListLeadTrail(["x", "x", "x", "y", "z"])
aLt = oLt.RepeatedLeadingItemsRemoved()
nTtl++
if isList(aLt) and len(aLt) = 3 and aLt[1] = "x" and aLt[2] = "y" and aLt[3] = "z"
	nPsd++
	? "  PASS: LeadTrail.RepeatedLeadingItemsRemoved"
else
	nFld++
	? "  FAIL: LeadTrail.RepeatedLeadingItemsRemoved (got " + @@(aLt) + ")"
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
