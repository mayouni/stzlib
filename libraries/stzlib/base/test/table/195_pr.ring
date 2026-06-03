# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #195.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	#-------------------------#
	[ "France",	"___"     ],
	[ "USA",	"___"     ],
	[ "Niger",	"___"	  ],
	[ "Egypt",	"___"	  ],
	[ "Kuwait",	"___"     ]
])


o1.ReplaceCellsByManyXT(
	[ [2, 1], [2, 2], [2, 3], [2, 4], [2, 5] ],
	[   "01",   "02",   "03" ]
)

o1.Show()
#--> NATION   LANGUAGE
#    ------- ---------
#    France         01
#       USA         02
#     Niger         03
#     Egypt         01
#    Kuwait         02

pf()
# Executed in 0.10 second(s)
