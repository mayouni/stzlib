# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #384.

load "../../stzBase.ring"

pr()

Q("__♥__♥__♥)__") {

	AddXT( "(", :BeforeLast = "♥" )
	? Content()
	#--> __♥__♥__(♥)__
}

StopProfiler()

pf()
# Executed in 0.05 second(s)
