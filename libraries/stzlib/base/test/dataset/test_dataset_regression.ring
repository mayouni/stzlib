# Integration regression for stzDataSet.
# Tests core descriptive statistics: Mean / Median / Mode / Variance /
# StdDev / Min / Max / Range + aliases.
#
# Run from base/stats/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzDataSet integration regression ==="

# ------------------------------------------------------------
# Numeric dataset
# ------------------------------------------------------------
? ""
? "--- Numeric ---"

oD = new stzDataSet([ 1, 2, 3, 4, 5 ])
chk("Mean = 3",                      oD.Mean() = 3)
chk("Average alias = 3",             oD.Average() = 3)
chk("Avrg alias = 3",                oD.Avrg() = 3)

chk("Median = 3",                    oD.Median() = 3)
chk("Min = 1",                       oD.Min() = 1)
chk("Max = 5",                       oD.Max() = 5)
chk("Range = 4",                     oD.Range() = 4)

# Variance / StdDev: just check non-NULL + numeric
nV = oD.Variance()
chk("Variance returns number",       isNumber(nV) and nV > 0)
chk("Var alias",                     oD.Var() = nV)
chk("V alias",                       oD.V() = nV)

nSd = oD.StandardDeviation()
chk("StdDev returns number > 0",     isNumber(nSd) and nSd > 0)
chk("StdDev alias",                  oD.StdDev() = nSd)

# ------------------------------------------------------------
# Even-length median
# ------------------------------------------------------------
? ""
? "--- Even-length median ---"

oE = new stzDataSet([ 1, 2, 3, 4 ])
chk("Median of [1,2,3,4] = 2.5",     oE.Median() = 2.5)

# ------------------------------------------------------------
# Single value
# ------------------------------------------------------------
? ""
? "--- Single value ---"

oOne = new stzDataSet([ 42 ])
chk("Single: Mean = 42",             oOne.Mean() = 42)
chk("Single: Min = Max = 42",        oOne.Min() = 42 and oOne.Max() = 42)
chk("Single: Range = 0",             oOne.Range() = 0)

# ------------------------------------------------------------
# Categorical
# ------------------------------------------------------------
? ""
? "--- Categorical ---"

oC = new stzDataSet([ "a", "b", "a", "c" ])
cMode = oC.Mode()
chk("Mode returns",                  cMode != NULL)
# Most-frequent: "a"
chk("Mode of ['a','b','a','c']",     cMode = "a" or (isList(cMode) and cMode[1] = "a"))

# ------------------------------------------------------------
# Empty
# ------------------------------------------------------------
? ""
? "--- Empty ---"

oEm = new stzDataSet([])
chk("Empty Mean = 0",                oEm.Mean() = 0)
chk("Empty Median = 0",              oEm.Median() = 0)

# ------------------------------------------------------------
# Bad ctor
# ------------------------------------------------------------
? ""
? "--- Bad input ---"

bRaised = 0
try
	oBad = new stzDataSet("not a list")
catch
	bRaised = 1
done
chk("Non-list ctor raises",          bRaised = 1)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzDataSet CHECKS PASSED!"
else
	? "SOME stzDataSet CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
