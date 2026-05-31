# Narrative
# --------
# #TODO write a #narration
#
# Extracted from stztabletest.ring, block #197.

load "../../../stzBase.ring"


pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE   ],
	[ "Tunisia",	"Arabic"    ],
	[ "France",	"French"    ],
	[ "Egypt",	"English"   ],
	[ "Belgium",	"French"    ],
	[ "Yemen",	"Arabic"    ]
])

o1.ReplaceNthCol(2, [ "___", "___" ])
? o1.Show()
#-->  NATION   LANGUAGE
#     -------- ---------
#     Tunisia        ___
#      France        ___
#       Egypt    English 
#     Belgium     Frencg
#       Yemen     Arabic

o1.ReplaceCellsInCol(:LANGUAGE, :By = ".....")
? o1.Show()
#--> NATION   LANGUAGE
#    -------- ---------
#    Tunisia      .....
#     France      .....
#      Egypt      .....
#    Belgium      .....
#      Yemen      .....

o1.ReplaceCol(:LANGUAGE, [ "Arabic", "French" ])
? o1.Show()
#-->  NATION   LANGUAGE
#     -------- ---------
#     Tunisia     Arabic
#      France     French
#       Egypt      .....
#     Belgium      .....
#       Yemen      .....

o1.ReplaceColXT(:LANGUAGE, [ "Arabic", "French" ])
? o1.Show()
#-->  NATION   LANGUAGE
#     -------- ---------
#     Tunisia     Arabic
#      France     French
#       Egypt     Arabic
#     Belgium     French
#       Yemen     Arabic

o1.ReplaceColNameAndData(:LANGUAGE, :CONTINENT, [ "Africa", "Europe", "Africa", "Europe", "Asia" ])
o1.Show()
#-->  NATION   CONTINENT
#     -------- ----------
#     Tunisia      Africa
#      France      Europe
#       Egypt      Africa
#     Belgium      Europe
#       Yemen        Asia

pf()
# Executed in 0.28 second(s)
