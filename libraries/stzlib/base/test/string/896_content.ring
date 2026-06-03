# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #896.
#ERR Error (R3) : Calling Function without definition: removext

load "../../stzBase.ring"

pr()

	Q("♥^^♥^^♥") {
		RemoveXT( "♥", :AtPositions = [1, 7]) # or :At = [1, 7]
		? Content()
		#--> ^^♥^^
	}

StopProfiler()

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.19
