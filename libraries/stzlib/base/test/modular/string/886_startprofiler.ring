# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #886.

load "../../../stzBase.ring"

	
Q("__♥__♥__/♥\__") {
	
	RemoveXT( [ "/","\" ], :AroundLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.10 second(s)
