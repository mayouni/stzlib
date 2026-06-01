# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #389.

load "../../../stzBase.ring"


Q("__/♥\__/♥\__♥__") {

	AddXT( [ "/","\" ], :AroundLast = "♥" )
	? Content()
	#--> __/♥\__/♥\__/♥\__
}

StopProfiler()
# Executed in 0.07 second(s)
