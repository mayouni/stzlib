# Test stzTable search via stzTableFinder submodule
# Run from base/table/test/: D:\Ring126\bin\ring.exe test_table_search.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

# Use core stzTable -- FindCol/FindColByName are now in core
o1 = new stzTable([
	[ :NAME,   :AGE,  :CITY     ],
	[ "Ali",    35,   "Tunis"   ],
	[ "Dania",  28,   "Cairo"   ],
	[ "Han",    42,   "Beijing" ],
	[ "Ali",    25,   "Tunis"   ]
])

# --- FindCol ---
? "=== FindCol ==="

n = o1.FindColByName(:age)
? "  FindColByName(:age): " + n
if n = 2
	nPass++
else
	nFail++
	? "  FAIL: expected 2"
ok

n = o1.FindColByName(:xyz)
? "  FindColByName(:xyz): " + n
if n = 0
	nPass++
else
	nFail++
	? "  FAIL: expected 0"
ok

# --- FindCol by number ---
? ""
? "=== FindCol (number) ==="

n = o1.FindCol(2)
? "  FindCol(2): " + n
if n = 2
	nPass++
else
	nFail++
	? "  FAIL: expected 2"
ok

n = o1.FindCol(99)
? "  FindCol(99): " + n
if n = 0
	nPass++
else
	nFail++
	? "  FAIL: expected 0"
ok

# --- Cell value checks ---
? ""
? "=== Cell lookups ==="

v = o1.Cell(:name, 1)
? "  Cell(:name,1): " + v
if v = "Ali"
	nPass++
else
	nFail++
	? "  FAIL: expected Ali"
ok

v = o1.Cell(:city, 4)
? "  Cell(:city,4): " + v
if v = "Tunis"
	nPass++
else
	nFail++
	? "  FAIL: expected Tunis"
ok

# --- Row count ---
? ""
? "=== Row count ==="

n = o1.NumberOfRows()
? "  NumberOfRows: " + n
if n = 4
	nPass++
else
	nFail++
	? "  FAIL: expected 4"
ok

# --- Col data ---
? ""
? "=== Col data ==="

aCol = o1.Col(:age)
? "  Col(:age): " + @@(aCol)
if len(aCol) = 4 and aCol[1] = 35 and aCol[4] = 25
	nPass++
else
	nFail++
	? "  FAIL: expected [35, 28, 42, 25]"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
