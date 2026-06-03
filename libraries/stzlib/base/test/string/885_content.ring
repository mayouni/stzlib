# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #885.

load "../../stzBase.ring"

	

pr()

Q("__/♥\__♥__♥__") {
	
	RemoveXT( [ "/","\" ], :AroundFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()

pf()
# Executed in 0.10 second(s)
