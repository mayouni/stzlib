# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #125.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "AliAli",	"Ali"     ],
	[ "Ali",	"Ben Ali" ]
])

? o1.NumberOfOccurrenceInCol(:FIRSTNAME, "Ali")
#--> 2

? o1.NumberOfOccurrenceInCol(:FIRSTNAME, :OfValue = "Ali")
#--> 2

? o1.NumberOfOccurrenceInCol(:FIRSTNAME, :OfSubValue = "Ali")
#--> 4

? o1.NumberOfOccurrenceXT(:InCol = :FIRSTNAME, :OfSubValue = "Ali")
#--> 4

? o1.NumberOfOccurrenceXT(:InRow = 3, :OfSubValue = "Ali")
#--> 3

? o1.NumberOfOccurrenceInRow(3, "Ali")
#--> 1

? o1.NumberOfOccurrenceInCell(2, 3, :OfSubValue = "Ali")
#--> 1

? o1.NumberOfOccurrenceXT(:InCell = [ 2, 3], :OfSubValue = "Ali")
#--> 1

pf()
# Executed in 0.16 second(s) in Ring 1.20
# Executed in 0.32 second(s) in Ring 1.17
