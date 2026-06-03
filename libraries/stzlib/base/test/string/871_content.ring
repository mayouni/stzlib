# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #871.

load "../../stzBase.ring"

	

pr()

	o1 = new stzString("programming*")
	o1.RemoveFromEnd("*")
	? o1.Content()
	#--> programming

StopProfiler()

pf()
# Executed in 0.01 second(s)
