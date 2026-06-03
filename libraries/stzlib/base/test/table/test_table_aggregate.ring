# Test stzTable core mutation operations
# Run from base/table/test/: D:\Ring126\bin\ring.exe test_table_aggregate.ring

load "../../stzBase.ring"

nPass = 0
nFail = 0

# --- Manual move row (using core ReplaceRow) ---
? "=== Move Row (core) ==="

o1 = new stzTable([
	:X = [ "a", "b", "c" ],
	:Y = [  1,   2,   3  ]
])

aRow1 = o1.Row(1)
aRow3 = o1.Row(3)
o1.ReplaceRow(3, aRow1)
o1.ReplaceRow(1, aRow3)

v = o1.Cell(:x, 3)
? "  After swap 1<->3: Cell(:x,3) = " + v
if v = "a"
	nPass++
else
	nFail++
	? "  FAIL: expected a"
ok

v1 = o1.Cell(:x, 1)
? "  Cell(:x,1) = " + v1
if v1 = "c"
	nPass++
else
	nFail++
	? "  FAIL: expected c"
ok

# --- Rows iteration ---
? ""
? "=== Rows ==="

o2 = new stzTable([
	[ :PRODUCT,  :QTY,  :PRICE ],
	[ "Apple",    10,    2.5   ],
	[ "Banana",    5,    1.2   ],
	[ "Cherry",   20,    3.0   ]
])

aRows = o2.Rows()
? "  Rows() count: " + len(aRows)
if len(aRows) = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3"
ok

# --- Column data ---
? ""
? "=== Column data ==="

aQty = o2.Col(:qty)
? "  Col(:qty): " + @@(aQty)
if len(aQty) = 3 and aQty[1] = 10 and aQty[2] = 5 and aQty[3] = 20
	nPass++
else
	nFail++
	? "  FAIL: expected [10, 5, 20]"
ok

# --- NumberOfCells ---
? ""
? "=== NumberOfCells ==="

n = o2.NumberOfCells()
? "  NumberOfCells: " + n
if n = 9
	nPass++
else
	nFail++
	? "  FAIL: expected 9"
ok

# --- Replace then verify ---
? ""
? "=== Replace and verify ==="

o2.ReplaceCell(:price, 2, 1.5)
v = o2.Cell(:price, 2)
? "  After ReplaceCell(:price,2,1.5): " + v
if v = 1.5
	nPass++
else
	nFail++
	? "  FAIL: expected 1.5"
ok

o2.ReplaceCol(:qty, [ 100, 200, 300 ])
aQty = o2.Col(:qty)
? "  After ReplaceCol(:qty): " + @@(aQty)
if aQty[1] = 100 and aQty[3] = 300
	nPass++
else
	nFail++
	? "  FAIL: expected [100, 200, 300]"
ok

# --- Empty table ---
? ""
? "=== Empty table ==="

o3 = new stzTable([2, 3])
? "  Empty table cols: " + o3.NumberOfColumns()
if o3.NumberOfColumns() = 2
	nPass++
else
	nFail++
	? "  FAIL: expected 2 cols"
ok

? "  Empty table rows: " + o3.NumberOfRows()
if o3.NumberOfRows() = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3 rows"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="
