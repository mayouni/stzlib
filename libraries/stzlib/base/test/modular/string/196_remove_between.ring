# Narrative
# --------
# REMOVE BETWEEN
#
# Extracted from stzStringTest.ring, block #196.

load "../../../stzBase.ring"


StartProfiler()

	o1 = new stzString("__/♥\__")

	o1.RemoveBetween("/", "\")
	? o1.Content()
	#--> __/\__

StopProfiler()
# Executed in 0.01 second(s)
