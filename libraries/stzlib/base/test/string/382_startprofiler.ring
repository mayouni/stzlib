# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #382.

load "../../stzBase.ring"


Q("__♥__♥)__♥__") {

	AddXT( "(", :BeforeNth = [2, "♥"] )
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()
# Executed in 0.05 second(s)
