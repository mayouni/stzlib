# Narrative
# --------
# o1 = new stzListOfStrings([ "A", "B", "C", "D", "E", "F"])
#
# Extracted from stzlistofstringstest.ring, block #23.
#ERR Error (R14) : Calling Method without definition: replacemanyonebyonecs

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "A", "B", "C", "D", "E", "F"])

o1.ReplaceManyOneByOneCS([ "b", "d", "f"], :With = [ "1", "2", "3" ], :CS=FALSE)
? @@( o1.Content() ) #--> [ "A", "1", "C", "2", "E", "3" ]

pf()
