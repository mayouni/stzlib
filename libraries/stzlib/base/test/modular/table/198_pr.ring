# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #198.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :NATION,	:CONTINENT   ],
	[ "Tunisia",	"Africa"    ],
	[ "France",	"Europe"    ],
	[ "Egypt",	"___"       ],
	[ "Belgium",	"___"       ],
	[ "Yemen",	"___"       ]
])

o1.ReplaceColNameAndDataXT( :CONTINENT, :LANGUAGE, [ "Arabic", "French" ] )
o1.Show()

#-->  NATION   LANGUAGE
#    -------- ---------
#    Tunisia     Arabic
#     France     French
#      Egypt     Arabic
#    Belgium     French
#      Yemen     Arabic

pf()
# Executed in 0.09 second(s)
