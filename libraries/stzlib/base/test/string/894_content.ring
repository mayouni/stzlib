# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #894.
#ERR Error (R3) : Calling Function without definition: removext

load "../../stzBase.ring"

pr()

	Q("_/♥\_/♥\_/♥♥\_/♥\_") {
		RemoveXT(:Nth = 4, "♥")
		? Content()
		#--> _/♥\_/♥\_/♥\_/♥\_
	}

StopProfiler()

pf()
# Executed in 0.01 second(s)
