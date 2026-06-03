# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #8.
#ERR Error (R41) : Invalid numeric string 

load "../../stzBase.ring"

pr()

o1 = new stzList([ "", "", "", "ONE", "TWO", "THREE", "", "", "" ])

o1.RemoveSection(1,3)
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE", "", "", "" ]

o1.RemoveRange(:Last, -3)
//? @@( o1.Content() )
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE" ]

StopProfiler()

pf()
