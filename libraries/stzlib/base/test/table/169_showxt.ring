# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #169.
#ERR Error (R14) : Calling Method without definition: showxt

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY,	:JOB 	],
	[ 10,	"Ali",		35000,		"job1"	],
	[ 20,	"Dan",		28900,		"job2"	],
	[ 30,	"Ben",		25982,		"job3"	]
])

? o1.ShowXT([])

#--> # | ID | EMPLOYEE | SALARY |  JOB
#    --+----+----------+--------+-----
#    1 | 10 |      Ali |  35000 | job1
#    2 | 20 |      Dan |  28900 | job2
#    3 | 30 |      Ben |  25982 | job3

? @@NL( o1.SubTable([ :EMPLOYEE, :SALARY ]) ) + NL
#--> [
#	[ "employee", [ "Ali", "Dan", "Ben" ] ],
#	[ "salary"  , [ 35000, 28900, 25982 ] ]
#    ]

o1.SubTableQRT([ :EMPLOYEE, :SALARY ], :stzTable).Show()

#--> EMPLOYEE   SALARY
#    --------- -------
#         Ali    35000
#         Dan    28900
#         Ben    25982

pf()
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 0.57 second(s) in Ring 1.17
