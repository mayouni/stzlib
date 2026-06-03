# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #203.

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

o1.ReplaceTheseRows( [ 3, 5 ], [ "___", "___", "___" ] )
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#      France     French     Paris      Europe
#         ___        ___       ___      Africa
#     Belgium     French   Brussel      Europe
#         ___        ___       ___        Asia

o1.ReplaceTheseRowsXT( [ 3, 5 ], [ "___", "~~~" ] )
o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#      France     French     Paris      Europe
#         ___        ~~~       ___         ~~~
#     Belgium     French   Brussel      Europe
#         ___        ~~~       ___         ~~~

pf()
# Executed in 0.26 second(s)
