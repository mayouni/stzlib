# Integration regression suite for stzMatrix.
# Existing test_engine_matrix.ring covers Sum/Min/Max via the engine
# delegation. This suite adds construction variants, MultiplyBy,
# Add scalar, Determinant (2x2 + 3x3), Diagonal, and edges
# (1x1 matrix, non-square, very-small / very-large values).
#
# Run from base/number/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzMatrix integration regression ==="

# ------------------------------------------------------------
# Construction from 2D list
# ------------------------------------------------------------
? ""
? "--- Construction (2D list) ---"

oM = new stzMatrix([ [1, 2, 3], [4, 5, 6] ])
chk("Rows() = 2",                   oM.Rows() = 2)
chk("Cols() = 3",                   oM.Cols() = 3)
aSize = oM.Size()
chk("Size() = [2, 3]",              isList(aSize) and aSize[1] = 2 and aSize[2] = 3)

aC = oM.Content()
chk("Content top-left = 1",         aC[1][1] = 1)
chk("Content bottom-right = 6",     aC[2][3] = 6)
chk("Content middle = 5",           aC[2][2] = 5)

# ------------------------------------------------------------
# Construction from dimensions (zero matrix)
# ------------------------------------------------------------
? ""
? "--- Construction (dims) ---"

oZ = new stzMatrix([ 3, 4 ])
chk("Zero matrix Rows = 3",         oZ.Rows() = 3)
chk("Zero matrix Cols = 4",         oZ.Cols() = 4)
aZc = oZ.Content()
chk("Zero matrix [1][1] = 0",       aZc[1][1] = 0)
chk("Zero matrix [3][4] = 0",       aZc[3][4] = 0)
chk("Zero matrix Sum = 0",          oZ.Sum() = 0)

# ------------------------------------------------------------
# MultiplyBy scalar
# ------------------------------------------------------------
? ""
? "--- MultiplyBy scalar ---"

oM1 = new stzMatrix([ [1, 2], [3, 4] ])
oM1.MultiplyBy(10)
aM1c = oM1.Content()
chk("Mul by 10: [1][1] = 10",       aM1c[1][1] = 10)
chk("Mul by 10: [1][2] = 20",       aM1c[1][2] = 20)
chk("Mul by 10: [2][1] = 30",       aM1c[2][1] = 30)
chk("Mul by 10: [2][2] = 40",       aM1c[2][2] = 40)
chk("Mul by 10: Sum = 100",         oM1.Sum() = 100)

# Mul by 0
oM2 = new stzMatrix([ [5, 10], [15, 20] ])
oM2.MultiplyBy(0)
chk("Mul by 0: Sum = 0",            oM2.Sum() = 0)

# Mul by 1 (identity)
oM3 = new stzMatrix([ [1, 2], [3, 4] ])
oM3.MultiplyBy(1)
chk("Mul by 1: Sum preserved",      oM3.Sum() = 10)

# ------------------------------------------------------------
# Sum / Min / Max sanity (engine path)
# ------------------------------------------------------------
? ""
? "--- Sum / Min / Max ---"

oSt = new stzMatrix([ [1, -2, 3], [-4, 5, -6] ])
chk("Sum = 1-2+3-4+5-6 = -3",       oSt.Sum() = -3)
chk("Min = -6",                     oSt.Min() = -6)
chk("Max = 5",                      oSt.Max() = 5)

# ------------------------------------------------------------
# Determinant (2x2 + 3x3)
# ------------------------------------------------------------
? ""
? "--- Determinant ---"

# [[1,2],[3,4]] : det = 1*4 - 2*3 = -2
oDet2 = new stzMatrix([ [1, 2], [3, 4] ])
chk("Det of [[1,2],[3,4]] = -2",    oDet2.Determinant() = -2)

# Singular matrix: [[2,4],[1,2]] : det = 0
oDetS = new stzMatrix([ [2, 4], [1, 2] ])
chk("Singular det = 0",             oDetS.Determinant() = 0)

# Identity-like 2x2
oDetI = new stzMatrix([ [1, 0], [0, 1] ])
chk("Identity 2x2 det = 1",         oDetI.Determinant() = 1)

# 3x3 determinant
# [[1,2,3],[0,1,4],[5,6,0]] = 1*(1*0-4*6) - 2*(0*0-4*5) + 3*(0*6-1*5)
#                          = 1*(-24) - 2*(-20) + 3*(-5)
#                          = -24 + 40 - 15 = 1
oDet3 = new stzMatrix([ [1, 2, 3], [0, 1, 4], [5, 6, 0] ])
chk("3x3 det = 1",                  oDet3.Determinant() = 1)

# ------------------------------------------------------------
# Diagonal
# ------------------------------------------------------------
? ""
? "--- Diagonal ---"

oDg = new stzMatrix([ [1, 2, 3], [4, 5, 6], [7, 8, 9] ])
aDg = oDg.Diagonal()
chk("Diagonal returns list",        isList(aDg))
chk("Diagonal len = 3",             len(aDg) = 3)
chk("Diagonal = [1, 5, 9]",         aDg[1] = 1 and aDg[2] = 5 and aDg[3] = 9)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# 1x1 matrix
oOne = new stzMatrix([ [42] ])
chk("1x1 Rows = 1",                 oOne.Rows() = 1)
chk("1x1 Cols = 1",                 oOne.Cols() = 1)
chk("1x1 Sum = 42",                 oOne.Sum() = 42)
chk("1x1 Det = 42",                 oOne.Determinant() = 42)

# Single row matrix (1x3)
oR1 = new stzMatrix([ [10, 20, 30] ])
chk("1x3 Rows = 1",                 oR1.Rows() = 1)
chk("1x3 Cols = 3",                 oR1.Cols() = 3)
chk("1x3 Sum = 60",                 oR1.Sum() = 60)

# Single col matrix (3x1)
oC1 = new stzMatrix([ [10], [20], [30] ])
chk("3x1 Rows = 3",                 oC1.Rows() = 3)
chk("3x1 Cols = 1",                 oC1.Cols() = 1)
chk("3x1 Sum = 60",                 oC1.Sum() = 60)

# Negative-only matrix
oNeg = new stzMatrix([ [-1, -2], [-3, -4] ])
chk("Negative Sum = -10",           oNeg.Sum() = -10)
chk("Negative Min = -4",            oNeg.Min() = -4)
chk("Negative Max = -1",            oNeg.Max() = -1)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzMatrix CHECKS PASSED!"
else
	? "SOME stzMatrix CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
