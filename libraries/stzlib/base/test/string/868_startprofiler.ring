# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #868.

load "../../stzBase.ring"

	
	o1 = new stzString("Ring mprogramming language")
	o1.RemoveXT( :First = "m", :From = "mprogramming")
	
	? o1.Content()
	#--> Ring progr*amming* language
	
StopProfiler()
# Executed in 0.01 second(s)
