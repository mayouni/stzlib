# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #393.

load "../../../stzBase.ring"


aList1 = Q("Ring is nice").SubStrings()
aList2 = Q("I love Ring").SubStrings()

? @@( Q(aList1).CommonItems(aList2) ) + NL
#--> [ "R", "Ri", "Rin", "Ring", "i", "in", "ing", "n", "ng", "g", " ", "e" ]
# Executed in 0.64 second(s)

o1 = new stzListOfLists([ aList1, aList2 ])
? @@( o1.CommonItems() )
#--> [ "i", " ", "n", "e", "R", "Ri", "Rin", "Ring", "in", "ing", "ng", "g" ]
#--> Executed in 0.64 second(s)

pf()
# Executed in 1.04 second(s)
