# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #384.
#ERR Error (R3) : Calling Function without definition: addxt

load "../../stzBase.ring"

pr()

Q("__♥__♥__♥)__") {

	AddXT( "(", :BeforeLast = "♥" )
	? Content()
	#--> __♥__♥__(♥)__
}

StopProfiler()

pf()
# Executed in 0.05 second(s)
