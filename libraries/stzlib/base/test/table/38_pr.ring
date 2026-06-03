# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #38.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ],
	[ "*",	    "*",      "*"   ],
	[ "*",	    "*",      "*"   ]
])

? o1.FindRow([ 30, 300, 3000 ])
#--> [ 4 ]

? o1.FindRow([ "*", "*", "*" ])
#--> [ 3, 5, 6 ]

? o1.FindManyRows([
	[ 30, 300, 3000 ],
	[ "*", "*", "*" ]
])
#--> [ 3, 4, 5, 6 ]

? o1.FindRowsExcept([
	[ 30, 300, 3000 ],
	[ "*", "*", "*" ]
])
#--> [1, 2]

pf()
# Executed in 0.03 second(s)
