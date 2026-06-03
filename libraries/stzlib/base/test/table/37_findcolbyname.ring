# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #37.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3,	:COL4 ],
	#-------------------------------------#
	[ 10,	    "*",      100,	"*"   ],
	[ 20,	    "*",      200,	"*"   ],
	[ 30,	    "*",      300,	"*"   ]
])

? o1.FindColByName(:COL3) + NL
#--> 3

? o1.FindColsByName([ :COL2, :COL4 ])
#--> [ 2, 4 ]

? o1.FindColsByName([ :FirstCol, :LastCol ])
#--> [ 1, 4 ]

? o1.FindColsByName([ :FirstCol, :LastCol, :LastCol ])
#--> [ 1, 4 ]

#--

? o1.FindColByValue([ 100, 200, 300 ])
#--> [ 3 ]

? o1.FindColByValue([ "*", "*", "*" ])
#--> [ 2, 4 ]

? o1.FindColsByValue([
	[ 100, 200, 300 ],
	[ "*", "*", "*" ]
])
#--> [ 2, 3, 4 ]

? @@( o1.FindColsByValueExcept([
	[ "*", "*", "*" ],
	[ 10, 20, 30 ]
]) )
#--> [ 3 ]

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.17 second(s) in Ring 1.17
