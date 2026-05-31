# Narrative
# --------
# StartProfiler()
#
# Extracted from stztabletest.ring, block #46.

load "../../../stzBase.ring"


o1 = new stzList([ "ONE", "two", "THREE", 1, 2 ])
? o1.ContainsCS("TwO", :CS=FALSE)
#--> TRUE

StopProfiler()
#--> Executed in 0.02 second(s)
