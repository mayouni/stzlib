# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #9.
#ERR Error (R14) : Calling Method without definition: removesection

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "", "", "", "ONE", "TWO", "THREE", "", "", "" ])

o1.RemoveSection(1,3)
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE", "", "", "" ]

o1.RemoveRange(:Last, -3)
//? @@( o1.Content() )
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE" ]

StopProfiler()

pf()
