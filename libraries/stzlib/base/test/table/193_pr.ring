# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #193.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	[ "___",	"Arabic"  ],
	[ "France",	"___"     ],
	[ "USA",	"___"     ]
])

o1.ReplaceCellsByMany(
	[     [1, 1],   [2, 2],    [2, 3] ],
	[  "Tunisia", "French", "English" ]
)

o1.Show()
#-->  NATION   LANGUAGE
#    -------- ---------
#    Tunisia     Arabic
#     France     French
#        USA    English

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.19 second(s) in Ring 1.17
