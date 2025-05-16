load "../max/stzmax.ring"


/*---

pr()


# Create sales data properly formatted
aData = [
    [ :Region, :Product, :Quarter, :Sales, :Units ],
    [ "North", "Product A", "Q1", 10000, 100 ],
    [ "North", "Product A", "Q2", 12000, 120 ],
    [ "North", "Product B", "Q1", 8000, 80 ],
    [ "North", "Product B", "Q2", 9000, 90 ],
    [ "South", "Product A", "Q1", 15000, 150 ],
    [ "South", "Product A", "Q2", 14000, 140 ],
    [ "South", "Product B", "Q1", 9500, 95 ],
    [ "South", "Product B", "Q2", 10500, 105 ],
    [ "East", "Product A", "Q1", 11000, 110 ],
    [ "East", "Product A", "Q2", 12500, 125 ],
    [ "East", "Product B", "Q1", 7500, 75 ],
    [ "East", "Product B", "Q2", 8500, 85 ],
    [ "West", "Product A", "Q1", 13000, 130 ],
    [ "West", "Product A", "Q2", 14500, 145 ],
    [ "West", "Product B", "Q1", 9000, 90 ],
    [ "West", "Product B", "Q2", 10000, 100 ]
]

# Create proper stzTable instance
oSalesData = new stzTable(aData)
oSalesData.Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ North  │ Product A │ Q1      │ 10000 │   100 │
# │ North  │ Product A │ Q2      │ 12000 │   120 │
# │ North  │ Product B │ Q1      │  8000 │    80 │
# │ North  │ Product B │ Q2      │  9000 │    90 │
# │ South  │ Product A │ Q1      │ 15000 │   150 │
# │ South  │ Product A │ Q2      │ 14000 │   140 │
# │ South  │ Product B │ Q1      │  9500 │    95 │
# │ South  │ Product B │ Q2      │ 10500 │   105 │
# │ East   │ Product A │ Q1      │ 11000 │   110 │
# │ East   │ Product A │ Q2      │ 12500 │   125 │
# │ East   │ Product B │ Q1      │  7500 │    75 │
# │ East   │ Product B │ Q2      │  8500 │    85 │
# │ West   │ Product A │ Q1      │ 13000 │   130 │
# │ West   │ Product A │ Q2      │ 14500 │   145 │
# │ West   │ Product B │ Q1      │  9000 │    90 │
# │ West   │ Product B │ Q2      │ 10000 │   100 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

# Pivot table of Sales by Region (rows) and Product (columns)
oSalesPivot = new stzPivotTable(oSalesData)
oSalesPivot {
	Analyze([:Sales], "SUM")
	SetRowsBy([ :Region ])
	SetColsBy([ :Product ])

    Show()

}
#-->
# ╭────────┬───────────────────────┬────────╮
# │        │        Product        │        │
# │        │───────────┬───────────│        │
# │ Region │ Product A │ Product B │  SUM   │
# ├────────┼───────────┼───────────┼────────┤
# │ North  │     12000 │     17000 │  29000 │
# │ South  │     29000 │     20000 │  49000 │
# │ East   │     23500 │     16000 │  39500 │
# │ West   │     27500 │     19000 │  46500 │
# ╰────────┴───────────┴───────────┴────────╯
#      SUM │     92000 │     72000 │ 164000  

# Another view - Sales by Product (rows) and Quarter (columns)

oProductPivot = new stzPivotTable(oSalesData)
oProductPivot {

    SetRowLabel(:Product)
    SetColumnLabel(:Quarter)
    SetValue(:Sales)
    SetAggregateFunction("SUM")

    Show()
	#-->
# ╭───────────┬─────────────────────┬────────╮
# │           │       Quarter       │        │
# │           │──────────┬──────────│        │
# │  Product  │    Q2    │    Q1    │ TOTAL  │
# ├───────────┼──────────┼──────────┼────────┤
# │ Product A │    53000 │    39000 │  92000 │
# │ Product B │    38000 │    34000 │  72000 │
# ╰───────────┴──────────┴──────────┴────────╯
#       TOTAL │    91000 │    73000 │ 164000  

	# Getting specific values from the pivot
	# ~> Value for Product A in Q1	

	? Value("Product A", "Q1")
	#--> 39000

	# Getting row and column totals
	# ~> Row total for Product A

	? RowTotal("Product A")
	#--> 92000

	# ~> Column total for Q2

	? ColumnTotal("Q2")
	#--> 91000

	? GrandTotal()
	#--> 164000
}

pf()
# Executed in 0.43 second(s) in Ring 1.22

/*---  Using multiple dimensions for rows and columns

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
	Show()
	#-->
# ╭───────────────────────┬─────────────────────┬─────────────────────┬─────────╮
# │                       │       Junior        │       Senior        │         │
# ├────────────┬──────────┼──────────┬──────────┼──────────┬──────────┤         │
# │ Department │ Location │  Female  │   Male   │  Female  │   Male   │ AVERAGE │
# ├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┼─────────┤
# │ Sales      │ New York │    46000 │          │    76000 │    75000 │  197000 │
# │            │ Chicago  │    43000 │    42000 │    73000 │    72000 │  230000 │
# │            │          │          │          │          │          │         │
# │ IT         │ New York │    53000 │    52000 │    86000 │    85000 │  276000 │
# │            │ Chicago  │    51000 │    50000 │    83000 │    82000 │  266000 │
# │            │          │          │          │          │          │         │
# │ HR         │ New York │    43000 │    42000 │    69000 │    68000 │  222000 │
# │            │ Chicago  │    41000 │    40000 │    66000 │    65000 │  212000 │
# ╰────────────┴──────────┴──────────┴──────────┴──────────┴──────────┴─────────╯
#	                AVERAGE │   277000 │   226000 │   453000 │   447000 │ 1403000 

	# 1 row and 2 columns

	SetRowsBy([ :Department ])
	SetColsBy([ :Experience, :Gender ])
	Show()
	#-->
# ╭────────────┬─────────────────────┬─────────────────────┬─────────╮
# │            │       Junior        │       Senior        │         │
# │            │──────────┬──────────│──────────┬──────────│         │
# │ Department │  Female  │   Male   │  Female  │   Male   │   SUM   │
# ├────────────┼──────────┼──────────┼──────────┼──────────┼─────────┤
# │ Sales      │    89000 │    42000 │   149000 │   147000 │  427000 │
# │ IT         │   104000 │   102000 │   169000 │   167000 │  542000 │
# │ HR         │    84000 │    82000 │   135000 │   133000 │  434000 │
# ╰────────────┴──────────┴──────────┴──────────┴──────────┴─────────╯
#          SUM │   277000 │   226000 │   453000 │   447000 │ 1403000 

	# 2 rows and 1 column

	SetRowsBy([ :Department, :Location ])
	SetColsBy([ :Experience ])
	Show()
	#-->
# ╭───────────────────────┬─────────────────────┬─────────╮
# │                       │     Department      │         │
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
	Show()
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

/*--- Various Aggregation Functions
*/
pr()
    
    # Define a product sales and ratings dataset

    o1 = new stzTable([

        [ :Product,    :Category,    :Region,    :Sales,    :Rating,   :Returns  ],
        # ----------------------------------------------------------------- #
        [ "Laptop A",  "Electronics", "North",    2500,        4.2,        5     ],
        [ "Laptop A",  "Electronics", "South",    3200,        4.0,        7     ],
        [ "Laptop A",  "Electronics", "East",     2800,        4.3,        4     ],
        [ "Laptop A",  "Electronics", "West",     3500,        4.1,        8     ],
        [ "Phone B",   "Electronics", "North",    1800,        4.5,        2     ],
        [ "Phone B",   "Electronics", "South",    2100,        4.6,        1     ],
        [ "Phone B",   "Electronics", "East",     1900,        4.4,        3     ],
        [ "Phone B",   "Electronics", "West",     2300,        4.7,        2     ],
        [ "Chair C",   "Furniture",   "North",     850,        3.8,        3     ],
        [ "Chair C",   "Furniture",   "South",     920,        3.9,        4     ],
        [ "Chair C",   "Furniture",   "East",      780,        3.7,        5     ],
        [ "Chair C",   "Furniture",   "West",      950,        4.0,        2     ],
        [ "Table D",   "Furniture",   "North",    1200,        4.2,        1     ],
        [ "Table D",   "Furniture",   "South",    1350,        4.1,        2     ],
        [ "Table D",   "Furniture",   "East",     1180,        4.0,        2     ],
        [ "Table D",   "Furniture",   "West",     1420,        4.3,        1     ]
    ])
    
    # Original product data

//    o1.Show()

	# Pivoting the table and starting analyisis

    o1.ToStzPivotTable() {
/*
    	# SUM aggregation (default)

		SetRowLabels([:Product])
        SetColumnLabels([:Region])
        SetValues([:Sales])
        SetAggregateFunction("SUM")

        Show()

    	# AVERAGE aggregation

    	SetRowLabels([:Category])
        SetColumnLabels([:Region])
        SetValues([:Rating])
        SetAggregateFunction("AVERAGE")
        Show()
*/ 
		# Count of Products by Category and Region + NL
    
		SetRowLabels([:Category])
        SetColumnLabels([:Region])
        SetValues([:Product])
        SetAggregateFunction("COUNT")
        Show()
/*   
		# Maximum Returns by Product and Region
    
		SetRowLabels([:Product])
		SetColumnLabels([:Region])
		SetValues([:Returns])
		SetAggregateFunction("MAX")
		Show()
*/
}

pf()

/*---

  Example 4: Custom Display Options
  Demonstrating custom display formatting

func Example4()
    
    # Simple financial data
    financialData = new stzTable([
        [ :Year,  :Quarter,  :Department,   :Revenue,    :Expenses,   :Profit  ],
        # ---------------------------------------------------------------------- #
        [ 2023,    "Q1",      "Sales",       120000,       85000,      35000   ],
        [ 2023,    "Q1",      "Marketing",    45000,       40000,       5000   ],
        [ 2023,    "Q1",      "Operations",   65000,       50000,      15000   ],
        [ 2023,    "Q2",      "Sales",       135000,       90000,      45000   ],
        [ 2023,    "Q2",      "Marketing",    50000,       42000,       8000   ],
        [ 2023,    "Q2",      "Operations",   70000,       52000,      18000   ],
        [ 2023,    "Q3",      "Sales",       142000,       92000,      50000   ],
        [ 2023,    "Q3",      "Marketing",    55000,       44000,      11000   ],
        [ 2023,    "Q3",      "Operations",   75000,       55000,      20000   ],
        [ 2023,    "Q4",      "Sales",       150000,       95000,      55000   ],
        [ 2023,    "Q4",      "Marketing",    60000,       46000,      14000   ],
        [ 2023,    "Q4",      "Operations",   80000,       58000,      22000   ],
        [ 2024,    "Q1",      "Sales",       130000,       88000,      42000   ],
        [ 2024,    "Q1",      "Marketing",    48000,       41000,       7000   ],
        [ 2024,    "Q1",      "Operations",   68000,       51000,      17000   ],
        [ 2024,    "Q2",      "Sales",       145000,       94000,      51000   ],
        [ 2024,    "Q2",      "Marketing",    53000,       43000,      10000   ],
        [ 2024,    "Q2",      "Operations",   73000,       54000,      19000   ]
    ])
    
    # Basic pivot with default display
    profitPivot = new stzPivotTable(financialData)
    profitPivot.RowLabels([:Year, :Quarter])
             .ColumnLabels([:Department])
             .Values([:Profit])
             .AggregateFunction("SUM")
    
    See "Default display:" + NL
    profitPivot.Show()
    
    # Custom display with borders
    See NL + "Custom display with borders:" + NL
    profitPivot.ShowXT([
        :Separator = " | ",
        :IntersectionChar = "+",
        :ShowRowNumbers,
        :UnderLineHeader
    ])
    
    # Custom display with right alignment
    See NL + "Custom display with right alignment:" + NL
    profitPivot.ShowXT([
        :Separator = " | ",
        :IntersectionChar = "+",
        :Alignment = :Right,
        :UnderLineHeader
    ])
    
    # Custom display with custom total label
    See NL + "Custom display with custom total label:" + NL
    profitPivot.TotalLabel("GRAND TOTAL")
              .ShowXT([
                  :Separator = " | ",
                  :IntersectionChar = "+",
                  :UnderLineHeader
              ])
    
    return

