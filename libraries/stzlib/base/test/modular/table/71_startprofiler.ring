# Narrative
# --------
# StartProfiler()
#
# Extracted from stztabletest.ring, block #71.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Abdelkarim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

? o1.IsSortedOnBy(:NAME, 'len(@cell)') #--> FALSE

o1.SortOnBy(:NAME, 'len(@cell)')

? o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    20        Hatem    46
#    30      Abraham    48
#    10   Abdelkarim    52

? o1.IsSortedOnBy(:NAME, 'len(@cell)') #--> TRUE

pr()
# Executed in 0.19 second(s) in Ring 1.24

#---

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Abdelkarim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

? o1.IsSortedDownOnBy(:NAME, 'len(@cell)') #--> FALSE

o1.SortDownOnBy(:NAME, 'len(@cell)')
? o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    10   Abdelkarim    52
#    30      Abraham    48
#    20        Hatem    46

? o1.IsSortedDownOnBy(:NAME, 'len(@cell)') #--> FALSE

pf()
# Executed in 0.19 second(s) in Ring 1.24
