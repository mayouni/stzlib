# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #66.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SwapColums( :AGE, :And = :NAME )

o1.Show()
#-->
#   ID   AGE      NAME
#   --- ----- --------
#   10    52     Karim
#   20    46     Hatem
#   30    48   Abraham

pf()
# Executed in 0.13 second(s) in Ring 1.20
# Executed in 0.71 second(s) in Ring 1.17
