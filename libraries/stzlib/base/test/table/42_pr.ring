# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #42.

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

? o1.FindRowsExceptAt([ 1, 2, 4 ])
#--> [ 3, 5, 6 ]

? o1.FindRowsExcept([
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ 30,	    300,      3000  ]
])
#--> [ 3, 5, 6 ]

#--

o1.RemoveAllRowsExcept([
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ 30,	    300,      3000  ]
]) # Or RemoveRowsOtherThan()

o1.Show()
#-->  COL1    COL2   COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#       30     300    3000

pf()
# # Executed in 0.10 second(s)
