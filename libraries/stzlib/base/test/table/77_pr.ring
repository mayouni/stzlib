# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #77.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.SectionAsPositions([2, 2], [3, 3]) ) + NL # Or FindSections()
#--> [ [ 2, 2 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ]

? @@(o1.Section([2, 2], [3, 3])) + NL
#--> [ "Hatem", "Karim", 52, 46, 48 ]

? @@NL(o1.SectionZ([2, 2], [3, 3])) + NL # or SectionAndPosiition()
#--> [
#	[ [ 2, 2 ], "Hatem" ],
#	[ [ 2, 3 ], "Karim" ],
#	[ [ 3, 1 ], 52 ],
#	[ [ 3, 2 ], 46 ],
#	[ [ 3, 3 ], 48 ]
# ]

? @@( o1.Section(:FirstCell, :LastCell) )
#--> [ 10, 20, 30, "Imed", "Hatem", "Karim", 52, 46, 48 ]

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.15 second(s) in Ring 1.17
