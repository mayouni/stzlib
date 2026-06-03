# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #888.
#ERR Error (R3) : Calling Function without definition: removext

load "../../stzBase.ring"

pr()

	Q("__/\/\__/♥\__") {
		RemoveXT("♥", :BoundedByIB = ["/", "\"]) # IB -> Bounds are also removed
		? Content()
		#--> __/\/\____
	}

StopProfiler()

pf()
# Executed in 0.10 second(s).
