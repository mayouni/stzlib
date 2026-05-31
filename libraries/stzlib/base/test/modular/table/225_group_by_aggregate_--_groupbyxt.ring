# Narrative
# --------
# GROUP BY + AGGREGATE --> GroupByXT()
#
# Extracted from stztabletest.ring, block #225.

load "../../../stzBase.ring"


pr()

# Creating a sales data table

o1 = new stzTable([
    [ :Region,  :Product,  :Quarter, :Sales,  :Units ],
    
    [ "North",  "Product A", "Q1",     10000,   100  ],
    [ "North",  "Product A", "Q2",     12000,   120  ],
    [ "North",  "Product B", "Q1",      8000,    80  ],
    [ "North",  "Product B", "Q2",      9500,    95  ],
    [ "South",  "Product A", "Q1",     15000,   150  ],
    [ "South",  "Product A", "Q2",     16500,   165  ],
    [ "South",  "Product B", "Q1",      9500,    95  ],
    [ "South",  "Product B", "Q2",     11000,   110  ],
    [ "East",   "Product A", "Q1",     11000,   110  ],
    [ "East",   "Product A", "Q2",     12500,   125  ],
    [ "East",   "Product B", "Q1",      7500,    75  ],
    [ "East",   "Product B", "Q2",      8500,    85  ],
    [ "West",   "Product A", "Q1",     13000,   130  ],
    [ "West",   "Product A", "Q2",     14500,   145  ],
    [ "West",   "Product B", "Q1",      9000,    90  ],
    [ "West",   "Product B", "Q2",     10500,   105  ]
])

# Group by Region with sum aggregation

oCopy = o1.Copy()

oCopy.GroupByXT([ :Region ], [ :Sales = 'Sum', :Units = 'Sum' ] )

# Group by Region with Sales and Units summed

oCopy.Show()
#-->
# ╭────────┬────────────┬───────────╮
# │ Region │ Sum(Sales) │ Sum(Units)│
# ├────────┼────────────┼───────────┤
# │ North  │     39500  │       395 │
# │ South  │     52000  │       520 │
# │ East   │     39500  │       395 │
# │ West   │     47000  │       470 │
# ╰────────┴────────────┴───────────╯

# Group by Region and Product with multiple aggregations

oCopy = o1.Copy()

oCopy.GroupByXT([:Region, :Product], [
    :Sales = 'Sum',
    :Units = 'Average'
])

# Group by Region and Product with sum of Sales and average Units

oCopy.Show()
#-->
# ╭────────┬───────────┬────────────┬───────────────╮
# │ Region │ Product   │ Sum(Sales) │ Average(Units)│
# ├────────┼───────────┼────────────┼───────────────┤
# │ North  │ Product A │     22000  │          110  │
# │ North  │ Product B │     17500  │           87.5│
# │ South  │ Product A │     31500  │          157.5│
# │ South  │ Product B │     20500  │          102.5│
# │ East   │ Product A │     23500  │          117.5│
# │ East   │ Product B │     16000  │           80  │
# │ West   │ Product A │     27500  │          137.5│
# │ West   │ Product B │     19500  │           97.5│
# ╰────────┴───────────┴────────────┴───────────────╯

# Group by Quarter with min/max aggregations

oCopy = o1.Copy()
oCopy.GroupByXT([:Quarter], [
    :Sales = 'Max',
    :Sales = 'Min',
    :Units = 'Count'
])

# Group by Quarter with max/min Sales and count of Units
oCopy.Show()
#-->
# ╭─────────┬────────────┬────────────┬─────────────╮
# │ Quarter │ Max(Sales) │ Min(Sales) │ Count(Units)│
# ├─────────┼────────────┼────────────┼─────────────┤
# │ Q1      │     15000  │      7500  │           8 │
# │ Q2      │     16500  │      8500  │           8 │
# ╰─────────┴────────────┴────────────┴─────────────╯

# Group by Product and Quarter

oCopy = o1.Copy()
oCopy.GroupByXT([ :Product, :Quarter ],
	[ :Sales = 'Sum', :Units = 'Sum' ]
)

# Group by Product and Quarter with sums"
oCopy.Show()
#-->
# ╭───────────┬─────────┬────────────┬───────────╮
# │ Product   │ Quarter │ Sum(Sales) │ Sum(Units)│
# ├───────────┼─────────┼────────────┼───────────┤
# │ Product A │ Q1      │     49000  │       490 │
# │ Product A │ Q2      │     55500  │       555 │
# │ Product B │ Q1      │     34000  │       340 │
# │ Product B │ Q2      │     39500  │       395 │
# ╰───────────┴─────────┴────────────┴───────────╯

pf()
# Executed in 0.46 second(s) in Ring 1.22

#=== Turning the table to a pivot table

pr()
    
# Define employee data in a stzTable object

o1 = new stzTable([

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

o1.ToStzPivotTable() {

	Analyze([ :Salary ], :Using = :SUM)
	InRowsPut([ :Department, :Location ])
	InColsPut([ :Experience, :Gender ])

	Show()

}
#-->
#	╭───────────────────────┬─────────────────────┬─────────────────────┬─────────╮
#	│                       │       Junior        │       Senior        │         │
#	├────────────┬──────────┼──────────┬──────────┼──────────┬──────────┤         │
#	│ Department │ Location │  Female  │   Male   │  Female  │   Male   │ AVERAGE │
#	├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┼─────────┤
#	│ Sales      │ New York │    46000 │          │    76000 │    75000 │  197000 │
#	│            │ Chicago  │    43000 │    42000 │    73000 │    72000 │  230000 │
#	│            │          │          │          │          │          │         │
#	│ IT         │ New York │    53000 │    52000 │    86000 │    85000 │  276000 │
#	│            │ Chicago  │    51000 │    50000 │    83000 │    82000 │  266000 │
#	│            │          │          │          │          │          │         │
#	│ HR         │ New York │    43000 │    42000 │    69000 │    68000 │  222000 │
#	│            │ Chicago  │    41000 │    40000 │    66000 │    65000 │  212000 │
#	╰────────────┴──────────┴──────────┴──────────┴──────────┴──────────┴─────────╯
#	                AVERAGE │   277000 │   226000 │   453000 │   447000 │ 1403000 

pf()
# Executed in 0.17 second(s) in Ring 1.22
