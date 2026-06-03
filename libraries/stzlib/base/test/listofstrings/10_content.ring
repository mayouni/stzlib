# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #10.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

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
