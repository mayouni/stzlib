# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #84.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME 	],
	#---------------#
	[ NULL,	NULL 	],
	[ NULL,	NULL 	],
	[ NULL,	NULL 	]
])

// A table is empty when all its cells are NULL

? o1.IsEmpty()
#--> TRUE

pf()
# Executed in 0.02 second(s)
