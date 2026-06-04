# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #876.

load "../../stzBase.ring"

	

pr()

Q("__♥__♥__♥)__") {
	
	RemoveXT( ")", :AfterLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()

pf()
# Executed in 0.04 second(s)
