# Test stzTable structure via stzTableStructure submodule
# Run from base/table/test/: D:\Ring126\bin\ring.exe test_table_structure.ring

load "../../stzBase.ring"

nPass = 0
nFail = 0

# --- AddColumn ---
? "=== AddColumn ==="

o1 = new stzTableStructure([
	:NAME = [ "Ali", "Dania" ],
	:AGE  = [  35,    28     ]
])

o1.AddColumn(:CITY = [ "Tunis", "Cairo" ])
n = o1.NumberOfColumns()
? "  After AddColumn: cols = " + n
if n = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3"
ok

v = o1.Cell(:city, 1)
? "  Cell(:city, 1): " + v
if v = "Tunis"
	nPass++
else
	nFail++
	? "  FAIL: expected Tunis"
ok

# --- AddRow ---
? ""
? "=== AddRow ==="

o1.AddRow([ "Han", 42, "Beijing" ])
n = o1.NumberOfRows()
? "  After AddRow: rows = " + n
if n = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3"
ok

v = o1.Cell(:name, 3)
? "  Cell(:name, 3): " + v
if v = "Han"
	nPass++
else
	nFail++
	? "  FAIL: expected Han"
ok

# --- RemoveColumn ---
? ""
? "=== RemoveColumn ==="

o2 = new stzTableStructure([
	:A = [ 1, 2 ],
	:B = [ 3, 4 ],
	:C = [ 5, 6 ]
])

o2.RemoveColumn(:B)
n = o2.NumberOfColumns()
? "  After RemoveColumn(:B): cols = " + n
if n = 2
	nPass++
else
	nFail++
	? "  FAIL: expected 2"
ok

b = o2.HasColName(:b)
? "  HasColName(:b) after remove: " + b
if b = 0
	nPass++
else
	nFail++
	? "  FAIL: expected 0"
ok

# --- RemoveRow ---
? ""
? "=== RemoveRow ==="

o3 = new stzTableStructure([
	:X = [ 10, 20, 30 ],
	:Y = [ 40, 50, 60 ]
])

o3.RemoveNthRow(2)
n = o3.NumberOfRows()
? "  After RemoveNthRow(2): rows = " + n
if n = 2
	nPass++
else
	nFail++
	? "  FAIL: expected 2"
ok

v = o3.Cell(:x, 2)
? "  Cell(:x, 2) after remove: " + v
if v = 30
	nPass++
else
	nFail++
	? "  FAIL: expected 30"
ok

# --- RenameCol ---
? ""
? "=== RenameCol ==="

o4 = new stzTableStructure([
	:OLD = [ 1, 2 ],
	:B   = [ 3, 4 ]
])

o4.RenameNthCol(1, :NEW)
b = o4.HasColName(:new)
? "  After RenameNthCol: HasColName(:new) = " + b
if b = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1"
ok

# --- AddRow roundtrip ---
? ""
? "=== AddRow roundtrip ==="

o5 = new stzTableStructure([
	:A = [ 1, 2 ],
	:B = [ 3, 4 ]
])

o5.AddRow([ 5, 6 ])
v = o5.Cell(:b, 3)
? "  After AddRow: Cell(:b,3) = " + v
if v = 6
	nPass++
else
	nFail++
	? "  FAIL: expected 6"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="
