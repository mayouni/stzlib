# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #890.

load "../../stzBase.ring"


	Q("__^^^__^^♥^^__") {
		RemoveXT("♥", :BoundedBy = "^^")
		? Content()
		#--> __^^^__^^^^__
	}

StopProfiler()
# Executed in 0.09 second(s)
