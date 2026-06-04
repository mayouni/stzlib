# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #886.

load "../../stzBase.ring"

	

pr()

Q("__♥__♥__/♥\__") {
	
	RemoveXT( [ "/","\" ], :AroundLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()

pf()
# Executed in 0.10 second(s)
