# Test stzPivotTable engine delegation
# Run from base/table/test/: D:\Ring126\bin\ring.exe test_pivot_engine_delegation.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

# --- Sales data for pivot testing ---

? "=== Engine Pivot: CrossTab SUM ==="

o1 = new stzPivotTable([
	[ :REGION,  :PRODUCT, :AMOUNT ],
	[ "North",  "Widget",  100    ],
	[ "North",  "Gadget",  200    ],
	[ "South",  "Widget",  150    ],
	[ "South",  "Gadget",  300    ],
	[ "North",  "Widget",  50     ],
	[ "South",  "Widget",  75     ]
])

o1.Analyze(:AMOUNT, :with = "SUM")
o1.By(:REGION, :and = :PRODUCT)
o1.SetShowTotals(FALSE, FALSE)
o1.Generate()

? "  Generated successfully"
nPass++

# North Widget: 100 + 50 = 150
v1 = o1.Value("North", "Widget")
? "  Value(North, Widget): " + v1
if v1 = 150
	nPass++
else
	nFail++
	? "  FAIL: expected 150, got " + v1
ok

# South Gadget: 300
v2 = o1.Value("South", "Gadget")
? "  Value(South, Gadget): " + v2
if v2 = 300
	nPass++
else
	nFail++
	? "  FAIL: expected 300, got " + v2
ok

# South Widget: 150 + 75 = 225
v3 = o1.Value("South", "Widget")
? "  Value(South, Widget): " + v3
if v3 = 225
	nPass++
else
	nFail++
	? "  FAIL: expected 225, got " + v3
ok

? ""
? "=== Engine Pivot: CrossTab COUNT ==="

o2 = new stzPivotTable([
	[ :DEPT,    :STATUS,   :SALARY ],
	[ "IT",     "Active",   50000  ],
	[ "IT",     "Active",   55000  ],
	[ "IT",     "Left",     45000  ],
	[ "HR",     "Active",   60000  ],
	[ "HR",     "Left",     40000  ]
])

o2.Analyze(:SALARY, :with = "COUNT")
o2.By(:DEPT, :and = :STATUS)
o2.SetShowTotals(FALSE, FALSE)
o2.Generate()

? "  Generated successfully (COUNT)"
nPass++

# IT Active: 2 employees
v4 = o2.Value("IT", "Active")
? "  Value(IT, Active): " + v4
if v4 = 2
	nPass++
else
	nFail++
	? "  FAIL: expected 2, got " + v4
ok

# HR Left: 1 employee
v5 = o2.Value("HR", "Left")
? "  Value(HR, Left): " + v5
if v5 = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1, got " + v5
ok

? ""
? "=== Engine Pivot: CrossTab with Totals ==="

o3 = new stzPivotTable([
	[ :REGION,  :PRODUCT, :AMOUNT ],
	[ "North",  "Widget",  100    ],
	[ "North",  "Gadget",  200    ],
	[ "South",  "Widget",  150    ],
	[ "South",  "Gadget",  300    ]
])

o3.Analyze(:AMOUNT, :with = "SUM")
o3.By(:REGION, :and = :PRODUCT)
o3.SetShowTotals(TRUE, TRUE)
o3.Generate()

? "  Generated with totals"
nPass++

# North row total: 100 + 200 = 300
v6 = o3.RowTotal("North")
? "  RowTotal(North): " + v6
if v6 = 300
	nPass++
else
	nFail++
	? "  FAIL: expected 300, got " + v6
ok

# Grand total: 100+200+150+300 = 750
v7 = o3.GrandTotal()
? "  GrandTotal: " + v7
if v7 = 750
	nPass++
else
	nFail++
	? "  FAIL: expected 750, got " + v7
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
