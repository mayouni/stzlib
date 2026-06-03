# Narrative
# --------
# Multiple Aggregations
#
# Extracted from stztabletest.ring, block #224.
#ERR Error (R14) : Calling Method without definition: aggregate

load "../../stzBase.ring"


pr()

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

# Calculating Sum of Sales, Average of Units, Count of Products

o1.Aggregate([
    :Sales 		= 'SUM',
    :Units 		= 'AVERAGE',
    :Product 	= 'COUNT'
])

o1.Show()
#-->
# ╭────────────┬────────────────┬────────────────╮
# │ Sum(sales) │ Average(units) │ Count(product) │
# ├────────────┼────────────────┼────────────────┤
# │      83000 │         103.75 │              8 │
# ╰────────────┴────────────────┴────────────────╯

pf()
# Executed in 0.03 second(s) in Ring 1.22
