# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #382.

load "../../stzBase.ring"

pr()

Q("__♥__♥)__♥__") {

	AddXT( "(", :BeforeNth = [2, "♥"] )
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()

pf()
# Executed in 0.05 second(s)
