# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #375.
#ERR Error (R3) : Calling Function without definition: addxt

load "../../stzBase.ring"

pr()

Q("Ring programmin language.") {

	AddXT("g", :After = "programmin") # You can use :To instead of :After
	? Content()
	#--> Ring programming language.

}

StopProfiler()
#--> Executed in 0.02 second(s) in Ring 1.21

pf()
