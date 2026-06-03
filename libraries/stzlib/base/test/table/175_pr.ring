# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #175.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],

	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	],
	[ 40,	"ali",		"ALI"	]
])

? o1.Count( :Value = "Ali" )
#--> 1

# Other alternatives of the same function:

? o1.Count( :Cell = "Ali" )
#--> 1

? o1.NumberOfOccurrence( :OfCell = "Ali" )
#--> 1

? o1.CountOfCell( "Ali" )
#--> 1

? o1.CountOfValue("Ali")
#--> 1

? o1.HowMany("Ali")
#--> 1

? o1.HowManyOccurrences( :Of = "Ali" )
#--> 1

pf()
# Executed in 0.07 second(s)
