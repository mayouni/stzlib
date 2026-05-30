# Integration regression suite for stzPivotTable.
# Existing test_pivot_engine_delegation.ring covers 10 engine-level
# paths. This suite exercises the user-facing API: Analyze + By +
# Generate, then Value / RowTotal / ColumnTotal / GrandTotal lookups.
#
# Run from base/table/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzPivotTable integration regression ==="

# ------------------------------------------------------------
# Sales dataset for pivot
# ------------------------------------------------------------
aData = [
	[ :Region, :Product, :Sales ],
	[ "North", "A", 10 ],
	[ "North", "B", 20 ],
	[ "South", "A", 30 ],
	[ "South", "B", 40 ],
	[ "East",  "A", 50 ],
	[ "East",  "B", 60 ]
]

oTab = new stzTable(aData)

? ""
? "--- SUM pivot: Sales by Region (rows) x Product (cols) ---"

oP = new stzPivotTable(oTab)
oP {
	Analyze([:Sales], "SUM")
	By([:Region], [:Product])
	Generate()
}

# Cell values
chk("Value(North, A) = 10",         oP.Value([ "North" ], [ "A" ]) = 10)
chk("Value(North, B) = 20",         oP.Value([ "North" ], [ "B" ]) = 20)
chk("Value(South, A) = 30",         oP.Value([ "South" ], [ "A" ]) = 30)
chk("Value(South, B) = 40",         oP.Value([ "South" ], [ "B" ]) = 40)
chk("Value(East,  A) = 50",         oP.Value([ "East"  ], [ "A" ]) = 50)
chk("Value(East,  B) = 60",         oP.Value([ "East"  ], [ "B" ]) = 60)

# Row totals
chk("RowTotal(North) = 30 (10+20)", oP.RowTotal([ "North" ]) = 30)
chk("RowTotal(South) = 70 (30+40)", oP.RowTotal([ "South" ]) = 70)
chk("RowTotal(East)  = 110 (50+60)", oP.RowTotal([ "East" ]) = 110)

# Column totals
chk("ColTotal(A) = 90 (10+30+50)",  oP.ColumnTotal([ "A" ]) = 90)
chk("ColTotal(B) = 120 (20+40+60)", oP.ColumnTotal([ "B" ]) = 120)

# Grand total
chk("GrandTotal = 210",             oP.GrandTotal() = 210)

# ------------------------------------------------------------
# COUNT pivot
# ------------------------------------------------------------
? ""
? "--- COUNT pivot ---"

oPc = new stzPivotTable(oTab)
oPc {
	Analyze([:Sales], "COUNT")
	By([:Region], [:Product])
	Generate()
}

chk("COUNT North/A = 1",            oPc.Value([ "North" ], [ "A" ]) = 1)
chk("COUNT GrandTotal = 6 (rows)",  oPc.GrandTotal() = 6)

# ------------------------------------------------------------
# AVG pivot
# ------------------------------------------------------------
? ""
? "--- AVG pivot ---"

# More complex dataset: multiple rows per (region, product)
aData2 = [
	[ :Region, :Product, :Sales ],
	[ "N", "A", 10 ],
	[ "N", "A", 20 ],
	[ "N", "B", 30 ],
	[ "S", "A", 40 ],
	[ "S", "B", 50 ],
	[ "S", "B", 70 ]
]

oTab2 = new stzTable(aData2)
oPa = new stzPivotTable(oTab2)
oPa {
	Analyze([:Sales], "AVG")
	By([:Region], [:Product])
	Generate()
}

chk("AVG N/A = 15 (10+20)/2",       oPa.Value([ "N" ], [ "A" ]) = 15)
chk("AVG N/B = 30 (single)",        oPa.Value([ "N" ], [ "B" ]) = 30)
chk("AVG S/B = 60 (50+70)/2",       oPa.Value([ "S" ], [ "B" ]) = 60)

# ------------------------------------------------------------
# MAX / MIN
# ------------------------------------------------------------
? ""
? "--- MAX / MIN pivots ---"

oPmx = new stzPivotTable(oTab2)
oPmx {
	Analyze([:Sales], "MAX")
	By([:Region], [:Product])
	Generate()
}
chk("MAX N/A = 20",                 oPmx.Value([ "N" ], [ "A" ]) = 20)
chk("MAX S/B = 70",                 oPmx.Value([ "S" ], [ "B" ]) = 70)

oPmn = new stzPivotTable(oTab2)
oPmn {
	Analyze([:Sales], "MIN")
	By([:Region], [:Product])
	Generate()
}
chk("MIN N/A = 10",                 oPmn.Value([ "N" ], [ "A" ]) = 10)
chk("MIN S/B = 50",                 oPmn.Value([ "S" ], [ "B" ]) = 50)

# ------------------------------------------------------------
# Missing intersection (cell not present)
# ------------------------------------------------------------
? ""
? "--- Missing cells ---"

# In oTab2, N/B has only 1 row; S/A has only 1 row
oPm = new stzPivotTable(oTab2)
oPm {
	Analyze([:Sales], "SUM")
	By([:Region], [:Product])
	Generate()
}
chk("Missing region returns 0 or sentinel", isNumber(oPm.Value([ "X" ], [ "A" ])) or isString(oPm.Value([ "X" ], [ "A" ])))

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzPivotTable CHECKS PASSED!"
else
	? "SOME stzPivotTable CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
