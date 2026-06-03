# Narrative
# --------
# o1 = new stzListOfStrings([ "111", "b", "222", "c", "111", "222", "111", "s", "222" ])
#
# Extracted from stzlistofstringstest.ring, block #103.

load "../../stzBase.ring"

pr()

o1.RemoveDuplicatesOfThisString("111")
? @@( o1.Content() )
#--> [ "111", "b", "222", "c", "222", "s", "222" ]

pf()
