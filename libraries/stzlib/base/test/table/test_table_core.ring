# Test stzTable core class -- init, ClassName, Content, Copy, ColNames
# Run from base/table/test/: D:\Ring126\bin\ring.exe test_table_core.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

# --- Init from hashlist ---
? "=== Init (hashlist) ==="

o1 = new stzTable([
	:NAME   = [ "Ali",   "Dania", "Han"   ],
	:JOB    = [ "Dev",   "Mgr",   "Doc"   ],
	:SALARY = [ 35000,   50000,   62500   ]
])

n = o1.NumberOfColumns()
? "  NumberOfColumns: " + n
if n = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3"
ok

# --- Init from row-style ---
? ""
? "=== Init (row-style) ==="

o2 = new stzTable([
	[ :ID,   :EMPLOYEE,  :SALARY ],
	[ 10,    "Ali",      35000   ],
	[ 20,    "Dania",    28900   ],
	[ 30,    "Han",      25982   ],
	[ 40,    "Ali",      12870   ]
])

n = o2.NumberOfColumns()
? "  NumberOfColumns: " + n
if n = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3"
ok

# --- ClassName ---
? ""
? "=== ClassName ==="

c = o1.ClassName()
? "  ClassName: " + c
if c = "stztable"
	nPass++
else
	nFail++
	? "  FAIL: expected stztable"
ok

# --- Content ---
? ""
? "=== Content ==="

aContent = o1.Content()
n = len(aContent)
? "  Content length: " + n
if n = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3"
ok

# --- Column names ---
? ""
? "=== Column Names ==="

b = o1.HasColName(:name)
? "  HasColName(:name): " + b
if b = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1"
ok

b = o1.HasColName(:xyz)
? "  HasColName(:xyz): " + b
if b = 0
	nPass++
else
	nFail++
	? "  FAIL: expected 0"
ok

b = o1.IsColNumber(2)
? "  IsColNumber(2): " + b
if b = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1"
ok

b = o1.IsColNumber(5)
? "  IsColNumber(5): " + b
if b = 0
	nPass++
else
	nFail++
	? "  FAIL: expected 0"
ok

# --- IsEmpty ---
? ""
? "=== IsEmpty ==="

o3 = new stzTable([])
b = o3.IsEmpty()
? "  Empty table IsEmpty: " + b
if b = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1"
ok

b = o1.IsEmpty()
? "  Non-empty table IsEmpty: " + b
if b = 0
	nPass++
else
	nFail++
	? "  FAIL: expected 0"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
