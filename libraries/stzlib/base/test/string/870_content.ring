# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #870.
#ERR Error (R14) : Calling Method without definition: removext

load "../../stzBase.ring"

	

pr()

	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Nth = [ [1, 3], "*" ], :From = "*progr*amming*")
	
	? o1.Content()
	#--> Ring progr*amming language
	
StopProfiler()

pf()
# Executed in 0.02 second(s)
