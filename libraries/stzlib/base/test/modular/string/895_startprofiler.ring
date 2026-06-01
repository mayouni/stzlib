# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #895.

load "../../../stzBase.ring"


	Q("^^♥^^") {
		RemoveXT( "♥", :AtPosition = 3)
		? Content()
		#--> ^^^^
	}

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19
