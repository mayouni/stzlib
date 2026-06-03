# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #388.

load "../../stzBase.ring"


Q("__♥__/♥\__/♥\__") {

	AddXT( [ "/","\" ], :AroundFirst = "♥" )
	? Content()
	#--> __/♥\__/♥\__/♥\__
}

StopProfiler()
# Executed in 0.06 second(s)
