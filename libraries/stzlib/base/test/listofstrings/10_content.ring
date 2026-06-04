# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #10.
#ERR Error (R14) : Calling Method without definition: trimstart

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "", "", "", "ONE", "TWO", "THREE", "", "", "" ])

o1.TrimStart()
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE", "", "", "" ]

o1.TrimEnd()
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE" ]

StopProfiler()

pf()
