# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #118.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Alibaba", 	"Abraham" ],
	[ "Alibaba",	"AliAli"  ]
])

? o1.Cell(:FIRSTNAME, 2)
#--> Alibaba

? @@( o1.FindInCell(:FIRSTNAME, 2, "ba") )
#--> [ 4, 6 ]

? @@( o1.FindInCell(:LASTNAME, 3, "Ali") )
#--> [ 1, 4 ]

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.18 second(s) in Ring 1.17
