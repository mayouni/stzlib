# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #378.

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
