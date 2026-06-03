# Integration regression suite for stzListOfNumbers.
# Existing test_engine_listofnumbers.ring covers 9 basic engine paths.
# This suite adds aggregates (Sum/Product/Mean/Median/Min/Max),
# sort variants (SortInAscending / SortInDescending), Reverse,
# Content / NumberOfItems, and edges (empty / single / negatives).
#
# Run from base/number/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzListOfNumbers integration regression ==="

# ------------------------------------------------------------
# Construction + Content
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oLn = new stzListOfNumbers([ 5, 2, 8, 1, 9, 3 ])
aC = oLn.Content()
chk("Content is a list",            isList(aC))
chk("Content len = 6",              len(aC) = 6)
chk("Content[1] = 5",               aC[1] = 5)
chk("Content[6] = 3",               aC[6] = 3)

# ------------------------------------------------------------
# Aggregates
# ------------------------------------------------------------
? ""
? "--- Aggregates ---"

chk("Sum = 28",                     oLn.Sum() = 28)
chk("Product = 2160",               oLn.Product() = 2160)
chk("Min = 1",                      oLn.Min() = 1)
chk("Max = 9",                      oLn.Max() = 9)

# Mean: 28/6 ~ 4.666...
mn = oLn.Mean()
chk("Mean approx 4.667",            isNumber(mn) and mn > 4.6 and mn < 4.7)

# ------------------------------------------------------------
# Median
# ------------------------------------------------------------
? ""
? "--- Median ---"

# [5,2,8,1,9,3] sorted = [1,2,3,5,8,9]; median = (3+5)/2 = 4
oLm = new stzListOfNumbers([ 5, 2, 8, 1, 9, 3 ])
md = oLm.Median()
chk("Median of 6 nums = 4",         md = 4)

# Odd-length: [1,3,5,7,9] median = 5
oLm2 = new stzListOfNumbers([ 1, 3, 5, 7, 9 ])
chk("Median of [1,3,5,7,9] = 5",    oLm2.Median() = 5)

# ------------------------------------------------------------
# Sort
# ------------------------------------------------------------
? ""
? "--- Sort ---"

oLs = new stzListOfNumbers([ 5, 2, 8, 1, 9, 3 ])
oLs.SortInAscending()
aSr = oLs.Content()
chk("Asc sort len = 6",             len(aSr) = 6)
chk("Asc sort [1] = 1",             aSr[1] = 1)
chk("Asc sort [6] = 9",             aSr[6] = 9)
chk("Asc sort middle = 3",          aSr[3] = 3)

oLsd = new stzListOfNumbers([ 5, 2, 8, 1, 9, 3 ])
oLsd.SortInDescending()
aSd = oLsd.Content()
chk("Desc sort [1] = 9",            aSd[1] = 9)
chk("Desc sort [6] = 1",            aSd[6] = 1)

# Passive form
oLsp = new stzListOfNumbers([ 5, 2, 8, 1, 9, 3 ])
aSp = oLsp.SortedInAscending()
chk("SortedInAsc returns list",     isList(aSp))
chk("SortedInAsc first = 1",        aSp[1] = 1)
chk("Passive sort doesn't mutate",  oLsp.Content()[1] = 5)

# ------------------------------------------------------------
# Reverse
# ------------------------------------------------------------
? ""
? "--- Reverse ---"

oLr = new stzListOfNumbers([ 1, 2, 3, 4, 5 ])
oLr.Reverse()
aRv = oLr.Content()
chk("Reverse [1] = 5",              aRv[1] = 5)
chk("Reverse [5] = 1",              aRv[5] = 1)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Single element
oOne = new stzListOfNumbers([ 42 ])
chk("Single Sum = 42",              oOne.Sum() = 42)
chk("Single Min = 42",              oOne.Min() = 42)
chk("Single Max = 42",              oOne.Max() = 42)
chk("Single Mean = 42",             oOne.Mean() = 42)
chk("Single Product = 42",          oOne.Product() = 42)

# All negatives
oNeg = new stzListOfNumbers([ -5, -2, -8, -1 ])
chk("Neg Sum = -16",                oNeg.Sum() = -16)
chk("Neg Min = -8",                 oNeg.Min() = -8)
chk("Neg Max = -1",                 oNeg.Max() = -1)

# Mixed sign
oMix = new stzListOfNumbers([ -3, 0, 5, -2, 10 ])
chk("Mixed Sum = 10",               oMix.Sum() = 10)
chk("Mixed Min = -3",               oMix.Min() = -3)
chk("Mixed Max = 10",               oMix.Max() = 10)

# Empty (edge)
oEm = new stzListOfNumbers([])
chk("Empty Content len = 0",        len(oEm.Content()) = 0)

# All same
oSm = new stzListOfNumbers([ 7, 7, 7, 7 ])
chk("All-same Sum = 28",            oSm.Sum() = 28)
chk("All-same Mean = 7",            oSm.Mean() = 7)
chk("All-same Min = 7",             oSm.Min() = 7)
chk("All-same Max = 7",             oSm.Max() = 7)

# ------------------------------------------------------------
# Floats
# ------------------------------------------------------------
? ""
? "--- Floats ---"

oFl = new stzListOfNumbers([ 1.5, 2.5, 3.5 ])
chk("Float Sum = 7.5",              oFl.Sum() = 7.5)
chk("Float Mean = 2.5",             oFl.Mean() = 2.5)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzListOfNumbers CHECKS PASSED!"
else
	? "SOME stzListOfNumbers CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
