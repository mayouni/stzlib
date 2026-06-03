# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #201.
#ERR Error (R14) : Calling Method without definition: replacecols

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

o1.ReplaceCols([ "___", "___", "___" ])
? o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#         ___        ___       ___         ___
#         ___        ___       ___         ___
#         ___        ___       ___         ___
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceColsXT([ "___", "~~~" ])
o1.Show()
#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#     ------- ---------- --------- ----------
#        ___        ___       ___         ___
#        ~~~        ~~~       ~~~         ~~~
#        ___        ___       ___         ___
#        ~~~        ~~~       ~~~         ~~~
#        ___        ___       ___         ___

pf()
# Executed in 0.20 second(s)
