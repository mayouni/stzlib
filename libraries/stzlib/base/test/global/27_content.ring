# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #27.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
o1.SortInAscending()
? @@( o1.Content() )
#--> [ [1,3], [4, 7], [8, 9] ]

pf()
# Executed in 0.07 second(s)
