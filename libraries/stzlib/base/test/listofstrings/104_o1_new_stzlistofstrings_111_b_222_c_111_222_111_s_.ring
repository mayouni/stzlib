# Narrative
# --------
# o1 = new stzListOfStrings([ "111", "b", "222", "c", "111", "222", "111", "s", "222" ])
#
# Extracted from stzlistofstringstest.ring, block #104.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

o1.RemoveDuplicatesOfTheseStrings([ "111", "222" ])
? @@( o1.Content() )
#--> [ "111", "b", "222", "c", "s" ]

pf()
