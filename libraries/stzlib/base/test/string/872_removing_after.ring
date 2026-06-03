# Narrative
# --------
# REMOVING AFTER
#
# Extracted from stzStringTest.ring, block #872.
#ERR Error (R3) : Calling Function without definition: removext

load "../../stzBase.ring"

pr()

StartProfiler()
	
Q("Ring programming* language.") {
	
	RemoveXT("*", :After = "programming")
	? Content()
	#--> Ring programming language.	
}
	
StopProfiler()
#--> Executed in 0.02 second(s)

pf()
