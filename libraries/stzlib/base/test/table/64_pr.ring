# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #64.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.MoveCol( :ID, :ToPosition = 3 )
# or alternatively: o1.MoveCol( :FromPosition = 1, :To = 3 )

o1.Show()
#-->
#  AGE      NAME   ID
#  ---- --------- ---
#   52     Karim   10
#   46     Hatem   20
#   48   Abraham   30

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.48 second(s) in Ring 1.17
