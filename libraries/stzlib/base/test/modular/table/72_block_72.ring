# Narrative
# --------
# */
#
# Extracted from stztabletest.ring, block #72.

load "../../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Abdelkarim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SortOn(:AGE)
? o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    20        Hatem    46
#    30      Abraham    48
#    10   Abdelkarim    52

o1.SortDownOn(:AGE)
o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    10   Abdelkarim    52
#    30      Abraham    48
#    20        Hatem    46

pf()
# Executed in 0.12 second(s)
