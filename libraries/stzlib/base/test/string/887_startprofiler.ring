# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #887.

load "../../stzBase.ring"


	Q("/♥♥♥\__/\/\__/♥♥♥\__") {
		RemoveXT("♥♥♥", :BoundedBy = [ "/", :And = "\" ])
		? Content()
		#--> /\__/\/\__/\__
	}

StopProfiler()
# Executed in 0.12 second(s).
