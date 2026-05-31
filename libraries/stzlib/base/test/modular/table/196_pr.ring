# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #196.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	[ "___",	"Arabic"  ],
	[ "France",	"___"     ],
	[ "USA",	"___"     ]
])

o1.ReplaceAll("___", :By = ".....")

o1.Show()
#--> NATION   LANGUAGE
#    ------- ---------
#     .....     Arabic
#    France      .....
#       USA      .....

pf()
# Executed in 0.13 second(s) in Ring 1.20
# Executed in 0.72 second(s) in Ring 1.17
