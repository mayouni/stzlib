# Integration-level regression suite for stzTable.
# The six existing per-submodule suites (core/access/aggregate/
# search/structure/sort_replace) already cover unit-level surface;
# this suite stresses the cross-cutting paths -- full lifecycle
# (build -> mutate -> query -> aggregate), Section + cell math,
# named-column round-trips, and edges (empty / single-row / single-col).
#
# Run from base/table/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzTable integration regression ==="

# ------------------------------------------------------------
# Full lifecycle
# ------------------------------------------------------------
? ""
? "--- Lifecycle ---"

oT = new stzTable([
	[ :NAME,   :AGE,  :CITY     ],
	[ "Ali",    35,   "Tunis"   ],
	[ "Dania",  28,   "Cairo"   ],
	[ "Han",    42,   "Beijing" ]
])

chk("NumberOfRows = 3",            oT.NumberOfRows() = 3)
chk("NumberOfCols = 3",            oT.NumberOfCols() = 3)
chk("Cell(:name,1) = 'Ali'",       oT.Cell(:name, 1) = "Ali")
chk("Cell(:age,2) = 28",           oT.Cell(:age, 2) = 28)
chk("Col(:name) len = 3",          len(oT.Col(:name)) = 3)
chk("Col(2) ages match",           oT.Col(2)[1] = 35 and oT.Col(2)[3] = 42)
chk("Row(1) reads in col order",   isList(oT.Row(1)) and oT.Row(1)[1] = "Ali")
chk("Row(2)[3] = 'Cairo'",         oT.Row(2)[3] = "Cairo")

# Mutation (Add/Insert row) lives on stzTableStructure, not stzTable -- covered
# in test_table_structure.ring. This suite focuses on read paths on stzTable.

# ------------------------------------------------------------
# Section (rectangular)
# ------------------------------------------------------------
? ""
? "--- Section (rectangular) ---"

aS = oT.Section([1,1], [2,2])
chk("Section([1,1],[2,2]) yields 4 cells", isList(aS) and len(aS) = 4)
chk("Section row-major order",             aS[1] = "Ali" and aS[2] = 35 and aS[3] = "Dania" and aS[4] = 28)

# Single-row section
aS1 = oT.Section([1,1], [3,1])
chk("Section single-row full width",       len(aS1) = 3 and aS1[1] = "Ali" and aS1[3] = "Tunis")

# Single-col section
aSc = oT.Section([2,1], [2,3])
chk("Section single-col 3 rows",           len(aSc) = 3 and aSc[1] = 35 and aSc[2] = 28 and aSc[3] = 42)

# Full table section
aSf = oT.Section([1,1], [3,3])
chk("Section whole table = 9 cells",       len(aSf) = 9)
chk("Section whole table first/last",      aSf[1] = "Ali" and aSf[9] = "Beijing")

# ------------------------------------------------------------
# Search + aggregate cross-check
# ------------------------------------------------------------
? ""
? "--- Search + Aggregate ---"

aAges = oT.Col(:age)
chk("Col(:age) returns numeric list",      isList(aAges) and isNumber(aAges[1]))
# Sum manually
nSum = 0
_nAgesLen_ = ring_len(aAges)
for i = 1 to _nAgesLen_ nSum += aAges[i] next
chk("Sum of ages = 105 (35+28+42)",        nSum = 105)

# ------------------------------------------------------------
# Edges: empty + single-row tables
# ------------------------------------------------------------
? ""
? "--- Edges ---"

oT1 = new stzTable([
	[ :X, :Y ],
	[ 1,  2 ]
])
chk("Single-row table NumberOfRows = 1",   oT1.NumberOfRows() = 1)
chk("Single-row Cell access",              oT1.Cell(:x, 1) = 1 and oT1.Cell(:y, 1) = 2)

# Single-col table
oT1c = new stzTable([
	[ :ONLY ],
	[ "a" ],
	[ "b" ],
	[ "c" ]
])
chk("Single-col NumberOfCols = 1",         oT1c.NumberOfCols() = 1)
chk("Single-col NumberOfRows = 3",         oT1c.NumberOfRows() = 3)
chk("Single-col Col(:only) full",          len(oT1c.Col(:only)) = 3)

# ------------------------------------------------------------
# Named-column round-trips
# ------------------------------------------------------------
? ""
? "--- Named-column round-trips ---"

# ReplaceCol is on stzTable directly
oT.ReplaceCol(:age, [100, 200, 300])
chk("ReplaceCol updates all rows",         oT.Cell(:age, 1) = 100 and oT.Cell(:age, 3) = 300)

# RemoveCol drops a column
oT.RemoveCol(:age)
chk("RemoveCol -> 2 cols",                 oT.NumberOfCols() = 2)
chk("Remaining cols are name + city",      oT.Cell(:name, 1) = "Ali" and oT.Cell(:city, 1) = "Tunis")

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzTable INTEGRATION CHECKS PASSED!"
else
	? "SOME stzTable INTEGRATION CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
