# Narrative
# --------
# pr()
#
# Extracted from stzPivotTableTest.ring, block #1.

load "../../stzBase.ring"

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

o1 = new stzPivotTable(oSalesData)
o1 {
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

o1 = new stzPivotTable(oSalesData)
o1 {

    SetRowLabel(:Product)
    SetColumnLabel(:Quarter)
    SetValue(:Sales)
    SetAggregateFunction("SUM")
	SetColumnOrder(["Q1", "Q2"])  # Set the desired quarter order

    Show()
	#-->
# ╭───────────┬─────────────────────┬────────╮
# │           │       Quarter       │        │
# │           │──────────┬──────────│        │
# │  Product  │    Q1    │    Q2    │  SUM   │
# ├───────────┼──────────┼──────────┼────────┤
# │ Product A │    39000 │    53000 │  92000 │
# │ Product B │    34000 │    38000 │  72000 │
# ╰───────────┴──────────┴──────────┴────────╯
#         SUM │    73000 │    91000 │ 164000  

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
# Executed in 0.40 second(s) in Ring 1.22
