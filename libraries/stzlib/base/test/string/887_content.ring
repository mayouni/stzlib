# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #887.
#ERR Error (R3) : Calling Function without definition: removext

load "../../stzBase.ring"

pr()

	Q("/♥♥♥\__/\/\__/♥♥♥\__") {
		RemoveXT("♥♥♥", :BoundedBy = [ "/", :And = "\" ])
		? Content()
		#--> /\__/\/\__/\__
	}

StopProfiler()

pf()
# Executed in 0.12 second(s).
