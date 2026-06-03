# Narrative
# --------
# *
#
# Extracted from stzStringTest.ring, block #377.

load "../../stzBase.ring"

pr()

StartProfiler()

Q("__♥__(♥__♥__") {

	AddXT( ")", :AfterNth = [2, "♥"] )
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()

pf()
# Executed in 0.03 second(s)
