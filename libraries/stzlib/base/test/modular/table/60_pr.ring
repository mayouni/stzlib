# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #60.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

? o1.ColName(3)
#--> :AGE

? o1.ColName(:NAME) + NL
#--> :NAME

o1.ReplaceColName(:NAME, :EMPLOYEE)

o1.Show()
#-->
#    ID    EMPLOYEE  AGE
#    --- ---------- ----
#    10     Karim     52
#    20     Hatem     46
#    30   Abraham     48

pf()
# Executed in 0.10 second(s) in Ring 1.20
# Executed in 0.48 second(s) in Ring 1.17
