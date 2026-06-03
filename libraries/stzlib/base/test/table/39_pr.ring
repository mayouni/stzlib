# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #39.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ]
])

o1.RemoveRow(3)

o1.Show()
#-->   COL1   COL2   COL3
#    ------ ------ ------
#       10     100   1000
#       20     200   2000
#       30     300   3000

pf()
# Executed in 0.09 second(s)
