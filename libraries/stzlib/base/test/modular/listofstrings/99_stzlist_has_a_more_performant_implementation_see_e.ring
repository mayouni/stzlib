# Narrative
# --------
# #Note stzList has a more performant implementation (see example after this)
#
# Extracted from stzlistofstringstest.ring, block #99.

load "../../../stzBase.ring"


pr()

o1 = new stzListOfStrings([ "one", "ONE", "two", "TWO" ])

? o1.ContainsNonDuplicatedStringsCS(TRUE)
#--> TRUE: In fact all strings are different when case sensitivity applies

? o1.ContainsNonDuplicatedStringsCS(FALSE)
#--> FALSE: In fact, "one" equals "ONE" and "two" equals "TWO" when case sensitiviy
# is applied. So, the list contains duplicated strings and the result is FALSE.

? @@( o1.NumberOfNonDuplicatedStringsCS(TRUE) )
#--> 4

? @@( o1.FindNonDuplicatedStringsCS(TRUE) )
#--> [ 1, 2, 3, 4 ]

? @@( o1.NonDuplicatedStringsCS(TRUE) )
#--> [ "one", "ONE", "two", "TWO" ]

? @@( o1.NonDuplicatedStringsCSZ(TRUE) ) # Or NonDuplicatedStringsAndTheirPositionsCS()
#--> [
#	[ "one", 1 ],
#	[ "ONE", 2 ],
#	[ "two", 3 ],
#	[ "TWO", 4 ]
# ]

pf()
# Executed in 0.07 second(s)
