# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #870.

load "../../stzBase.ring"

	
	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Nth = [ [1, 3], "*" ], :From = "*progr*amming*")
	
	? o1.Content()
	#--> Ring progr*amming language
	
StopProfiler()
# Executed in 0.02 second(s)
