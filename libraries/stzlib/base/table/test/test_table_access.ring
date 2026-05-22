# Test stzTable column/row/cell access submodules
# Run from base/table/test/: D:\Ring126\bin\ring.exe test_table_access.ring

load "../../stzBase.ring"

nPass = 0
nFail = 0

o1 = new stzTable([
	[ :NAME,   :AGE,  :CITY     ],
	[ "Ali",    35,   "Tunis"   ],
	[ "Dania",  28,   "Cairo"   ],
	[ "Han",    42,   "Beijing" ]
])

# --- Column Access ---
? "=== Column Access ==="

aCol = o1.Col(:name)
? "  Col(:name): " + @@(aCol)
if len(aCol) = 3 and aCol[1] = "Ali"
	nPass++
else
	nFail++
	? "  FAIL: expected [Ali, Dania, Han]"
ok

aCol = o1.Col(2)
? "  Col(2): " + @@(aCol)
if len(aCol) = 3 and aCol[1] = 35
	nPass++
else
	nFail++
	? "  FAIL: expected [35, 28, 42]"
ok

c = o1.NthColName(1)
? "  NthColName(1): " + c
if StzLower(c) = "name"
	nPass++
else
	nFail++
	? "  FAIL: expected name"
ok

c = o1.LastColName()
? "  LastColName: " + c
if StzLower(c) = "city"
	nPass++
else
	nFail++
	? "  FAIL: expected city"
ok

# --- Row Access ---
? ""
? "=== Row Access ==="

aRow = o1.Row(1)
? "  Row(1): " + @@(aRow)
if len(aRow) = 3 and aRow[1] = "Ali"
	nPass++
else
	nFail++
	? "  FAIL: expected [Ali, 35, Tunis]"
ok

aRow = o1.LastRow()
? "  LastRow: " + @@(aRow)
if len(aRow) = 3 and aRow[1] = "Han"
	nPass++
else
	nFail++
	? "  FAIL: expected [Han, 42, Beijing]"
ok

n = o1.NumberOfRows()
? "  NumberOfRows: " + n
if n = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3"
ok

# --- Cell Access ---
? ""
? "=== Cell Access ==="

v = o1.Cell(:name, 2)
? "  Cell(:name, 2): " + v
if v = "Dania"
	nPass++
else
	nFail++
	? "  FAIL: expected Dania"
ok

v = o1.Cell(:age, 3)
? "  Cell(:age, 3): " + v
if v = 42
	nPass++
else
	nFail++
	? "  FAIL: expected 42"
ok

n = o1.NumberOfCells()
? "  NumberOfCells: " + n
if n = 9
	nPass++
else
	nFail++
	? "  FAIL: expected 9"
ok

# --- Section ---
? ""
? "=== Section ==="

aSection = o1.Section([1, 1], [2, 2])
? "  Section([1,1],[2,2]): " + @@(aSection)
if len(aSection) = 5
	nPass++
else
	nFail++
	? "  FAIL: expected 5 cells (col1 rows 1-3 + col2 rows 1-2)"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="
