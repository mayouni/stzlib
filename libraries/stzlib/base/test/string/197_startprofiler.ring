# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #197.

load "../../stzBase.ring"


	o1 = new stzString("__/♥\__")

	o1.RemoveBetweenIB("/", "\") # ..XT() -> Bounds are also removed
	? o1.Content()
	#--> ____

StopProfiler()
# Executed in 0.01 second(s)
