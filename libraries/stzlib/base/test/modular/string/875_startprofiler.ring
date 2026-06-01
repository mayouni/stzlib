# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #875.

load "../../../stzBase.ring"

	
Q("__♥)__♥__♥__") {

	RemoveXT( ")", :AfterFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.03 second(s)
