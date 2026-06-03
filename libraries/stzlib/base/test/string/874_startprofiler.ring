# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #874.

load "../../stzBase.ring"

	
Q("__♥__♥)__♥__") {
	
	RemoveXT( ")", :AfterNth = [2, "♥"] )
	? Content()
	#--> __♥__♥__♥__
	
}
	
StopProfiler()
# Executed in 0.02 second(s)
