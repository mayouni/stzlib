# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #385.

load "../../stzBase.ring"

pr()

Q("__♥__♥__♥__") {

	AddXT(" ", :AroundEach = "♥")
	? Content()
	#--> __ ♥ __ ♥ __ ♥ __
}

StopProfiler()

pf()
# Executed in 0.06 second(s)
