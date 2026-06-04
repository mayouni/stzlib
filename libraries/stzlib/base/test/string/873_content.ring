# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #873.

load "../../stzBase.ring"

	

pr()

Q("__♥)__♥)__♥)__") {
	
	RemoveXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()

pf()
# Executed in 0.02 second(s)
