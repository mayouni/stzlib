# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #895.
#ERR Error (R3) : Calling Function without definition: removext

load "../../stzBase.ring"

pr()

	Q("^^♥^^") {
		RemoveXT( "♥", :AtPosition = 3)
		? Content()
		#--> ^^^^
	}

StopProfiler()

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19
