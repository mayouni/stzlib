# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #378.

load "../../stzBase.ring"


Q("__(♥__♥__♥__") {

	AddXT( ")", :AfterFirst = "♥" ) # ... or :ToFirst
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()
# Executed in 0.04 second(s)
