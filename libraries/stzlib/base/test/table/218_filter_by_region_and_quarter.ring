# Narrative
# --------
# Filter by Region and Quarter
#
# Extracted from stztabletest.ring, block #218.

load "../../stzBase.ring"


pr()

o1 = new stzTable([

    :Region = [
		"North", "South", "East",
		"West", "North", "South",
		"East", "West"
	],

    :Product = [
		"Product A", "Product A", "Product A",
		"Product A", "Product B", "Product B",
		"Product B", "Product B"
	],

    :Quarter = [ "Q1", "Q1", "Q1", "Q1", "Q1", "Q1", "Q1", "Q1" ],
    :Sales = [ 10000, 15000, 11000, 13000, 8000, 9500, 7500, 9000 ],
    :Units = [ 100, 150, 110, 130, 80, 95, 75, 90 ]

])

# Returns a table with only East region, Q1 quarter rows

o1.FilterByCQ([
    :Region = "East",
    :Quarter = "Q1"
]).Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ East   │ Product A │ Q1      │ 11000 │   110 │
# │ East   │ Product B │ Q1      │  7500 │    75 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

# Filter with Multiple Region Values and a given product

o1.FilterByCQ([ 
    :Region = [ "East", "West" ], 
    :Product = "Product A"
]).Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ East   │ Product A │ Q1      │ 11000 │   110 │
# │ West   │ Product A │ Q1      │ 13000 │   130 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

pf()
# Executed in 0.12 second(s) in Ring 1.22
