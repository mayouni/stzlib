# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #202.
#ERR Error (R14) : Calling Method without definition: replacethesecols

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceTheseCols( [ :LANGUAGE, :CONTINENT ], [ "___", "___", "___" ] )
? o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia        ___     Tunis         ___
#      France        ___     Paris         ___
#       Egypt        ___     Cairo         ___
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceTheseColsXT( [ :LANGUAGE, :CONTINENT ], [ "___", "~~~" ] )
o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia        ___     Tunis         ___
#      France        ~~~     Paris         ~~~
#       Egypt        ___     Cairo         ___
#     Belgium        ~~~   Brussel         ~~~
#       Yemen        ___     Sanaa         ___

pf()
# Executed in 0.22 second(s)
