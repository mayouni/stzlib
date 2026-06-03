# Third batch of submodule regression tests covering Classifier,
# Extractor, Merger, Duplicates, Splits, Sections.

load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== List submodule regression tests (batch 3) ==="

# ============================================================
# stzListExtractor
# ============================================================
? ""
? "--- stzListExtractor ---"

oEx = new stzListExtractor([1, 2, 3, 4, 5])

nTtl++
xExt = oEx.ExtractFirst()
if xExt = 1 and oEx.NumberOfItems() = 4
	nPsd++
	? "  PASS: ExtractFirst removes and returns 1"
else
	nFld++
	? "  FAIL: ExtractFirst (got " + xExt + ")"
ok

oEx2 = new stzListExtractor([10, 20, 30, 40])
nTtl++
xExt2 = oEx2.ExtractLast()
if xExt2 = 40 and oEx2.NumberOfItems() = 3
	nPsd++
	? "  PASS: ExtractLast removes and returns 40"
else
	nFld++
	? "  FAIL: ExtractLast (got " + xExt2 + ")"
ok

oEx3 = new stzListExtractor([1, 2, 3, 4, 5])
aSec = oEx3.ExtractSection(2, 4)
nTtl++
if isList(aSec) and len(aSec) = 3 and aSec[1] = 2 and aSec[3] = 4
	nPsd++
	? "  PASS: ExtractSection(2,4) returns [2,3,4]"
else
	nFld++
	? "  FAIL: ExtractSection (got " + @@(aSec) + ")"
ok

# Type extractors
oEx4 = new stzListExtractor([1, "a", 2, "b", 3])
aStr = oEx4.ExtractStrings()
nTtl++
if isList(aStr) and len(aStr) = 2 and aStr[1] = "a" and aStr[2] = "b"
	nPsd++
	? "  PASS: ExtractStrings"
else
	nFld++
	? "  FAIL: ExtractStrings (got " + @@(aStr) + ")"
ok

# After ExtractStrings the original should only have numbers
nTtl++
if oEx4.NumberOfItems() = 3 and oEx4.Content()[1] = 1 and oEx4.Content()[3] = 3
	nPsd++
	? "  PASS: ExtractStrings leaves only numbers"
else
	nFld++
	? "  FAIL: ExtractStrings left wrong content"
ok

# Pop = ExtractLast alias
oEx5 = new stzListExtractor(["a", "b", "c"])
xPop = oEx5.Pop()
nTtl++
if xPop = "c" and oEx5.NumberOfItems() = 2
	nPsd++
	? "  PASS: Pop returns last and removes"
else
	nFld++
	? "  FAIL: Pop"
ok

# Take = ExtractSection alias
oEx6 = new stzListExtractor([1, 2, 3, 4, 5])
aTake = oEx6.Take(3)
nTtl++
if isList(aTake) and len(aTake) = 3 and aTake[3] = 3
	nPsd++
	? "  PASS: Take(3) returns first 3"
else
	nFld++
	? "  FAIL: Take (got " + @@(aTake) + ")"
ok

# ============================================================
# stzListMerger
# ============================================================
? ""
? "--- stzListMerger ---"

# DiffWith
oM = new stzListMerger([1, 2, 3, 4, 5])
aDiff = oM.DiffWith([2, 4])
nTtl++
if isList(aDiff) and len(aDiff) = 3 and aDiff[1] = 1 and aDiff[3] = 5
	nPsd++
	? "  PASS: DiffWith([2,4]) = [1,3,5]"
else
	nFld++
	? "  FAIL: DiffWith (got " + @@(aDiff) + ")"
ok

# IntersectWith
aInt = oM.IntersectWith([3, 4, 5, 6])
nTtl++
if isList(aInt) and len(aInt) = 3
	nPsd++
	? "  PASS: IntersectWith returns 3 common"
else
	nFld++
	? "  FAIL: IntersectWith (got " + @@(aInt) + ")"
ok

# UnionWith
aUni = oM.UnionWith([3, 6, 7])
nTtl++
if isList(aUni) and len(aUni) = 7
	nPsd++
	? "  PASS: UnionWith returns 7 unique items"
else
	nFld++
	? "  FAIL: UnionWith (got " + @@(aUni) + ")"
ok

# ZipWith
oM2 = new stzListMerger(["a", "b", "c"])
aZip = oM2.ZipWith([1, 2, 3])
nTtl++
if isList(aZip) and len(aZip) = 3 and isList(aZip[1]) and aZip[1][1] = "a" and aZip[1][2] = 1
	nPsd++
	? "  PASS: ZipWith pairs corresponding items"
else
	nFld++
	? "  FAIL: ZipWith (got " + @@(aZip) + ")"
ok

# InterleaveWith
oM3 = new stzListMerger([1, 3, 5])
oM3.InterleaveWith([2, 4, 6])
aInter = oM3.Content()
nTtl++
if isList(aInter) and len(aInter) = 6 and aInter[1] = 1 and aInter[2] = 2 and aInter[3] = 3
	nPsd++
	? "  PASS: InterleaveWith alternates items"
else
	nFld++
	? "  FAIL: InterleaveWith (got " + @@(aInter) + ")"
ok

# Partition
oM4 = new stzListMerger([1, 2, 3, 4, 5, 6])
aPart = oM4.Partition(3)
nTtl++
if isList(aPart) and len(aPart) = 3
	nPsd++
	? "  PASS: Partition(3) = 3 groups"
else
	nFld++
	? "  FAIL: Partition (got " + @@(aPart) + ")"
ok

# Flattened (Merger has Flatten too)
oM5 = new stzListMerger([1, [2, 3], 4])
aFlat = oM5.Flattened()
nTtl++
if isList(aFlat) and len(aFlat) = 4 and aFlat[1] = 1 and aFlat[2] = 2 and aFlat[4] = 4
	nPsd++
	? "  PASS: Merger.Flattened one level"
else
	nFld++
	? "  FAIL: Merger.Flattened (got " + @@(aFlat) + ")"
ok

# ============================================================
# stzListDuplicates
# ============================================================
? ""
? "--- stzListDuplicates ---"

oD = new stzListDuplicates([1, 2, 3, 2, 4, 2, 5, 3])

aDup = oD.DuplicatedItems()
nTtl++
if isList(aDup) and len(aDup) >= 2
	nPsd++
	? "  PASS: DuplicatedItems found duplicates"
else
	nFld++
	? "  FAIL: DuplicatedItems (got " + @@(aDup) + ")"
ok

nTtl++
if oD.HasDuplicates() = 1
	nPsd++
	? "  PASS: HasDuplicates = 1"
else
	nFld++
	? "  FAIL: HasDuplicates"
ok

oD2 = new stzListDuplicates([1, 2, 3, 4])
nTtl++
if oD2.HasDuplicates() = 0
	nPsd++
	? "  PASS: HasDuplicates = 0 on unique list"
else
	nFld++
	? "  FAIL: HasDuplicates unique"
ok

oD3 = new stzListDuplicates([1, 2, 2, 3, 3, 3])
oD3.RemoveDuplicates()
nTtl++
if oD3.NumberOfItems() = 3 and oD3.Content()[1] = 1 and oD3.Content()[3] = 3
	nPsd++
	? "  PASS: RemoveDuplicates leaves uniques"
else
	nFld++
	? "  FAIL: RemoveDuplicates (got " + @@(oD3.Content()) + ")"
ok

oD4 = new stzListDuplicates([1, 2, 2, 3])
aUnique = oD4.UniqueItems()
nTtl++
if isList(aUnique) and len(aUnique) = 3
	nPsd++
	? "  PASS: UniqueItems returns 3"
else
	nFld++
	? "  FAIL: UniqueItems (got " + @@(aUnique) + ")"
ok

nTtl++
if oD.NumberOfDuplicates() >= 2
	nPsd++
	? "  PASS: NumberOfDuplicates >= 2"
else
	nFld++
	? "  FAIL: NumberOfDuplicates (got " + oD.NumberOfDuplicates() + ")"
ok

# ============================================================
# stzListSplits
# ============================================================
? ""
? "--- stzListSplits ---"

# Use passive Splitted* forms which return the result.
oS = new stzListSplits([1, 2, 3, 4, 5, 6])
aSpA = oS.SplittedAtPosition(3)
nTtl++
if isList(aSpA) and len(aSpA) = 2
	nPsd++
	? "  PASS: SplittedAtPosition(3) returns 2 parts"
else
	nFld++
	? "  FAIL: SplittedAtPosition (got " + @@(aSpA) + ")"
ok

oS2 = new stzListSplits([1, 2, 3, 4, 5])
aSpB = oS2.SplittedBeforePosition(3)
nTtl++
if isList(aSpB) and len(aSpB) = 2
	nPsd++
	? "  PASS: SplittedBeforePosition(3) returns 2 parts"
else
	nFld++
	? "  FAIL: SplittedBeforePosition (got " + @@(aSpB) + ")"
ok

oS3 = new stzListSplits([1, 2, 3, 4, 5, 6, 7, 8])
aSpN = oS3.SplittedToPartsOfNItems(3)
nTtl++
if isList(aSpN) and len(aSpN) >= 2
	nPsd++
	? "  PASS: SplittedToPartsOfNItems(3) returns multiple parts"
else
	nFld++
	? "  FAIL: SplittedToPartsOfNItems (got " + @@(aSpN) + ")"
ok

# ============================================================
# stzListSections (already partially covered by delegations test)
# ============================================================
? ""
? "--- stzListSections ---"

oSec = new stzListSections([10, 20, 30, 40, 50])
aSec1 = oSec.Section(2, 4)
nTtl++
if isList(aSec1) and len(aSec1) = 3 and aSec1[1] = 20 and aSec1[3] = 40
	nPsd++
	? "  PASS: Sections.Section(2,4) = [20,30,40]"
else
	nFld++
	? "  FAIL: Sections.Section (got " + @@(aSec1) + ")"
ok

aMany = oSec.Sections([[1, 2], [4, 5]])
nTtl++
if isList(aMany) and len(aMany) = 2
	nPsd++
	? "  PASS: Sections([[1,2],[4,5]]) returns 2 sections"
else
	nFld++
	? "  FAIL: Sections (got " + @@(aMany) + ")"
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
