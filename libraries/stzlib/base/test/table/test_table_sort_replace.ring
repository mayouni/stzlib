# Test stzTable sorting (via stzTableSorter) and replacement (via core)
# Run from base/table/test/: D:\Ring126\bin\ring.exe test_table_sort_replace.ring

load "../../stzBase.ring"

nPass = 0
nFail = 0

# --- Sort ---
? "=== Sort ==="

o1 = new stzTableSorter([
	[ :NAME,   :SCORE ],
	[ "Charlie", 85   ],
	[ "Alice",   92   ],
	[ "Bob",     78   ]
])

o1.SortOn(:name)
aCol = o1.Col(:name)
? "  After SortOn(:name): " + @@(aCol)
if aCol[1] = "Alice" and aCol[2] = "Bob" and aCol[3] = "Charlie"
	nPass++
else
	nFail++
	? "  FAIL: expected [Alice, Bob, Charlie]"
ok

aScores = o1.Col(:score)
? "  Scores after sort: " + @@(aScores)
if aScores[1] = 92
	nPass++
else
	nFail++
	? "  FAIL: expected Alice's score 92 first"
ok

# --- SortDown ---
? ""
? "=== SortDown ==="

o2 = new stzTableSorter([
	[ :NAME,   :SCORE ],
	[ "Alice",   92   ],
	[ "Bob",     78   ],
	[ "Charlie", 85   ]
])

o2.SortDownOn(:score)
aScores = o2.Col(:score)
? "  After SortDownOn(:score): " + @@(aScores)
if aScores[1] = 92 and aScores[2] = 85 and aScores[3] = 78
	nPass++
else
	nFail++
	? "  FAIL: expected [92, 85, 78]"
ok

# --- ReplaceCell (core method) ---
? ""
? "=== ReplaceCell ==="

o3 = new stzTable([
	:NAME = [ "Ali", "Dania", "Han" ],
	:AGE  = [  35,    28,      42   ]
])

o3.ReplaceCell(:name, 2, "Sara")
v = o3.Cell(:name, 2)
? "  After ReplaceCell(:name, 2, Sara): " + v
if v = "Sara"
	nPass++
else
	nFail++
	? "  FAIL: expected Sara"
ok

# --- ReplaceRow (core method) ---
? ""
? "=== ReplaceRow ==="

o3.ReplaceRow(3, [ "Lina", 30 ])
v = o3.Cell(:name, 3)
? "  After ReplaceRow(3): name = " + v
if v = "Lina"
	nPass++
else
	nFail++
	? "  FAIL: expected Lina"
ok

v = o3.Cell(:age, 3)
? "  After ReplaceRow(3): age = " + v
if v = 30
	nPass++
else
	nFail++
	? "  FAIL: expected 30"
ok

# --- ReplaceCol (core method) ---
? ""
? "=== ReplaceCol ==="

o4 = new stzTable([
	:X = [ 1, 2, 3 ],
	:Y = [ 4, 5, 6 ]
])

o4.ReplaceCol(:y, [ 10, 20, 30 ])
aCol = o4.Col(:y)
? "  After ReplaceCol(:y): " + @@(aCol)
if aCol[1] = 10 and aCol[3] = 30
	nPass++
else
	nFail++
	? "  FAIL: expected [10, 20, 30]"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="
