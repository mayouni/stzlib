# Integration regression suite for stzList2D.
# Class extends stzListOfLists; primary surface is Transpose() and
# its many aliases (Turn / SwapColsAndRows / SwapRowsAndCols /
# SwitchColsAndRows / SwitchRowsAndCols) + passive forms (Transposed
# / *Swapped / *Switched).
#
# Run from base/list/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzList2D integration regression ==="

# A 2x3 matrix-shaped 2D list
aSample = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ]
]

# ------------------------------------------------------------
# Construction
# ------------------------------------------------------------
? ""
? "--- Construction ---"

o2D = new stzList2D(aSample)
chk("Content len = 2 (rows)",       len(o2D.Content()) = 2)
chk("Content[1] len = 3 (cols)",    len(o2D.Content()[1]) = 3)
chk("Content[1][1] = 1",            o2D.Content()[1][1] = 1)
chk("Content[2][3] = 6",            o2D.Content()[2][3] = 6)
chk("List2D alias works",           len(o2D.List2D()) = 2)

# ------------------------------------------------------------
# Transpose (active)
# ------------------------------------------------------------
? ""
? "--- Transpose ---"

oT = new stzList2D(aSample)
oT.Transpose()
aT = oT.Content()
chk("After Transpose: 3 rows",      len(aT) = 3)
chk("After Transpose: 2 cols",      len(aT[1]) = 2)
chk("Transpose [1][1] = 1",         aT[1][1] = 1)
chk("Transpose [1][2] = 4",         aT[1][2] = 4)
chk("Transpose [3][1] = 3",         aT[3][1] = 3)
chk("Transpose [3][2] = 6",         aT[3][2] = 6)

# Double transpose should restore
oT.Transpose()
aT2 = oT.Content()
chk("Double Transpose: 2 rows",     len(aT2) = 2)
chk("Double Transpose [1][1] = 1",  aT2[1][1] = 1)
chk("Double Transpose [2][3] = 6",  aT2[2][3] = 6)

# ------------------------------------------------------------
# Aliases (all should produce same result as Transpose)
# ------------------------------------------------------------
? ""
? "--- Aliases ---"

oTr = new stzList2D(aSample)
oTr.Turn()
chk("Turn = Transpose: [3][1] = 3", oTr.Content()[3][1] = 3)

oSwap = new stzList2D(aSample)
oSwap.SwapColsAndRows()
chk("SwapColsAndRows produces 3 rows", len(oSwap.Content()) = 3)

oSwap2 = new stzList2D(aSample)
oSwap2.SwapRowsAndCols()
chk("SwapRowsAndCols [1][1] = 1",   oSwap2.Content()[1][1] = 1)

oSw = new stzList2D(aSample)
oSw.SwitchColsAndRows()
chk("SwitchColsAndRows [2][1] = 2", oSw.Content()[2][1] = 2)

oSw2 = new stzList2D(aSample)
oSw2.SwitchRowsAndCols()
chk("SwitchRowsAndCols [3][2] = 6", oSw2.Content()[3][2] = 6)

# ------------------------------------------------------------
# Passive forms (Transposed / *Swapped / *Switched)
# ------------------------------------------------------------
? ""
? "--- Passive forms ---"

oP = new stzList2D(aSample)
aPas = oP.Transposed()
chk("Transposed returns list",      isList(aPas))
chk("Transposed result has 3 rows", len(aPas) = 3)
chk("Transposed leaves self",       len(oP.Content()) = 2)

aSwd = oP.ColsAndRowsSwapped()
chk("ColsAndRowsSwapped works",     len(aSwd) = 3)
chk("Still hasn't mutated self",    len(oP.Content()) = 2)

aRowsCols = oP.RowsAndColsSwapped()
chk("RowsAndColsSwapped works",     len(aRowsCols) = 3)

aSwitched = oP.ColsAndRowsSwitched()
chk("ColsAndRowsSwitched works",    len(aSwitched) = 3)

aRowsSw = oP.RowsAndColsSwitched()
chk("RowsAndColsSwitched works",    len(aRowsSw) = 3)

# ------------------------------------------------------------
# Fluent Q form
# ------------------------------------------------------------
? ""
? "--- Q form ---"

oQ = new stzList2D(aSample)
ret = oQ.TransposeQ()
chk("TransposeQ returns This",      isObject(ret))
chk("TransposeQ mutated self",      len(oQ.Content()) = 3)

# Chain
oCh = new stzList2D(aSample)
oCh.TransposeQ().TransposeQ()
chk("Chain restores 2 rows",        len(oCh.Content()) = 2)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Square matrix
oSq = new stzList2D([
	[ 1, 2 ],
	[ 3, 4 ]
])
oSq.Transpose()
aSq = oSq.Content()
chk("Square 2x2 transpose [1][2]=3", aSq[1][2] = 3)
chk("Square 2x2 transpose [2][1]=2", aSq[2][1] = 2)

# Single row -> single column
oSr = new stzList2D([ [ 10, 20, 30 ] ])
oSr.Transpose()
aSrT = oSr.Content()
chk("1x3 -> 3x1: rows = 3",         len(aSrT) = 3)
chk("1x3 -> 3x1: [1][1] = 10",      aSrT[1][1] = 10)
chk("1x3 -> 3x1: [3][1] = 30",      aSrT[3][1] = 30)

# Single column -> single row
oSc = new stzList2D([
	[ "a" ],
	[ "b" ],
	[ "c" ]
])
oSc.Transpose()
aScT = oSc.Content()
chk("3x1 -> 1x3: rows = 1",         len(aScT) = 1)
chk("3x1 -> 1x3: cols = 3",         len(aScT[1]) = 3)
chk("3x1 -> 1x3: [1][2] = b",       aScT[1][2] = "b")

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzList2D CHECKS PASSED!"
else
	? "SOME stzList2D CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
