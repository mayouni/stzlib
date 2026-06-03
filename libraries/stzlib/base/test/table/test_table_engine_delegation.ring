# Test stzTable engine delegation (sort + aggregation via Zig engine)
# Run from base/table/test/: D:\Ring126\bin\ring.exe test_table_engine_delegation.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

# --- Sort (via stzTableSorter, delegates to engine pdq sort) ---

? "=== Engine Delegation: Sort ==="

o1 = new stzTableSorter([
	[ :NAME,    :AGE,   :SALARY ],
	[ "Han",     42,    25982   ],
	[ "Ali",     35,    35000   ],
	[ "Dania",   28,    28900   ]
])

# Sort ascending on :NAME column (engine pdq sort)
o1.SortOn(:NAME)

cFirst = o1.Cell(:NAME, 1)
? "  After SortOn(:NAME), first: " + cFirst
if cFirst = "Ali"
	nPass++
else
	nFail++
	? "  FAIL: expected Ali, got " + cFirst
ok

cLast = o1.Cell(:NAME, 3)
? "  Last: " + cLast
if cLast = "Han"
	nPass++
else
	nFail++
	? "  FAIL: expected Han, got " + cLast
ok

# Verify sort also moved the age column correctly
nAge = o1.Cell(:AGE, 1)
? "  Ali's age: " + nAge
if nAge = 35
	nPass++
else
	nFail++
	? "  FAIL: expected 35, got " + nAge
ok

# Sort descending on :SALARY
o1.SortDownOn(:SALARY)

cTopSalary = o1.Cell(:NAME, 1)
? "  After SortDownOn(:SALARY), top earner: " + cTopSalary
if cTopSalary = "Ali"
	nPass++
else
	nFail++
	? "  FAIL: expected Ali (35000), got " + cTopSalary
ok

# --- Aggregation (via stzTableAggregator, delegates to engine) ---
? ""
? "=== Engine Delegation: Aggregation ==="

o2 = new stzTableAggregator([
	[ :PRODUCT,   :PRICE,   :QTY ],
	[ "Apple",     2,        10  ],
	[ "Banana",    1,        20  ],
	[ "Cherry",    3,        15  ],
	[ "Date",      5,         8  ]
])

nSum = o2.SumCol(:PRICE)
? "  SumCol(:PRICE): " + nSum
if nSum = 11
	nPass++
else
	nFail++
	? "  FAIL: expected 11, got " + nSum
ok

nAvg = o2.AvgCol(:PRICE)
? "  AvgCol(:PRICE): " + nAvg
if nAvg = 2.75
	nPass++
else
	nFail++
	? "  FAIL: expected 2.75, got " + nAvg
ok

nMin = o2.MinCol(:PRICE)
? "  MinCol(:PRICE): " + nMin
if nMin = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1, got " + nMin
ok

nMax = o2.MaxCol(:PRICE)
? "  MaxCol(:PRICE): " + nMax
if nMax = 5
	nPass++
else
	nFail++
	? "  FAIL: expected 5, got " + nMax
ok

nProduct = o2.ProductCol(:QTY)
? "  ProductCol(:QTY): " + nProduct
if nProduct = 24000
	nPass++
else
	nFail++
	? "  FAIL: expected 24000, got " + nProduct
ok

# --- Aggregate after mutation (verify engine re-sync) ---
? ""
? "=== Engine Delegation: Aggregate after mutation ==="

o3 = new stzTableAggregator([
	[ :ITEM,     :PRICE,   :QTY ],
	[ "Mango",    4,        12  ],
	[ "Apple",    2,         8  ],
	[ "Fig",      6,         5  ]
])

nSum2 = o3.SumCol(:QTY)
? "  SumCol(:QTY) before mutation: " + nSum2
if nSum2 = 25
	nPass++
else
	nFail++
	? "  FAIL: expected 25, got " + nSum2
ok

# Mutate a cell (triggers engine invalidation)
o3.ReplaceCell(:QTY, 1, 20)

# Aggregation should re-sync with engine
nSum3 = o3.SumCol(:QTY)
? "  SumCol(:QTY) after mutation: " + nSum3
if nSum3 = 33
	nPass++
else
	nFail++
	? "  FAIL: expected 33, got " + nSum3
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
