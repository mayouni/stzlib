# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #41.

load "../../stzBase.ring"

pr()

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

o1.RemoveRows([3, 5, 6])

o1.Show()

#-->   COL1    COL2   COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#       30     300    3000

pf()
# Executed in 0.08 second(s)
