# Narrative
# --------
# Group by Multiple Columns
#
# Extracted from stztabletest.ring, block #222.
#ERR Error (R20) : Calling function with extra number of parameters

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

o1.Show()

# Detailed grouping by Region and Product

o1.GroupBy([ :Product, :Region ], [ :Sales = 'Sum', :Units = 'Average' ])
o1.Show()
#-->
# ╭────────┬───────────┬────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼────────┼───────────┼─────────┼───────┼───────┤
# │ North  │ Product A │ North  │ Product A │ Q1      │ 10000 │   100 │
# │ South  │ Product A │ South  │ Product A │ Q1      │ 15000 │   150 │
# │ East   │ Product A │ East   │ Product A │ Q1      │ 11000 │   110 │
# │ West   │ Product A │ West   │ Product A │ Q1      │ 13000 │   130 │
# │ North  │ Product B │ North  │ Product B │ Q2      │  8000 │    80 │
# │ South  │ Product B │ South  │ Product B │ Q1      │  9500 │    95 │
# │ East   │ Product B │ East   │ Product B │ Q2      │  7500 │    75 │
# │ West   │ Product B │ West   │ Product B │ Q1      │  9000 │    90 │
# ╰────────┴───────────┴────────┴───────────┴─────────┴───────┴───────╯

o1.ShowXT(:SubTotal = TRUE, :GrandTotal = TRUE)
#-->
# ╭─────────────────┬────────┬────────────┬────────────╮
# │     Product     │ Region │ Sum(sales) │ Sum(units) │
# ├─────────────────┼────────┼────────────┼────────────┤
# │ Product A       │ North  │      10000 │        100 │
# │ Product A       │ South  │      15000 │        150 │
# │ Product A       │ East   │      11000 │        110 │
# │ Product A       │ West   │      13000 │        130 │
# │ --------------- │ ------ │ ---------- │ ---------- │
# │       Sub-total │        │      49000 │        490 │
# │                 │        │            │            │
# │ Product B       │ North  │       8000 │         80 │
# │ Product B       │ South  │       9500 │         95 │
# │ Product B       │ East   │       7500 │         75 │
# │ Product B       │ West   │       9000 │         90 │
# │ --------------- │ ------ │ ---------- │ ---------- │
# │       Sub-total │        │      34000 │        340 │
# ├─────────────────┼────────┼────────────┼────────────┤
# │     GRAND-TOTAL │        │      83000 │        830 │
# ╰─────────────────┴────────┴────────────┴────────────╯

pf()
# Executed in 0.36 second(s) in Ring 1.22
