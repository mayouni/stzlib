# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #62.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.MoveRow( :From = 3, :To = 1 )

o1.Show()
#-->
#   ID      NAME   AGE
#   --- --------- ----
#   30   Abraham    48
#   20     Hatem    46
#   10     Karim    52

pf()
# Executed in 0.14 second(s)
