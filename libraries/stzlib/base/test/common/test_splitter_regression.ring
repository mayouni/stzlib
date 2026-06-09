# Integration regression suite for stzSplitter.
# Numeric splitter -- given a total number of positions, returns
# section descriptors when splitting at one or many positions.
#
# Run from base/common/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzSplitter integration regression ==="

# ------------------------------------------------------------
# Construction
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oSp = new stzSplitter(10)
chk("NumberOfPositions = 10",       oSp.NumberOfPositions() = 10)
chk("NumberOfItems alias = 10",     oSp.NumberOfItems() = 10)

aC = oSp.Content()
chk("Content is list",              isList(aC))
chk("Content len = 10",             len(aC) = 10)
chk("Content[1] = 1",               aC[1] = 1)
chk("Content[10] = 10",             aC[10] = 10)

# ------------------------------------------------------------
# SplitAtPosition: middle
# ------------------------------------------------------------
? ""
? "--- SplitAtPosition middle ---"

# Splitting [1..10] at position 5 -> [[1,4], [6,10]]
aR = oSp.SplitAtPosition(5)
chk("Middle split returns 2 sections", isList(aR) and len(aR) = 2)
chk("First section [1, 4]",         aR[1][1] = 1 and aR[1][2] = 4)
chk("Second section [6, 10]",       aR[2][1] = 6 and aR[2][2] = 10)

# ------------------------------------------------------------
# SplitAtPosition: at position 1 (head)
# ------------------------------------------------------------
? ""
? "--- SplitAtPosition head ---"

aH = oSp.SplitAtPosition(1)
chk("Head split returns 1 section", isList(aH) and len(aH) = 1)
chk("Section [2, 10]",              aH[1][1] = 2 and aH[1][2] = 10)

# ------------------------------------------------------------
# SplitAtPosition: at last position (tail)
# ------------------------------------------------------------
? ""
? "--- SplitAtPosition tail ---"

aT = oSp.SplitAtPosition(10)
chk("Tail split returns 1 section", isList(aT) and len(aT) = 1)
chk("Section [1, 9]",               aT[1][1] = 1 and aT[1][2] = 9)

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------
? ""
? "--- Aliases ---"

aA = oSp.SplitsAtPosition(5)
chk("SplitsAtPosition alias works", isList(aA) and len(aA) = 2)

aB = oSp.Split(5)
chk("Split alias works",            isList(aB))

# ------------------------------------------------------------
# Construction with pair (positions, partLen)
# ------------------------------------------------------------
? ""
? "--- Pair ctor ---"

oP = new stzSplitter([ 10, 2 ])
chk("Pair ctor NumberOfPositions",  oP.NumberOfPositions() = 10)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Small splitter
oTwo = new stzSplitter(2)
aRtwo = oTwo.SplitAtPosition(1)
chk("Split(2 positions, at 1)",     len(aRtwo) = 1 and aRtwo[1][1] = 2 and aRtwo[1][2] = 2)

# Bad input raises
bRaised = 0
try
	oBad = new stzSplitter("abc")
catch
	bRaised = 1
done
chk("Non-numeric ctor raises",      bRaised = 1)

bRaised2 = 0
try
	oNeg = new stzSplitter(-5)
catch
	bRaised2 = 1
done
chk("Negative ctor raises",         bRaised2 = 1)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzSplitter CHECKS PASSED!"
else
	? "SOME stzSplitter CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
