# Narrative
# --------
# #TODO write a #narration
#
# Extracted from stztabletest.ring, block #199.
#ERR Error (R2) : Array Access (Index out of range)

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

o1.ReplaceRow(2, [ "___", "___" ]) # Or ReplaceNthRow()
? o1.Show()

#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#         ___        ___     Paris      Europe
#       Egypt    English     Cairo      Africa
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceCellsInRow(2, :By = ".....")
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#       .....      .....     .....       .....
#       Egypt    English     Cairo      Africa
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceRowXT(2, [ "____", "~~~~" ])
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#       ____      ~~~~     ____           ~~~~
#       Egypt    English     Cairo      Africa
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia


pf()
# Executed in 0.35 second(s)
