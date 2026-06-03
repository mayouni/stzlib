# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #10.

load "../../stzBase.ring"


o1 = new stzListOfStrings([ "", "", "", "ONE", "TWO", "THREE", "", "", "" ])

o1.TrimStart()
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE", "", "", "" ]

o1.TrimEnd()
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE" ]

StopProfiler()
