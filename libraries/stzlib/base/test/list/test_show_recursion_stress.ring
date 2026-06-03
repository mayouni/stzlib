# Stress test for the global recursive funcs in stzListShow.
# Pre-cleanup these funcs used bare loop vars (i, j, nLen) which
# clobbered each other on recursive calls. The M-S1 Phase 2 cleanup
# replaced them with per-function _prefixed_ locals. This test
# exercises deeply nested + mutually-recursive paths so any
# regression would surface as wrong output or infinite loops.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzListShow recursion stress ==="

# ------------------------------------------------------------
# Deep nesting
# ------------------------------------------------------------
? ""
? "--- Deep nesting (10 levels) ---"

# Build a 10-level nested list: [1, [2, [3, [4, [5, [6, [7, [8, [9, [10]]]]]]]]]]
# Use explicit deep-copy because Ring's `aDeep = [i, aDeep]` literal
# does NOT make a fresh copy of the inner reference -- the inner aDeep
# can get overwritten on the next iteration of the for loop.
aDeep = [10]
for i = 9 to 1 step -1
	aCopy = []
	for j = 1 to len(aDeep)
		add(aCopy, aDeep[j])
	next
	aDeep = [i, aCopy]
next

nDepth = GetMaxDepth(aDeep)
nTtl++
if nDepth = 10
	nPsd++
	? "  PASS: GetMaxDepth correctly returns 10"
else
	nFld++
	? "  FAIL: GetMaxDepth (got " + nDepth + ")"
ok

# ComputableForm should successfully format it without error
cFmt = ComputableForm(aDeep)
nTtl++
if isString(cFmt) and StzStringContains(cFmt, "10")
	nPsd++
	? "  PASS: ComputableForm formats 10-level nested"
else
	nFld++
	? "  FAIL: ComputableForm 10-level"
ok

# ------------------------------------------------------------
# Mutually-recursive path: ComputableFormNL -> FormatValueSmartNL
#                       -> FormatListSmartNL -> FormatItemForNL
#                       -> FormatListSmartNL (recurses)
# ------------------------------------------------------------
? ""
? "--- Mutually-recursive NL chain ---"

# Trigger the smart NL formatter (lists wider than $nMaxInlineWidth = 50)
aWide = [
    ["alpha", "beta", "gamma"],
    ["delta", "epsilon", "zeta"],
    ["eta", "theta", "iota"]
]

cNL = ComputableFormNL(aWide)
nTtl++
if isString(cNL) and StzStringContains(cNL, "alpha") and StzStringContains(cNL, "iota")
	nPsd++
	? "  PASS: ComputableFormNL processes 2D nested list"
else
	nFld++
	? "  FAIL: ComputableFormNL 2D"
ok

# ------------------------------------------------------------
# Calling recursive funcs MULTIPLE TIMES at the same scope
# (this is where bare-var clobbering manifests pre-cleanup)
# ------------------------------------------------------------
? ""
? "--- Repeated calls at same scope ---"

aOne = [1, [2, 3]]
aTwo = [4, [5, [6, 7]]]
aThree = [8, 9, 10]

# Successive GetMaxDepth calls -- pre-cleanup these would have
# clobbered each others nMaxDepth/nDepth attribute on the (global)
# scope and produced wrong values for whichever ran last
nD1 = GetMaxDepth(aOne)
nD2 = GetMaxDepth(aTwo)
nD3 = GetMaxDepth(aThree)

nTtl++
if nD1 = 2 and nD2 = 3 and nD3 = 1
	nPsd++
	? "  PASS: GetMaxDepth no cross-call clobbering (2, 3, 1)"
else
	nFld++
	? "  FAIL: GetMaxDepth cross-call (got " + nD1 + ", " + nD2 + ", " + nD3 + ")"
ok

# Same for CalculateComplexity (calls GetMaxDepth internally)
nC1 = CalculateComplexity(aOne)
nC2 = CalculateComplexity(aTwo)
nC3 = CalculateComplexity(aThree)

nTtl++
if nC1 > 0 and nC2 > nC1 and nC3 > 0
	nPsd++
	? "  PASS: CalculateComplexity grows with depth and no clobbering"
else
	nFld++
	? "  FAIL: CalculateComplexity (got " + nC1 + ", " + nC2 + ", " + nC3 + ")"
ok

# Same for EstimateInlineWidth (recursive)
nW1 = EstimateInlineWidth([1, 2, 3])
nW2 = EstimateInlineWidth([1, [2, 3], 4])
nW3 = EstimateInlineWidth([1, [2, [3, [4, 5]]], 6])

nTtl++
if nW1 < nW2 and nW2 < nW3
	nPsd++
	? "  PASS: EstimateInlineWidth grows with depth (no clobbering)"
else
	nFld++
	? "  FAIL: EstimateInlineWidth growth (got " + nW1 + ", " + nW2 + ", " + nW3 + ")"
ok

# ------------------------------------------------------------
# Nested calls (recursion via callback chain)
# ContainsNestedLists is called recursively by other funcs
# ------------------------------------------------------------
? ""
? "--- ContainsNestedLists in repeated context ---"

bCnl1 = ContainsNestedLists([1, 2, 3])
bCnl2 = ContainsNestedLists([1, [2], 3])
bCnl3 = ContainsNestedLists([1, [2, [3]], 4])

nTtl++
if bCnl1 = 0 and bCnl2 = 1 and bCnl3 = 1
	nPsd++
	? "  PASS: ContainsNestedLists consistent across calls"
else
	nFld++
	? "  FAIL: ContainsNestedLists (got " + bCnl1 + ", " + bCnl2 + ", " + bCnl3 + ")"
ok

# ------------------------------------------------------------
# FormatShortList -- nested
# ------------------------------------------------------------
? ""
? "--- FormatShortList with long list ---"

# > $nMinValueForShortForm = 10
aLong = []
for i = 1 to 25
	add(aLong, i)
next

cSF = ComputableShortForm(aLong)
nTtl++
if isString(cSF) and StzStringContains(cSF, "...")
	nPsd++
	? "  PASS: ComputableShortForm on 25-item list"
else
	nFld++
	? "  FAIL: ComputableShortForm long list"
ok

# Verify first and last items are present
nTtl++
if StzStringContains(cSF, "1") and StzStringContains(cSF, "25")
	nPsd++
	? "  PASS: short form keeps endpoints"
else
	nFld++
	? "  FAIL: short form endpoints"
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
