# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #100.
#ERR Error (R14) : Calling Method without definition: containsnonduplicateditemscs

load "../../stzBase.ring"

pr()

o1 = new stzList([ "one", "ONE", "two", "TWO" ])

? o1.ContainsNonDuplicatedItemsCS(TRUE)
#--> TRUE: In fact all strings are different when case sensitivity applies

? o1.ContainsNonDuplicatedItemsCS(FALSE)
#--> FALSE: In fact, "one" equals "ONE" and "two" equals "TWO" when case sensitiviy
# is applied. So, the list contains duplicated strings and the result is FALSE.

? @@( o1.NumberOfNonDuplicatedItemsCS(TRUE) )
#--> 4

? @@( o1.FindNonDuplicatedItemsCS(TRUE) )
#--> [ 1, 2, 3, 4 ]

? @@( o1.NonDuplicatedItemsCS(TRUE) )
#--> [ "one", "ONE", "two", "TWO" ]

? @@( o1.NonDuplicatedItemsCSZ(TRUE) ) # Or NonDuplicatedStringsAndTheirPositionsCS()
#--> [
#	[ "one", 1 ],
#	[ "ONE", 2 ],
#	[ "two", 3 ],
#	[ "TWO", 4 ]
# ]

pf()
# Executed in 0.02 second(s)
