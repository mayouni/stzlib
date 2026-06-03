# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #866.

load "../../stzBase.ring"

	

pr()

	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Each = "*", :From = "*progr*amming*")
	
	? o1.Content()
	#--> Ring programming language
	
StopProfiler()

pf()
# Executed in 0.01 second(s)
