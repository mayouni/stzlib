# Fourth batch of submodule regression tests covering Show (global
# recursive formatters) and expanded Classifier coverage.
#
# The Show functions are recursive globals -- the M-S1 Phase 2
# cleanup made them recursion-safe by giving each function unique
# _prefixed_ locals. These tests exercise nested input so that
# the recursive paths actually run.

load "../../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== List submodule regression tests (batch 4) ==="

# ============================================================
# stzListShow -- global recursive formatters
# ============================================================
? ""
? "--- stzListShow ComputableForm (FormatValue/FormatList) ---"

# Basic types
nTtl++
if ComputableForm(42) = "42"
	nPsd++
	? "  PASS: ComputableForm(42)"
else
	nFld++
	? "  FAIL: ComputableForm(42) = '" + ComputableForm(42) + "'"
ok

nTtl++
if ComputableForm("hi") = '"hi"'
	nPsd++
	? "  PASS: ComputableForm string"
else
	nFld++
	? "  FAIL: ComputableForm string"
ok

# Empty list
nTtl++
if ComputableForm([]) = "[ ]"
	nPsd++
	? "  PASS: ComputableForm empty list"
else
	nFld++
	? "  FAIL: ComputableForm empty list = '" + ComputableForm([]) + "'"
ok

# Flat list
cFlat = ComputableForm([1, 2, 3])
nTtl++
if StzStringContains(cFlat, "1") and StzStringContains(cFlat, "2") and StzStringContains(cFlat, "3")
	nPsd++
	? "  PASS: ComputableForm flat list contains all items"
else
	nFld++
	? "  FAIL: ComputableForm flat list = '" + cFlat + "'"
ok

# Nested list (exercises FormatList recursive call)
cNested = ComputableForm([1, [2, 3], 4])
nTtl++
if StzStringContains(cNested, "1") and StzStringContains(cNested, "2") and StzStringContains(cNested, "3") and StzStringContains(cNested, "4")
	nPsd++
	? "  PASS: ComputableForm nested -- recursion safe"
else
	nFld++
	? "  FAIL: ComputableForm nested = '" + cNested + "'"
ok

# Deeply nested (3 levels)
cDeep = ComputableForm([1, [2, [3, [4, 5]]], 6])
nTtl++
if StzStringContains(cDeep, "1") and StzStringContains(cDeep, "5") and StzStringContains(cDeep, "6")
	nPsd++
	? "  PASS: ComputableForm 4-level nested -- recursion safe"
else
	nFld++
	? "  FAIL: ComputableForm 4-level nested = '" + cDeep + "'"
ok

? ""
? "--- stzListShow GetMaxDepth / CalculateComplexity ---"

# GetMaxDepth -- recursive
nTtl++
if GetMaxDepth([1, 2, 3]) = 1
	nPsd++
	? "  PASS: GetMaxDepth flat = 1"
else
	nFld++
	? "  FAIL: GetMaxDepth flat (got " + GetMaxDepth([1,2,3]) + ")"
ok

nTtl++
if GetMaxDepth([1, [2, 3], 4]) = 2
	nPsd++
	? "  PASS: GetMaxDepth 2-level = 2"
else
	nFld++
	? "  FAIL: GetMaxDepth 2-level (got " + GetMaxDepth([1,[2,3],4]) + ")"
ok

nTtl++
if GetMaxDepth([1, [2, [3, [4, 5]]], 6]) = 4
	nPsd++
	? "  PASS: GetMaxDepth 4-level = 4 -- recursion safe"
else
	nFld++
	? "  FAIL: GetMaxDepth 4-level (got " + GetMaxDepth([1, [2, [3, [4, 5]]], 6]) + ")"
ok

# CalculateComplexity is recursive via GetMaxDepth
nCpx = CalculateComplexity([1, [2, 3], [4, 5, 6]])
nTtl++
if isNumber(nCpx) and nCpx > 0
	nPsd++
	? "  PASS: CalculateComplexity returns positive"
else
	nFld++
	? "  FAIL: CalculateComplexity (got " + @@(nCpx) + ")"
ok

? ""
? "--- stzListShow EstimateInlineWidth / ContainsNestedLists ---"

# EstimateInlineWidth is recursive
nW1 = EstimateInlineWidth([1, 2, 3])
nW2 = EstimateInlineWidth([1, [2, 3], 4])
nTtl++
if isNumber(nW1) and isNumber(nW2) and nW2 > nW1
	nPsd++
	? "  PASS: EstimateInlineWidth grows with nesting"
else
	nFld++
	? "  FAIL: EstimateInlineWidth"
ok

nTtl++
if ContainsNestedLists([1, [2], 3]) = 1
	nPsd++
	? "  PASS: ContainsNestedLists detects inner list"
else
	nFld++
	? "  FAIL: ContainsNestedLists"
ok

nTtl++
if ContainsNestedLists([1, 2, 3]) = 0
	nPsd++
	? "  PASS: ContainsNestedLists false on flat list"
else
	nFld++
	? "  FAIL: ContainsNestedLists false"
ok

? ""
? "--- stzListShow Short forms ---"

# ComputableShortForm -- works on string longer than $nMinValueForShortForm (10)
cLong = "abcdefghijklmnopqrstu"
cShort = ComputableShortForm(cLong)
nTtl++
if StzStringContains(cShort, "...")
	nPsd++
	? "  PASS: ComputableShortForm inserts ellipsis"
else
	nFld++
	? "  FAIL: ComputableShortForm no ellipsis"
ok

# ComputableShortFormXT with explicit nItems
cShortXT = ComputableShortFormXT([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 2)
nTtl++
if StzStringContains(cShortXT, "...")
	nPsd++
	? "  PASS: ComputableShortFormXT inserts ellipsis in list"
else
	nFld++
	? "  FAIL: ComputableShortFormXT no ellipsis"
ok

# @@NL1 -- multi-line format
cNL1 = @@NL1([1, 2, 3])
nTtl++
if isString(cNL1) and StzStringContains(cNL1, "1") and StzStringContains(cNL1, "3")
	nPsd++
	? "  PASS: @@NL1 multi-line format"
else
	nFld++
	? "  FAIL: @@NL1"
ok

# ============================================================
# stzListClassifier -- expanded coverage
# ============================================================
? ""
? "--- stzListClassifier (expanded) ---"

oC = new stzListClassifier(["x", "y", "x", "z", "x", "y"])

nTtl++
if oC.NumberOfClasses() = 3
	nPsd++
	? "  PASS: NumberOfClasses = 3"
else
	nFld++
	? "  FAIL: NumberOfClasses"
ok

aClasses = oC.Classes()
nTtl++
if isList(aClasses) and len(aClasses) = 3
	nPsd++
	? "  PASS: Classes returns 3 names"
else
	nFld++
	? "  FAIL: Classes (got " + @@(aClasses) + ")"
ok

# FrequencyOf -- engine-backed (CountCS)
nTtl++
if oC.FrequencyOf("x") = 3
	nPsd++
	? "  PASS: FrequencyOf x = 3"
else
	nFld++
	? "  FAIL: FrequencyOf x (got " + oC.FrequencyOf("x") + ")"
ok

nTtl++
if oC.FrequencyOf("y") = 2
	nPsd++
	? "  PASS: FrequencyOf y = 2"
else
	nFld++
	? "  FAIL: FrequencyOf y (got " + oC.FrequencyOf("y") + ")"
ok

nTtl++
if oC.MostFrequent() = "x"
	nPsd++
	? "  PASS: MostFrequent = x"
else
	nFld++
	? "  FAIL: MostFrequent (got " + oC.MostFrequent() + ")"
ok

nTtl++
if oC.LeastFrequent() = "z"
	nPsd++
	? "  PASS: LeastFrequent = z"
else
	nFld++
	? "  FAIL: LeastFrequent (got " + oC.LeastFrequent() + ")"
ok

# Mode -- list of all top-tied items
aMode = oC.Mode()
nTtl++
if isList(aMode) and len(aMode) = 1 and aMode[1] = "x"
	nPsd++
	? "  PASS: Mode = [x]"
else
	nFld++
	? "  FAIL: Mode (got " + @@(aMode) + ")"
ok

# Bisect / FirstHalf / SecondHalf
oC2 = new stzListClassifier([1, 2, 3, 4, 5, 6])
aBis = oC2.Bisect()
nTtl++
if isList(aBis) and len(aBis) = 2 and len(aBis[1]) = 3 and len(aBis[2]) = 3
	nPsd++
	? "  PASS: Bisect splits 6 items into 3+3"
else
	nFld++
	? "  FAIL: Bisect"
ok

aFh = oC2.FirstHalf()
nTtl++
if isList(aFh) and len(aFh) = 3 and aFh[1] = 1 and aFh[3] = 3
	nPsd++
	? "  PASS: FirstHalf = [1,2,3]"
else
	nFld++
	? "  FAIL: FirstHalf"
ok

aSh = oC2.SecondHalf()
nTtl++
if isList(aSh) and len(aSh) = 3 and aSh[1] = 4 and aSh[3] = 6
	nPsd++
	? "  PASS: SecondHalf = [4,5,6]"
else
	nFld++
	? "  FAIL: SecondHalf"
ok

# Chunks (engine-backed)
aCh = oC2.Chunks(2)
nTtl++
if isList(aCh) and len(aCh) = 3
	nPsd++
	? "  PASS: Chunks(2) = 3 chunks"
else
	nFld++
	? "  FAIL: Chunks (got " + @@(aCh) + ")"
ok

# Partition into n groups
aPart = oC2.Partition(3)
nTtl++
if isList(aPart) and len(aPart) = 3
	nPsd++
	? "  PASS: Partition(3) = 3 groups"
else
	nFld++
	? "  FAIL: Partition (got " + @@(aPart) + ")"
ok

# ItemsAppearingNTimes
oC3 = new stzListClassifier([1, 1, 2, 3, 3, 3])
aTwo = oC3.ItemsAppearingNTimes(2)
nTtl++
if isList(aTwo) and len(aTwo) = 1 and aTwo[1] = 1
	nPsd++
	? "  PASS: ItemsAppearingNTimes(2) = [1]"
else
	nFld++
	? "  FAIL: ItemsAppearingNTimes(2) (got " + @@(aTwo) + ")"
ok

aMore = oC3.ItemsAppearingMoreThanNTimes(2)
nTtl++
if isList(aMore) and len(aMore) = 1 and aMore[1] = 3
	nPsd++
	? "  PASS: ItemsAppearingMoreThanNTimes(2) = [3]"
else
	nFld++
	? "  FAIL: ItemsAppearingMoreThanNTimes (got " + @@(aMore) + ")"
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
