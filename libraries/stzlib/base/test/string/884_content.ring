# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #884.

load "../../stzBase.ring"

	

pr()

Q("__♥__/♥\__♥__") {

	RemoveXT([ "/","\" ], :AroundNth = [2, "♥"])
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()

pf()
# Executed in 0.07 second(s)
