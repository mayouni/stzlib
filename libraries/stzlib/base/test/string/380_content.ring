# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #380.
#ERR Error (R3) : Calling Function without definition: addxt

load "../../stzBase.ring"

pr()

Q("Ring programming guage.") {	
	AddXT("lan", :Before = "guage")
	? Content()
	#--> Ring programming language.
}

StopProfiler()

pf()
# Executed in 0.06 second(s) in Ring 1.22
