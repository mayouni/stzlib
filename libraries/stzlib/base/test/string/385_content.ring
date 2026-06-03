# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #385.
#ERR Error (R3) : Calling Function without definition: addxt

load "../../stzBase.ring"

pr()

Q("__♥__♥__♥__") {

	AddXT(" ", :AroundEach = "♥")
	? Content()
	#--> __ ♥ __ ♥ __ ♥ __
}

StopProfiler()

pf()
# Executed in 0.06 second(s)
