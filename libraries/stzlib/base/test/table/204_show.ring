# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #204.

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

o1.ReplaceCells(
	[ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ] ],
	:By = "___"
)
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#      France     French     Paris      Europe
#         ___        ___       ___      Africa
#     Belgium     French   Brussel      Europe
#         ___        ___       ___        Asia

o1.ReplaceCellsByMany( 
	[ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ] ],
	:By = [ "~~~", "~~~", "~~~" ]
)
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia        ~~~     Tunis      Africa
#      France        ~~~     Paris      Europe
#       Egypt        ~~~       ___         ___
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceCellsByManyXT( 
	[ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ] ],
	:By = [ "^^v^^", "~~^~~" ]
)
o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#    -------- ---------- --------- ----------
#    Tunisia      ^^v^^     Tunis      Africa
#     France      ~~^~~     Paris      Europe
#      Egypt      ^^v^^     ~~^~~       ^^v^^
#    Belgium     French   Brussel      Europe
#      Yemen     Arabic     Sanaa        Asia

pf()
# Executed in 0.21 second(s)
