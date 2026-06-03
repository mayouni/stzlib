# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #883.
#ERR Error (R3) : Calling Function without definition: removext

load "../../stzBase.ring"

	

pr()

Q("__/♥\__/♥\__/♥\__") {
	
	RemoveXT([ "/","\" ], :Around = "♥") # or just :AroundEach = "♥" if you want
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()

pf()
# Executed in 0.06 second(s)
