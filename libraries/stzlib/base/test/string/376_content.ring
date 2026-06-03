# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #376.
#ERR Error (R3) : Calling Function without definition: addxt

load "../../stzBase.ring"

pr()

Q("__(♥__(♥__(♥__") {

	AddXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
	? Content()
	#--> __(♥)__(♥)__(♥)__
}

StopProfiler()

pf()
# Executed in 0.02 second(s)
