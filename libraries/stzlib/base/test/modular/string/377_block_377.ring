# Narrative
# --------
# *
#
# Extracted from stzStringTest.ring, block #377.

load "../../../stzBase.ring"

StartProfiler()

Q("__♥__(♥__♥__") {

	AddXT( ")", :AfterNth = [2, "♥"] )
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()
# Executed in 0.03 second(s)
