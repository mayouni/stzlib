# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #869.

load "../../../stzBase.ring"

	
	o1 = new stzString("Ring programmingm language")
	o1.RemoveXT( :Last = "m", :From = "programmingm")
	
	? o1.Content()
	#--> Ring programming language
	
StopProfiler()
# Executed in 0.01 second(s)
