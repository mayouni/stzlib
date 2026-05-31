# Narrative
# --------
# Using multiple dimensions for rows and columns
#
# Extracted from stzPivotTableTest.ring, block #2.

load "../../../stzBase.ring"


pr()
    
# Define employee data in a stzTable object

oTable = new stzTable([

	[ :Department, :Location,   :Gender,  :Experience,  "Salary"   ],
	# ------------------------------------------------------------ #
	[ "Sales",     "New York",  "Male",   "Junior",      45000    ],
	[ "Sales",     "New York",  "Female", "Junior",      46000    ],
	[ "Sales",     "New York",  "Male",   "Senior",      75000    ],
	[ "Sales",     "New York",  "Female", "Senior",      76000    ],
	[ "Sales",     "Chicago",   "Male",   "Junior",      42000    ],
	[ "Sales",     "Chicago",   "Female", "Junior",      43000    ],
	[ "Sales",     "Chicago",   "Male",   "Senior",      72000    ],
	[ "Sales",     "Chicago",   "Female", "Senior",      73000    ],
	[ "IT",        "New York",  "Male",   "Junior",      52000    ],
	[ "IT",        "New York",  "Female", "Junior",      53000    ],
	[ "IT",        "New York",  "Male",   "Senior",      85000    ],
	[ "IT",        "New York",  "Female", "Senior",      86000    ],
	[ "IT",        "Chicago",   "Male",   "Junior",      50000    ],
	[ "IT",        "Chicago",   "Female", "Junior",      51000    ],
	[ "IT",        "Chicago",   "Male",   "Senior",      82000    ],
	[ "IT",        "Chicago",   "Female", "Senior",      83000    ],
	[ "HR",        "New York",  "Male",   "Junior",      42000    ],
	[ "HR",        "New York",  "Female", "Junior",      43000    ],
	[ "HR",        "New York",  "Male",   "Senior",      68000    ],
	[ "HR",        "New York",  "Female", "Senior",      69000    ],
	[ "HR",        "Chicago",   "Male",   "Junior",      40000    ],
	[ "HR",        "Chicago",   "Female", "Junior",      41000    ],
	[ "HR",        "Chicago",   "Male",   "Senior",      65000    ],
	[ "HR",        "Chicago",   "Female", "Senior",      66000    ]
])
    
# Multi-dimensional pivot with Department/Location as rows and
# Experience/Gender as columns

oPivot = new stzPivotTable(oTable)

oPivot {

	Analyze([ :Salary ], :Using = :SUM)

	# 2 rows and 2 columns

	SetRowsBy([ :Department, :Location ])
	SetColsBy([ :Experience, :Gender ])
	ShowXT(True, :GrandTotal=True)

	#-->
# ╭───────────────────────┬─────────────────────┬─────────────────────┬─────────╮
# │                       │       Junior        │       Senior        │         │
# │                       │──────────┬──────────┼──────────┬──────────│         │
# │ Department │ Location │  Female  │   Male   │  Female  │   Male   │   SUM   │
# ├────────────┬──────────┼──────────┼──────────┼──────────┼──────────┼─────────┤
# │ Sales      │ New York │    46000 │          │    76000 │    75000 │  197000 │
# │            │ Chicago  │    43000 │    42000 │    73000 │    72000 │  230000 │
# │            │          │          │          │          │          │         │
# │ IT         │ New York │    53000 │    52000 │    86000 │    85000 │  276000 │
# │            │ Chicago  │    51000 │    50000 │    83000 │    82000 │  266000 │
# │            │          │          │          │          │          │         │
# │ HR         │ New York │    43000 │    42000 │    69000 │    68000 │  222000 │
# │            │ Chicago  │    41000 │    40000 │    66000 │    65000 │  212000 │
# ╰────────────┴──────────┴──────────┴──────────┴──────────┴──────────┴─────────╯
#                     SUM │   277000 │   226000 │   453000 │   447000 │ 1403000 

	# 1 row and 2 columns
/*
	SetRowsBy([ :Department ])
	SetColsBy([ :Experience, :Gender ])
	Show()
	#-->
# ╭────────────┬─────────────────────┬─────────────────────┬─────────╮
# │            │       Junior        │       Senior        │         │
# │            │──────────┬──────────│──────────┬──────────│         │
# │ Department │  Female  │   Male   │  Female  │   Male   │   SUM   │
# ├────────────┼──────────┼──────────┼──────────┼──────────┼─────────┤
# │ Sales      │   131000 │   131000 │   296000 │   296000 │  854000 │
# │ IT         │   206000 │   206000 │   336000 │   336000 │ 1084000 │
# │ HR         │   166000 │   166000 │   268000 │   268000 │  868000 │
# ╰────────────┴──────────┴──────────┴──────────┴──────────┴─────────╯
#          SUM │   503000 │   503000 │   900000 │   900000 │ 2806000 

	# 2 rows and 1 column

	SetRowsBy([ :Department, :Location ])
	SetColsBy([ :Experience ])
	Show()
	#-->
# ╭───────────────────────┬─────────────────────┬─────────╮
# │                       │     Experience      │         │
# │                       │──────────┬──────────│         │
# │ Department │ Location │  Junior  │  Senior  │   SUM   │
# ├────────────┬──────────┼──────────┼──────────┼─────────┤
# │ Sales      │ Chicago  │    85000 │   145000 │  230000 │
# │            │          │          │          │         │
# │ IT         │ New York │   105000 │   171000 │  276000 │
# │            │ Chicago  │   101000 │   165000 │  266000 │
# │            │          │          │          │         │
# │ HR         │ New York │    85000 │   137000 │  222000 │
# │            │ Chicago  │    81000 │   131000 │  212000 │
# ╰────────────┴──────────┴──────────┴──────────┴─────────╯
#                     SUM │   503000 │   900000 │ 1403000  

	# 1 row and 1 column

	SetRowsBy([ :Department ])
	SetColsBy([ :Experience ])
	Show(true, true)
	#--> 
# ╭────────────┬─────────────────────┬─────────╮
# │            │     Experience      │         │
# │            │──────────┬──────────│         │
# │ Department │  Junior  │  Senior  │   SUM   │
# ├────────────┼──────────┼──────────┼─────────┤
# │ Sales      │   131000 │   296000 │  427000 │
# │ IT         │   206000 │   336000 │  542000 │
# │ HR         │   166000 │   268000 │  434000 │
# ╰────────────┴──────────┴──────────┴─────────╯
#          SUM │   503000 │   900000 │ 1403000  

}

pf()
# Executed in 0.32 second(s) in Ring 1.22
