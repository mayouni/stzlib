# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #187.

load "../../stzBase.ring"

pr()

// Finding nth occurrence of a value in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindNthInCol(:Occurrence = 1, :InCol = :LASTNAME, :OfValue = "Abraham") )
#--> [2, 2]

# Or you can use this short form:

? @@( o1.FindNthInCol(1, 2, "Abraham") )
#--> [2, 2]

? @@( o1.FindNthInCol(2, :FIRSTNAME, "Ali") )
#--> [1, 3]

? @@( o1.FindFirstInCol(:FIRSTNAME, "Ali") )
#--> [1, 2]

? @@( o1.FindLastInCol(:FIRSTNAME, "Ali") )
#--> [1, 3]

pf()
# Executed in 0.19 second(s) in Ring 1.19
# Executed in 0.43 second(s) in Ring 1.17
