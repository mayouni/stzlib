# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #871.

load "../../stzBase.ring"

	
	o1 = new stzString("programming*")
	o1.RemoveFromEnd("*")
	? o1.Content()
	#--> programming

StopProfiler()
# Executed in 0.01 second(s)
