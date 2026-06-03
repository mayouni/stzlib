# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #875.

load "../../stzBase.ring"

	

pr()

Q("__♥)__♥__♥__") {

	RemoveXT( ")", :AfterFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()

pf()
# Executed in 0.03 second(s)
