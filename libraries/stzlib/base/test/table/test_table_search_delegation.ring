# Test stzTableSearch engine delegation
# Run from base/table/test/: D:\Ring126\bin\ring.exe test_table_search_delegation.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

# --- FindCellCS for strings (engine fast path) ---

? "=== Engine Delegation: FindCellCS ==="

o1 = new stzTableSearch([
	[ :NAME,    :CITY,     :ROLE ],
	[ "Ali",    "Tunis",   "Dev" ],
	[ "Dania",  "Cairo",   "Dev" ],
	[ "Han",    "Beijing", "PM"  ],
	[ "Ali",    "Niamey",  "QA"  ]
])

aPos = o1.FindCell("Ali")
? "  FindCell('Ali'): " + @@(aPos)
if @@(aPos) = "[ [ 1, 1 ], [ 1, 4 ] ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ [ 1, 1 ], [ 1, 4 ] ], got " + @@(aPos)
ok

aPos2 = o1.FindCell("Dev")
? "  FindCell('Dev'): " + @@(aPos2)
if @@(aPos2) = "[ [ 3, 1 ], [ 3, 2 ] ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ [ 3, 1 ], [ 3, 2 ] ], got " + @@(aPos2)
ok

aPos3 = o1.FindCell("missing")
? "  FindCell('missing'): " + @@(aPos3)
if @@(aPos3) = "[ ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ ], got " + @@(aPos3)
ok

# --- Case-insensitive ---

? ""
? "=== Engine Delegation: FindCellCS case-insensitive ==="

aCS = o1.FindCellCS("ali", 1)
? "  FindCellCS('ali', CS=1): " + @@(aCS)
if @@(aCS) = "[ ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ ], got " + @@(aCS)
ok

aCI = o1.FindCellCS("ali", 0)
? "  FindCellCS('ali', CS=0): " + @@(aCI)
if @@(aCI) = "[ [ 1, 1 ], [ 1, 4 ] ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ [ 1, 1 ], [ 1, 4 ] ], got " + @@(aCI)
ok

# --- Verify existing table delegation still works ---

? ""
? "=== Regression: SortOn still works ==="

o2 = new stzTableSorter([
	[ :NAME,    :AGE ],
	[ "Charlie", 30  ],
	[ "Alice",   25  ],
	[ "Bob",     35  ]
])

o2.SortOn(:NAME)
cFirst = o2.Cell(:NAME, 1)
? "  After SortOn(:NAME), first: " + cFirst
if cFirst = "Alice"
	nPass++
else
	nFail++
	? "  FAIL: expected Alice, got " + cFirst
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
