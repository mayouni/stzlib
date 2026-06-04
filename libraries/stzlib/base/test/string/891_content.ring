# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #891.

load "../../stzBase.ring"

pr()

	Q("__/\/\__^^♥^^__") {
		RemoveXT("♥", :BoundedByIB = "^^")
		? Content()
		#--> __/\/\____
	}

StopProfiler()

pf()
# Executed in 0.10 second(s)
