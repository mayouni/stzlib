# Narrative
# --------
# REMOVE XT ================= #todo Write a #narration
#
# Extracted from stzStringTest.ring, block #865.
#ERR Error (R14) : Calling Method without definition: removext

load "../../stzBase.ring"

pr()

StartProfiler()
	
	o1 = new stzString("Ring programming♥ language")
	o1.RemoveXT("♥", :From = "programming♥")
	
	? o1.Content()
	#--> Ring programming language
	
StopProfiler()

pf()
# Executed in 0.01 second(s)
