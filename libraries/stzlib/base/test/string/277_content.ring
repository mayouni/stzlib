# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #277.

load "../../stzBase.ring"

pr()

o1 = new stzString("999999999999")
o1.SpacifyXT( [ " ", "." ], [ 3, 2 ], :Backward )
? o1.Content()
#--> 999 999 999 999

o1 = new stzString("999999999999")
o1.SpacifyXT( " ", [ 3, 2 ], :Backward )
? o1.Content()
#--> 999 999 999 999

o1 = new stzString("999999999999")
o1.SpacifyXT( " ", 3, [ :Forward, :Backward ] )
? o1.Content()
#--> 999 999 999 999

StopProfiler()

pf()
# Executed in 0.05 second(s).
