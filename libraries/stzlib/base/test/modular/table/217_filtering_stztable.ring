# Narrative
# --------
# Filtering stzTable
#
# Extracted from stztabletest.ring, block #217.

load "../../../stzBase.ring"


pr()

# Note: It's more efficient to provide the data in this hashlist format:
#
# o1 = new stzTable([
#     :Region = [
# 		"North", "South", "East",
# 		"West", "North", "South",
# 		"East", "West"
# 	],
# 
#    :Product = [
# 		"Product A", "Product A", "Product A",
# 		"Product A", "Product B", "Product B",
# 		"Product B", "Product B"
# 	],
# 
#     :Quarter = [
# 		"Q1", "Q1", "Q1",
# 		"Q1", "Q2", "Q1",
# 		"Q2", "Q1"
# 	],
# 
#     :Sales = [ 10000, 15000, 11000, 13000, 8000, 9500, 7500, 9000 ],
# 
#     :Units = [ 100, 150, 110, 130, 80, 95, 75, 90 ]
# ]
# 
# This is because the object internally stores its data in this format,
# making it more performant.
# 
# However, in the following example, we use a more expressive structure
# that's easier to read and understand.


o1 = new stzTable([

	[ :Region,	:Product,	:Quarter,	:Sales,	:Units ],

	[ "North",	"Product A",	"Q1",	10000,		100 ],
	[ "South",  "Product A",	"Q1",	15000,		150	],
	[ "East",	"Product A",	"Q1",	11000,		110 ],
	[ "West",	"Product A",	"Q1",	13000,		130 ],
	[ "North",	"Product B",	"Q2",	 8000,		 80 ],
	[ "South",	"Product B",	"Q1",	 9500,		 95 ],
	[ "East",	"Product B",	"Q2",	 7500,		 75 ],
	[ "West",	"Product B",	"Q1",	 9000,		 90 ]
])

# Filter by Single Region (on a copy of the table ~> CQ extension)
#~> The original content is not affected by the filter

o1.FilterByCQ([ :Region = "North", :Quarter = "Q2" ]).Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ North  │ Product B │ Q2      │  8000 │    80 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

# Full table display (because the filter above operated on
# a copy of the table ane left the original content intact)

o1.Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ North  │ Product A │ Q1      │ 10000 │   100 │
# │ South  │ Product A │ Q1      │ 15000 │   150 │
# │ East   │ Product A │ Q1      │ 11000 │   110 │
# │ West   │ Product A │ Q1      │ 13000 │   130 │
# │ North  │ Product B │ Q2      │  8000 │    80 │
# │ South  │ Product B │ Q1      │  9500 │    95 │
# │ East   │ Product B │ Q2      │  7500 │    75 │
# │ West   │ Product B │ Q1      │  9000 │    90 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

# Filtering the table only North region)
#~> Now it's content is update to have only the filtered data

o1.FilterBy([ :Region = "North" ])
o1.Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ North  │ Product A │ Q1      │ 10000 │   100 │
# │ North  │ Product B │ Q2      │  8000 │    80 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

pf()
# Executed in 0.26 second(s) in Ring 1.22
