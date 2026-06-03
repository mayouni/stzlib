# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #379.

load "../../stzBase.ring"


Q("__♥__♥__(♥__") {

	AddXT( ")", :AfterLast = "♥" ) # ... or :ToLast
	? Content()
	#--> __♥__♥__(♥)__
}

StopProfiler()
# Executed in 0.04 second(s)
