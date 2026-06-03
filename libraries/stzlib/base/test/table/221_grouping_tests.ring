# Narrative
# --------
# Grouping Tests
#
# Extracted from stztabletest.ring, block #221.
#ERR Error (R21) : Using operator with values of incorrect type

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

# Group by Single Column

o1.GroupBy([ :Region ])

o1.Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ North  │ Product A │ Q1      │ 10000 │   100 │
# │ South  │ Product A │ Q1      │ 15000 │   150 │
# │ East   │ Product A │ Q1      │ 11000 │   110 │
# │ West   │ Product A │ Q1      │ 13000 │   130 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

pf()
# Executed in 0.10 second(s) in Ring 1.22
