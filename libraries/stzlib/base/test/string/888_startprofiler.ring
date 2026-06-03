# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #888.

load "../../stzBase.ring"


	Q("__/\/\__/♥\__") {
		RemoveXT("♥", :BoundedByIB = ["/", "\"]) # IB -> Bounds are also removed
		? Content()
		#--> __/\/\____
	}

StopProfiler()
# Executed in 0.10 second(s).
