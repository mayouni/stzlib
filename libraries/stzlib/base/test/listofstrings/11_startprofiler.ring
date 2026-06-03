# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #11.

load "../../stzBase.ring"


o1 = new stzListOfStrings([ "", "", "", "ONE", "TWO", "THREE", "", "", "" ])
o1.Trim()
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE" ]

StopProfiler()
