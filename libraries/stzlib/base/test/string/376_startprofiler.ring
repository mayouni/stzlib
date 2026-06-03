# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #376.

load "../../stzBase.ring"


Q("__(♥__(♥__(♥__") {

	AddXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
	? Content()
	#--> __(♥)__(♥)__(♥)__
}

StopProfiler()
# Executed in 0.02 second(s)
