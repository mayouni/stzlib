# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #885.

load "../../../stzBase.ring"

	
Q("__/♥\__♥__♥__") {
	
	RemoveXT( [ "/","\" ], :AroundFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.10 second(s)
