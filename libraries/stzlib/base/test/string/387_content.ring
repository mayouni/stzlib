# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #387.

load "../../stzBase.ring"

pr()

Q("__♥__♥__♥__") {

	AddXT([ "/","\" ], :AroundNth = [2, "♥"])
	? Content()
	#--> __♥__/♥\__♥__
}

StopProfiler()

pf()
# Executed in 0.06 second(s)
