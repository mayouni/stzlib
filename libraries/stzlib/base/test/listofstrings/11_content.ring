# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #11.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "", "", "", "ONE", "TWO", "THREE", "", "", "" ])
o1.Trim()
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE" ]

StopProfiler()

pf()
