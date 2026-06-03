# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #892.

load "../../stzBase.ring"

pr()

	Q("/♥♥♥\__/♥\/♥♥\__/♥\__") {
		RemoveXT("♥", [])
		? Content()
		#--> /\__/\/\__/\__
	}

StopProfiler()

pf()
# Executed in 0.01 second(s)
