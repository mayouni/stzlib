# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #198.
#ERR Error (R14) : Calling Method without definition: replacecolnameanddataxt

load "../../stzBase.ring"

pr()

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
