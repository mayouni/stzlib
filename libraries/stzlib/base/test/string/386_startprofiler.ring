# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #386.

load "../../stzBase.ring"


Q("__♥__♥__♥__") {

	AddXT([ "/","\" ], :AroundEach = "♥") # ... or just :Around = "♥" if you want
	? Content()
	#--> __/♥\__/♥\__/♥\__
}
# Executed in 0.06 second(s)

StopProfiler()
