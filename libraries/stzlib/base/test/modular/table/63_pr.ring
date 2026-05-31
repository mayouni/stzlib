# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #63.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SwapRows( :BetweenPositions = 2, :And = 3 )

? o1.Show()
#-->
#   ID      NAME   AGE
#   --- --------- ----
#   10     Karim    52
#   30   Abraham    48
#   20     Hatem    46

o1.SwapColumns( :BetweenPosition = 2, :And = 3 )

o1.Show()
#-->
#  ID   AGE      NAME
#  --- ----- --------
#  10    52     Karim
#  30    48   Abraham
#  20    46     Hatem

pf()
# Executed in 0.30 second(s)
# Executed in 1.05 second(s)
