

load "../max/stzmax.ring"

pr()

aList = 1:50_000_000


for i = 1 to 50_000_000
    aList[i] += 10
next

pf()

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
? NL()

# Pivot table of Sales by Region (rows) and Product (columns)
oSalesPivot = new stzPivotTable(oSalesData)
oSalesPivot {
    SetRowLabel(:Region)
    SetColumnLabel(:Product)
    SetValue(:Sales)
    SetAggregateFunction("SUM")
    Show()
}

# Another view - Sales by Product (rows) and Quarter (columns)
? NL()
oProductPivot = new stzPivotTable(oSalesData)
oProductPivot {
    SetRowLabel(:Product)
    SetColumnLabel(:Quarter)
    SetValue(:Sales)
    SetAggregateFunction("SUM")
    Show()
}

? NL()
# Getting specific values from the pivot
? "Value for Product A in Q1: " + oProductPivot.Value("Product A", "Q1")

# Getting row and column totals
? "Row total for Product A: " + oProductPivot.RowTotal("Product A")
? "Column total for Q2: " + oProductPivot.ColumnTotal("Q2")
? "Grand total: " + oProductPivot.GrandTotal()

pf()

/*--- Creating a simple sales analysis by region and product

pr()

oSalesData = new stzTable([
	[ :Region,   :Product,   :Quarter,  :Sales,   :Units  ],
	# ----------------------------------------------------- #
	[ "North",   "Product A",    "Q1",    10000,    100    ],
	[ "North",   "Product A",    "Q2",    12000,    120    ],
	[ "North",   "Product B",    "Q1",     8000,     80    ],
	[ "North",   "Product B",    "Q2",     9000,     90    ],
	[ "South",   "Product A",    "Q1",    15000,    150    ],
	[ "South",   "Product A",    "Q2",    14000,    140    ],
	[ "South",   "Product B",    "Q1",     9500,     95    ],
	[ "South",   "Product B",    "Q2",    10500,    105    ],
	[ "East",    "Product A",    "Q1",    11000,    110    ],
	[ "East",    "Product A",    "Q2",    12500,    125    ],
	[ "East",    "Product B",    "Q1",     7500,     75    ],
	[ "East",    "Product B",    "Q2",     8500,     85    ],
	[ "West",    "Product A",    "Q1",    13000,    130    ],
	[ "West",    "Product A",    "Q2",    14500,    145    ],
	[ "West",    "Product B",    "Q1",     9000,     90    ],
	[ "West",    "Product B",    "Q2",    10000,    100    ]
])

# Original sales data

oSalesData.Show()
? NL()
    
# Pivot table of Sales by Region (rows) and Product (columns)
    
oSalesPivot = new stzPivotTable(oSalesData)

oSalesPivot {

	SetRowLabels([:Region])
	SetColumnLabels([:Product])
	SetValues([:Sales])
	SetAggregateFunction("SUM")

	Show()
	#-->
	#         PRODUCT A   PRODUCT B    TOTAL
	# ------ ----------- ----------- -------
	# North       12000       17000    29000
	# South       29000       20000    49000
	#  East       23500       16000    39500
	#  West       27500       19000    46500
	# TOTAL       92000       72000   164000

}

# Another view - Sales by Product (rows) and Quarter (columns)

? NL()

oProductPivot = new stzPivotTable(oSalesData)

oProductPivot {

	SetRowLabels([:Product])
	SetColumnLabels([:Quarter])
	SetValues([:Sales])
	SetAggregateFunction("SUM")

	Show()
	#-->
	#                Q1      Q2    TOTAL
	# ---------- ------- ------- -------
	# Product A   39000   53000    92000
	# Product B   34000   38000    72000
	#     TOTAL   73000   91000   164000
 
	? NL()

	# Getting specific values from the pivot

	? Value("Product A", "Q1")
	#--> 39000

	# Getting row and column totals

	? RowTotal("Product A")
	#--> 92000

	? ColumnTotal("Q2")
	#--> 91000

	? GrandTotal()
	#--> 164000
}

pf()
# Executed in 0.57 second(s) in Ring 1.22

/*---  Using multiple dimensions for rows and columns
*/

pr()
    
# Define employee data in a stzTable object

oTable = new stzTable([

	[ :Department, :Location,   :Gender,  :Experience,  :Salary   ],
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

	SetRowLabels([ :Department, :Location ])
	SetColumnLabels([ :Experience, :Gender ])

	SetValues([ :Salary ])

	SetAggregateFunction("AVERAGE")
	SetTotalLabel("AVERAGE")

	Show()
	#-->
	#              JUNIOR   SENIOR     AVERAGE
	# -------- ----------- -------- ----------
	#   Sales    43666.67    74000   117666.67
	#      IT       51500    84000      135500
	#     HR       41500    67000      108500
	# -------- ----------- -------- ----------
	# AVERAGE   136666.67   225000   361666.67

}

pf()
# Executed in 0.18 second(s) in Ring 1.22

/*
  Example 3: Different Aggregation Functions
  Demonstrating various aggregation functions

func Example3()
    
    # Define a product sales and ratings dataset
    productData = new stzTable([
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
    
    See "Original product data:" + NL
    productData.Show()
    
    # SUM aggregation (default)
    See NL + "Sum of Sales by Product and Region:" + NL
    
    sumPivot = new stzPivotTable(productData)
    sumPivot.RowLabels([:Product])
          .ColumnLabels([:Region])
          .Values([:Sales])
          .AggregateFunction("SUM")
          .Show()
    
    # AVERAGE aggregation
    See NL + "Average Rating by Category and Region:" + NL
    
    avgPivot = new stzPivotTable(productData)
    avgPivot.RowLabels([:Category])
          .ColumnLabels([:Region])
          .Values([:Rating])
          .AggregateFunction("AVG")
          .Show()
    
    # COUNT aggregation
    See NL + "Count of Products by Category and Region:" + NL
    
    countPivot = new stzPivotTable(productData)
    countPivot.RowLabels([:Category])
            .ColumnLabels([:Region])
            .Values([:Product])
            .AggregateFunction("COUNT")
            .Show()
    
    # MAX aggregation
    See NL + "Maximum Returns by Product and Region:" + NL
    
    maxPivot = new stzPivotTable(productData)
    maxPivot.RowLabels([:Product])
          .ColumnLabels([:Region])
          .Values([:Returns])
          .AggregateFunction("MAX")
          .Show()
    
    return

/*
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

