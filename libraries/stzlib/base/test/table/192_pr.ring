# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #192.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	[ "___",	"Arabic"  ],
	[ "France",	"___"     ],
	[ "USA",	"___"     ]
])

? o1.Cell(2, 3) + NL
#--> "___"

o1.ReplaceCell(2, 3, :With = "English")

? o1.Cell(2, 3)
#--> "English"

pf()
# Executed in 0.02 second(s)
