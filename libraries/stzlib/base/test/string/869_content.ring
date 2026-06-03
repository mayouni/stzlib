# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #869.
#ERR Error (R14) : Calling Method without definition: removext

load "../../stzBase.ring"

	

pr()

	o1 = new stzString("Ring programmingm language")
	o1.RemoveXT( :Last = "m", :From = "programmingm")
	
	? o1.Content()
	#--> Ring programming language
	
StopProfiler()

pf()
# Executed in 0.01 second(s)
