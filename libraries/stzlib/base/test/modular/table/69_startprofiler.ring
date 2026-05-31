# Narrative
# --------
# StartProfiler()
#
# Extracted from stztabletest.ring, block #69.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SortDown()

? o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    30   Abraham    48
#    20     Hatem    46
#    10     Karim    52

o1.Sort()

? o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    10     Karim    52
#    20     Hatem    46
#    30   Abraham    48

o1.SortOn(:AGE)

? o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    20     Hatem    46
#    30   Abraham    48
#    10     Karim    52

o1.SortDownOn(:AGE)

o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    10     Karim    52
#    30   Abraham    48
#    20     Hatem    46

StopProfiler()
# Executed in 0.27 second(s) in Ring 1.24
