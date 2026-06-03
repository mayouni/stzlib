# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #378.
#ERR Error (R3) : Calling Function without definition: addxt

load "../../stzBase.ring"

pr()

Q("__(♥__♥__♥__") {

	AddXT( ")", :AfterFirst = "♥" ) # ... or :ToFirst
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()

pf()
# Executed in 0.04 second(s)
